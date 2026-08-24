--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ItemModule = require(ReplicatedStorage.TS.item.item)
local Items = ItemModule.Items
local Currencies = require(ReplicatedStorage.TS.game["game-currency"]).Currencies
local Shops = require(ReplicatedStorage.TS.game.shop["game-shop"]).Shops
local RigUtil = require(ReplicatedStorage.TS.util["rig-util"]).RigUtil
local ItemDropUtil = require(ReplicatedStorage.TS.item["item-drop-util"]).ItemDropUtil
local RobloxSound = require(ReplicatedStorage.TS.asset.roblox["roblox-sound"]).RobloxSound

-- The original game plays ONE chest animation: a single swing to the
-- fully-open pose (~110 degrees), then the chest never closes. That is the
-- PRODUCTION CHEST_OPEN asset; the recovered "studio" CHEST_OPEN variant only
-- swings the lid partway (~45 degrees), so the server always uses the
-- production id (a user-owned re-upload, so it also works in Studio).
local CHEST_OPEN_ANIMATION_ID = "rbxassetid://140119704385533"

type InventoryItem = {
	Slot: number,
	Type: string,
	Quantity: number,
}

type Inventory = {
	Size: number,
	Contents: { [number]: InventoryItem },
}

type ReacquiredUpgrade = {
	LowerTierItems: { InventoryItem },
}

type ItemDefinition = {
	Name: string,
	ItemGroup: string?,
	Melee: { Damage: number }?,
	Pickaxe: { TimeMultiplier: number }?,
	Armour: { ArmourType: string, DamageMitigation: number }?,
	Block: any?,
	Currency: any?,
	Rewrite: { Type: string }?,
}

type ChestState = {
	Size: number,
	Contents: { [number]: InventoryItem },
	-- Set once the opening animation has played; chests stay open forever.
	Opened: boolean?,
}

export type WorldDropOptions = {
	GeneratorDrop: boolean?,
	InitialVelocity: Vector3?,
	OwnerUserId: number?,
	PickupDelay: number?,
	StackKey: string?,
}

local CHEST_SIZE = 18
local HOTBAR_SIZE = 8
local MAX_ITEM_QUANTITY = 1_000_000
local MAX_PREDICTION_ID_LENGTH = 128
local PREDICTION_TIMEOUT = 3
local DROP_PICKUP_DELAY = 1
-- Live-server measurement supplied for this reconstruction.
local DROP_PICKUP_RANGE = 5
local DROP_PICKUP_SCAN_INTERVAL = 0.1
local CHEST_INTERACTION_RANGE = 14

local CURRENCY_TYPE_BY_ITEM: { [string]: string } = {}
for currencyType, currency in Currencies do
	CURRENCY_TYPE_BY_ITEM[currency.ItemType] = currencyType
end

local InventoryService = {}
InventoryService.__index = InventoryService

local function cloneInventory(inventory: Inventory): Inventory
	local contents: { [number]: InventoryItem } = {}
	for slot, item in inventory.Contents do
		contents[slot] = {
			Slot = item.Slot,
			Type = item.Type,
			Quantity = item.Quantity,
		}
	end
	return {
		Size = inventory.Size,
		Contents = contents,
	}
end

local function findItem(inventory: Inventory, itemType: string): InventoryItem?
	for _, item in inventory.Contents do
		if item.Type == itemType then
			return item
		end
	end
	return nil
end

local function findEmptySlot(inventory: Inventory, fromEnd: boolean?): number?
	if fromEnd then
		for slot = inventory.Size - 1, 0, -1 do
			if inventory.Contents[slot] == nil then
				return slot
			end
		end
	else
		for slot = 0, inventory.Size - 1 do
			if inventory.Contents[slot] == nil then
				return slot
			end
		end
	end
	return nil
end

local function findEmptySlotInRange(
	inventory: Inventory,
	firstSlot: number,
	lastSlot: number,
	fromEnd: boolean?
): number?
	if fromEnd then
		for slot = lastSlot, firstSlot, -1 do
			if inventory.Contents[slot] == nil then
				return slot
			end
		end
	else
		for slot = firstSlot, lastSlot do
			if inventory.Contents[slot] == nil then
				return slot
			end
		end
	end
	return nil
end

local function updateInventoryBasic(
	inventory: Inventory,
	itemType: string,
	quantity: number,
	fromEnd: boolean?
): (Inventory?, number?)
	local updatedInventory = cloneInventory(inventory)
	local existingItem = findItem(updatedInventory, itemType)
	if existingItem == nil then
		if quantity <= 0 then
			return nil, nil
		end
		local emptySlot = findEmptySlot(updatedInventory, fromEnd)
		if emptySlot == nil then
			return nil, nil
		end
		existingItem = {
			Slot = emptySlot,
			Type = itemType,
			Quantity = 0,
		}
	end

	local newQuantity = existingItem.Quantity + quantity
	if newQuantity < 0 or newQuantity > MAX_ITEM_QUANTITY then
		return nil, nil
	end
	if newQuantity == 0 then
		updatedInventory.Contents[existingItem.Slot] = nil
	else
		updatedInventory.Contents[existingItem.Slot] = {
			Slot = existingItem.Slot,
			Type = itemType,
			Quantity = newQuantity,
		}
	end
	return updatedInventory, existingItem.Slot
end

local function updateInventoryPreferMain(
	inventory: Inventory,
	itemType: string,
	quantity: number
): (Inventory?, number?)
	local existingItem = findItem(inventory, itemType)
	if existingItem ~= nil then
		return updateInventoryBasic(inventory, itemType, quantity)
	end
	if quantity <= 0 or quantity > MAX_ITEM_QUANTITY then
		return nil, nil
	end

	local mainInventoryStart = math.min(HOTBAR_SIZE, inventory.Size)
	local emptySlot = findEmptySlotInRange(inventory, mainInventoryStart, inventory.Size - 1, true)
	if emptySlot == nil and mainInventoryStart > 0 then
		emptySlot = findEmptySlotInRange(inventory, 0, mainInventoryStart - 1, true)
	end
	if emptySlot == nil then
		return nil, nil
	end

	local updatedInventory = cloneInventory(inventory)
	updatedInventory.Contents[emptySlot] = {
		Slot = emptySlot,
		Type = itemType,
		Quantity = quantity,
	}
	return updatedInventory, emptySlot
