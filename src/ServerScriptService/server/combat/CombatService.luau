--!strict

-- Server-authoritative combat. Client fires MeleeStrike/MeleeStrikeEntity; we
-- re-validate and apply results via the client's replicated contract:
-- Health/Shield attributes (UI reads those, not the Humanoid), DamageDealt,
-- DamageImpulse (applied by PlayerVelocityController), elimination via
-- RoundService (PlayerKilled + PlayerEliminated).
-- The client's melee raycast only hits parts named "Hitbox"/"ProjectileHitbox"
-- found via Character:FindFirstChild, so every character gets welded hitboxes.
-- Shield absorbs exactly one hit regardless of remaining shield. Knockback is
-- fixed per damage type (client never ties it to damage).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local ItemModule = require(ReplicatedStorage.TS.item.item)
local MeleeConstants = require(ReplicatedStorage.TS.melee["melee-constants"]).MeleeConstants

type ItemDefinition = {
	Name: string,
	Melee: { Damage: number }?,
	Armour: { ArmourType: string, DamageMitigation: number }?,
}

local Items = ItemModule.Items :: { [string]: ItemDefinition }

local DAMAGE_TYPE_MELEE = "Melee"
local DAMAGE_TYPE_BOW = "Bow"
local DAMAGE_TYPE_FALL = "Fall"

-- Client accepts strikes up to MAXIMUM_HIT_RANGE_BLOCKS * 3; slack covers latency.
local MAX_MELEE_RANGE = MeleeConstants.MAXIMUM_HIT_RANGE_BLOCKS * 3 + 1.5
-- Client's PlayerVelocityController divides by assembly mass * 14.332, so
-- velocity change is strength / 14.332 studs/s. Fixed per damage type — the
-- recovered client never scales knockback by hit damage. Tuned via KnockbackTest:
-- melee 150 * 8 = 1200 (~83.8 studs/s), projectiles 150 * 10 = 1500 (~104.7 studs/s).
local KNOCKBACK_BASE = 150
local MELEE_KNOCKBACK_MULTIPLIER = 8
local PROJECTILE_KNOCKBACK_MULTIPLIER = 10
local KNOCKBACK_UPWARD_BIAS = 0.6
local ARMOUR_TYPES = { "Helmet", "Chestplate", "Leggings" }

-- Healed per damaging hit while LifeSteal is active.
local LIFESTEAL_HEAL_PER_HIT = 3

-- Window in which an environmental elimination (Void/Fall) credits the last hitter.
local LAST_ATTACK_CREDIT_SECONDS = 10

-- Client's melee raycast whitelist looks up these exact part names.
type HitboxConfig = {
	Name: string,
	Size: Vector3,
	Offset: CFrame,
}

local CHARACTER_HITBOXES: { HitboxConfig } = {
	{
		Name = "Hitbox",
		Size = Vector3.new(5, 6, 5),
		Offset = CFrame.new(0, 0.5, 0),
	},
	{
		Name = "ProjectileHitbox",
		Size = Vector3.new(10, 6, 10),
		Offset = CFrame.new(0, 0.5, 0),
	},
}

-- Backstop for missed CharacterAdded events (races during Studio/custom-game
-- transitions) and removed/broken hitboxes.
local HITBOX_RECONCILE_SECONDS = 0.5

-- Stops short of the target root so terrain directly behind it never blocks.
local LINE_OF_SIGHT_MARGIN = 1.5

type CombatContext = {
	outbound: any,
	playerSessions: any,
	roundService: any,
	powerUpService: any,
	regenerationService: any,
	killLog: any,
	eggWarsService: any?,
}

local CombatService = {}
CombatService.__index = CombatService

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
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

local function getHealth(player: Player): number
	local health = player:GetAttribute(Attribute.Health)
	if not isFiniteNumber(health) then
		return HealthConstants.MAX_HEALTH
	end
	return math.clamp(health, HealthConstants.MIN_HEALTH, HealthConstants.MAX_HEALTH)
end

