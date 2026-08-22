--!strict

-- Server-authoritative natural regeneration. The clock ticks once per
-- second; every alive player in a running round advances one tick and is
-- healed by the amount their tick group grants (see RegenerationRules:
-- group 1 heals nothing, group 2 heals 1/tick, group 3 heals 2/tick, and so
-- on, capped at MAX_HEALTH). Taking health damage resets the player's tick
-- clock to zero (CombatService.dealDamage -> onPlayerDamaged), so
-- regeneration only resumes after the player has gone unhurt for a full
-- tick group.
--
-- Healing flows through the replicated `Health` Player attribute — the
-- client's health bar and name tags read that attribute, not the Humanoid —
-- so no client change is required.
--
-- Lifecycle: spawning into a round resets the clock, eliminations clear it,
-- and round resets clear every player's clock so each round starts clean.
-- Outside a running round the ticker drops all counters.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local RegenerationRules = require(script.Parent.RegenerationRules)

type RegenerationContext = {
	outbound: any,
	playerSessions: any,
	combatService: any,
	customGameService: any,
}

local RegenerationService = {}
RegenerationService.__index = RegenerationService

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function getHealth(player: Player): number
	local health = player:GetAttribute(Attribute.Health)
	if not isFiniteNumber(health) then
		return HealthConstants.MAX_HEALTH
	end
	return math.clamp(health, HealthConstants.MIN_HEALTH, HealthConstants.MAX_HEALTH)
end

function RegenerationService.new(context: RegenerationContext)
	return setmetatable({
		context = context,
		-- Ticks since the player last took health damage. Weak-keyed so
		-- entries never outlive their player.
		ticksSinceDamage = setmetatable({}, { __mode = "k" }) :: { [Player]: number },
		playerRemovingConnection = nil :: RBXScriptConnection?,
		started = false,
	}, RegenerationService)
end

-- Called by CombatService.dealDamage whenever a hit actually costs the
-- target health: the post-damage tick clock restarts at zero, so the first
-- regenerating tick is a full tick group later.
function RegenerationService.onPlayerDamaged(self, player: Player)
	self.ticksSinceDamage[player] = 0
end

-- Spawning into a round starts the clock fresh (round boundaries also clear
-- every clock, but keeping the invariant local to the spawn is free).
function RegenerationService.resetPlayer(self, player: Player)
	self.ticksSinceDamage[player] = 0
end

function RegenerationService.clearPlayer(self, player: Player)
	self.ticksSinceDamage[player] = nil
end

function RegenerationService.clearAll(self)
	table.clear(self.ticksSinceDamage)
end

-- One clock step (once per TICK_SECONDS): advance every alive player's
-- post-damage tick counter and heal them by the amount the current tick
-- group grants.
function RegenerationService.tick(self)
	local combatService = self.context.combatService
	if combatService == nil or not combatService:isInRound() then
		-- Outside a running round no counter is meaningful; dropping them
		-- every step also guarantees each round starts from a clean clock.
		self:clearAll()
		return
	end
	for _, player in Players:GetPlayers() do
		if player:GetAttribute(Attribute.Alive) ~= true or player:GetAttribute(Attribute.Spectating) == true then
			continue
		end
		local ticks, regenAmount = RegenerationRules.advance(self.ticksSinceDamage[player] or 0)
		self.ticksSinceDamage[player] = ticks
		if regenAmount <= 0 then
			continue
		end
		local health = getHealth(player)
		if health >= HealthConstants.MAX_HEALTH then
			continue
		end
		player:SetAttribute(Attribute.Health, math.min(HealthConstants.MAX_HEALTH, health + regenAmount))
	end
end

function RegenerationService.start(self)
	if self.started then
		return
	end
	self.started = true
	-- Drift-free one-second cadence: the next tick time is absolute, so a
	-- late step (studio hitches, task scheduler granularity) self-corrects
	-- instead of accumulating delay the way a plain task.wait(1) loop does.
	task.spawn(function()
		local nextTickTime = os.clock() + RegenerationRules.TICK_SECONDS
		while self.started do
			local waitTime = nextTickTime - os.clock()
			if waitTime > 0 then
				task.wait(waitTime)
			end
			nextTickTime += RegenerationRules.TICK_SECONDS
			self:tick()
		end
	end)
	self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self:clearPlayer(player)
	end)
end

function RegenerationService.stop(self)
	self.started = false
	if self.playerRemovingConnection ~= nil then
		self.playerRemovingConnection:Disconnect()
		self.playerRemovingConnection = nil
	end
	self:clearAll()
end

return RegenerationService
