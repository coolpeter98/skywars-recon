--!strict

-- Server-authoritative projectile simulation for every ranged weapon.
--
-- The client charges a ranged weapon locally and, on release, fires
-- `FireProjectile(direction, strength)`. This service validates the shooter
-- (alive, holding a ranged item, off that weapon's cooldown, holding ammo when
-- the weapon requires it, finite non-zero direction, strength in [0, 1]),
-- consumes ammo authoritatively, then replicates the shot with
-- `ProjectileFired` and simulates the flight using the same speed and
-- acceleration the client's FastCast uses.
--
-- Collisions end the flight via `ProjectileTerminated`. An environment hit on
-- a weldable projectile (Arrow) lets the client finish its own visual
-- simulation so the arrow welds; player hits and everything else clean the
-- visual up immediately. Per-projectile behavior (damage, knockback,
-- explosions, teleports, pulls) lives in the HIT_BEHAVIORS registry keyed by
-- the projectile item type, so a new projectile type is one registry entry.
--
-- The client may locally predict its own Arrow (same speed and acceleration)
-- and pass an identifier suffix with `FireProjectile`; this service echoes it
-- back as `<UserId>:<suffix>` so the prediction is reconciled instead of
-- rendered twice. Every other projectile type is only rendered from the
-- server broadcast (the client predicts nothing for them).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local Items = require(ReplicatedStorage.TS.item.item).Items
local ProjectileConstants = require(ReplicatedStorage.TS.projectile["projectile-constants"]).ProjectileConstants
local WorldConstants = require(ReplicatedStorage.TS.world["world-constants"]).WorldConstants

local DEFAULT_PROJECTILE_SPEED = 200
local MAX_PROJECTILE_LIFETIME = 10
local MAX_SEGMENT_LENGTH = 2
local MAX_STEP_DELTA = 0.25
local MAX_PREDICTION_ID_LENGTH = 64

-- The subset of the shared item module's projectile definition this service
-- reads. The full definitions carry cosmetic fields (particles, sounds,
-- viewport options) that are irrelevant to the server simulation.
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

-- What hit behaviors are handed: the service state they may read, never its
-- public API. Keeps behaviors trivially testable and independent of method
-- layout.
export type ProjectileServiceState = {
	context: any,
	activeProjectiles: { [string]: Projectile },
	started: boolean,
	heartbeatConnection: RBXScriptConnection?,
}

-- A hit behavior decides what a collision does and whether the client should
-- finish its own visual simulation (`true` = let the client weld, used by
-- projectiles whose WeldOnCollide is enabled).
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

-- Casts a ray from `from` to `to`, subdividing the span into short segments so
-- a fast projectile cannot tunnel through a thin block or player hitbox.
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

-- Applies a projectile's damage to a hit player. Damage 0 (Snowball) still
-- delivers the fixed projectile knockback through CombatService's zero-damage
-- path; the impulse direction is the projectile's travel velocity.
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

-- Behavior for projectile types without an explicit registry entry: deal the
-- projectile's damage to hit players, and mirror the client's weld default
-- (WeldOnCollide == nil treats the projectile as weldable). Arrow relies on
-- this default on purpose.
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