end

local function findBestItem(inventory: Inventory, score: (itemDefinition: ItemDefinition) -> number?): InventoryItem?
	local bestItem: InventoryItem? = nil
	local bestScore: number? = nil
	for _, item in inventory.Contents do
		local itemDefinition: ItemDefinition? = Items[item.Type]
		local itemScore = itemDefinition and score(itemDefinition) or nil
		if itemScore ~= nil and (bestScore == nil or itemScore > bestScore) then
			bestItem = item
			bestScore = itemScore
		end
	end
	return bestItem
end

local function updatePlayerInventory(
	inventory: Inventory,
	itemType: string,
	quantity: number,
	preferOpenHotbarForUpgrade: boolean?
): (Inventory?, number?, ReacquiredUpgrade?)
	local itemDefinition: ItemDefinition? = Items[itemType]
	if itemDefinition == nil or quantity == 0 or quantity % 1 ~= 0 then
		return nil, nil
	end
	if quantity < 0 or findItem(inventory, itemType) ~= nil then
		return updateInventoryBasic(inventory, itemType, quantity)
	end

	local function replaceItem(
		currentItem: InventoryItem?,
		score: (itemDefinition: ItemDefinition) -> number?
	): (Inventory?, number?, ReacquiredUpgrade?)
		if currentItem == nil or currentItem.Type == itemType then
			return updateInventoryBasic(inventory, itemType, quantity)
		end
		local currentDefinition: ItemDefinition? = Items[currentItem.Type]
		local currentScore = currentDefinition and score(currentDefinition) or nil
		local newScore = score(itemDefinition)
		if currentScore ~= nil and newScore ~= nil and newScore <= currentScore then
			return updateInventoryPreferMain(inventory, itemType, quantity)
		end
		-- A previously displaced lower-tier tool may be sitting in the main
		-- inventory after its upgrade was deposited into a chest. If the
		-- hotbar now has room, put the reacquired upgrade there instead of
		-- replacing the lower-tier tool in its main-inventory slot.
		if preferOpenHotbarForUpgrade and currentItem.Slot >= HOTBAR_SIZE then
			local emptyHotbarSlot = findEmptySlotInRange(inventory, 0, math.min(HOTBAR_SIZE, inventory.Size) - 1)
			if emptyHotbarSlot ~= nil then
				local lowerTierItems: { InventoryItem } = {}
				for _, existingItem in inventory.Contents do
					local existingDefinition: ItemDefinition? = Items[existingItem.Type]
					if existingDefinition ~= nil and score(existingDefinition) ~= nil then
						table.insert(lowerTierItems, {
							Slot = existingItem.Slot,
							Type = existingItem.Type,
							Quantity = existingItem.Quantity,
						})
					end
				end
				table.sort(lowerTierItems, function(left, right)
					return left.Slot > right.Slot
				end)
				local updatedInventory, receivedSlot = updateInventoryBasic(inventory, itemType, quantity)
				return updatedInventory, receivedSlot, { LowerTierItems = lowerTierItems }
			end
		end

		local replacedInventory = cloneInventory(inventory)
		replacedInventory.Contents[currentItem.Slot] = {
			Slot = currentItem.Slot,
			Type = itemType,
			Quantity = quantity,
		}
		local movedInventory = updateInventoryPreferMain(replacedInventory, currentItem.Type, currentItem.Quantity)
		if movedInventory == nil then
			return nil, nil
		end
		return movedInventory, currentItem.Slot
	end

	if itemDefinition.Melee ~= nil then
		local function meleeScore(definition: ItemDefinition): number?
			return definition.Melee and definition.Melee.Damage or nil
		end
		return replaceItem(findBestItem(inventory, meleeScore), meleeScore)
	elseif itemDefinition.Pickaxe ~= nil then
		local function pickaxeScore(definition: ItemDefinition): number?
			return definition.Pickaxe and (1 - definition.Pickaxe.TimeMultiplier) or nil
		end
		return replaceItem(findBestItem(inventory, pickaxeScore), pickaxeScore)
	elseif itemDefinition.Armour ~= nil then
		return updateInventoryPreferMain(inventory, itemType, quantity)
	end
	return updateInventoryBasic(inventory, itemType, quantity)
end

local function addArmourFromChest(
	inventory: Inventory,
	equippedArmour: { [string]: string },
	itemType: string,
	quantity: number
): (Inventory?, string?, string?)
	local itemDefinition: ItemDefinition? = Items[itemType]
	local armour = itemDefinition and itemDefinition.Armour or nil
	if armour == nil then
		return nil, nil, nil
	end

	local armourType = armour.ArmourType
	local currentItemType = equippedArmour[armourType]
	local currentDefinition: ItemDefinition? = if currentItemType then Items[currentItemType] else nil
	local currentArmour = currentDefinition and currentDefinition.Armour or nil
	local shouldEquip = currentArmour == nil or armour.DamageMitigation > currentArmour.DamageMitigation
	if not shouldEquip then
		local storedInventory = updateInventoryPreferMain(inventory, itemType, quantity)
		return storedInventory, nil, nil
	end

	local updatedInventory = cloneInventory(inventory)
	if currentItemType ~= nil then
		local storedInventory = updateInventoryPreferMain(updatedInventory, currentItemType, 1)
		if storedInventory == nil then
			return nil, nil, nil
		end
		updatedInventory = storedInventory
	end
	if quantity > 1 then
		local storedInventory = updateInventoryPreferMain(updatedInventory, itemType, quantity - 1)
		if storedInventory == nil then
			return nil, nil, nil
		end
		updatedInventory = storedInventory
	end
	return updatedInventory, armourType, itemType