local function getShield(player: Player): number
	local shield = player:GetAttribute(Attribute.Shield)
	if not isFiniteNumber(shield) then
		return 0
	end
	return math.clamp(shield, 0, HealthConstants.MAX_SHIELD)
end

function CombatService.new(context: CombatContext)
	return setmetatable({
		context = context,
		cooldowns = setmetatable({}, { __mode = "k" }) :: { [Player]: { [string]: number } },
		lastAttackers = {} :: { [Player]: { Attacker: Player, Weapon: string?, Time: number } },
		playerAddedConnection = nil :: RBXScriptConnection?,
		characterConnections = {} :: { [Player]: RBXScriptConnection },
		hitboxReconcileGeneration = 0,
		started = false,
	}, CombatService)
end

function CombatService:isInRound(): boolean
	local roundService = self.context.roundService
	return roundService ~= nil and roundService:isInRound()
end

function CombatService:attachHitbox(character: Model, config: HitboxConfig)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return
	end

	local existing = character:FindFirstChild(config.Name)
	if existing ~= nil and existing:IsA("BasePart") then
		local weld = existing:FindFirstChildOfClass("Weld")
		if weld ~= nil and weld.Part0 == root and weld.Part1 == existing then
			existing.Size = config.Size
			existing.Transparency = 1
			existing.CanCollide = false
			existing.CanTouch = false
			existing.CanQuery = true
			existing.Massless = true
			existing.CastShadow = false
			weld.C0 = config.Offset
			return
		end
	end
	if existing ~= nil then
		existing:Destroy()
	end

	local hitbox = Instance.new("Part")
	hitbox.Name = config.Name
	hitbox.Size = config.Size
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.CanTouch = false
	hitbox.CanQuery = true
	hitbox.Massless = true
	hitbox.CastShadow = false
	hitbox.CFrame = root.CFrame * config.Offset
	hitbox.Parent = character

	-- WeldConstraint.C0 is not scriptable; classic Weld is. Hitbox must stay a
	-- direct child of the character (client uses Character:FindFirstChild).
	local weld = Instance.new("Weld")
	weld.Name = "CombatHitboxWeld"
	weld.Part0 = root
	weld.Part1 = hitbox
	weld.C0 = config.Offset
	weld.Parent = hitbox
end

function CombatService:ensureHitboxes(character: Model)
	for _, config in CHARACTER_HITBOXES do
		self:attachHitbox(character, config)
	end
end

function CombatService:bindPlayer(player: Player)
	local existing = self.characterConnections[player]
	if existing ~= nil then
		existing:Disconnect()
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			local root = character:WaitForChild("HumanoidRootPart", 10)
			if root ~= nil and root:IsA("BasePart") and player.Character == character and character.Parent ~= nil then
				self:ensureHitboxes(character)
			end
		end)
	end)
	local character = player.Character
	if character ~= nil then
		self:ensureHitboxes(character)
	end
end

function CombatService:reconcileHitboxes()
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character ~= nil and character.Parent ~= nil then
			self:ensureHitboxes(character)
		end
	end
end

-- Returns (root, meleeDamage, heldItemType) if the attacker may swing now, else nil.
function CombatService:isValidAttacker(player: Player): (BasePart?, number?, string?)
	if not self:isInRound() then
		return nil
	end
	if player:GetAttribute(Attribute.Alive) ~= true or player:GetAttribute(Attribute.Spectating) == true then
		return nil
	end
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return nil
	end
	local heldItemType = session.heldItemType
	if type(heldItemType) ~= "string" then
		return nil
	end
	local itemDefinition = Items[heldItemType]
	if itemDefinition == nil or itemDefinition.Melee == nil or not isFiniteNumber(itemDefinition.Melee.Damage) then
		return nil
	end
	local root = getPlayerRoot(player)
	if root == nil then
		return nil
	end
	return root, math.max(0, itemDefinition.Melee.Damage), heldItemType
end

