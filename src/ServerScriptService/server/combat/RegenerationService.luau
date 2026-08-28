--!strict

-- Natural regeneration: 1-second ticks, ramping per 4-tick group (RegenerationRules).
-- Any hit that costs health resets the clock (CombatService -> onPlayerDamaged).
-- Healing writes the replicated Health attribute — the client's health bar and
-- name tags read that attribute, not the Humanoid.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local RegenerationRules = require(script.Parent.RegenerationRules)

type RegenerationContext = {
	outbound: any,
	playerSessions: any,
	combatService: any,
	roundService: any,
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
		-- Ticks since last health damage; weak-keyed.
		ticksSinceDamage = setmetatable({}, { __mode = "k" }) :: { [Player]: number },
		playerRemovingConnection = nil :: RBXScriptConnection?,
		started = false,
	}, RegenerationService)
end

-- Health damage restarts the clock at zero.
function RegenerationService.onPlayerDamaged(self, player: Player)
	self.ticksSinceDamage[player] = 0
end

function RegenerationService.resetPlayer(self, player: Player)
	self.ticksSinceDamage[player] = 0
end

function RegenerationService.clearPlayer(self, player: Player)
	self.ticksSinceDamage[player] = nil
end

function RegenerationService.clearAll(self)
	table.clear(self.ticksSinceDamage)
end

function RegenerationService.tick(self)
	local combatService = self.context.combatService
	if combatService == nil or not combatService:isInRound() then
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
	-- Drift-free cadence: absolute next-tick time self-corrects after hitches.
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