end

local function serializeContents(contents: { [number]: InventoryItem }): { InventoryItem }
	local items = {}
	for _, item in contents do
		table.insert(items, {
			Slot = item.Slot,
			Type = item.Type,
			Quantity = item.Quantity,
		})
	end
	table.sort(items, function(left, right)
		return left.Slot < right.Slot
	end)
	return items
end

local function getPlayerRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function getDropFolder(): Folder
	local dropFolder = Workspace:FindFirstChild("ItemDrops")
	if dropFolder ~= nil and dropFolder:IsA("Folder") then
		return dropFolder
	end
	if dropFolder ~= nil then
		dropFolder:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "ItemDrops"
	folder.Parent = Workspace
	return folder
end

function InventoryService.new(context)
	return setmetatable({
		context = context,
		chests = setmetatable({}, { __mode = "k" }) :: { [Model]: ChestState },
		connections = {} :: { RBXScriptConnection },
		characterConnections = {} :: { [Player]: RBXScriptConnection },
		dropConnections = {} :: { [Model]: RBXScriptConnection },
		dropPickupScanElapsed = 0,
		started = false,
	}, InventoryService)
end

-- Rejected inventory/shop actions are silent. The original server does not
-- use the client's global Alert surface for these validation failures.
function InventoryService.notify(_: any, _: Player, _: string) end

function InventoryService.playPickupSound(self, player: Player)
	self.context.outbound:fire(
		"SoundPlayed",
		player,
		HttpService:GenerateGUID(false),
		RobloxSound.Inventory.PICKUP_ITEM,
		nil,
		{ Volume = 0.8 }
	)
end

function InventoryService.playShopSound(self, player: Player, soundId: string)
	self.context.outbound:fire("SoundPlayed", player, HttpService:GenerateGUID(false), soundId, nil, { Volume = 0.9 })
end

function InventoryService.refreshCurrency(self, player: Player, shouldReplicate: boolean?)
	local session = self.context.playerSessions:require(player)
	for currencyType in Currencies do
		if type(session.gameCurrency.Quantities[currencyType]) ~= "number" then
			session.gameCurrency.Quantities[currencyType] = 0
		end
	end
	if shouldReplicate then
		self.context.outbound:sendGameCurrency(player, session.gameCurrency)
	end
end

-- Slot rearrangements are client-local and have no client-to-server remote.
-- After bootstrap, replicate quantity deltas so the recovered client applies
-- them to its current layout (and refreshes the active item on an upgrade).
function InventoryService.replicateItemChange(
	self,
	player: Player,
	itemType: string,
	quantity: number,
	predictionId: string?
)
	if quantity == 0 then
		return
	end
	if CURRENCY_TYPE_BY_ITEM[itemType] ~= nil then
		self:refreshCurrency(player, true)
		return
	end
	self.context.outbound:fire("InventoryUpdated", player, itemType, quantity, predictionId)
end

function InventoryService.getItemQuantity(self, player: Player, itemType: string): number
	local session = self.context.playerSessions:require(player)
	local currencyType = CURRENCY_TYPE_BY_ITEM[itemType]
	if currencyType ~= nil then
		return session.gameCurrency.Quantities[currencyType] or 0
	end
	local item = findItem(session.inventory, itemType)
	return if item then item.Quantity else 0
end

function InventoryService.changeItem(
	self,
	player: Player,
	itemType: string,
	quantity: number,
	predictionId: string?
): boolean
	if Items[itemType] == nil or quantity == 0 or quantity % 1 ~= 0 or math.abs(quantity) > MAX_ITEM_QUANTITY then
		return false
	end
	local session = self.context.playerSessions:require(player)
	local currencyType = CURRENCY_TYPE_BY_ITEM[itemType]
	if currencyType ~= nil then
		local currentQuantity = session.gameCurrency.Quantities[currencyType] or 0
		local newQuantity = currentQuantity + quantity
		if newQuantity < 0 or newQuantity > MAX_ITEM_QUANTITY then
			return false
		end
		session.gameCurrency.Quantities[currencyType] = newQuantity
		self:replicateItemChange(player, itemType, quantity, predictionId)
		return true
	end
	if quantity < 0 and self:getItemQuantity(player, itemType) < -quantity then
		return false
	end
	local updatedInventory = updatePlayerInventory(session.inventory, itemType, quantity)
	if updatedInventory == nil then
		return false
	end
	session.inventory = updatedInventory
	self:replicateItemChange(player, itemType, quantity, predictionId)
	if quantity < 0 and session.heldItemType == itemType and self:getItemQuantity(player, itemType) == 0 then
		self:setHeldItem(player, nil)
	end
	return true
end

function InventoryService.clear(self, player: Player)
	local session = self.context.playerSessions:require(player)
	table.clear(session.inventory.Contents)
	for currencyType in Currencies do
		session.gameCurrency.Quantities[currencyType] = 0
	end
	table.clear(session.pendingInventoryPredictions)
	self:setHeldItem(player, nil)
	for armourType in session.equippedArmour do
		self:applyArmourVisual(player, armourType, nil)
	end
	table.clear(session.equippedArmour)
	session.openChest = nil
	self.context.outbound:fire("InventoryCleared", player)
	self:refreshCurrency(player, true)
end

function InventoryService.getActiveSkin(self, session, itemType: string): string?
	local itemDefinition: ItemDefinition? = Items[itemType]
	if itemDefinition == nil or itemDefinition.ItemGroup == nil then
		return nil
	end
	local cosmetics = session.profile.Cosmetics
	local activeSkins = cosmetics and cosmetics.ActiveSkinsGroup
	local skinId = activeSkins and activeSkins[itemDefinition.ItemGroup]
	return if type(skinId) == "string" and skinId ~= "" then skinId else nil
end

