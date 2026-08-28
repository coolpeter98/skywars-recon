--!strict

-- Server-side projectile simulation. The client charges locally and fires
-- FireProjectile(direction, strength); we validate, consume ammo, broadcast
-- ProjectileFired, and simulate with the same speed/acceleration as the
-- client's FastCast. Per-type collision behavior lives in HIT_BEHAVIORS.
--
-- Arrow is the only client-predicted projectile type: the client passes an
-- identifier suffix that we echo back as "<UserId>:<suffix>" so its local
-- render is reconciled instead of duplicated.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local BlockConstants = require(ReplicatedStorage.TS.block["block-constants"]).BlockConstants
local Items = require(ReplicatedStorage.TS.item.item).Items
local ProjectileConstants = require(ReplicatedStorage.TS.projectile["projectile-constants"]).ProjectileConstants
local WorldConstants = require(ReplicatedStorage.TS.world["world-constants"]).WorldConstants
local RobloxImage = require(ReplicatedStorage.TS.asset.roblox["roblox-image"]).RobloxImage

local DEFAULT_PROJECTILE_SPEED = 200
local MAX_PROJECTILE_LIFETIME = 10
local MAX_SEGMENT_LENGTH = 2
local MAX_STEP_DELTA = 0.25
local MAX_PREDICTION_ID_LENGTH = 64

-- Recovered ExplosionRadius is in block units (Capybara/Dynamite = 3, i.e.
-- ~6 blocks across); a block cell is 3 studs.
local BLOCK_SIZE: number = BlockConstants.BLOCK_SIZE

-- Only the projectile-simulation fields of the shared item definition; the
-- rest is cosmetics the server never touches.
export type ProjectileData = {
	Damage: number?,
	WeldOnCollide: boolean?,
	CollidePlayers: boolean?,
	Velocity: number?,
	Acceleration: Vector3?,
	ExplosionRadius: number?,
	KnockbackRadius: number?,
	KnockbackScalar: Vector3?,
	ImpactSound: string?,
	ExplosionSound: string?,
	ExplosionParticles: { [string]: any }?,
	-- Optional custom burst texture; falls back to the recovered sparkle.
	Texture: string?,
}

export type RangedDefinition = {
	ProjectileType: string,
	RequiresAmmo: boolean?,
	Cooldown: number?,
	DrawTime: number?,
	MinimumDrawTime: number?,
}

export type Projectile = {
	identifier: string,
	shooter: Player,
	-- The held weapon this was fired from (also the client's cooldown key).
	weaponName: string,
	-- The item whose Projectile definition drives the simulation and visuals.
	projectileType: string,
	data: ProjectileData,
	position: Vector3,
	velocity: Vector3,
	acceleration: Vector3,
	elapsed: number,
	raycastParams: RaycastParams,
}

-- Hit behaviors get the raw service state (not its API) so they stay
-- independent of method layout.
export type ProjectileServiceState = {
	context: any,
	activeProjectiles: { [string]: Projectile },
	started: boolean,
	heartbeatConnection: RBXScriptConnection?,
}

-- Handlers return true to let the client finish its own visual simulation
-- (welding the projectile), false to clean the visual up immediately.
export type HitBehavior = {
	onPlayerHit: ((self: ProjectileServiceState, projectile: Projectile, target: Player) -> boolean)?,
	onEnvironmentHit: ((self: ProjectileServiceState, projectile: Projectile, position: Vector3) -> boolean)?,
}

type Termination = {
	projectile: Projectile,
	finishSimulation: boolean,
}

local ProjectileService = {}
ProjectileService.__index = ProjectileService

local HIT_BEHAVIORS: { [string]: HitBehavior } = {}

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

-- Short segments so a fast projectile can't tunnel through thin blocks or
-- player hitboxes.
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

-- Zero-damage projectiles (Snowball) still knock back via CombatService's
-- zero-damage path.
local function dealPlayerHit(self: ProjectileServiceState, projectile: Projectile, target: Player)
	local combatService = self.context.combatService
	if combatService == nil then
		return
	end
	local damage = projectile.data.Damage
	if not isFinite(damage) then
		return
	end
	combatService:dealProjectileHit(projectile.shooter, target, damage, projectile.velocity)
end

-- Default for types without a registry entry. Mirrors the client's weld
-- default (nil WeldOnCollide = weldable); Arrow relies on this.
local DEFAULT_HIT_BEHAVIOR: HitBehavior = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, target: Player)
		dealPlayerHit(self, projectile, target)
		return false
	end,
	onEnvironmentHit = function(_: ProjectileServiceState, projectile: Projectile, _: Vector3)
		local weld = projectile.data.WeldOnCollide
		return if weld == nil then true else weld
	end,
}

