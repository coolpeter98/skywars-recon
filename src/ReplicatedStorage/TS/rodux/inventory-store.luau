-- InventoryStore

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local InventoryConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants")
local HOTBAR_SIZE = InventoryConstants.HOTBAR_SIZE
local INVENTORY_SIZE = InventoryConstants.INVENTORY_SIZE
local InventoryUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-util").InventoryUtil
local HttpService: HttpService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").HttpService
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")

type ActionBar = {
	ActionBarId: string,
	Image: string?,
	Text: string?,
	Color: Color3?,
	StartTime: number,
	Removed: boolean,
}

type InventoryStoreState = {
	ActiveSlot: number,
	Inventory: {
		Contents: { [number]: any },
		Size: number,
	},
	ActionBarMap: { [string]: ActionBar },
}

type InventoryStoreAction = {
	["type"]: string,
	SlotId: number?,
	Item: any?,
	Image: string?,
	Text: string?,
	Color: Color3?,
	ActionBarId: string?,
}

local DefaultInventoryStore: InventoryStoreState = {
	["ActiveSlot"] = 0,
	["Inventory"] = nil,
	["ActionBarMap"] = nil,
	["Inventory"] = {
		["Contents"] = {},
		["Size"] = HOTBAR_SIZE + INVENTORY_SIZE
	},
	["ActionBarMap"] = {}
}

local InventoryStoreActionType = {
	["MoveItem"] = "MoveItem",
	["AddActionBar"] = "AddActionBar",
	["RemoveActionBar"] = "RemoveActionBar"
}

local function InventoryStoreReducer(state: InventoryStoreState, action: InventoryStoreAction): InventoryStoreState
	local actionType = action.type
	if actionType == InventoryStoreActionType.MoveItem then
		local inventory = InventoryUtil.cloneInventory(state.Inventory)
		local existingItem = inventory.Contents[action.SlotId]
		if existingItem then
			local contents = inventory.Contents
			local sourceSlot = action.Item.Slot
			local swappedItem = table.clone(existingItem)
			setmetatable(swappedItem, nil)
			swappedItem.Slot = action.Item.Slot
			contents[sourceSlot] = swappedItem
		else
			inventory.Contents[action.Item.Slot] = nil
		end
		local contents = inventory.Contents
		local slotId = action.SlotId
		local movedItem = table.clone(action.Item)
		setmetatable(movedItem, nil)
		movedItem.Slot = action.SlotId
		contents[slotId] = movedItem
		local newState = table.clone(state)
		setmetatable(newState, nil)
		newState.Inventory = inventory
		return newState
	end
	if actionType == InventoryStoreActionType.AddActionBar then
		local actionBarId = HttpService:GenerateGUID()
		local startTime = os.clock()
		local actionBar = {
			["ActionBarId"] = nil,
			["Image"] = nil,
			["Text"] = nil,
			["Color"] = nil,
			["StartTime"] = nil,
			["Removed"] = false,
			["ActionBarId"] = actionBarId,
			["Image"] = action.Image,
			["Text"] = action.Text,
			["Color"] = action.Color,
			["StartTime"] = startTime
		}
		local actionBarMap = ObjectUtils.copy(state.ActionBarMap)
		actionBarMap[actionBarId] = actionBar
		local newState = table.clone(state)
		setmetatable(newState, nil)
		newState.ActionBarMap = actionBarMap
		return newState
	end
	if actionType == InventoryStoreActionType.RemoveActionBar then
		local actionBar = state.ActionBarMap[action.ActionBarId]
		if not actionBar then
			return state
		end
		local actionBarMap = ObjectUtils.copy(state.ActionBarMap)
		local actionBarId = actionBar.ActionBarId
		local removedActionBar = table.clone(actionBar)
		setmetatable(removedActionBar, nil)
		removedActionBar.Removed = true
		actionBarMap[actionBarId] = removedActionBar
		local remainingCount = 0
		local remainingBars = {}
		for index, bar in ObjectUtils.values(actionBarMap) do
			local _ = index - 1
			if not bar.Removed == true then
				remainingCount = remainingCount + 1
				remainingBars[remainingCount] = bar
			end
		end
		if #remainingBars == 0 then
			table.clear(actionBarMap)
		end
		local newState = table.clone(state)
		setmetatable(newState, nil)
		newState.ActionBarMap = actionBarMap
		return newState
	end
end

return {
	["InventoryStoreReducer"] = InventoryStoreReducer,
	["DefaultInventoryStore"] = DefaultInventoryStore,
	["InventoryStoreActionType"] = InventoryStoreActionType
}
