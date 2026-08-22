--!strict

-- Server-authoritative combat. The client picks *who* it swung at (mouse /
-- mobile overlap checks) and fires MeleeStrike(player) or
-- MeleeStrikeEntity(model); this service re-validates everything that matters
-- server-side and applies the result through the client's replicated combat
-- contract:
--
--   * `Health` / `Shield` Player attributes — the health bar and name tags
--     read those attributes, not the Humanoid.
--   * `DamageDealt` broadcast — damage indicators + hit highlight.
--   * `DamageImpulse` — knockback, applied by PlayerVelocityController.
--   * Elimination via CustomGameService, which publishes `PlayerKilled`
--     (kill feed) and `PlayerEliminated` (spectating / round end).
--
-- Character combat hitboxes: the client's melee raycast is a WHITELIST of
-- parts named "Hitbox" (and "ProjectileHitbox" for ranged combat) on other
-- players' characters, plus tagged entities and placed blocks. This service
-- welds a transparent, massless hitbox part onto every character so the
-- client can actually find players to swing at.
--
-- Universal pieces every damage source shares:
--   * `dealDamage` — the single damage pipeline (armour, shield, health,
--     indicator, elimination, kill credit, friendly-fire) used by melee,
--     bows, and any future damage type.
--   * `getKnockback` — the single knockback system. Callers pass a direction
--     (attacker -> target, or a projectile's velocity); strength scales with
--     the raw hit damage so stronger weapons knock harder, and the horizontal
--     flattening, upward bias, and per-damage factors live here, so melee and
--     bows behave identically.
--   * The cooldown registry — one registry for every combat action. Bow
--     cooldowns replicate through CooldownUpdated for the bow UI; extra keys
--     (e.g. "Melee") are ignored by the client.
--
-- Melee validation: attacker is alive, in a running round, and holding a
-- melee item; the strike respects the shared damage cooldown, maximum melee
-- range (the client's loosest desktop bound plus latency slack), line of
-- sight, and friendly-fire rules. Damage is reduced by equipped armour
-- (additive DamageMitigation per piece, matching the client) and absorbed by
-- shield before it reaches health.
--
-- Bow hits are routed through the same damage path by ProjectileService.

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

-- The client accepts strikes up to MAXIMUM_HIT_RANGE_BLOCKS * 3 (its desktop
-- raycast bound); the slack covers network latency between the client-side
-- check and the server.
local MAX_MELEE_RANGE = MeleeConstants.MAXIMUM_HIT_RANGE_BLOCKS * 3 + 1.5
-- The client's PlayerVelocityController scales the DamageImpulse vector by
-- (AssemblyMass / 14.332) before applying it, so the resulting velocity
-- change is `strength / 14.332` studs/s regardless of mass. Knockback is
-- FIXED per damage type instead of scaled by hit damage: the recovered
-- client never ties knockback magnitude to damage (DamageImpulse is a bare
-- Vector3, sword definitions carry only Damage, and no client code derives
-- knockback from damage), so every hit shoves the same. Values tuned by feel
-- with the KnockbackTest harness (kb.shove(80) / kb.bow(80)): melee
-- strength 80 * 8 = 640 (~44.7 studs/s), projectiles 80 * 10 = 800
-- (~55.8 studs/s), upward bias 0.6.
local KNOCKBACK_BASE = 80
local MELEE_KNOCKBACK_MULTIPLIER = 8
local PROJECTILE_KNOCKBACK_MULTIPLIER = 10
local KNOCKBACK_UPWARD_BIAS = 0.6
local ARMOUR_TYPES = { "Helmet", "Chestplate", "Leggings" }

-- How long after a validated hit an environmental elimination (Void/Fall)
-- still credits that attacker as the killer (combat tagging).
local LAST_ATTACK_CREDIT_SECONDS = 10

-- The melee raycast whitelist looks up these exact part names on characters.
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

-- The line-of-sight ray stops this far short of the target root so a wall or
-- floor directly behind the target never blocks the strike.
local LINE_OF_SIGHT_MARGIN = 1.5

type CombatContext = {
	outbound: any,
	playerSessions: any,
	customGameService: any,
	killLog: any,
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
		started = false,
	}, CombatService)
end

function CombatService:isInRound(): boolean
	local customGameService = self.context.customGameService
	local record = customGameService and customGameService.record or nil
	return record ~= nil and record.InGame == true and customGameService.roundState == "InGame"
end

-- Welds one of the client's expected combat hitboxes onto a character.
function CombatService:attachHitbox(character: Model, config: HitboxConfig)
	if character:FindFirstChild(config.Name) ~= nil then
		return
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
	hitbox.Parent = character
	task.spawn(function()
		if character.Parent == nil then
			return
		end
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root == nil or not root:IsA("BasePart") then
			return
		end
		-- Use the classic Weld joint: WeldConstraint.C0/C1 are NOT scriptable
		-- in current Roblox builds, while Weld.C0 is. The part stays a direct
		-- child of the character model because the client's melee raycast
		-- looks it up with Character:FindFirstChild("Hitbox").
		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = hitbox
		weld.C0 = config.Offset
		weld.Parent = hitbox
		-- Self-heal: if anything removes the hitbox while the character is
		-- still alive, put it straight back.
		hitbox.Destroying:Connect(function()
			local player = Players:GetPlayerFromCharacter(character)
			if player ~= nil and player.Character == character then
				task.delay(0.2, function()
					if player.Character == character and character.Parent ~= nil then
						self:attachHitbox(character, config)
					end
				end)
			end
		end)
	end)
end

-- Every character gets the combat hitboxes the client's raycasts expect.
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
		self:ensureHitboxes(character)
	end)
	local character = player.Character
	if character ~= nil then
		self:ensureHitboxes(character)
	end