-- Plays a projectile's ExplosionSound at a position through the client-side
-- SoundPlayed pipeline (the client renders no explosion audio of its own).
local function playExplosionSound(self: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local soundId = projectile.data.ExplosionSound
	if soundId == nil then
		return
	end
	self.context.outbound:fireAll("SoundPlayed", ("Explosion_%s"):format(projectile.identifier), soundId, position, {
		Volume = 1,
	})
end

-- Spawns a one-shot particle burst from a projectile's recovered
-- ExplosionParticles definition. The client renders flight ParticleTrails
-- itself, but no client code consumes ExplosionParticles, so the server owns
-- every impact burst (explosions, snowball impacts, ...); it is cosmetic only.
--
-- The burst is produced through continuous emission (a high Rate for a few
-- frames, then Rate 0): ParticleEmitter:Emit() calls made on the server do
-- not replicate to clients, while regular emission does. The anchor must
-- stay alive until the last emitted particle's lifetime expires — destroying
-- it earlier kills the remaining visible particles.
--
-- `scale` is a presentation multiplier (particle size, speed and count) and
-- `emitSeconds` the emission window, for bursts whose recovered config is
-- imperceptible in practice; the recovered config itself is never rewritten.
local BURST_DEFAULT_EMIT_SECONDS = 0.1
local BURST_DEFAULT_COUNT = 50
local BURST_DEFAULT_LIFETIME = NumberRange.new(0.5, 1)

local function spawnParticleBurst(position: Vector3, config: { [string]: any }?, scale: number?, emitSeconds: number?)
	if config == nil then
		return
	end
	scale = scale or 1
	emitSeconds = emitSeconds or BURST_DEFAULT_EMIT_SECONDS
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
	emitter.Color = config.Color
	if config.Size ~= nil and scale ~= 1 then
		local keypoints = {}
		for _, keypoint in config.Size.Keypoints do
			table.insert(
				keypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope)
			)
		end
		emitter.Size = NumberSequence.new(keypoints)
	else
		emitter.Size = config.Size
	end
	emitter.Acceleration = config.Acceleration
	emitter.Lifetime = config.Lifetime or BURST_DEFAULT_LIFETIME
	emitter.Rotation = config.Rotation or NumberRange.new(0, 360)
	emitter.SpreadAngle = config.SpreadAngle or Vector2.new(180, 180)
	emitter.LightInfluence = config.LightInfluence
	emitter.LightEmission = config.LightEmission
	emitter.Speed = if type(config.Speed) == "number"
		then NumberRange.new(config.Speed * scale)
		else NumberRange.new(5 * scale)
	emitter.Rate = (config.Count or BURST_DEFAULT_COUNT) * scale / emitSeconds
	emitter.Enabled = true
	emitter.Parent = anchor

	local maxLifetime = emitter.Lifetime.Max
	task.delay(emitSeconds, function()
		if anchor.Parent ~= nil then
			emitter.Rate = 0
		end
	end)
	task.delay(emitSeconds + maxLifetime + 0.2, function()
		anchor:Destroy()
	end)
end

-- Shoves every valid enemy within the projectile's KnockbackRadius with the
-- full fixed projectile impulse, away from the explosion center. Uniform with
-- every other combat source: no self hits, no teammate hits, alive targets
-- only. AoE damage is the caller's concern (Dynamite deals none).
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

-- Applies AoE explosion damage with a linear falloff from full damage at the
-- impact point to zero at ExplosionRadius. Same target rules as the knockback
-- (no self/teammate hits, alive targets only). Damage routes through
-- CombatService without an impulse — the blast already shoved these players.
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

-- Shared explosion entry point for explosive projectiles: one-time sound and
-- particle burst at the impact point, AoE knockback, and optional AoE damage
-- (Dynamite none, Capybara linear falloff). Block breaking is intentionally
-- not implemented yet (the placeholder map is not chunked).
--
-- The recovered explosion burst (Count 100, 0.5-stud particles, gravity
-- dragging them away within ~0.5-1s) reads as a couple of specks in
-- practice, so it renders at 3x size/speed/count spread over 0.3 s.
local EXPLOSION_PARTICLE_SCALE = 3
local EXPLOSION_PARTICLE_EMIT_SECONDS = 0.3

local function explode(self: ProjectileServiceState, projectile: Projectile, position: Vector3, damage: number?)
	playExplosionSound(self, projectile, position)
	spawnParticleBurst(
		position,
		projectile.data.ExplosionParticles,
		EXPLOSION_PARTICLE_SCALE,
		EXPLOSION_PARTICLE_EMIT_SECONDS
	)
	explodeKnockback(self, projectile, position)
	if damage ~= nil and damage > 0 then
		explodeDamage(self, projectile, position, damage)
	end
