--!strict

-- Server-authoritative Arrow projectile simulation.
--
-- The client charges a bow locally and, on release, fires
-- `FireProjectile(direction, strength)`. This service validates the shooter
-- (alive, holding a Bow, off cooldown, holding Arrow ammo, finite non-zero
-- direction, strength in [0, 1]), consumes one Arrow authoritatively, then
-- replicates the shot with `ProjectileFired` and simulates the arrow's flight
-- using the same speed and acceleration the client's FastCast uses.
--
-- Collisions end the flight via `ProjectileTerminated`: an environment hit
-- lets the client finish its own visual simulation (the arrow welds), while a
-- player hit or a lifetime expiry cleans the visual up immediately. Player
-- hits are routed into CombatService, which applies the arrow's damage,
-- knockback (the same knockback system melee uses), and elimination/kill-feed
-- events. Bow cooldowns also live in CombatService's shared registry.
--
-- The client may locally predict its own arrow (same speed and acceleration)
-- and pass an identifier suffix with `FireProjectile`; this service echoes it
-- back as `<UserId>:<suffix>` so the prediction is reconciled instead of
-- rendered twice.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local Items = require(ReplicatedStorage.TS.item.item).Items
local ProjectileConstants = require(ReplicatedStorage.TS.projectile["projectile-constants"]).ProjectileConstants
local WorldConstants = require(ReplicatedStorage.TS.world["world-constants"]).WorldConstants

local BOW_ITEM_TYPE = "Bow"
local ARROW_ITEM_TYPE = "Arrow"
local DEFAULT_PROJECTILE_SPEED = 200
local MAX_PROJECTILE_LIFETIME = 10
local MAX_SEGMENT_LENGTH = 2
local MAX_STEP_DELTA = 0.25
local MAX_PREDICTION_ID_LENGTH = 64

type Projectile = {
	identifier: string,
	shooter: Player,
	itemName: string,
	position: Vector3,
	velocity: Vector3,
	acceleration: Vector3,
	elapsed: number,
	raycastParams: RaycastParams,
}

type Termination = {
	projectile: Projectile,
	finishSimulation: boolean,
}

local ProjectileService = {}
ProjectileService.__index = ProjectileService

local function isFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

local function getPlayerRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil and humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root ~= nil and root:IsA("BasePart") then root else nil
end

local function getPlayerFromHit(hitInstance: Instance): Player?
	local model = hitInstance:FindFirstAncestorOfClass("Model")
	if model == nil then
		return nil
	end
	return Players:GetPlayerFromCharacter(model)
end

-- Casts a ray from `from` to `to`, subdividing the span into short segments so
-- a fast arrow cannot tunnel through a thin block or player hitbox.
local function castSegment(from: Vector3, to: Vector3, params: RaycastParams): RaycastResult?
	local delta = to - from
	local distance = delta.Magnitude
	if distance <= 0 then
		return nil
	end
	local direction = delta / distance
	local origin = from
	local remaining = distance
	while remaining > 0 do
		local segmentLength = math.min(remaining, MAX_SEGMENT_LENGTH)
		local hit = Workspace:Raycast(origin, direction * segmentLength, params)
		if hit ~= nil then
			return hit
		end
		origin += direction * segmentLength
		remaining -= segmentLength
	end
	return nil
end

function ProjectileService.new(context)
	return setmetatable({
		context = context,
		activeProjectiles = {} :: { [string]: Projectile },
		heartbeatConnection = nil :: RBXScriptConnection?,
		started = false,
	}, ProjectileService)
end

-- Cooldowns live in CombatService's shared registry (one system for every
-- combat action). Bow cooldowns replicate to the client for the bow UI.
function ProjectileService.isOnCooldown(self, player: Player, key: string): boolean
	return self.context.combatService:isOnCooldown(player, key)
end

function ProjectileService.setCooldown(self, player: Player, key: string, duration: number)
	self.context.combatService:setCooldown(player, key, duration, true)
end

function ProjectileService.isValidShooter(self, player: Player): boolean
	if player:GetAttribute(Attribute.Alive) ~= true then
		return false
	end
	if player:GetAttribute(Attribute.Spectating) == true then
		return false
	end
	return getPlayerRoot(player) ~= nil
end

function ProjectileService.resolveIdentifier(self, player: Player, predictedIdentifier: string?): string
	local suffix = HttpService:GenerateGUID(false)
	if
		type(predictedIdentifier) == "string"
		and #predictedIdentifier > 0
		and #predictedIdentifier <= MAX_PREDICTION_ID_LENGTH
	then
		suffix = predictedIdentifier
	end
	local identifier = ("%d:%s"):format(player.UserId, suffix)
	if self.activeProjectiles[identifier] ~= nil then
		identifier = ("%d:%s"):format(player.UserId, HttpService:GenerateGUID(false))
	end
	return identifier
end