end

-- Returns (root, meleeDamage, heldItemType) when the attacker is allowed to
-- swing a melee weapon right now, or nil.
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

-- Shared melee gate for player and entity strikes: round state, attacker
-- validity, and the melee cooldown. Callers apply the cooldown themselves
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

-- One cooldown registry for every combat action. When `replicate` is set the
-- client learns about the cooldown through CooldownUpdated (the bow UI reads
-- the "Bow" key; keys the client does not care about are simply stored).
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

-- Anything between the two roots (other than the two characters themselves)
-- blocks the strike, mirroring the client's visibility checks. The ray stops
-- a margin short of the target root so terrain right behind the target never
-- rejects a clean hit.
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

-- Additive per-piece mitigation, matching ArmourController on the client.
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

-- Universal knockback impulse. Every damage source funnels its knockback
-- through here so direction flattening, the upward bias, and constants behave
-- identically. `direction` points from the attacker toward the target (melee:
-- attacker root -> target root; projectiles: travel velocity). `strength`
-- equals rawDamage * the source's per-damage factor; the client scales the
-- impulse by the assembly mass itself.
function CombatService:getKnockback(direction: Vector3, strength: number): Vector3
	local horizontalDirection = direction * Vector3.new(1, 0, 1)
	if horizontalDirection.Magnitude < 0.001 then
		horizontalDirection = Vector3.new(1, 0, 0)
	else
		horizontalDirection = horizontalDirection.Unit
	end
	return (horizontalDirection + Vector3.new(0, KNOCKBACK_UPWARD_BIAS, 0)).Unit * strength
end

-- The fixed impulse every projectile hit delivers. Explosion knockback
-- (Capybara/Dynamite) reuses this so every projectile source shoves the same.
function CombatService:getProjectileKnockback(direction: Vector3): Vector3
	return self:getKnockback(direction, KNOCKBACK_BASE * PROJECTILE_KNOCKBACK_MULTIPLIER)
end