-- Routes a collision through the projectile type's behavior and returns
-- whether the client should finish its own visual simulation.
local function applyHit(self: ProjectileServiceState, projectile: Projectile, hit: RaycastResult): boolean
	local hitPlayer = getPlayerFromHit(hit.Instance)
	local behavior = HIT_BEHAVIORS[projectile.projectileType] or DEFAULT_HIT_BEHAVIOR
	if hitPlayer ~= nil then
		if behavior.onPlayerHit ~= nil then
			return behavior.onPlayerHit(self, projectile, hitPlayer)
		end
		return false
	end
	if behavior.onEnvironmentHit ~= nil then
		return behavior.onEnvironmentHit(self, projectile, hit.Position)
	end
	return false
end

-- The client plays no explosion audio of its own, so the server fires the
-- recovered ExplosionSound through SoundPlayed.
local function playExplosionSound(self: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local soundId = projectile.data.ExplosionSound
	if soundId == nil then
		return
	end
	self.context.outbound:fireAll("SoundPlayed", ("Explosion_%s"):format(projectile.identifier), soundId, position, {
		Volume = 1,
	})
end

-- The client renders flight trails but nothing consumes ExplosionParticles,
-- so the server owns impact bursts. Emitted via continuous emission because
-- ParticleEmitter:Emit() on the server does not replicate. The anchor must
-- outlive the longest particle lifetime or the visible particles die with it.
local BURST_EMIT_SECONDS = 0.1
local BURST_DEFAULT_COUNT = 50
local BURST_DEFAULT_LIFETIME = NumberRange.new(0.5, 1)

local function spawnParticleBurst(
	position: Vector3,
	config: { [string]: any }?,
	scale: number?,
	lightInfluence: number?
)
	if config == nil then
		return
	end
	scale = scale or 1
	local anchor = Instance.new("Part")
	anchor.Name = "ImpactFx"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.CastShadow = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = position
	anchor.Parent = Workspace

	local emitter = Instance.new("ParticleEmitter")
	-- Assigning nil to a ParticleEmitter property errors, so every optional
	-- config field is nil-guarded (e.g. the snowball has no Acceleration).
	if config.Color ~= nil then
		emitter.Color = config.Color
	end
	-- Default texture: without it bursts render as plain squares.
	emitter.Texture = config.Texture or RobloxImage.PARTICLE
	if config.Size ~= nil and scale ~= 1 then
		local keypoints = {}
		for _, keypoint in config.Size.Keypoints do
			table.insert(
				keypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope)
			)
		end
		emitter.Size = NumberSequence.new(keypoints)
	elseif config.Size ~= nil then
		emitter.Size = config.Size
	end
	if config.Acceleration ~= nil then
		emitter.Acceleration = config.Acceleration
	end
	emitter.Lifetime = config.Lifetime or BURST_DEFAULT_LIFETIME
	emitter.Rotation = config.Rotation or NumberRange.new(0, 360)
	emitter.SpreadAngle = config.SpreadAngle or Vector2.new(180, 180)
	if lightInfluence ~= nil or config.LightInfluence ~= nil then
		emitter.LightInfluence = if lightInfluence ~= nil then lightInfluence else config.LightInfluence
	end
	if config.LightEmission ~= nil then
		emitter.LightEmission = config.LightEmission
	end
	emitter.Speed = if type(config.Speed) == "number"
		then NumberRange.new(config.Speed * scale)
		else NumberRange.new(5 * scale)
	emitter.Rate = (config.Count or BURST_DEFAULT_COUNT) * scale / BURST_EMIT_SECONDS
	emitter.Enabled = true
	emitter.Parent = anchor

	local maxLifetime = emitter.Lifetime.Max
	task.delay(BURST_EMIT_SECONDS, function()
		if anchor.Parent ~= nil then
			emitter.Rate = 0
		end
	end)
	task.delay(BURST_EMIT_SECONDS + maxLifetime + 0.2, function()
		anchor:Destroy()
	end)
end