-- Shared melee gate for player and entity strikes; callers set the cooldown
-- once the hit is confirmed.
function CombatService:canMeleeAttack(player: Player): (BasePart?, number?)
	if self:isOnCooldown(player, DAMAGE_TYPE_MELEE) then
		return nil
	end
	return self:isValidAttacker(player)
end

function CombatService:isOnCooldown(player: Player, key: string): boolean
	local playerCooldowns = self.cooldowns[player]
	if playerCooldowns == nil then
		return false
	end
	local expireTime = playerCooldowns[key]
	return expireTime ~= nil and os.clock() < expireTime
end

-- `replicate` pushes the cooldown to the client via CooldownUpdated (bow UI
-- reads the "Bow" key; other keys are stored but ignored client-side).
function CombatService:setCooldown(player: Player, key: string, duration: number, replicate: boolean?)
	local playerCooldowns = self.cooldowns[player]
	if playerCooldowns == nil then
		playerCooldowns = {}
		self.cooldowns[player] = playerCooldowns
	end
	playerCooldowns[key] = os.clock() + duration
	if replicate then
		self.context.outbound:fire("CooldownUpdated", player, key, duration)
	end
end

function CombatService:clearCooldowns()
	table.clear(self.cooldowns)
end

function CombatService:isValidTarget(attacker: Player, target: Player): boolean
	if target == attacker then
		return false
	end
	if target:GetAttribute(Attribute.Alive) ~= true or target:GetAttribute(Attribute.Spectating) == true then
		return false
	end
	return getPlayerRoot(target) ~= nil
end

-- Team mates can never damage each other, regardless of damage source.
function CombatService:isFriendlyFire(attacker: Player?, target: Player): boolean
	if attacker == nil then
		return false
	end
	local attackerTeam = attacker:GetAttribute(Attribute.TeamId)
	local targetTeam = target:GetAttribute(Attribute.TeamId)
	return type(attackerTeam) == "string" and attackerTeam ~= "" and attackerTeam == targetTeam
end

function CombatService:hasLineOfSight(attackerRoot: BasePart, targetRoot: BasePart): boolean
	local direction = targetRoot.Position - attackerRoot.Position
	local distance = direction.Magnitude
	if distance <= LINE_OF_SIGHT_MARGIN then
		return true
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local attackerCharacter = attackerRoot.Parent
	local targetCharacter = targetRoot.Parent
	local filter = {}
	if attackerCharacter ~= nil then
		table.insert(filter, attackerCharacter)
	end
	if targetCharacter ~= nil and targetCharacter ~= attackerCharacter then
		table.insert(filter, targetCharacter)
	end
	raycastParams.FilterDescendantsInstances = filter
	local rayLength = distance - LINE_OF_SIGHT_MARGIN
	return Workspace:Raycast(attackerRoot.Position, direction.Unit * rayLength, raycastParams) == nil
end

-- Additive per-piece mitigation, matching the client's ArmourController.
function CombatService:getArmourMitigation(player: Player): number
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return 0
	end
	local totalMitigation = 0
	for _, armourType in ARMOUR_TYPES do
		local itemType = session.equippedArmour[armourType]
		if type(itemType) == "string" then
			local itemDefinition = Items[itemType]
			local armour = itemDefinition and itemDefinition.Armour or nil
			if armour ~= nil and isFiniteNumber(armour.DamageMitigation) then
				totalMitigation += armour.DamageMitigation
			end
		end
	end
	return math.clamp(totalMitigation, 0, 1)
end

-- `direction`: attacker -> target root for melee, travel velocity for projectiles.
-- Client scales the impulse by assembly mass itself.
function CombatService:getKnockback(direction: Vector3, strength: number): Vector3
	local horizontalDirection = direction * Vector3.new(1, 0, 1)
	if horizontalDirection.Magnitude < 0.001 then
		horizontalDirection = Vector3.new(1, 0, 0)
	else
		horizontalDirection = horizontalDirection.Unit
	end
	return (horizontalDirection + Vector3.new(0, KNOCKBACK_UPWARD_BIAS, 0)).Unit * strength
end

