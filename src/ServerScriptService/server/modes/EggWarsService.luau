--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local BlockConstants = require(ReplicatedStorage.TS.block["block-constants"]).BlockConstants
local Currencies = require(ReplicatedStorage.TS.game["game-currency"]).Currencies
local EggCharacters = require(ReplicatedStorage.TS["egg-character"]["egg-character"]).EggCharacters
local Shops = require(ReplicatedStorage.TS.game.shop["game-shop"]).Shops
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local RobloxAnimation = require(ReplicatedStorage.TS.asset.roblox["roblox-animation"]).RobloxAnimation
local RobloxSound = require(ReplicatedStorage.TS.asset.roblox["roblox-sound"]).RobloxSound
local EggWarsMap = require(script.Parent.EggWarsMap)
local MathUtil = require(ReplicatedStorage.TS.util["math-util"]).MathUtil

type GeneratorData = EggWarsMap.GeneratorData
type ArenaData = EggWarsMap.ArenaData

type RespawnLoadout = {
	SwordTier: number,
	PickaxeTier: number,
	ArmourTier: number?,
}

type WorldDropOptions = {
	GeneratorDrop: boolean?,
	StackKey: string?,
}

local GAME_MODE = "EggWarsQuads"
local TEAM_IDS = { "Red", "Lime", "Cyan", "Yellow" }
-- Live-server automatic generator-grant radius, in studs.
local GENERATOR_PICKUP_RANGE = 5
local GENERATOR_LOOP_STEP = 0.05
local RESPAWN_DELAY = 6
local BASE_HEAL_RADIUS = 25 * BlockConstants.BLOCK_SIZE
local BASE_HEAL_INTERVAL = 1
local BASE_HEAL_BY_LEVEL = { 2.5, 5, 7.5 }
local TRIUMPH_HEAL_BY_LEVEL = { 30, 40, 50 }
local LIFESTEAL_BY_LEVEL = { 0.04, 0.08, 0.12 }
local LAST_STAND_BONUS_BY_LEVEL = { 0.05, 0.1, 0.15 }
local LOOTING_LUCK_BY_LEVEL = { 0.1, 0.2, 0.3 }
local LAST_STAND_HEALTH_THRESHOLD = 30

-- Live-server measurements supplied for this reconstruction.
local FIXED_GENERATORS = {
	[2] = { ItemType = "IronCoin", Interval = 2.5 },
	[3] = { ItemType = "GoldCoin", Interval = 2 / 3 },
	[4] = { ItemType = "Shard", Interval = 6 },
}
local HOME_BRONZE_INTERVALS = { [0] = 0.75, [1] = 0.6, [2] = 0.6, [3] = 0.5 }
local HOME_IRON_INTERVALS = { [2] = 5, [3] = 3 }

local SWORD_TIERS = { "BronzeSword", "IronSword", "GoldSword", "DiamondSword", "OnyxSword" }
local PICKAXE_TIERS = { "BronzePickaxe", "IronPickaxe", "GoldPickaxe", "DiamondPickaxe", "OnyxPickaxe" }
local ARMOUR_TIERS = {
	{ "BronzeHelmet", "BronzeChestplate", "BronzeLeggings" },
	{ "IronHelmet", "IronChestplate", "IronLeggings" },
	{ "GoldHelmet", "GoldChestplate", "GoldLeggings" },
	{ "DiamondHelmet", "DiamondChestplate", "DiamondLeggings" },
	{ "OnyxHelmet", "OnyxChestplate", "OnyxLeggings" },
}

local EggWarsService = {}
EggWarsService.__index = EggWarsService