-- Damage without knockback, for sources that apply their own impulse (e.g.
-- explosions shove through getProjectileKnockback). "Bow" keeps the shooter's
-- hit-marker sound and stays inside the client's DamageDealt type whitelist
-- (Melee/Bow/Fall/Void).
function CombatService:dealExplosionDamage(attacker: Player?, target: Player, damage: number)
	self:dealDamage(attacker, target, DAMAGE_TYPE_BOW, damage, nil)
end

-- Shared damage application for every damage source. Applies friendly-fire,
-- armour and shield, updates the replicated Health/Shield attributes,
-- broadcasts the DamageDealt indicator, sends the knockback impulse built by
-- the universal knockback system, and eliminates the target (with kill
-- credit) when health reaches zero.
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

	-- Combat tagging: every validated hit marks the attacker (including
	-- zero-damage knockback like Snowball) so Fall/Void eliminations can
	-- credit the last hitter. CustomGameService.eliminatePlayer consumes
	-- the tag when no direct killer exists.
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

	-- Fixed per damage type; independent of the hit's damage so zero-damage
	-- weapons (e.g. Snowball) still deliver full knockback.
	local knockbackStrength = if damageType == DAMAGE_TYPE_BOW
		then KNOCKBACK_BASE * PROJECTILE_KNOCKBACK_MULTIPLIER
		else KNOCKBACK_BASE * MELEE_KNOCKBACK_MULTIPLIER

	-- Zero-damage hits skip health, shield, and elimination entirely and
	-- only deliver the knockback impulse.
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
		absorbedDamage = math.min(shield, damageToHealth)
		shield -= absorbedDamage
		damageToHealth -= absorbedDamage
		target:SetAttribute(Attribute.Shield, shield)
	end
	local shieldHit = absorbedDamage > 0

	local health = getHealth(target)
	local newHealth = math.max(HealthConstants.MIN_HEALTH, health - damageToHealth)
	target:SetAttribute(Attribute.Health, newHealth)

	-- The number the client shows: health damage when any got through,
	-- otherwise the amount the shield absorbed.
	local indicatorDamage = if damageToHealth > 0 then damageToHealth else absorbedDamage
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
		local customGameService = self.context.customGameService
		if customGameService ~= nil then
			customGameService:eliminatePlayer(target, damageType, killer)
		end
		self:ragdoll(targetCharacter)
	end
end

-- The last player to land a validated hit on `target` inside the credit
-- window, plus the item they were holding at hit time. Environmental
-- eliminations (Void/Fall) consume this for killer credit. Returns
-- (attacker, weapon) or nil; stale/left-game tags are dropped here.
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

-- Round boundaries invalidate every combat tag: a hit from a previous round
-- must never credit an elimination in the next one.
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

-- Strikes at non-player combat entities (tagged "entity" / "egg") that carry
-- a Health attribute. Dying eggs publish EggEliminated for the kill feed.
function CombatService:meleeStrikeEntity(player: Player, entity: Model)
	local attackerRoot, damage = self:canMeleeAttack(player)
	if attackerRoot == nil or damage == nil then
		return
	end
	local isCombatEntity = CollectionService:HasTag(entity, "entity") or CollectionService:HasTag(entity, "egg")
	if not isCombatEntity or entity.Parent == nil then
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

	local newHealth = math.max(0, entityHealth - math.max(1, math.floor(damage + 0.5)))
	entity:SetAttribute(Attribute.Health, newHealth)
	if newHealth <= 0 then
		local entityName = entity.Name
		self.context.outbound:fireAll("EggEliminated", entityName, player)
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
			local customGameService = self.context.customGameService
			if customGameService ~= nil and customGameService.getRoundInfo ~= nil then
				local roundInfo = customGameService:getRoundInfo()
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
		entity:Destroy()
	end
end

-- Bow hit entry point (called by ProjectileService on player collisions).
-- Knockback reuses the same system as melee, driven by the arrow's velocity.
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
	-- Keep the corpse on the island: disabling the Dead state stops the
	-- default auto-respawn cycle while the eliminated player is spectating.
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
end

function CombatService.stop(self)
	self.started = false
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