-- Explosion knockback reuses the projectile impulse; explosions don't add their own.
function CombatService:getProjectileKnockback(direction: Vector3): Vector3
	return self:getKnockback(direction, KNOCKBACK_BASE * PROJECTILE_KNOCKBACK_MULTIPLIER)
end

-- "Bow" keeps the shooter's hit-marker sound and fits the client's
-- DamageDealt type whitelist (Melee/Bow/Fall/Void).
function CombatService:dealExplosionDamage(attacker: Player?, target: Player, damage: number)
	self:dealDamage(attacker, target, DAMAGE_TYPE_BOW, damage, nil)
end

-- Fall damage (block-level comparison per FallDamageService). No attacker or
-- knockback; elimination still credits the last hitter (knock off a cliff).
function CombatService:dealFallDamage(target: Player, damage: number)
	self:dealDamage(nil, target, DAMAGE_TYPE_FALL, damage, nil)
end

-- Single damage pipeline: friendly fire, armour/shield, Health/Shield
-- attributes, DamageDealt indicator, knockback impulse, elimination.
function CombatService:dealDamage(
	attacker: Player?,
	target: Player,
	damageType: string,
	damage: number,
	knockbackDirection: Vector3?
)
	if not isFiniteNumber(damage) then
		return
	end
	if attacker ~= nil and attacker == target then
		return
	end
	if self:isFriendlyFire(attacker, target) then
		return
	end
	local session = self.context.playerSessions:get(target)
	if session == nil or target:GetAttribute(Attribute.Alive) ~= true then
		return
	end
	if getPlayerRoot(target) == nil then
		return
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		damage = eggWarsService:modifyOutgoingDamage(attacker, damage)
	end

	-- Combat tagging: even zero-damage hits (Snowball) tag the attacker so
	-- Fall/Void eliminations credit the last hitter.
	if attacker ~= nil then
		local weapon: string? = nil
		if attacker.Character ~= nil then
			local tool = attacker.Character:FindFirstChildOfClass("Tool")
			if tool ~= nil then
				weapon = tool.Name
			end
		end
		self.lastAttackers[target] = { Attacker = attacker, Weapon = weapon, Time = os.clock() }
	end

	-- Fixed per damage type, so zero-damage weapons (Snowball) still knock.
	local knockbackStrength = if damageType == DAMAGE_TYPE_BOW
		then KNOCKBACK_BASE * PROJECTILE_KNOCKBACK_MULTIPLIER
		else KNOCKBACK_BASE * MELEE_KNOCKBACK_MULTIPLIER

	-- Zero-damage hits only deliver knockback.
	if damage <= 0 then
		if knockbackDirection ~= nil then
			self.context.outbound:fire(
				"DamageImpulse",
				target,
				self:getKnockback(knockbackDirection, knockbackStrength)
			)
		end
		return
	end

	local rawDamage = math.max(1, math.floor(damage + 0.5))
	local damageToHealth = math.max(1, math.floor(rawDamage * (1 - self:getArmourMitigation(target)) + 0.5))

	local shield = getShield(target)
	local absorbedDamage = 0
	if shield > 0 and damageToHealth > 0 then
		-- All-or-nothing: even 1 shield point blocks an entire hit, then the shield is removed.
		absorbedDamage = damageToHealth
		damageToHealth = 0
		target:SetAttribute(Attribute.Shield, 0)
	end
	local shieldHit = absorbedDamage > 0

	local health = getHealth(target)
	local newHealth = math.max(HealthConstants.MIN_HEALTH, health - damageToHealth)
	target:SetAttribute(Attribute.Health, newHealth)

	-- Health damage resets the regeneration clock; shield-absorbed hits don't.
	if damageToHealth > 0 then
		local regenerationService = self.context.regenerationService
		if regenerationService ~= nil then
			regenerationService:onPlayerDamaged(target)
		end
	end

	-- A consumed shield ends the Shield power-up; LifeSteal heals per damaging hit.
	local powerUpService = self.context.powerUpService
	if shieldHit and powerUpService ~= nil then
		powerUpService:onShieldConsumed(target)
	end
	if attacker ~= nil and powerUpService ~= nil and powerUpService:hasPowerUp(attacker, "LifeSteal") then
		attacker:SetAttribute(
			Attribute.Health,
			math.min(HealthConstants.MAX_HEALTH, getHealth(attacker) + LIFESTEAL_HEAL_PER_HIT)
		)
	end
	if eggWarsService ~= nil then
		eggWarsService:onDamageDealt(attacker, damageToHealth)
	end

	-- Client shows health damage, or the shield-absorbed amount if none got through.
	local indicatorDamage = if damageToHealth > 0 then damageToHealth else absorbedDamage
	-- No-op in custom rounds; guarded inside the service.
	local experienceService = self.context.experienceService
	if experienceService ~= nil then
		experienceService:onDamage(attacker, target, indicatorDamage)
	end
	local targetCharacter = target.Character
	if targetCharacter ~= nil then
		self.context.outbound:fireAll(
			"DamageDealt",
			targetCharacter,
			indicatorDamage,
			newHealth,
			damageType,
			shieldHit,
			attacker
		)
	end
	if knockbackDirection ~= nil then
		local knockback = self:getKnockback(knockbackDirection, knockbackStrength)
		self.context.outbound:fire("DamageImpulse", target, knockback)
	end

	if newHealth <= HealthConstants.MIN_HEALTH then
		local killer = if attacker ~= nil and attacker.Parent == Players then attacker else nil
		local roundService = self.context.roundService
		if roundService ~= nil then
			roundService:eliminatePlayer(target, damageType, killer)
		end
		self:ragdoll(targetCharacter)
	end