-- Full fixed projectile impulse to every valid enemy within KnockbackRadius,
-- away from the blast. Same uniform rules as all combat: no self/teammate
-- hits, alive only. AoE damage is the caller's concern.
local function explodeKnockback(self: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local knockbackRadius = projectile.data.KnockbackRadius
	local combatService = self.context.combatService
	if knockbackRadius == nil or combatService == nil then
		return
	end
	for _, player in Players:GetPlayers() do
		if not combatService:isValidTarget(projectile.shooter, player) then
			continue
		end
		if combatService:isFriendlyFire(projectile.shooter, player) then
			continue
		end
		local root = getPlayerRoot(player)
		if root == nil then
			continue
		end
		local offset = root.Position - position
		local distance = offset.Magnitude
		if distance > knockbackRadius then
			continue
		end
		local direction = if distance > 0.001 then offset / distance else Vector3.new(1, 0, 0)
		self.context.outbound:fire("DamageImpulse", player, combatService:getProjectileKnockback(direction))
	end
end

-- Linear falloff from full damage at the impact point to zero at
-- ExplosionRadius. Routes through CombatService without an impulse — the
-- blast already knocked these players back.
local function explodeDamage(self: ProjectileServiceState, projectile: Projectile, position: Vector3, damage: number)
	local explosionRadius = projectile.data.ExplosionRadius
	local combatService = self.context.combatService
	if explosionRadius == nil or combatService == nil or explosionRadius <= 0 then
		return
	end
	for _, player in Players:GetPlayers() do
		if not combatService:isValidTarget(projectile.shooter, player) then
			continue
		end
		if combatService:isFriendlyFire(projectile.shooter, player) then
			continue
		end
		local root = getPlayerRoot(player)
		if root == nil then
			continue
		end
		local distance = (root.Position - position).Magnitude
		if distance > explosionRadius then
			continue
		end
		local dealtDamage = damage * (1 - distance / explosionRadius)
		if dealtDamage > 0 then
			combatService:dealExplosionDamage(projectile.shooter, player, dealtDamage)
		end
	end
end

-- ExplosionRadius is in blocks; BlockWorldService re-culls carved faces via
-- the same path pickaxe mining uses, and grants nothing to the shooter.
local function breakBlocks(self: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local blockWorldService = self.context.blockWorldService
	local explosionRadius = projectile.data.ExplosionRadius
	if blockWorldService == nil or explosionRadius == nil or explosionRadius <= 0 then
		return
	end
	blockWorldService:mineExplosion(position, explosionRadius * BLOCK_SIZE)
end

-- Shared explosive entry point: sound, burst, knockback, optional AoE damage,
-- spherical block carve.
local function explode(self: ProjectileServiceState, projectile: Projectile, position: Vector3, damage: number?)
	playExplosionSound(self, projectile, position)
	spawnParticleBurst(position, projectile.data.ExplosionParticles)
	explodeKnockback(self, projectile, position)
	if damage ~= nil and damage > 0 then
		explodeDamage(self, projectile, position, damage)
	end
	breakBlocks(self, projectile, position)
end

local function teleportShooter(_: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local root = getPlayerRoot(projectile.shooter)
	if root == nil then
		return
	end
	root.CFrame = CFrame.new(position)
	root.AssemblyLinearVelocity = Vector3.zero
end

-- Recovered KnockbackScalar (-1.5, 1, -1.5) multiplies the fish's velocity
-- component-wise, so X/Z pull back toward the fisherman while vertical is
-- kept and a fully-charged cast pulls harder.
local function pullPlayer(self: ProjectileServiceState, projectile: Projectile, target: Player)
	local scalar = projectile.data.KnockbackScalar
	if scalar == nil then
		return
	end
	local combatService = self.context.combatService
	if combatService == nil then
		return
	end
	if not combatService:isValidTarget(projectile.shooter, target) then
		return
	end
	if combatService:isFriendlyFire(projectile.shooter, target) then
		return
	end
	local velocity = projectile.velocity
	local impulse = Vector3.new(velocity.X * scalar.X, velocity.Y * scalar.Y, velocity.Z * scalar.Z)
	self.context.outbound:fire("DamageImpulse", target, impulse)
end

-- Cooldowns share CombatService's registry. `true` in setCooldown replicates
-- via CooldownUpdated, keyed by the held weapon's item name.
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

-- Resolves the held ranged weapon into its projectile definition, validates
-- ammo and cooldown, and starts a simulated projectile of that type.
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
	local heldItemType = session.heldItemType
	if type(heldItemType) ~= "string" then
		return false
	end
	local weaponDefinition = Items[heldItemType]
	if weaponDefinition == nil or weaponDefinition.Ranged == nil then
		return false
	end
	local ranged = weaponDefinition.Ranged :: RangedDefinition
	local projectileType = ranged.ProjectileType
	if type(projectileType) ~= "string" then
		return false
	end
	local projectileItem = Items[projectileType]
	local projectileData = projectileItem and projectileItem.Projectile or nil
	if projectileData == nil then
		return false
	end
	if self:isOnCooldown(player, heldItemType) then
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
	if not isFinite(strength) or strength <= 0 or strength > 1 then
		return false
	end

	-- RequiresAmmo defaults true on the client; FishingRod opts out.
	local requiresAmmo = ranged.RequiresAmmo ~= false
	local inventoryService = self.context.inventoryService
	if requiresAmmo and inventoryService:getItemQuantity(player, projectileType) < 1 then
		return false
	end
	local root = getPlayerRoot(player)
	if root == nil then
		return false
	end
	if requiresAmmo and not inventoryService:changeItem(player, projectileType, -1) then
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
		weaponName = heldItemType,
		projectileType = projectileType,
		data = projectileData,
		position = origin,
		velocity = unitDirection * speed,
		acceleration = acceleration,
		elapsed = 0,
		raycastParams = raycastParams,
	}

	-- No explicit Cooldown (Bow, Capybara, Dynamite) → shared micro-cooldown;
	-- the client gates them by DrawTime anyway.
	local cooldown = if ranged.Cooldown ~= nil then ranged.Cooldown else ProjectileConstants.COOLDOWN
	self:setCooldown(player, heldItemType, cooldown)
	self.context.outbound:fireAll(
		"ProjectileFired",
		player,
		projectileType,
		origin,
		unitDirection,
		speed,
		identifier,
		nil,
		nil
	)
	return true
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
			table.insert(terminations, { projectile = projectile, finishSimulation = applyHit(self, projectile, hit) })
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

-- Declared after the methods so `typeof(ProjectileService)` sees the whole
-- service type.
function ProjectileService.new(context): typeof(ProjectileService)
	return setmetatable({
		context = context,
		activeProjectiles = {} :: { [string]: Projectile },
		heartbeatConnection = nil :: RBXScriptConnection?,
		started = false,
	}, ProjectileService)
end

-- Extension point: registers or replaces the hit behavior for a projectile
-- item type. Built-in types register through this same table below.
function ProjectileService.registerHitBehavior(projectileType: string, behavior: HitBehavior)
	HIT_BEHAVIORS[projectileType] = behavior
end

-- One entry per projectile item type; add new weapons here (or via
-- registerHitBehavior from another module).

-- Snowball: zero damage, fixed knockback via the zero-damage path, plus its
-- recovered ExplosionParticles burst on every impact (client plays the
-- ImpactSound and flight trail itself). WeldOnCollide = false, so environment
-- hits clean the visual up.
HIT_BEHAVIORS.Snowball = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, target: Player)
		dealPlayerHit(self, projectile, target)
		spawnParticleBurst(projectile.position, projectile.data.ExplosionParticles)
		return false
	end,
	onEnvironmentHit = function(_: ProjectileServiceState, projectile: Projectile, position: Vector3)
		spawnParticleBurst(position, projectile.data.ExplosionParticles)
		return false
	end,
}