function InventoryService.setHeldItem(self, player: Player, itemType: string?): boolean
	local session = self.context.playerSessions:require(player)
	if itemType ~= nil then
		local itemDefinition: ItemDefinition? = Items[itemType]
		if itemDefinition == nil or itemDefinition.Armour ~= nil or self:getItemQuantity(player, itemType) <= 0 then
			return false
		end
	end
	session.heldItemType = itemType
	local skinId = if itemType then self:getActiveSkin(session, itemType) else nil
	self.context.outbound:fireAll("ToolEquipped", player, itemType, skinId)
	return true
end

function InventoryService.removeArmourVisual(self, character: Model, armourType: string)
	for _, child in character:GetChildren() do
		if child:GetAttribute("Armour") == true then
			local itemDefinition: ItemDefinition? = Items[child.Name]
			if itemDefinition and itemDefinition.Armour and itemDefinition.Armour.ArmourType == armourType then
				child:Destroy()
			end
		end
	end
end

function InventoryService.applyArmourVisual(self, player: Player, armourType: string, itemType: string?)
	local character = player.Character
	if character == nil then
		return
	end
	self:removeArmourVisual(character, armourType)
	if itemType == nil then
		player:SetAttribute(armourType, nil)
		return
	end

	local session = self.context.playerSessions:require(player)
	local skinId = self:getActiveSkin(session, itemType) or ""
	local success, armourModel = pcall(function()
		return RigUtil.equipArmour(character, itemType, skinId)
	end)
	if not success then
		warn(("[Server] Failed to render armour %s for %s: %s"):format(itemType, player.Name, tostring(armourModel)))
		armourModel = nil
	end
	if armourModel == nil then
		armourModel = Instance.new("Model")
		armourModel.Name = itemType
		armourModel.Parent = character
	end
	armourModel:SetAttribute("Armour", true)
	player:SetAttribute(armourType, itemType)
end

function InventoryService.equipArmour(self, player: Player, itemType: string): boolean
	local itemDefinition: ItemDefinition? = Items[itemType]
	if itemDefinition == nil or itemDefinition.Armour == nil then
		return false
	end
	local session = self.context.playerSessions:require(player)
	if self:getItemQuantity(player, itemType) < 1 then
		return false
	end

	local armourType = itemDefinition.Armour.ArmourType
	local updatedInventory = updateInventoryBasic(session.inventory, itemType, -1)
	if updatedInventory == nil then
		return false
	end
	local previousItemType = session.equippedArmour[armourType]
	if previousItemType ~= nil then
		updatedInventory = updatePlayerInventory(updatedInventory, previousItemType, 1)
		if updatedInventory == nil then
			self:notify(player, "Your inventory is full.")
			return false
		end
	end

	session.inventory = updatedInventory
	session.equippedArmour[armourType] = itemType
	self:applyArmourVisual(player, armourType, itemType)
	if previousItemType ~= itemType then
		self:replicateItemChange(player, itemType, -1)
		if previousItemType ~= nil then
			self:replicateItemChange(player, previousItemType, 1)
		end
	end
	return true
end

function InventoryService.unequipArmour(self, player: Player, itemType: string): boolean
	local itemDefinition: ItemDefinition? = Items[itemType]
	if itemDefinition == nil or itemDefinition.Armour == nil then
		return false
	end
	local session = self.context.playerSessions:require(player)
	local armourType = itemDefinition.Armour.ArmourType
	if session.equippedArmour[armourType] ~= itemType then
		return false
	end
	local updatedInventory = updatePlayerInventory(session.inventory, itemType, 1)
	if updatedInventory == nil then
		self:notify(player, "Your inventory is full.")
		return false
	end

	session.inventory = updatedInventory
	session.equippedArmour[armourType] = nil
	self:applyArmourVisual(player, armourType, nil)
	self:replicateItemChange(player, itemType, 1)
	return true
end

function InventoryService.createWorldDrop(
	self,
	itemType: string,
	quantity: number,
	cframe: CFrame,
	options: WorldDropOptions?
): Model?
	if Items[itemType] == nil or quantity <= 0 or quantity % 1 ~= 0 or quantity > MAX_ITEM_QUANTITY then
		return nil
	end
	options = options or {}
	local dropFolder = getDropFolder()
	local stackKey = options.StackKey
	if stackKey ~= nil then
		for _, candidate in dropFolder:GetChildren() do
			if
				candidate:IsA("Model")
				and candidate:GetAttribute("StackKey") == stackKey
				and candidate:GetAttribute("PickupInProgress") ~= true
			then
				local currentQuantity = candidate:GetAttribute("Quantity")
				if type(currentQuantity) == "number" and currentQuantity + quantity <= MAX_ITEM_QUANTITY then
					candidate:SetAttribute("Quantity", currentQuantity + quantity)
					return candidate
				end
			end
		end
	end
	local success, drop = pcall(function()
		return ItemDropUtil.createItemDropModel(itemType)
	end)
	if not success or drop == nil then
		warn(("[Server] Failed to create item drop %s: %s"):format(itemType, tostring(drop)))
		return nil
	end
	-- The invisible primary hitbox is the drop's physical body: it must collide
	-- with the arena so unanchored loot settles on the floor. Render descendants
	-- stay non-solid, and CanTouch remains enabled for the immediate pickup path.
	for _, descendant in drop:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = descendant == drop.PrimaryPart
			descendant.CanQuery = false
		end
	end
	drop:SetAttribute("ItemType", itemType)
	drop:SetAttribute("Quantity", quantity)
	if options.OwnerUserId ~= nil then
		drop:SetAttribute("OwnerUserId", options.OwnerUserId)
	end
	if options.GeneratorDrop == true then
		drop:SetAttribute("GeneratorDrop", true)
	end
	if stackKey ~= nil then
		drop:SetAttribute("StackKey", stackKey)
	end
	drop:SetAttribute("PickupAt", Workspace:GetServerTimeNow() + (options.PickupDelay or 0))
	drop:PivotTo(cframe)
	drop.Parent = dropFolder
	self:bindDrop(drop)
	if drop.PrimaryPart ~= nil and options.InitialVelocity ~= nil then
		drop.PrimaryPart.AssemblyLinearVelocity = options.InitialVelocity
	end
	return drop
