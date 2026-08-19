-- InventoryController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local AwaitPlayerRoot = RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitPlayerRoot
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local HttpService: HttpService = Services.HttpService
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local InventoryUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-util").InventoryUtil
local HOTBAR_SIZE = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"inventory",
	"inventory-constants"
).HOTBAR_SIZE
local HotbarController = RuntimeLib.import(script, script.Parent, "hotbar-controller").HotbarController
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local InventoryScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "inventory", "inventory-screen").InventoryScreen
local ChestScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "chest", "chest-screen").ChestScreen
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "character-util").CharacterUtil

type InventoryItem = {
	Slot: number,
	Type: string,
	Quantity: number,
}

type Inventory = {
	Size: number,
	Contents: { [number]: InventoryItem },
}

type InventoryController = {
	screenController: any,
	itemPredictions: { [string]: { Type: string, Quantity: number } },
}

local InventoryController = setmetatable({}, {
	["__tostring"] = function()
		return "InventoryController"
	end,
})
InventoryController.__index = InventoryController

function InventoryController.new(...)
	local self = InventoryController
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function InventoryController.constructor(self: InventoryController, screenController: any)
	self.screenController = screenController
	self.itemPredictions = {}
end

function InventoryController.onStart(self: InventoryController)
	-- Equip tool
	Events.ToolEquipped:connect(function(player: Player, toolId: string?, skinId: string?)
		local character = player.Character
		if not character then
			return nil
		end
		local currentTool = character:FindFirstChildOfClass("Tool")
		if toolId == "" or not toolId then
			for _, tool in character:GetChildren() do
				if tool:IsA("Tool") then
					tool:Destroy()
				end
			end
			return nil
		end
		local newTool = SkinsUtil.getTool(toolId, skinId)
		if currentTool and currentTool.Name == newTool.Name then
			return nil
		end
		CharacterUtil.equipTool(character, toolId, skinId)
	end)
	-- Prediction reverted
	Events.InventoryPredictionReverted:connect(function(predictionId: string)
		local prediction = self.itemPredictions[predictionId]
		if not prediction then
			return nil
		end
		local deltaQuantity = prediction.Quantity * -1
		local inventory = GlobalStore:getState().Inventory
		local result = InventoryUtil.updatePlayerInventory(inventory, prediction.Type, deltaQuantity)
		if not result.updated then
			return nil
		end
		Flamework.resolveDependency("zG"):setValue("Inventory", result.inventory)
		self.itemPredictions[predictionId] = nil
	end)
	-- Inventory updated
	Events.InventoryUpdated:connect(
		function(itemType: string, quantity: number, predictionId: string?)
			self:updateInventory(itemType, quantity, predictionId)
		end
	)
	-- Inventory cleared
	Events.InventoryCleared:connect(function()
		self:clearInventory()
	end)
	-- Round ended
	Events.Spectate:connect(function()
		self:clearInventory()
		self.screenController:close(InventoryScreen)
		self.screenController:close(ChestScreen)
	end)
	-- Player died
	Events.PlayerEliminated:connect(function(player: Player)
		if Players.LocalPlayer ~= player then
			return nil
		end
		self:clearInventory()
		self.screenController:close(InventoryScreen)
		self.screenController:close(ChestScreen)
	end)
	Flamework.resolveDependency("rB8").GameEnded:bind(function()
		self:clearInventory()
		self.screenController:close(InventoryScreen)
		self.screenController:close(ChestScreen)
	end)
	self:bindControls()
end

function InventoryController.registerItemPrediction(
	self: InventoryController,
	itemType: string,
	quantity: number
): string
	local predictionId = HttpService:GenerateGUID(false)
	self:updateInventory(itemType, quantity, nil, true)
	self.itemPredictions[predictionId] = {
		["Type"] = itemType,
		["Quantity"] = quantity,
	}
	Events.ItemPickup(itemType, quantity, predictionId)
	return predictionId
end