-- Dynamite: knockback-only blast (Projectile.Damage = 0) plus spherical
-- block carve; explodes on any collision.
HIT_BEHAVIORS.Dynamite = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, _: Player)
		explode(self, projectile, projectile.position)
		return false
	end,
	onEnvironmentHit = function(self: ProjectileServiceState, projectile: Projectile, _: Vector3)
		explode(self, projectile, projectile.position)
		return false
	end,
}

-- Capybara: explosive AoE — 42 damage with linear falloff across
-- ExplosionRadius (3) plus the Dynamite-style knockback and block carve.
HIT_BEHAVIORS.Capybara = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, _: Player)
		explode(self, projectile, projectile.position, projectile.data.Damage)
		return false
	end,
	onEnvironmentHit = function(self: ProjectileServiceState, projectile: Projectile, _: Vector3)
		explode(self, projectile, projectile.position, projectile.data.Damage)
		return false
	end,
}

-- Teleporter: moves the shooter to the exact impact point on any collision.
HIT_BEHAVIORS.Teleporter = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, _: Player)
		teleportShooter(self, projectile, projectile.position)
		return false
	end,
	onEnvironmentHit = function(self: ProjectileServiceState, projectile: Projectile, _: Vector3)
		teleportShooter(self, projectile, projectile.position)
		return false
	end,
}

-- Fish (FishingRod): pulls the hooked player toward the caster; no weld on
-- environment hits (WeldOnCollide = false).
HIT_BEHAVIORS.Fish = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, target: Player)
		pullPlayer(self, projectile, target)
		return false
	end,
	onEnvironmentHit = function(_: ProjectileServiceState, _: Projectile, _: Vector3)
		return false
	end,
}

return ProjectileService