end

function InventoryService.createDrop(self, player: Player, itemType: string, quantity: number): Model?
	local root = getPlayerRoot(player)
	if root == nil then
		return nil
	end
	return self:createWorldDrop(
		itemType,
		quantity,
		CFrame.new(root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 2, 0)),
		{
			OwnerUserId = player.UserId,
			PickupDelay = DROP_PICKUP_DELAY,
			InitialVelocity = root.CFrame.LookVector * 18 + Vector3.new(0, 8, 0),
		}
	)
end

function InventoryService.dropHeldItem(self, player: Player): boolean
	local eggWarsService = self.context.eggWarsService
	local runtimeContext = self.context.runtimeContext:get()
	-- Egg Wars disables manual item dropping for the whole match lifecycle,
	-- including its pregame and cage phases. Generator-created world drops are
	-- separate and continue to use createWorldDrop directly.
	if eggWarsService ~= nil and eggWarsService:isGameMode(runtimeContext.GameMode) then
		return false
	end
	local session = self.context.playerSessions:require(player)
	local itemType = session.heldItemType
	if itemType == nil then
		return false
	end
	local itemDefinition: ItemDefinition? = Items[itemType]
	-- Tiered tools retain their normal non-droppable rule in other modes.
	if itemDefinition == nil or itemDefinition.Melee ~= nil or itemDefinition.Pickaxe ~= nil then
		return false
	end
	local quantity = self:getItemQuantity(player, itemType)
	if quantity <= 0 then
		return false
	end
	local drop = self:createDrop(player, itemType, 1)
	if drop == nil then
		return false
	end
	if not self:changeItem(player, itemType, -1) then
		drop:Destroy()
		return false
	end
	return true
end

function InventoryService.tryPickupDropForPlayer(self, drop: Model, player: Player)
	if drop.Parent == nil or drop:GetAttribute("PickupInProgress") == true then
		return
	end
	if
		player.Parent ~= Players
		or self.context.playerSessions:get(player) == nil
		or player:GetAttribute("Alive") ~= true
		or player:GetAttribute("Spectating") == true
	then
		return
	end
	local pickupAt = drop:GetAttribute("PickupAt")
	local ownerUserId = drop:GetAttribute("OwnerUserId")
	if type(pickupAt) == "number" and Workspace:GetServerTimeNow() < pickupAt and ownerUserId == player.UserId then
		return
	end
	local root = getPlayerRoot(player)
	if
		root == nil
		or drop.PrimaryPart == nil
		or (root.Position - drop.PrimaryPart.Position).Magnitude > DROP_PICKUP_RANGE
	then
		return
	end
	local itemTypeAttribute = drop:GetAttribute("ItemType")
	local itemType = if type(itemTypeAttribute) == "string" then itemTypeAttribute else drop.Name
	local quantityAttribute = drop:GetAttribute("Quantity")
	local quantity = if type(quantityAttribute) == "number" and quantityAttribute % 1 == 0 then quantityAttribute else 1
	if
		drop:GetAttribute("GeneratorDrop") == true
		and (self.context.eggWarsService == nil or not self.context.eggWarsService:isActive())
	then
		return
	end
	if drop:GetAttribute("GeneratorDrop") == true then
		quantity *= self.context.eggWarsService:getGeneratorLootMultiplier(player)
	end
	if Items[itemType] == nil or quantity <= 0 or quantity > MAX_ITEM_QUANTITY then
		return
	end
	drop:SetAttribute("PickupInProgress", true)
	if self:changeItem(player, itemType, quantity) then
		self:playPickupSound(player)
		drop:Destroy()
	else
		drop:SetAttribute("PickupInProgress", nil)
	end
end

function InventoryService.tryPickupDrop(self, drop: Model, hit: BasePart)
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	if player ~= nil then
		self:tryPickupDropForPlayer(drop, player)
	end
end

function InventoryService.scanDropPickups(self)
	for drop in self.dropConnections do
		local primaryPart = drop.PrimaryPart
		if drop.Parent ~= nil and primaryPart ~= nil and drop:GetAttribute("PickupInProgress") ~= true then
			local nearbyPlayers = {} :: { { Player: Player, Distance: number } }
			for _, player in Players:GetPlayers() do
				local root = getPlayerRoot(player)
				if root ~= nil then
					local distance = (root.Position - primaryPart.Position).Magnitude
					if distance <= DROP_PICKUP_RANGE then
						table.insert(nearbyPlayers, { Player = player, Distance = distance })
					end
				end
			end
			table.sort(nearbyPlayers, function(left, right)
				return if left.Distance == right.Distance
					then left.Player.UserId < right.Player.UserId
					else left.Distance < right.Distance
			end)
			for _, entry in nearbyPlayers do
				self:tryPickupDropForPlayer(drop, entry.Player)
				if drop.Parent == nil or drop:GetAttribute("PickupInProgress") == true then
					break
				end
			end
		end
	end
end

function InventoryService.bindDrop(self, instance: Instance)
	if not instance:IsA("Model") or self.dropConnections[instance] ~= nil then
		return
	end
	local deadline = os.clock() + 5
	local function connectPrimaryPart()
		if self.dropConnections[instance] ~= nil then
			return
		end
		if instance.Parent == nil then
			if os.clock() < deadline then
				task.delay(0.1, connectPrimaryPart)
			end
			return
		end
		local primaryPart = instance.PrimaryPart
		if primaryPart == nil then
			if os.clock() < deadline then
				task.delay(0.1, connectPrimaryPart)
			end
			return
		end
		local touchConnection = primaryPart.Touched:Connect(function(hit)
			self:tryPickupDrop(instance, hit)
		end)
		self.dropConnections[instance] = touchConnection
		instance.Destroying:Once(function()
			touchConnection:Disconnect()
			self.dropConnections[instance] = nil
		end)
	end
	connectPrimaryPart()
