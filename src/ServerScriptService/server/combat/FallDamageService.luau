--!strict

-- Server-authoritative fall damage. The recovered game does not use
-- velocity to compute fall damage: it compares the Y level of the block the
-- player fell from with the Y level of the block they land on, and falls
-- shorter than 10 blocks deal nothing (both verified against the real
-- game). This service reconstructs that rule:
--
--   * every FALL_CHECK_INTERVAL seconds, each alive player's support
--     surface is found by raycasting straight down into
--     Workspace.BlockContainer (the arena plus player-placed blocks — the
--     same whitelist the client's block raycasts use);
--   * a surface within GROUNDED_MAX_DISTANCE below the root part counts as
--     the ground the player is standing on, unless they are falling fast
--     enough to just be passing it (velocity gates *detection only* — the
--     damage itself is computed purely from block levels);
--   * the surface's block level (FallDamageRules.getBlockLevel) is
--     remembered while grounded, so leaving the ground records "the block
--     you fell from";
--   * on landing, blocksFallen = fellFromLevel - landingLevel feeds
--     FallDamageRules.getFallDamage, and any damage flows through
--     CombatService:dealFallDamage -> the shared dealDamage pipeline
--     (armour mitigation, all-or-nothing shield absorption, the
--     DamageDealt indicator, regeneration reset, and elimination with the
--     existing last-attacker kill credit).
--
-- Spawns and round resets never hurt: damage only applies to a fall that
-- began from a measured standing surface, so a character spawning in
-- mid-air (recovered maps place spawn points above their islands) lands for
-- free. If something shoves a player upward mid-fall (the Teleporter item,
-- upward explosions), the highest level reached becomes the new fall start
-- so the fall is never inflated.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local FallDamageRules = require(script.Parent.FallDamageRules)

type FallDamageContext = {
	combatService: any,
}

type FallState = {
	grounded: boolean,
	fallStartLevel: number?,
}

local FallDamageService = {}
FallDamageService.__index = FallDamageService

-- Sampling cadence of the grounded check (drift-free, like
-- RegenerationService's ticker). Fast enough that a landing is never missed
-- between samples: after touchdown the player stays grounded.
local FALL_CHECK_INTERVAL = 0.05

-- A support surface no farther than this below the root part counts as the
-- ground the player is standing on (hip height plus slack against the
-- 3-stud block grid).
local GROUNDED_MAX_DISTANCE = 4.5

-- Falling faster than this while near a surface means the player is passing
-- it, not standing on it. Detection only — damage is computed from block
-- levels, never from velocity.
local FALLING_SPEED_THRESHOLD = 20

-- How far below the root part the support raycast reaches (deep enough for
-- the tallest island on any map).
local SUPPORT_RAY_DISTANCE = 200

function FallDamageService.new(context: FallDamageContext)
	return setmetatable({
		context = context,
		-- Per-player fall tracking. Weak-keyed so entries never outlive
		-- their player.
		states = setmetatable({}, { __mode = "k" }) :: { [Player]: FallState },
		playerRemovingConnection = nil :: RBXScriptConnection?,
		started = false,
	}, FallDamageService)
end

-- The block level of the surface directly under the root part when the
-- player is standing on it (nil when nothing nearby supports them). Only
-- the arena and player-placed blocks count — they all live inside
-- Workspace.BlockContainer, the whitelist the client's block raycasts use.
function FallDamageService:getSupportLevel(root: BasePart): number?
	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer == nil then
		return nil
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { blockContainer }
	local result = Workspace:Raycast(root.Position, Vector3.new(0, -SUPPORT_RAY_DISTANCE, 0), raycastParams)
	if result == nil or result.Instance == nil then
		return nil
	end
	if root.Position.Y - result.Position.Y > GROUNDED_MAX_DISTANCE then
		return nil
	end
	return FallDamageRules.getBlockLevel(result.Position.Y)
end

-- One grounded-check step for one player: detect leaving the ground and
-- landing, and apply the block-level fall damage on touchdown.
function FallDamageService:updatePlayer(player: Player, root: BasePart)
	local supportLevel = self:getSupportLevel(root)
	local fallingFast = root.AssemblyLinearVelocity.Y < -FALLING_SPEED_THRESHOLD
	local grounded = supportLevel ~= nil and not fallingFast

	local state = self.states[player]
	if state == nil then
		state = { grounded = false, fallStartLevel = nil }
		self.states[player] = state
	end

	if grounded then
		if not state.grounded and state.fallStartLevel ~= nil then
			-- Touchdown: compare the block they fell from with the block
			-- they landed on — the game's own rule, no velocity involved.
			local blocksFallen = state.fallStartLevel - supportLevel
			if blocksFallen > 0 then
				local damage = FallDamageRules.getFallDamage(blocksFallen)
				if damage > 0 then
					local combatService = self.context.combatService
					if combatService ~= nil and combatService.dealFallDamage ~= nil then
						combatService:dealFallDamage(player, damage)
					end
				end
			end
		end
		state.grounded = true
		state.fallStartLevel = supportLevel
		return
	end

	-- Airborne (or falling fast past a nearby surface). Leaving the ground
	-- keeps the last support level as "the block they fell from".
	if state.grounded then
		state.grounded = false
	end
	if state.fallStartLevel ~= nil then
		-- Upward displacement mid-fall (teleports, upward explosions) must
		-- not inflate the fall: the highest level reached becomes the new
		-- fall start.
		local currentLevel = FallDamageRules.getRootLevel(root.Position.Y)
		if currentLevel > state.fallStartLevel then
			state.fallStartLevel = currentLevel
		end
	end
end

function FallDamageService:tick()
	local combatService = self.context.combatService
	if combatService == nil or not combatService:isInRound() then
		-- Outside a running round no fall state is meaningful; dropping it
		-- every step also guarantees each round starts clean.
		self:clearAll()
		return
	end
	for _, player in Players:GetPlayers() do
		if player:GetAttribute(Attribute.Alive) ~= true or player:GetAttribute(Attribute.Spectating) == true then
			self:clearPlayer(player)
			continue
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root == nil or not root:IsA("BasePart") then
			self:clearPlayer(player)
			continue
		end
		self:updatePlayer(player, root)
	end
end

-- Spawning into a round drops any previous fall state so the first landing
-- (spawn points sit above their islands) is always free.
function FallDamageService:resetPlayer(player: Player)
	self.states[player] = nil
end

function FallDamageService:clearPlayer(player: Player)
	self.states[player] = nil
end

function FallDamageService:clearAll()
	table.clear(self.states)
end

function FallDamageService.start(self)
	if self.started then
		return
	end
	self.started = true
	-- Drift-free cadence: the next check time is absolute, so a late step
	-- (studio hitches, task scheduler granularity) self-corrects instead of
	-- accumulating delay the way a plain task.wait loop does.
	task.spawn(function()
		local nextTickTime = os.clock() + FALL_CHECK_INTERVAL
		while self.started do
			local waitTime = nextTickTime - os.clock()
			if waitTime > 0 then
				task.wait(waitTime)
			end
			nextTickTime += FALL_CHECK_INTERVAL
			self:tick()
		end
	end)
	self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self:clearPlayer(player)
	end)
end

function FallDamageService.stop(self)
	self.started = false
	if self.playerRemovingConnection ~= nil then
		self.playerRemovingConnection:Disconnect()
		self.playerRemovingConnection = nil
	end
	self:clearAll()
end

return FallDamageService