function InventoryController.updateInventory(
	self: InventoryController,
	itemType: string,
	quantity: number,
	predictionId: string?,
	silent: boolean?
)
	if silent == nil then
		silent = false
	end
	local isPredicted
	if predictionId == "" or not predictionId then
		isPredicted = predictionId
	else
		isPredicted = self.itemPredictions[predictionId] ~= nil
	end
	if isPredicted == "" or not isPredicted then
		local inventory = GlobalStore:getState().Inventory
		local activeSlot = GlobalStore:getState().ActiveSlot
		local result = InventoryUtil.updatePlayerInventory(inventory, itemType, quantity)
		if result.updated then
			Flamework.resolveDependency("zG"):setValue("Inventory", result.inventory)
			if result.slotId == activeSlot then
				Flamework.resolveDependency("Dqk"):updateActiveItem(silent)
			else
				local _ = Items[itemType]
			end
		else
			return nil
		end
	else
		self.itemPredictions[predictionId] = nil
		return nil
	end
end

function InventoryController.clearInventory(_)
	local inventory = GlobalStore:getState().Inventory
	local newInventory = InventoryUtil.cloneInventory(inventory)
	table.clear(newInventory.Contents)
	Flamework.resolveDependency("zG"):setValue("Inventory", newInventory)
end

function InventoryController.hasItem(_, itemType: string, quantity: number?, inventory: Inventory?): boolean
	local requiredQuantity = quantity == nil and 1 or quantity
	if inventory == nil then
		inventory = GlobalStore:getState().Inventory
	end
	for _, item in inventory.Contents do
		if item.Type == itemType then
			return requiredQuantity <= item.Quantity
		end
	end
	return false
end

function InventoryController.moveItem(self: InventoryController, itemType: string)
	local inventory = GlobalStore:getState().Inventory
	local item = InventoryUtil.findItem(inventory, itemType)
	if not item then
		return nil
	end
	local isInHotbar = item.Slot < HOTBAR_SIZE
	local emptySlot = InventoryUtil.findEmptySlot(inventory, not isInHotbar and 0 or HOTBAR_SIZE)
	if emptySlot == nil or not isInHotbar and HOTBAR_SIZE < emptySlot then
		return nil
	end
	self:moveItemToSlot(item, emptySlot)
end

function InventoryController.moveItemToSlot(_, item: InventoryItem, slot: number)
	local activeSlot = GlobalStore:getState().ActiveSlot
	local itemSlot = item.Slot
	Flamework.resolveDependency("zG"):moveItem(item, slot)
	if itemSlot == activeSlot or slot == activeSlot then
		Flamework.resolveDependency("Dqk"):updateActiveItem()
	end
end

function InventoryController.isInventoryOpen(self: InventoryController): boolean
	return self.screenController:isOpen("Inventory")
end

function InventoryController.toggleInventory(self: InventoryController)
	if self.screenController:closeFocusedScreens() then
		return nil
	end
	AwaitPlayerRoot()
	self.screenController:open(InventoryScreen, {})
end

function InventoryController.bindControls(self: InventoryController)
	UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return nil
		end
		if inputObject.UserInputState ~= Enum.UserInputState.Begin then
			return nil
		end
		if InputUtil.isToggleInventory(inputObject) then
			self:toggleInventory()
			return nil
		end
		local slot = HotbarController:getSlotFromKey(inputObject.KeyCode)
		if slot == nil then
			return nil
		end
		local localPlayer = Players.LocalPlayer
		local mouse = localPlayer:GetMouse()
		local count = 0
		local itemSlots = {}
		for index, guiObject in localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y) do
			local _ = index - 1
			if #{ string.find(guiObject.Name, "ItemSlot ") } ~= 0 == true then
				count = count + 1
				itemSlots[count] = guiObject
			end
		end
		local lastIndex = #itemSlots
		local topSlot = itemSlots[lastIndex]
		itemSlots[lastIndex] = nil
		if not topSlot then
			return nil
		end
		local slotName = string.gsub(topSlot.Name, "ItemSlot ", "")
		local slotNumber = tonumber(slotName)
		if slotNumber == nil or slotNumber == slot then
			return nil
		end
		local inventory = GlobalStore:getState().Inventory
		local itemAtSlot = inventory.Contents[slotNumber]
		if itemAtSlot then
			self:moveItemToSlot(itemAtSlot, slot)
			return nil
		end
		local itemAtTargetSlot = inventory.Contents[slot]
		if itemAtTargetSlot then
			self:moveItemToSlot(itemAtTargetSlot, slotNumber)
		end
	end)
end

Reflect.defineMetadata(InventoryController, "identifier", "qOA")
Reflect.defineMetadata(InventoryController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(InventoryController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(InventoryController, "$:flamework@Controller", Controller, {})
return {
	["InventoryController"] = InventoryController,
}