end

-- Last attacker within the credit window, plus the weapon held at hit time.
-- Consumed by environmental eliminations for killer credit.
function CombatService:getLastAttacker(target: Player): (Player?, string?)
	local tag = self.lastAttackers[target]
	if tag == nil then
		return nil
	end
	if tag.Time + LAST_ATTACK_CREDIT_SECONDS < os.clock() then
		self.lastAttackers[target] = nil
		return nil
	end
	local attacker = tag.Attacker
	if attacker == nil or attacker == target or attacker.Parent ~= Players then
		self.lastAttackers[target] = nil
		return nil
	end
	return attacker, tag.Weapon
end

function CombatService:clearLastAttacker(target: Player)
	self.lastAttackers[target] = nil
end

-- Round boundaries invalidate combat tags.
function CombatService:clearLastAttackers()
	table.clear(self.lastAttackers)
end

function CombatService:meleeStrike(player: Player, target: Player?)
	if target == nil then
		return
	end
	local attackerRoot, damage = self:canMeleeAttack(player)
	if attackerRoot == nil or damage == nil then
		return
	end
	if not self:isValidTarget(player, target) then
		return
	end
	local targetRoot = getPlayerRoot(target)
	if targetRoot == nil then
		return
	end
	if (targetRoot.Position - attackerRoot.Position).Magnitude > MAX_MELEE_RANGE then
		return
	end
	if not self:hasLineOfSight(attackerRoot, targetRoot) then
		return
	end
	self:setCooldown(player, DAMAGE_TYPE_MELEE, HealthConstants.DAMAGE_COOLDOWN)

	self:dealDamage(player, target, DAMAGE_TYPE_MELEE, damage, targetRoot.Position - attackerRoot.Position)
end