end

function InventoryService.registerPrediction(
	self,
	player: Player,
	itemType: string,
	quantity: number,
	predictionId: string
): boolean
	local session = self.context.playerSessions:require(player)
	local itemDefinition: ItemDefinition? = Items[itemType]
	if
		itemDefinition == nil
		or quantity ~= -1
		or #predictionId == 0
		or #predictionId > MAX_PREDICTION_ID_LENGTH
		or session.pendingInventoryPredictions[predictionId] ~= nil
		or self:getItemQuantity(player, itemType) < 1
	then
		self.context.outbound:fire("InventoryPredictionReverted", player, predictionId)
		return false
	end
	session.pendingInventoryPredictions[predictionId] = {
		itemType = itemType,
		quantity = quantity,
		createdAt = os.clock(),
	}
	task.delay(PREDICTION_TIMEOUT, function()
		local currentSession = self.context.playerSessions:get(player)
		if currentSession and currentSession.pendingInventoryPredictions[predictionId] ~= nil then
			currentSession.pendingInventoryPredictions[predictionId] = nil
			self.context.outbound:fire("InventoryPredictionReverted", player, predictionId)
		end
	end)
	return true
end

function InventoryService.rejectPrediction(self, player: Player, predictionId: string)
	local session = self.context.playerSessions:require(player)
	if session.pendingInventoryPredictions[predictionId] ~= nil then
		session.pendingInventoryPredictions[predictionId] = nil
		self.context.outbound:fire("InventoryPredictionReverted", player, predictionId)
	end
end

function InventoryService.commitPrediction(self, player: Player, predictionId: string): (boolean, string?)
	local session = self.context.playerSessions:require(player)
	local prediction = session.pendingInventoryPredictions[predictionId]
	if prediction == nil then
		return false, nil
	end
	session.pendingInventoryPredictions[predictionId] = nil
	if self:getItemQuantity(player, prediction.itemType) < -prediction.quantity then
		self.context.outbound:fire("InventoryPredictionReverted", player, predictionId)
		return false, prediction.itemType
	end
	local updatedInventory = updateInventoryBasic(session.inventory, prediction.itemType, prediction.quantity)
	if updatedInventory == nil then
		self.context.outbound:fire("InventoryPredictionReverted", player, predictionId)
		return false, prediction.itemType
	end
	session.inventory = updatedInventory
	self.context.outbound:fire("InventoryUpdated", player, prediction.itemType, prediction.quantity, predictionId)
	if self:getItemQuantity(player, prediction.itemType) == 0 and session.heldItemType == prediction.itemType then
		self:setHeldItem(player, nil)
	end
	return true, prediction.itemType
end

function InventoryService.isChestAccessible(self, player: Player, chest: Model): boolean
	if not chest:IsDescendantOf(Workspace) or not CollectionService:HasTag(chest, "block:chest") then
		return false
	end
	local root = getPlayerRoot(player)
	if root == nil then
		return false
	end
	return (root.Position - chest:GetPivot().Position).Magnitude <= CHEST_INTERACTION_RANGE
end

function InventoryService.getChestState(self, chest: Model): ChestState
	local state = self.chests[chest]
	if state ~= nil then
		return state
	end
	state = {
		Size = CHEST_SIZE,
		Contents = {},
	}
	local serializedInventory = chest:GetAttribute("Inventory")
	if type(serializedInventory) == "string" and serializedInventory ~= "" then
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, serializedInventory)
		if success and type(decoded) == "table" then
			for key, value in decoded do
				if type(value) == "table" then
					local slot = value.Slot or tonumber(key)
					local itemType = value.Type
					local quantity = value.Quantity
					if
						type(slot) == "number"
						and slot % 1 == 0
						and slot >= 0
						and slot < CHEST_SIZE
						and type(itemType) == "string"
						and Items[itemType] ~= nil
						and type(quantity) == "number"
						and quantity % 1 == 0
						and quantity > 0
						and quantity <= MAX_ITEM_QUANTITY
					then
						state.Contents[slot] = { Slot = slot, Type = itemType, Quantity = quantity }
					end
				end
			end
		end
	end
	self.chests[chest] = state
	return state
end

function InventoryService.sendChest(self, player: Player, chest: Model, shouldOpen: boolean)
	local state = self:getChestState(chest)
	self.context.outbound:fire("ChestUpdated", player, chest, serializeContents(state.Contents), shouldOpen)
end