end

-- Moves the shooter's character to the projectile's impact point, exactly as
-- the client places nothing and defines no offset. Velocity is zeroed so the
-- arrival is clean.
local function teleportShooter(_: ProjectileServiceState, projectile: Projectile, position: Vector3)
	local root = getPlayerRoot(projectile.shooter)
	if root == nil then
		return
	end
	root.CFrame = CFrame.new(position)
	root.AssemblyLinearVelocity = Vector3.zero
end

-- Pulls the hooked player toward the caster: the recovered KnockbackScalar
-- (-1.5, 1, -1.5) negates the fish's travel direction (X/Z pull back toward
-- the fisherman) while keeping the vertical component. The scalar multiplies
-- the projectile's velocity component-wise, faithfully to the recovered item
-- data, so a fully-charged cast pulls harder than a limp one.
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

-- Cooldowns live in CombatService's shared registry (one system for every
-- combat action). Replicated cooldowns reach the client through
-- CooldownUpdated, keyed by the held weapon's item name.
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

	-- Weapons without RequiresAmmo consume their projectile item type (the
	-- client's default is RequiresAmmo = true); FishingRod opts out.
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

	-- Weapons without an explicit Cooldown (Bow, Capybara, Dynamite) use the
	-- shared micro-cooldown; the client charges them over DrawTime anyway.
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

-- Constructs a service instance. Declared after the method definitions so
-- `typeof(ProjectileService)` captures the complete service type.
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

-- ────────────────────────── Projectile behaviors ───────────────────────────
-- One entry per projectile item type; a behavior decides what a collision does
-- (see HitBehavior). The registry lives here so every weapon's behavior is
-- visible in one place; registerHitBehavior exists for future extension.

-- Snowball: deals no damage (Projectile.Damage = 0) but still delivers the
-- fixed projectile knockback impulse through CombatService's zero-damage
-- path, and bursts with its recovered ExplosionParticles on every impact
-- (the client plays its ImpactSound and renders the flight trail itself).
-- The recovered burst is 20 near-white 0.2-stud particles — imperceptible in
-- practice — so it renders at 3x size/speed/count without rewriting the
-- config. WeldOnCollide = false, so environment hits clean the visual up.
-- Its 0.5 s cooldown and speed come from the item definition automatically.
local SNOWBALL_PARTICLE_SCALE = 3
HIT_BEHAVIORS.Snowball = {
	onPlayerHit = function(self: ProjectileServiceState, projectile: Projectile, target: Player)
		dealPlayerHit(self, projectile, target)
		spawnParticleBurst(projectile.position, projectile.data.ExplosionParticles, SNOWBALL_PARTICLE_SCALE)
		return false
	end,
	onEnvironmentHit = function(_: ProjectileServiceState, projectile: Projectile, position: Vector3)
		spawnParticleBurst(position, projectile.data.ExplosionParticles, SNOWBALL_PARTICLE_SCALE)
		return false
	end,
}

-- Dynamite: a pure knockback explosion — Projectile.Damage = 0, so the blast
-- only shoves within KnockbackRadius (no block damage yet). Explodes on any
-- collision, player or environment.
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

-- Capybara: an explosive AoE — Projectile.Damage = 50 applied with a linear
-- falloff across ExplosionRadius (3), plus the same full-impulse knockback
-- blast as Dynamite within KnockbackRadius (5). No block breaking yet.
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

-- Teleporter: no damage — moves the shooter to the exact impact point on any
-- collision (player or environment), then cleans the visual up. Its 15 s
-- cooldown comes from the item definition.
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

-- Fish (FishingRod): no damage — pulls the hooked player toward the caster
-- with the recovered KnockbackScalar impulse. The hook does not weld
-- (WeldOnCollide = false), so environment hits clean the visual up. Its 1 s
-- cooldown and RequiresAmmo = false come from the item definition.
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
