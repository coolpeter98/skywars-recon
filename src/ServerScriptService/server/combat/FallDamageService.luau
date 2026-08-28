--!strict

-- Fall damage uses block-level comparison (fall-from level vs landing level),
-- never velocity — verified against the real game; falls under 10 blocks do
-- nothing (see FallDamageRules). Support raycasts target only
-- Workspace.BlockContainer (arena + placed blocks, the client's whitelist).
-- Velocity gates detection only, never damage math.

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

-- Sampling cadence of the grounded check.
local FALL_CHECK_INTERVAL = 0.05

-- Hip height plus slack against the 3-stud block grid.
local GROUNDED_MAX_DISTANCE = 4.5

-- Falling faster than this past a surface means passing it, not standing on it.
local FALLING_SPEED_THRESHOLD = 20

-- How far below the root part the support raycast reaches (deep enough for
-- the tallest island on any map).
local SUPPORT_RAY_DISTANCE = 200

function FallDamageService.new(context: FallDamageContext)
	return setmetatable({
		context = context,
		states = setmetatable({}, { __mode = "k" }) :: { [Player]: FallState },
		playerRemovingConnection = nil :: RBXScriptConnection?,
		started = false,
	}, FallDamageService)
end

-- Block level of the surface under the root, or nil if unsupported.
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
			-- Touchdown: fall-from level vs landing level, no velocity involved.
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

	-- Airborne; leaving the ground records the fall-start level.
	if state.grounded then
		state.grounded = false
	end
	if state.fallStartLevel ~= nil then
		-- Upward displacement (teleports, explosions) raises the fall start so
		-- the fall is never inflated.
		local currentLevel = FallDamageRules.getRootLevel(root.Position.Y)
		if currentLevel > state.fallStartLevel then
			state.fallStartLevel = currentLevel
		end
	end
end

function FallDamageService:tick()
	local combatService = self.context.combatService
	if combatService == nil or not combatService:isInRound() then
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

-- Spawn (points sit above islands) lands for free.
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
	-- Drift-free cadence: absolute next-tick time self-corrects after hitches.
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