function ProjectileService.fireProjectile(
	self,
	player: Player,
	direction: Vector3,
	strength: number,
	predictedIdentifier: string?
): boolean
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return false
	end
	if not self:isValidShooter(player) then
		return false
	end
	if session.heldItemType ~= BOW_ITEM_TYPE then
		return false
	end
	if self:isOnCooldown(player, BOW_ITEM_TYPE) then
		return false
	end
	if
		typeof(direction) ~= "Vector3"
		or not isFinite(direction.X)
		or not isFinite(direction.Y)
		or not isFinite(direction.Z)
		or direction.Magnitude <= 0
	then
		return false
	end
	if not isFinite(strength) or strength < 0 or strength > 1 then
		return false
	end

	local arrowDefinition = Items[ARROW_ITEM_TYPE]
	local projectileData = arrowDefinition and arrowDefinition.Projectile or nil
	if projectileData == nil then
		return false
	end
	if self.context.inventoryService:getItemQuantity(player, ARROW_ITEM_TYPE) < 1 then
		return false
	end
	local root = getPlayerRoot(player)
	if root == nil then
		return false
	end

	if not self.context.inventoryService:changeItem(player, ARROW_ITEM_TYPE, -1) then
		return false
	end

	local unitDirection = direction.Unit
	local baseSpeed = if projectileData.Velocity ~= nil then projectileData.Velocity else DEFAULT_PROJECTILE_SPEED
	local speed = baseSpeed * strength
	local acceleration = if projectileData.Acceleration ~= nil
		then projectileData.Acceleration
		else WorldConstants.WORLD_ACCELERATION
	local origin = (root.CFrame * ProjectileConstants.ORIGIN_OFFSET).Position
	local identifier = self:resolveIdentifier(player, predictedIdentifier)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local character = player.Character
	if character ~= nil then
		raycastParams.FilterDescendantsInstances = { character }
	end

	self.activeProjectiles[identifier] = {
		identifier = identifier,
		shooter = player,
		itemName = ARROW_ITEM_TYPE,
		position = origin,
		velocity = unitDirection * speed,
		acceleration = acceleration,
		elapsed = 0,
		raycastParams = raycastParams,
	}

	self:setCooldown(player, BOW_ITEM_TYPE, ProjectileConstants.COOLDOWN)
	self.context.outbound:fireAll(
		"ProjectileFired",
		player,
		ARROW_ITEM_TYPE,
		origin,
		unitDirection,
		speed,
		identifier,
		nil,
		nil
	)
	return true
end

-- Applies arrow damage when a simulated projectile collides with a player.
-- Damage comes from the projectile item's definition (e.g. Arrow.Projectile.
-- Damage); knockback is built by CombatService's universal knockback system
-- from the arrow's travel velocity.
function ProjectileService.dealPlayerHit(self, projectile: Projectile, target: Player)
	local combatService = self.context.combatService
	if combatService == nil then
		return
	end
	local itemDefinition = Items[projectile.itemName]
	local projectileData = itemDefinition and itemDefinition.Projectile or nil
	local damage = projectileData and projectileData.Damage or nil
	if not isFinite(damage) then
		return
	end
	combatService:dealProjectileHit(projectile.shooter, target, damage, projectile.velocity)
end

function ProjectileService.terminate(self, projectile: Projectile, finishSimulation: boolean)
	if self.activeProjectiles[projectile.identifier] == nil then
		return
	end
	self.activeProjectiles[projectile.identifier] = nil
	self.context.outbound:fireAll("ProjectileTerminated", projectile.identifier, finishSimulation)
end

function ProjectileService.step(self, rawDeltaTime: number)
	local deltaTime = math.min(rawDeltaTime, MAX_STEP_DELTA)
	local terminations: { Termination } = {}
	for _, projectile in self.activeProjectiles do
		projectile.elapsed += deltaTime
		if projectile.elapsed >= MAX_PROJECTILE_LIFETIME then
			table.insert(terminations, { projectile = projectile, finishSimulation = false })
			continue
		end

		local previousPosition = projectile.position
		projectile.velocity += projectile.acceleration * deltaTime
		projectile.position += projectile.velocity * deltaTime

		local hit = castSegment(previousPosition, projectile.position, projectile.raycastParams)
		if hit ~= nil then
			projectile.position = hit.Position
			local hitPlayer = getPlayerFromHit(hit.Instance)
			if hitPlayer ~= nil then
				self:dealPlayerHit(projectile, hitPlayer)
			end
			table.insert(terminations, { projectile = projectile, finishSimulation = hitPlayer == nil })
		end
	end

	for _, termination in terminations do
		self:terminate(termination.projectile, termination.finishSimulation)
	end
end

function ProjectileService.clearAll(self)
	local projectiles: { Projectile } = {}
	for _, projectile in self.activeProjectiles do
		table.insert(projectiles, projectile)
	end
	for _, projectile in projectiles do
		self:terminate(projectile, false)
	end
	self.context.combatService:clearCooldowns()
end

function ProjectileService.start(self)
	if self.started then
		return
	end
	self.started = true
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:step(deltaTime)
	end)
end

function ProjectileService.stop(self)
	if not self.started then
		return
	end
	self.started = false
	if self.heartbeatConnection ~= nil then
		self.heartbeatConnection:Disconnect()
		self.heartbeatConnection = nil
	end
	self:clearAll()
end

return ProjectileService
