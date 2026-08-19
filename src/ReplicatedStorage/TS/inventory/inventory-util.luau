-- InventoryUtil

type ItemDef = {
	Melee: { Damage: number }?,
	Pickaxe: { TimeMultiplier: number }?,
	Armour: any,
}

type InventoryItem = {
	Slot: number,
	Type: string,
	Quantity: number,
}

type Inventory = {
	Size: number,
	Contents: { [number]: InventoryItem },
}

type UpdateResult = {
	updated: boolean,
	slotId: number?,
	inventory: Inventory?,
}

local Items: { [string]: ItemDef } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items

local InventoryUtil = {}

local findItem: (inventory: Inventory, itemType: string) -> InventoryItem?
local updateInventory: (inventory: Inventory, itemType: string, quantity: number, fromEnd: boolean?) -> UpdateResult
local findBestItem: (inventory: Inventory, score: (itemDef: ItemDef) -> number?) -> InventoryItem?
local cloneInventory: (inventory: Inventory) -> Inventory
local findEmptySlot: (inventory: Inventory, startIndex: number?, fromEnd: boolean?) -> number?

function InventoryUtil.updatePlayerInventory(inventory: Inventory, itemType: string, quantity: number): UpdateResult
	if quantity <= 0 or findItem(inventory, itemType) then
		return updateInventory(inventory, itemType, quantity)
	else
		local itemDef: ItemDef = Items[itemType]
		local function replaceItem(currentItem: InventoryItem?, score: (itemDef: ItemDef) -> number?): UpdateResult
			if not currentItem or currentItem.Type == itemType then
				return updateInventory(inventory, itemType, quantity)
			end
			if score(Items[currentItem.Type]) > score(itemDef) then
				return updateInventory(inventory, itemType, quantity, true)
			end
			inventory.Contents[currentItem.Slot] = {
				["Slot"] = currentItem.Slot,
				["Type"] = itemType,
				["Quantity"] = quantity,
			}
			local moveResult = updateInventory(inventory, currentItem.Type, currentItem.Quantity, true)
			local result = {
				["updated"] = true,
				["slotId"] = nil,
				["inventory"] = nil,
				["slotId"] = currentItem.Slot,
			}
			local updatedInventory: Inventory?
			if moveResult.updated then
				updatedInventory = moveResult.inventory
			else
				updatedInventory = inventory
			end
			result.inventory = updatedInventory
			return result
		end
		if itemDef.Melee then
			local function scoreMelee(itemDef: ItemDef): number?
				local meleeDamage = itemDef.Melee
				if meleeDamage then
					meleeDamage = itemDef.Melee.Damage
				end
				return meleeDamage
			end
			return replaceItem(findBestItem(inventory, scoreMelee), scoreMelee)
		elseif itemDef.Pickaxe then
			local function scorePickaxe(itemDef: ItemDef): number?
				local pickaxeScore = itemDef.Pickaxe
				if pickaxeScore then
					pickaxeScore = 1 - itemDef.Pickaxe.TimeMultiplier
				end
				return pickaxeScore
			end
			return replaceItem(findBestItem(inventory, scorePickaxe), scorePickaxe)
		elseif itemDef.Armour then
			return updateInventory(inventory, itemType, quantity, true)
		else
			return updateInventory(inventory, itemType, quantity)
		end
	end
end

findBestItem = function(inventory: Inventory, score: (itemDef: ItemDef) -> number?): InventoryItem?
	local bestItem: InventoryItem? = nil
	for _, item in inventory.Contents do
		local itemScore = score(Items[item.Type])
		if itemScore ~= nil and (not bestItem or score(Items[bestItem.Type]) < itemScore) then
			bestItem = item
		end
	end
	return bestItem
end

updateInventory = function(inventory: Inventory, itemType: string, quantity: number, fromEnd: boolean?): UpdateResult
	local clonedInventory = cloneInventory(inventory)
	local existingItem = findItem(clonedInventory, itemType)
	if not existingItem then
		local emptySlot: number? = findEmptySlot(clonedInventory, 0, fromEnd)
		if emptySlot == nil then
			return {
				["updated"] = false,
			}
		end
		existingItem = {
			["Slot"] = nil,
			["Type"] = nil,
			["Quantity"] = 0,
			["Slot"] = emptySlot,
			["Type"] = itemType,
		}
	end
	local newQuantity = quantity + existingItem.Quantity
	if newQuantity <= 0 then
		clonedInventory.Contents[existingItem.Slot] = nil
	else
		local contents = clonedInventory.Contents
		local slot = existingItem.Slot
		local itemClone = table.clone(existingItem)
		setmetatable(itemClone, nil)
		itemClone.Quantity = newQuantity
		contents[slot] = itemClone
	end
	return {
		["updated"] = true,
		["slotId"] = nil,
		["inventory"] = nil,
		["slotId"] = existingItem.Slot,
		["inventory"] = clonedInventory,
	}
end
InventoryUtil.updateInventory = updateInventory

cloneInventory = function(inventory: Inventory): Inventory
	local newInventory = {
		["Contents"] = {},
		["Size"] = inventory.Size,
	}
	local hasRun = false
	local index = 0
	while true do
		if hasRun then
			index = index + 1
		else
			hasRun = true
		end
		if index >= inventory.Size then
			return newInventory
		end
		local item = inventory.Contents[index]
		if item then
			local newContents = newInventory.Contents
			local itemClone = table.clone(item)
			setmetatable(itemClone, nil)
			newContents[index] = itemClone
		end
	end
end
InventoryUtil.cloneInventory = cloneInventory

findItem = function(inventory: Inventory, itemType: string): InventoryItem?
	for _, item in inventory.Contents do
		if item.Type == itemType then
			return item
		end
	end
	return nil
end
InventoryUtil.findItem = findItem

findEmptySlot = function(inventory: Inventory, startIndex: number?, fromEnd: boolean?): number?
	startIndex = startIndex == nil and 0 or startIndex
	if fromEnd == nil then
		fromEnd = false
	end
	local lastIndex = inventory.Size - 1
	local index
	if fromEnd then
		index = lastIndex
	else
		index = startIndex
	end
	local hasRun = false
	while true do
		if hasRun then
			if fromEnd then
				index = index - 1
			else
				index = index + 1
			end
		else
			hasRun = true
		end
		local inBounds: boolean
		if fromEnd then
			inBounds = startIndex <= index
		else
			inBounds = index <= lastIndex
		end
		if not inBounds then
			return nil
		end
		if inventory.Contents[index] == nil then
			return index
		end
	end
end
InventoryUtil.findEmptySlot = findEmptySlot

return {
	["InventoryUtil"] = InventoryUtil,
}