-- Plays the chest's single open animation once, then freezes the track on
-- its final frame so the chest stays fully open in 3D forever (the original
-- game never closes chests). The chest models ship with the
-- AnimationController/Animator rig for exactly this server-driven playback;
-- the client only checks that the rig exists.
local function playChestOpen(self, chest: Model)
	-- The client plays no chest audio of its own; the recovered chest-open
	-- sound goes through the SoundPlayed pipeline at the chest's position.
	self.context.outbound:fireAll(
		"SoundPlayed",
		("ChestOpen_%s"):format(HttpService:GenerateGUID(false)),
		RobloxSound.Chest.OPEN,
		chest:GetPivot().Position,
		{ Volume = 0.8 }
	)
	local animationController = chest:FindFirstChild("AnimationController")
	if animationController == nil or not animationController:IsA("AnimationController") then
		return
	end
	local animator = animationController:FindFirstChildOfClass("Animator")
	if animator == nil then
		return
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = CHEST_OPEN_ANIMATION_ID
	local track = animator:LoadAnimation(animation)
	track:Play()

	-- The server streams animation content asynchronously: Length reports 0
	-- until the asset loads and the queued play starts, so wait for the real
	-- length and then freeze just before the final frame (a stopped track
	-- would snap the lid back closed).
	task.spawn(function()
		local waited = 0
		while track.Length <= 0 and waited < 5 do
			waited += task.wait(0.1)
		end
		if track.Length <= 0 then
			return
		end
		while track.IsPlaying and track.TimePosition < track.Length - 0.05 do
			task.wait(0.03)
		end
		if track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
end

function InventoryService.broadcastChest(self, chest: Model)
	for _, player in Players:GetPlayers() do
		local session = self.context.playerSessions:get(player)
		if session and session.openChest == chest then
			self:sendChest(player, chest, false)
		end
	end
end

function InventoryService.openChest(self, player: Player, chest: Model): boolean
	if not self:isChestAccessible(player, chest) then
		return false
	end
	local session = self.context.playerSessions:require(player)
	session.openChest = chest
	local state = self:getChestState(chest)
	if state.Opened ~= true then
		state.Opened = true
		playChestOpen(self, chest)
	end
	self:sendChest(player, chest, true)
	return true
end

function InventoryService.closeChest(self, player: Player, chest: Model)
	local session = self.context.playerSessions:require(player)
	if session.openChest == chest then
		session.openChest = nil
	end
end

function InventoryService.transferChestItem(
	self,
	player: Player,
	chest: Model,
	itemType: string,
	quantity: number
): boolean
	if
		quantity == 0
		or quantity % 1 ~= 0
		or math.abs(quantity) > MAX_ITEM_QUANTITY
		or Items[itemType] == nil
		or not self:isChestAccessible(player, chest)
	then
		return false
	end
	local session = self.context.playerSessions:require(player)
	if session.openChest ~= chest then
		return false
	end
	local chestState = self:getChestState(chest)
	local updatedPlayerInventory: Inventory?
	local updatedChestInventory: Inventory?
	local equippedArmourType: string?
	local equippedArmourItemType: string?
	local previousEquippedArmourItemType: string?
	local reacquiredUpgrade: ReacquiredUpgrade?
	local receivedItemSlot: number?
	local heldItemType = session.heldItemType
	local heldItem = if heldItemType then findItem(session.inventory, heldItemType) else nil
	local heldItemSlot = if heldItem then heldItem.Slot else nil
	if quantity > 0 then
		if self:getItemQuantity(player, itemType) < quantity then
			return false
		end
		updatedChestInventory = updateInventoryBasic(chestState, itemType, quantity)
		if updatedChestInventory == nil then
			self:notify(player, "This chest is full.")
			return false
		end
		updatedPlayerInventory = updateInventoryBasic(session.inventory, itemType, -quantity)
	else
		local chestItem = findItem(chestState, itemType)
		if chestItem == nil or chestItem.Quantity < -quantity then
			return false
		end
		local itemDefinition: ItemDefinition = Items[itemType]
		if itemDefinition.Armour ~= nil then
			updatedPlayerInventory, equippedArmourType, equippedArmourItemType =
				addArmourFromChest(session.inventory, session.equippedArmour, itemType, -quantity)
		else
			updatedPlayerInventory, receivedItemSlot, reacquiredUpgrade =
				updatePlayerInventory(session.inventory, itemType, -quantity, true)
		end
		if updatedPlayerInventory == nil then
			self:notify(player, "Your inventory is full.")
			return false
		end
		updatedChestInventory = updateInventoryBasic(chestState, itemType, quantity)
	end
	if updatedPlayerInventory == nil or updatedChestInventory == nil then
		return false
	end
	session.inventory = updatedPlayerInventory
	self.chests[chest] = updatedChestInventory
	if equippedArmourType ~= nil and equippedArmourItemType ~= nil then
		previousEquippedArmourItemType = session.equippedArmour[equippedArmourType]
		session.equippedArmour[equippedArmourType] = equippedArmourItemType
		self:applyArmourVisual(player, equippedArmourType, equippedArmourItemType)
	end
	if quantity > 0 then
		self:replicateItemChange(player, itemType, -quantity)
	elseif equippedArmourItemType ~= nil then
		if previousEquippedArmourItemType ~= nil then
			self:replicateItemChange(player, previousEquippedArmourItemType, 1)
		end
		self:replicateItemChange(player, itemType, -quantity - 1)
	elseif reacquiredUpgrade ~= nil then
		-- The recovered client upgrades a lower-tier tool in place. When that
		-- lower tier is in main storage, replay the delta as remove/add/restore:
		-- with no competing tool present, the client puts the reacquired upgrade
		-- into its first open hotbar slot, then restores the lower tiers at the
		-- end of main inventory. This preserves every unrelated client-local slot.
		for _, lowerTierItem in reacquiredUpgrade.LowerTierItems do
			self:replicateItemChange(player, lowerTierItem.Type, -lowerTierItem.Quantity)
		end
		self:replicateItemChange(player, itemType, -quantity)
		for _, lowerTierItem in reacquiredUpgrade.LowerTierItems do
			self:replicateItemChange(player, lowerTierItem.Type, lowerTierItem.Quantity)
		end
	else
		self:replicateItemChange(player, itemType, -quantity)
	end
	if heldItemType ~= nil and heldItemSlot ~= nil then
		local itemAtPreviousHeldSlot = updatedPlayerInventory.Contents[heldItemSlot]
		if itemAtPreviousHeldSlot ~= nil then
			self:setHeldItem(player, itemAtPreviousHeldSlot.Type)
		elseif findItem(updatedPlayerInventory, heldItemType) == nil then
			self:setHeldItem(player, nil)
		else
			self:setHeldItem(player, heldItemType)
		end
	elseif quantity < 0 then
		local receivedItem = if receivedItemSlot ~= nil
			then updatedPlayerInventory.Contents[receivedItemSlot]
			else findItem(updatedPlayerInventory, itemType)
		local itemDefinition: ItemDefinition = Items[itemType]
		if itemDefinition.Melee ~= nil and receivedItem ~= nil and receivedItem.Slot < HOTBAR_SIZE then
			self:setHeldItem(player, itemType)
		end
	end
	self:broadcastChest(chest)
	return true
end

function InventoryService.getCurrencyItemType(self, currencyType: string): string?
	local currency = Currencies[currencyType]
	return currency and currency.ItemType or nil
end

function InventoryService.purchaseItem(self, player: Player, shopType: string, itemIndex: number): boolean
	local shop = Shops[shopType]
	local shopItem = shop and shop.Items[itemIndex + 1]
	if shopItem == nil then
		return false
	end
	local currencyItemType = self:getCurrencyItemType(shopItem.CurrencyType)
	if currencyItemType == nil or self:getItemQuantity(player, currencyItemType) < shopItem.Price then
		self:notify(player, "You do not have enough currency.")
		return false
	end
	local limit = shopItem.Limit
	if limit ~= nil and self:getItemQuantity(player, shopItem.ItemType) + shopItem.Quantity > limit then
		self:notify(player, "You have reached this item's limit.")
		return false
	end

	local session = self.context.playerSessions:require(player)
	local updatedInventory = updatePlayerInventory(session.inventory, shopItem.ItemType, shopItem.Quantity)
	if updatedInventory == nil then
		self:notify(player, "Your inventory is full.")
		return false
	end
	session.inventory = updatedInventory
	if not self:changeItem(player, currencyItemType, -shopItem.Price) then
		return false
	end
	self:replicateItemChange(player, shopItem.ItemType, shopItem.Quantity)
	self:playShopSound(player, RobloxSound.EggUi.PURCHASE)
	return true
end

function InventoryService.purchaseUpgrade(self, player: Player, shopType: string, itemIndex: number): boolean
	local shop = Shops[shopType]
	local upgrade = shop and shop.ItemUpgrades[itemIndex + 1]
	if upgrade == nil then
		return false
	end
	local session = self.context.playerSessions:require(player)
	local currentIndex = 0
	if upgrade.Id == "Armour" then
		local currentChestplate = session.equippedArmour.Chestplate
		for index, candidate in upgrade.Items do
			if candidate.ItemType == currentChestplate then
				currentIndex = index
				break
			end
		end
	else
		for index, candidate in upgrade.Items do
			if findItem(session.inventory, candidate.ItemType) ~= nil then
				currentIndex = math.max(currentIndex, index)
			end
		end
	end
	local target = upgrade.Items[currentIndex + 1]
	if target == nil then
		self:notify(player, "This upgrade is already maxed.")
		return false
	end
	local currencyItemType = self:getCurrencyItemType(target.CurrencyType)
	if currencyItemType == nil or self:getItemQuantity(player, currencyItemType) < target.Price then
		self:notify(player, "You do not have enough currency.")
		return false
	end

	local updatedInventory = cloneInventory(session.inventory)
	local replacedItemType: string?
	local replacedItemQuantity = 0
	if upgrade.Id == "Armour" then
		for _, armourItemType in target.ArmourTypes do
			local armourDefinition: ItemDefinition? = Items[armourItemType]
			if armourDefinition == nil or armourDefinition.Armour == nil then
				return false
			end
		end
	else
		if currentIndex > 0 then
			local currentItemType = upgrade.Items[currentIndex].ItemType
			local currentItem = findItem(updatedInventory, currentItemType)
			if currentItem then
				replacedItemType = currentItemType
				replacedItemQuantity = currentItem.Quantity
				updatedInventory = updateInventoryBasic(updatedInventory, currentItemType, -currentItem.Quantity)
			end
		end
		if updatedInventory ~= nil then
			updatedInventory = updatePlayerInventory(updatedInventory, target.ItemType, target.Quantity)
		end
		if updatedInventory == nil then
			self:notify(player, "Your inventory is full.")
			return false
		end
	end

	session.inventory = updatedInventory
	if not self:changeItem(player, currencyItemType, -target.Price) then
		return false
	end
	if upgrade.Id == "Armour" then
		for _, armourItemType in target.ArmourTypes do
			local armourDefinition: ItemDefinition = Items[armourItemType]
			local armourType = armourDefinition.Armour.ArmourType
			session.equippedArmour[armourType] = armourItemType
			self:applyArmourVisual(player, armourType, armourItemType)
		end
	end
	if replacedItemType ~= nil then
		self:replicateItemChange(player, replacedItemType, -replacedItemQuantity)
	end
	if upgrade.Id ~= "Armour" then
		self:replicateItemChange(player, target.ItemType, target.Quantity)
	end
	self:playShopSound(player, RobloxSound.EggUi.UPGRADE)
	return true
end

function InventoryService.bindPlayer(self, player: Player)
	if self.characterConnections[player] ~= nil then
		return
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.defer(function()
			local session = self.context.playerSessions:get(player)
			if session == nil then
				return
			end
			for armourType, itemType in session.equippedArmour do
				self:applyArmourVisual(player, armourType, itemType)
			end
			if session.heldItemType ~= nil then
				self:setHeldItem(player, session.heldItemType)
			end
		end)
	end)
end

function InventoryService.start(self)
	if self.started then
		return
	end
	self.started = true
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			self:bindPlayer(player)
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			local connection = self.characterConnections[player]
			if connection then
				connection:Disconnect()
				self.characterConnections[player] = nil
			end
		end)
	)
	table.insert(
		self.connections,
		CollectionService:GetInstanceAddedSignal("item"):Connect(function(instance)
			self:bindDrop(instance)
		end)
	)
	table.insert(
		self.connections,
		RunService.Heartbeat:Connect(function(deltaTime)
			self.dropPickupScanElapsed += deltaTime
			if self.dropPickupScanElapsed < DROP_PICKUP_SCAN_INTERVAL then
				return
			end
			self.dropPickupScanElapsed = 0
			self:scanDropPickups()
		end)
	)
	for _, player in Players:GetPlayers() do
		self:bindPlayer(player)
	end
	for _, instance in CollectionService:GetTagged("item") do
		self:bindDrop(instance)
	end
end

function InventoryService.stop(self)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	for _, connection in self.dropConnections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.characterConnections)
	table.clear(self.dropConnections)
	table.clear(self.chests)
	self.dropPickupScanElapsed = 0
	self.started = false
end

return InventoryService