-- Non-player combat entities (tagged "entity"/"egg") with a Health attribute.
function CombatService:meleeStrikeEntity(player: Player, entity: Model)
	local attackerRoot, damage = self:canMeleeAttack(player)
	if attackerRoot == nil or damage == nil then
		return
	end
	local isEgg = CollectionService:HasTag(entity, "egg")
	local isCombatEntity = CollectionService:HasTag(entity, "entity") or isEgg
	if not isCombatEntity or entity.Parent == nil then
		return
	end
	local eggWarsService = self.context.eggWarsService
	if isEgg and (eggWarsService == nil or not eggWarsService:canDamageEgg(player, entity)) then
		return
	end
	local entityHealth = entity:GetAttribute(Attribute.Health)
	if not isFiniteNumber(entityHealth) or entityHealth <= 0 then
		return
	end
	local primaryPart = entity.PrimaryPart
	if primaryPart == nil or (primaryPart.Position - attackerRoot.Position).Magnitude > MAX_MELEE_RANGE then
		return
	end
	self:setCooldown(player, DAMAGE_TYPE_MELEE, HealthConstants.DAMAGE_COOLDOWN)

	if eggWarsService ~= nil then
		damage = eggWarsService:modifyOutgoingDamage(player, damage)
	end
	local dealtDamage = math.max(1, math.floor(damage + 0.5))
	local newHealth = math.max(0, entityHealth - dealtDamage)
	entity:SetAttribute(Attribute.Health, newHealth)
	self.context.outbound:fireAll(
		"DamageDealt",
		entity,
		math.min(entityHealth, dealtDamage),
		newHealth,
		DAMAGE_TYPE_MELEE,
		false,
		player
	)
	if isEgg and eggWarsService ~= nil then
		eggWarsService:onEggDamaged(entity)
	end
	if newHealth <= 0 then
		local entityName = entity.Name
		if isEgg and eggWarsService ~= nil then
			local eggTeamId = entity:GetAttribute(Attribute.TeamId)
			if type(eggTeamId) == "string" then
				entityName = eggTeamId
			end
			eggWarsService:onEggEliminated(entity, player)
		else
			self.context.outbound:fireAll("EggEliminated", entityName, player)
		end
		local killLog = self.context.killLog
		if killLog ~= nil then
			local weapon: string? = nil
			if player.Character ~= nil then
				local tool = player.Character:FindFirstChildOfClass("Tool")
				if tool ~= nil then
					weapon = tool.Name
				end
			end
			local roundId: number? = nil
			local gameMode: string? = nil
			local mapName: string? = nil
			local roundService = self.context.roundService
			if roundService ~= nil then
				local roundInfo = roundService:getRoundInfo()
				roundId = roundInfo.RoundId
				gameMode = roundInfo.GameMode
				mapName = roundInfo.MapName
			end
			killLog:record({
				Kind = "Entity",
				Victim = entityName,
				Killer = player.Name,
				KillerUserId = player.UserId,
				DamageType = DAMAGE_TYPE_MELEE,
				Weapon = weapon,
				Position = if primaryPart ~= nil then primaryPart.Position else nil,
				RoundId = roundId,
				GameMode = gameMode,
				MapName = mapName,
			})
		end
		if not isEgg then
			entity:Destroy()
		end
	end
end

function CombatService:dealProjectileHit(shooter: Player, target: Player, damage: number, direction: Vector3)
	self:dealDamage(shooter, target, DAMAGE_TYPE_BOW, damage, direction)
end

function CombatService:ragdoll(character: Model?)
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	-- Disabling the Dead state stops the auto-respawn cycle so the corpse stays.
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid.AutoRotate = false
	humanoid.Health = 0
	pcall(function()
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end)
end

function CombatService.start(self)
	if self.started then
		return
	end
	self.started = true
	self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		self:bindPlayer(player)
	end)
	for _, player in Players:GetPlayers() do
		self:bindPlayer(player)
	end
	self.hitboxReconcileGeneration += 1
	local generation = self.hitboxReconcileGeneration
	task.spawn(function()
		while self.started and self.hitboxReconcileGeneration == generation do
			self:reconcileHitboxes()
			task.wait(HITBOX_RECONCILE_SECONDS)
		end
	end)
end

function CombatService.stop(self)
	self.started = false
	self.hitboxReconcileGeneration += 1
	if self.playerAddedConnection ~= nil then
		self.playerAddedConnection:Disconnect()
		self.playerAddedConnection = nil
	end
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)
	self:clearCooldowns()
	self:clearLastAttackers()
end

return CombatService