local function getPlayerRoot(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") or nil
	return if root ~= nil and root:IsA("BasePart") then root else nil
end

local function getTeamId(player: Player): string?
	local teamId = player:GetAttribute(Attribute.TeamId)
	return if type(teamId) == "string" and teamId ~= "" then teamId else nil
end

local function getHealth(player: Player): number
	local health = player:GetAttribute(Attribute.Health)
	return if type(health) == "number" then health else HealthConstants.MAX_HEALTH
end

local function findInventoryTier(session, tiers: { string }): number?
	local highestTier: number? = nil
	for tier, itemType in tiers do
		for _, item in session.inventory.Contents do
			if item.Type == itemType and item.Quantity > 0 then
				highestTier = tier
				break
			end
		end
	end
	return highestTier
end

local function findArmourTier(session): number?
	local chestplate = session.equippedArmour.Chestplate
	if type(chestplate) ~= "string" then
		return nil
	end
	for tier, armourItems in ARMOUR_TIERS do
		if armourItems[2] == chestplate then
			return tier
		end
	end
	return nil
end

local function isGeneratorShared(itemType: string): boolean
	for _, currency in Currencies do
		if currency.ItemType == itemType then
			return currency.GeneratorShare == true
		end
	end
	return false
end

local function loadAnimation(model: Model, animationId: string, looped: boolean): AnimationTrack?
	local animationController = model:FindFirstChildWhichIsA("AnimationController", true)
	if animationController == nil then
		return nil
	end
	local animator = animationController:FindFirstChildOfClass("Animator")
	if animator == nil then
		animator = Instance.new("Animator")
		animator.Parent = animationController
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()
	if not success or track == nil then
		return nil
	end
	track.Looped = looped
	return track
end

function EggWarsService.new(context)
	return setmetatable({
		context = context,
		active = false,
		generation = 0,
		arenaData = nil :: ArenaData?,
		eggAlive = {} :: { [string]: boolean },
		teamUpgrades = {} :: { [string]: { [string]: number } },
		playerLoadouts = {} :: { [Player]: RespawnLoadout },
		generatorSounds = {} :: { string },
		dropTracks = setmetatable({}, { __mode = "k" }) :: { [Model]: AnimationTrack },
		random = Random.new(),
	}, EggWarsService)
end

function EggWarsService.isActive(self): boolean
	return self.active
end

function EggWarsService.protectsMapGeometry(self): boolean
	return self.arenaData ~= nil
end

function EggWarsService.isGameMode(_: any, gameMode: string?): boolean
	return gameMode == GAME_MODE
end

function EggWarsService.getUpgradeLevel(self, teamId: string?, upgradeId: string): number
	local upgrades = if teamId ~= nil then self.teamUpgrades[teamId] else nil
	return if upgrades ~= nil then upgrades[upgradeId] or 0 else 0
end

function EggWarsService.getPlayerUpgrades(self, player: Player): { [string]: number }
	local teamId = getTeamId(player)
	local upgrades = if teamId ~= nil then self.teamUpgrades[teamId] else nil
	return if upgrades ~= nil then table.clone(upgrades) else {}
end

function EggWarsService.replicatePlayer(self, player: Player)
	self.context.outbound:setValue(player, "TeamUpgrades", self:getPlayerUpgrades(player))
end

function EggWarsService.replicateTeam(self, teamId: string)
	for _, player in Players:GetPlayers() do
		if getTeamId(player) == teamId then
			self:replicatePlayer(player)
		end
	end
end

local function colorToRichTextHex(color: Color3): string
	return ("#%02X%02X%02X"):format(math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
end

function EggWarsService.broadcastTeamAlert(self, teamId: string, text: string, soundId: string?)
	local eggCharacter = EggCharacters[teamId]
	local alertIcon = if eggCharacter ~= nil and eggCharacter.IconId ~= nil then eggCharacter.IconId else ""
	local alertColor = if eggCharacter ~= nil and eggCharacter.Color ~= nil
		then eggCharacter.Color
		else Color3.fromRGB(54, 226, 112)
	local soundName = if soundId ~= nil then HttpService:GenerateGUID(false) else nil
	for _, teammate in Players:GetPlayers() do
		if getTeamId(teammate) == teamId then
			if soundId ~= nil and soundName ~= nil then
				self.context.outbound:fire("SoundPlayed", teammate, soundName, soundId, nil, { Volume = 0.9 })
			end
			self.context.outbound:fire("Alert", teammate, alertIcon, text, alertColor, 4)
		end
	end
end

function EggWarsService.applyGameTeams(self, gameTeams: { [string]: any })
	if self.arenaData == nil then
		return
	end
	for teamId, team in gameTeams do
		team.CanRespawn = self.eggAlive[teamId] == true
	end
end

function EggWarsService.isEggAlive(self, teamId: string?): boolean
	return self.active and teamId ~= nil and self.eggAlive[teamId] == true
end

function EggWarsService.canRespawn(self, player: Player): boolean
	return self:isEggAlive(getTeamId(player))
end

function EggWarsService.getRespawnDelay(_: any): number
	return RESPAWN_DELAY
end

function EggWarsService.getSpawnInventory(
	self,
	player: Player
): ({ { Type: string, Quantity: number } }, string, { string })
	local loadout = self.playerLoadouts[player]
	if loadout == nil then
		loadout = {
			SwordTier = 1,
			PickaxeTier = 1,
			ArmourTier = 1,
		}
		self.playerLoadouts[player] = loadout
	end
	local sword = SWORD_TIERS[loadout.SwordTier] or SWORD_TIERS[1]
	local pickaxe = PICKAXE_TIERS[loadout.PickaxeTier] or PICKAXE_TIERS[1]
	local items = {
		{ Type = sword, Quantity = 1 },
		{ Type = pickaxe, Quantity = 1 },
	}
	local armourItems = {}
	if loadout.ArmourTier ~= nil then
		for _, itemType in ARMOUR_TIERS[loadout.ArmourTier] or {} do
			table.insert(items, { Type = itemType, Quantity = 1 })
			table.insert(armourItems, itemType)
		end
	end
	return items, sword, armourItems
end

function EggWarsService.equipSpawnArmour(self, player: Player, armourItems: { string })
	for _, itemType in armourItems do
		self.context.inventoryService:equipArmour(player, itemType)
	end
end

function EggWarsService.captureDowngradedLoadout(self, player: Player)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local swordTier = findInventoryTier(session, SWORD_TIERS) or 1
	local pickaxeTier = findInventoryTier(session, PICKAXE_TIERS) or 1
	local armourTier = findArmourTier(session)
	self.playerLoadouts[player] = {
		SwordTier = math.max(1, swordTier - 1),
		PickaxeTier = math.max(1, pickaxeTier - 1),
		ArmourTier = if armourTier ~= nil then math.max(1, armourTier - 1) else nil,
	}
end

function EggWarsService.healPlayer(_: any, player: Player, amount: number)
	if amount <= 0 or player:GetAttribute(Attribute.Alive) ~= true then
		return
	end
	player:SetAttribute(Attribute.Health, math.min(HealthConstants.MAX_HEALTH, getHealth(player) + amount))
end

function EggWarsService.onPlayerDefeated(self, player: Player, killer: Player?)
	if not self.active then
		return
	end
	self:captureDowngradedLoadout(player)
	if killer == nil or killer == player or killer.Parent ~= Players then
		return
	end

	-- Egg Wars awards every carried currency directly to the killer. Weapons,
	-- blocks, armour, and utility items are discarded by the normal death clear.
	for _, currency in Currencies do
		local quantity = self.context.inventoryService:getItemQuantity(player, currency.ItemType)
		if quantity > 0 then
			self.context.inventoryService:changeItem(killer, currency.ItemType, quantity)
		end
	end

	local triumphLevel = self:getUpgradeLevel(getTeamId(killer), "Triumph")
	local triumphHeal = TRIUMPH_HEAL_BY_LEVEL[triumphLevel]
	if triumphHeal ~= nil then
		self:healPlayer(killer, triumphHeal)
	end
end

function EggWarsService.modifyOutgoingDamage(self, attacker: Player?, damage: number): number
	if not self.active or attacker == nil or damage <= 0 or getHealth(attacker) >= LAST_STAND_HEALTH_THRESHOLD then
		return damage
	end
	local level = self:getUpgradeLevel(getTeamId(attacker), "LastStand")
	local bonus = LAST_STAND_BONUS_BY_LEVEL[level]
	return if bonus ~= nil then damage * (1 + bonus) else damage
end

function EggWarsService.onDamageDealt(self, attacker: Player?, healthDamage: number)
	if not self.active or attacker == nil or healthDamage <= 0 then
		return
	end
	local level = self:getUpgradeLevel(getTeamId(attacker), "Lifesteal")
	local fraction = LIFESTEAL_BY_LEVEL[level]
	if fraction ~= nil then
		self:healPlayer(attacker, healthDamage * fraction)
	end
end

function EggWarsService.getGeneratorLootMultiplier(self, player: Player): number
	if not self.active then
		return 1
	end
	local level = self:getUpgradeLevel(getTeamId(player), "LootingLuck")
	local chance = LOOTING_LUCK_BY_LEVEL[level]
	return if chance ~= nil and self.random:NextNumber() < chance then 2 else 1
end

function EggWarsService.canDamageEgg(self, player: Player, egg: Model): boolean
	if not self.active or egg.Parent == nil then
		return false
	end
	local eggTeamId = egg:GetAttribute(Attribute.TeamId)
	return type(eggTeamId) == "string" and self.eggAlive[eggTeamId] == true and eggTeamId ~= getTeamId(player)
end

function EggWarsService.playPositionalSound(self, soundId: string, position: Vector3, volume: number?)
	self.context.outbound:fireAll(
		"SoundPlayed",
		HttpService:GenerateGUID(false),
		soundId,
		position,
		{ Volume = volume or 1 }
	)
end

function EggWarsService.onEggDamaged(self, egg: Model)
	if not self.active then
		return
	end
	self:playPositionalSound(RobloxSound.Egg.EGG_HIT, egg:GetPivot().Position, 0.85)
	local hitTrack = loadAnimation(egg, RobloxAnimation.EGG_HIT_ONE, false)
	if hitTrack ~= nil then
		hitTrack:Play()
	end
end

function EggWarsService.onEggEliminated(self, egg: Model, player: Player): boolean
	local teamId = egg:GetAttribute(Attribute.TeamId)
	if not self.active or type(teamId) ~= "string" or self.eggAlive[teamId] ~= true then
		return false
	end
	self.eggAlive[teamId] = false
	self.context.outbound:fireAll("EggEliminated", teamId, player)
	local eggCharacter = EggCharacters[teamId]
	local teamColor = if eggCharacter ~= nil and eggCharacter.Color ~= nil
		then eggCharacter.Color
		else Color3.fromRGB(54, 226, 112)
	local alertText = ('<font color="%s">Your team\'s</font> egg was destroyed!'):format(colorToRichTextHex(teamColor))
	self:broadcastTeamAlert(teamId, alertText)
	self:playPositionalSound(RobloxSound.Egg.EGG_DEATH, egg:GetPivot().Position, 1)
	local deathTrack = loadAnimation(egg, RobloxAnimation.EGG_DEATH, false)
	if deathTrack ~= nil then
		deathTrack:Play()
	end
	self.context.roundService:replicateAll()
	-- Keep the defeated egg model until round cleanup. EggComponent owns the
	-- island keypoint and changes it to IconDeadId on EggEliminated; destroying
	-- the model would also destroy that component and remove the dead marker.
	return true
end

function EggWarsService.purchaseTeamUpgrade(self, player: Player, shopType: string, itemIndex: number): boolean
	if
		not self.active
		or not self.context.roundService:isInRound()
		or player:GetAttribute(Attribute.Alive) ~= true
		or shopType ~= "Merchant"
	then
		return false
	end
	local teamId = getTeamId(player)
	local shop = Shops[shopType]
	local upgrade = shop and shop.TeamUpgrades[itemIndex + 1] or nil
	if teamId == nil or upgrade == nil or type(upgrade.Id) ~= "string" or type(upgrade.Tiers) ~= "table" then
		return false
	end
	local currentLevel = self:getUpgradeLevel(teamId, upgrade.Id)
	local nextTier = upgrade.Tiers[currentLevel + 1]
	if nextTier == nil then
		self.context.inventoryService:notify(player, "This team upgrade is already maxed.")
		return false
	end
	local currency = Currencies[nextTier.CurrencyType]
	if currency == nil or self.context.inventoryService:getItemQuantity(player, currency.ItemType) < nextTier.Price then
		self.context.inventoryService:notify(player, "You do not have enough currency.")
		return false
	end
	if not self.context.inventoryService:changeItem(player, currency.ItemType, -nextTier.Price) then
		return false
	end
	self.teamUpgrades[teamId][upgrade.Id] = currentLevel + 1
	self:replicateTeam(teamId)
	local tierName = MathUtil.toRomanNumeral(currentLevel + 1)
	local alertText = ('<font color="#FC03E3">%s</font> has been upgraded to <font color="#FC03E3">Tier %s</font>'):format(
		upgrade.Name,
		tierName
	)
	self:broadcastTeamAlert(teamId, alertText, RobloxSound.EggUi.TEAM_UPGRADE)
	return true
end

function EggWarsService.getDropPosition(_: any, generator: GeneratorData): Vector3?
	local primaryPart = generator.Model.PrimaryPart
	return if primaryPart ~= nil then primaryPart.Position else nil
end

function EggWarsService.getNearbyPlayers(_: any, position: Vector3): { Player }
	local nearby = {} :: { { Player: Player, Distance: number } }
	for _, player in Players:GetPlayers() do
		local root = getPlayerRoot(player)
		if
			root ~= nil
			and player:GetAttribute(Attribute.Alive) == true
			and player:GetAttribute(Attribute.Spectating) ~= true
			and (root.Position - position).Magnitude <= GENERATOR_PICKUP_RANGE
		then
			table.insert(nearby, {
				Player = player,
				Distance = (root.Position - position).Magnitude,
			})
		end
	end
	table.sort(nearby, function(left, right)
		return if left.Distance == right.Distance
			then left.Player.UserId < right.Player.UserId
			else left.Distance < right.Distance
	end)
	local players = {}
	for _, entry in nearby do
		table.insert(players, entry.Player)
	end
	return players
end

function EggWarsService.emitGeneratorDrop(self, generator: GeneratorData, itemType: string)
	if not self.active or generator.Model.Parent == nil then
		return
	end
	local dropPosition = self:getDropPosition(generator)
	if dropPosition == nil then
		return
	end
	-- Both automatic grants and the physical fallback originate at the machine
	-- root. Adding an arbitrary height here makes the coin visibly appear above
	-- the generator and can leave it inaccessible on uneven map geometry.
	local nearbyPlayers = self:getNearbyPlayers(generator.Model:GetPivot().Position)
	local generatorShare = isGeneratorShared(itemType)
	local granted = false
	if generatorShare then
		for _, player in nearbyPlayers do
			local quantity = self:getGeneratorLootMultiplier(player)
			if self.context.inventoryService:changeItem(player, itemType, quantity) then
				self.context.inventoryService:playPickupSound(player)
				granted = true
			end
		end
	else
		local nearestPlayer = nearbyPlayers[1]
		if nearestPlayer ~= nil then
			local quantity = self:getGeneratorLootMultiplier(nearestPlayer)
			granted = self.context.inventoryService:changeItem(nearestPlayer, itemType, quantity)
			if granted then
				self.context.inventoryService:playPickupSound(nearestPlayer)
			end
		end
	end

	if not granted then
		local options: WorldDropOptions = {
			GeneratorDrop = true,
			StackKey = generator.Id .. ":" .. itemType,
		}
		self.context.inventoryService:createWorldDrop(itemType, 1, CFrame.new(dropPosition), options)
	end
	self:playPositionalSound(RobloxSound.Dropper.DROPPER_DROP, generator.Model:GetPivot().Position, 0.55)
	local track = self.dropTracks[generator.Model]
	if track ~= nil then
		track:Play()
	end
end

function EggWarsService.runGeneratorLoop(
	self,
	generator: GeneratorData,
	itemType: string,
	resolveInterval: () -> number?
)
	local generation = self.generation
	task.spawn(function()
		local nextDropAt: number? = nil
		while self.active and self.generation == generation and generator.Model.Parent ~= nil do
			local interval = resolveInterval()
			if interval == nil then
				nextDropAt = nil
				task.wait(0.1)
			else
				local now = os.clock()
				if nextDropAt == nil then
					nextDropAt = now + interval
				elseif now >= nextDropAt then
					self:emitGeneratorDrop(generator, itemType)
					nextDropAt = now + interval
				end
				task.wait(GENERATOR_LOOP_STEP)
			end
		end
	end)
end

function EggWarsService.startGenerator(self, generator: GeneratorData)
	local primaryPart = generator.Model.PrimaryPart
	if primaryPart == nil then
		return
	end
	local soundName = "EggWarsGenerator_" .. generator.Id
	table.insert(self.generatorSounds, soundName)
	self.context.outbound:fireAll(
		"SoundPlayed",
		soundName,
		RobloxSound.Dropper.DROPPER_IDLE,
		primaryPart.Position,
		{ Looped = true, Volume = 0.3, RollOffMaxDistance = 70 }
	)
	local dropTrack = loadAnimation(generator.Model, RobloxAnimation.DROPPER_DROP, false)
	if dropTrack ~= nil then
		self.dropTracks[generator.Model] = dropTrack
	end

	if generator.Tier == 1 then
		self:runGeneratorLoop(generator, "BronzeCoin", function()
			local level = self:getUpgradeLevel(generator.TeamId, "Generator")
			return HOME_BRONZE_INTERVALS[level]
		end)
		self:runGeneratorLoop(generator, "IronCoin", function()
			local level = self:getUpgradeLevel(generator.TeamId, "Generator")
			return HOME_IRON_INTERVALS[level]
		end)
	else
		local definition = FIXED_GENERATORS[generator.Tier]
		if definition ~= nil then
			self:runGeneratorLoop(generator, definition.ItemType, function()
				return definition.Interval
			end)
		end
	end
end

function EggWarsService.startHealingLoop(self)
	local generation = self.generation
	task.spawn(function()
		while self.active and self.generation == generation do
			task.wait(BASE_HEAL_INTERVAL)
			if self.context.roundService:isInRound() then
				local arenaData = self.arenaData
				if arenaData ~= nil then
					for _, player in Players:GetPlayers() do
						local teamId = getTeamId(player)
						local level = self:getUpgradeLevel(teamId, "BaseHeal")
						local heal = BASE_HEAL_BY_LEVEL[level]
						local basePosition = if teamId ~= nil then arenaData.EggPositions[teamId] else nil
						local root = getPlayerRoot(player)
						if
							heal ~= nil
							and basePosition ~= nil
							and root ~= nil
							and (root.Position - basePosition).Magnitude <= BASE_HEAL_RADIUS
						then
							self:healPlayer(player, heal)
						end
					end
				end
			end
		end
	end)
end

-- Called exactly when the lobby countdown ends and the cage phase begins.
-- This is intentionally later than MapService.load(), matching the live map:
-- no WorldData-generated objects exist while players wait in the pre-game lobby.
function EggWarsService.prepareRound(self, gameMode: string, map: Model): boolean
	if gameMode ~= GAME_MODE then
		return true
	end
	self:clearRound()
	local arenaData = EggWarsMap.populate(map)
	if arenaData == nil then
		warn(("[EggWarsService] failed to populate %s"):format(map.Name))
		return false
	end
	self.active = true
	self.generation += 1
	self.arenaData = arenaData
	for _, teamId in TEAM_IDS do
		self.eggAlive[teamId] = true
		self.teamUpgrades[teamId] = {}
	end
	for _, generator in arenaData.Generators do
		self:startGenerator(generator)
	end
	self:startHealingLoop()
	return true
end

function EggWarsService.clearRound(self)
	self.active = false
	self.generation += 1
	for _, soundName in self.generatorSounds do
		self.context.outbound:fireAll("SoundStopped", soundName)
	end
	table.clear(self.generatorSounds)
	table.clear(self.dropTracks)
	table.clear(self.eggAlive)
	table.clear(self.teamUpgrades)
	table.clear(self.playerLoadouts)
	self.arenaData = nil
	local dropFolder = Workspace:FindFirstChild("ItemDrops")
	if dropFolder ~= nil then
		for _, drop in dropFolder:GetChildren() do
			if drop:GetAttribute("GeneratorDrop") == true then
				drop:Destroy()
			end
		end
	end
	EggWarsMap.clearExternalArtifacts(Workspace:FindFirstChild("BlockContainer"))
end

function EggWarsService.endRound(self)
	if not self.active then
		return
	end
	self.active = false
	self.generation += 1
	for _, soundName in self.generatorSounds do
		self.context.outbound:fireAll("SoundStopped", soundName)
	end
	table.clear(self.generatorSounds)
end

function EggWarsService.onPlayerRemoving(self, player: Player)
	self.playerLoadouts[player] = nil
end

function EggWarsService.stop(self)
	self:clearRound()
end

return EggWarsService
