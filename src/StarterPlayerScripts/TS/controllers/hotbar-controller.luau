-- HotbarController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local AwaitPlayerRoot = RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitPlayerRoot
local HOTBAR_SIZE = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants").HOTBAR_SIZE
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local ToolUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "tool-util").ToolUtil
local HotbarScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "hotbar", "hotbar-screen").HotbarScreen
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local GameConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

type HotbarController = {
	screenController: any,
	ActiveItemUpdated: any,
	lastActiveSlot: number?,
	lastHeldItem: any?,
	idleTrack: AnimationTrack?,
	running: boolean,
}

local HotbarController = setmetatable({}, {
	["__tostring"] = function()
		return "HotbarController"
	end
})
HotbarController.__index = HotbarController

function HotbarController.new(...)
	local self = setmetatable({}, HotbarController)
	return self:constructor(...) or self
end

function HotbarController.constructor(self: HotbarController, screenController: any)
	self.screenController = screenController
	self.ActiveItemUpdated = AsyncEvent.new()
	self.lastActiveSlot = nil
	self.lastHeldItem = nil
	self.idleTrack = nil
	self.running = false
end

function HotbarController.onStart(self: HotbarController)
	Flamework.resolveDependency("1LA").SetSpectating:bind(function(spectatingEvent)
		local isSpectating = spectatingEvent.spectating
		local customGame = GlobalStore:getState().CustomGame
		if customGame ~= nil then
			customGame = customGame.ServerData.InGame
		end
		local inGame = customGame == true or PlaceUtil.isGameServer()
		if Players.LocalPlayer:GetAttribute(Attribute.Alive) == true and (not isSpectating and inGame) then
			self:onGameStart(Maid.new())
		end
	end)
end

function HotbarController.onGameStart(self: HotbarController, maid)
	if Flamework.resolveDependency("1LA"):isSpectating() or self.running then
		return nil
	end
	self.running = true
	self:setupHotbar(maid)
	maid:GiveTask(function()
		self.running = false
	end)
	maid:GiveTask(Flamework.resolveDependency("1LA").SetSpectating:bind(function(spectatingEvent)
		if spectatingEvent.spectating then
			maid:DoCleaning()
		end
	end))
	if GameConstants.POST_GAME_LOBBY_ENABLED then
		maid:GiveTask(Events.PlayerEliminated:connect(function(player)
			if Players.LocalPlayer == player then
				maid:DoCleaning()
			end
		end))
	end
	maid:GiveTask(Flamework.resolveDependency("rB8").GameEnded:bind(function()
		maid:DoCleaning()
	end))
end

function HotbarController.displayActionBar(self, _, _)
end

function HotbarController.getHeldItemInfo(self: HotbarController)
	local state = GlobalStore:getState()
	local foundItem = nil
	for _, slot in state.Inventory.Contents do
		if slot.Slot == state.ActiveSlot then
			foundItem = slot
			break
		end
	end
	if foundItem == nil then
		return nil
	else
		return Items[foundItem.Type]
	end
end

function HotbarController.getSword(self: HotbarController)
	for _, item in self:getHotbarItems() do
		local itemInfo = Items[item.Type]
		if itemInfo.Melee then
			return itemInfo
		end
	end
end

function HotbarController.getHotbarItems(self: HotbarController): { any }
	local inventory = GlobalStore:getState().Inventory
	local items = {}
	for slotIndex = 0, HOTBAR_SIZE - 1 do
		local item = inventory.Contents[slotIndex]
		if item then
			table.insert(items, item)
		end
	end
	return items
end

function HotbarController.setupHotbar(self: HotbarController, maid)
	self.screenController:open(HotbarScreen, {})
	maid:GiveTask(function()
		self.screenController:close(HotbarScreen)
	end)
	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return nil
		end
		if self.screenController:isFocused() then
			return nil
		end
		local activeSlot = GlobalStore:getState().ActiveSlot
		local slotId = HotbarController:getSlotFromKey(input.KeyCode)
		if slotId == nil or slotId == activeSlot then
			return nil
		end
		self:setActiveSlot(slotId)
	end))
	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return nil
		end
		if self.screenController:isFocused() then
			return nil
		end
		if not InputUtil.isCycle(input) then
			return nil
		end
		self:setActiveSlot((GlobalStore:getState().ActiveSlot + (InputUtil.isCycleLeft(input) and -1 or 1)) % 8)
	end))
	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isDropItem(input) then
			return nil
		end
		if not self:getHeldItemInfo() then
			return nil
		end
		Events.UseHeldItem:fire()
	end))
	task.spawn(function()
		AwaitPlayerRoot()
		self:updateActiveItem()
	end)
	maid:GiveTask(Players.LocalPlayer.CharacterRemoving:Connect(function()
		local idleTrack = self.idleTrack
		if idleTrack ~= nil then
			idleTrack:Destroy()
		end
		self.idleTrack = nil
		task.defer(function()
			AwaitPlayerRoot()
			self:updateActiveItem()
		end)
	end))
	maid:GiveTask(self.screenController.ScreenOpenedEvent:bind(function(screenOpenedEvent)
		if screenOpenedEvent.screenHandler.Options.DisableDock then
			self.screenController:close(HotbarScreen)
		end
	end))
	maid:GiveTask(self.screenController.ScreenClosedEvent:bind(function(screenClosedEvent)
		if screenClosedEvent.screenHandler.Options.DisableDock then
			self.screenController:open(HotbarScreen, {})
		end
	end))
end

function HotbarController.setActiveSlot(self: HotbarController, slotId: number)
	Flamework.resolveDependency("zG"):setValue("ActiveSlot", slotId)
	self:updateActiveItem()
end

function HotbarController.updateActiveItem(self: HotbarController, silent: boolean?)
	if silent == nil then
		silent = false
	end
	local activeSlot = GlobalStore:getState().ActiveSlot
	local heldItem = self:getHeldItemInfo()
	local prevHeldItemName
	if heldItem == nil then
		prevHeldItemName = heldItem
	else
		prevHeldItemName = heldItem.Name
	end
	if heldItem and heldItem.Rewrite then
		local teamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
		local teamName = teamId == nil and "White" or teamId
		heldItem = Items[string.gsub(heldItem.Rewrite.Type, "{TeamId}", teamName)]
	end
	local character = Players.LocalPlayer.Character
	local heldTool = nil
	if character then
		for _, tool in character:GetChildren() do
			if tool:IsA("Tool") then
				local toolName = tool.Name
				local itemName
				if heldItem == nil then
					itemName = heldItem
				else
					itemName = heldItem.Name
				end
				if toolName == itemName then
					heldTool = tool
				else
					tool:Destroy()
				end
			end
		end
	end
	if heldItem and not heldTool then
		local skinId = Flamework.resolveDependency("Ggz"):getActiveSkinFromItem(heldItem.Name)
		local tool = Flamework.resolveDependency("Ggz"):getTool(heldItem.Name)
		local currentCharacter = Players.LocalPlayer.Character
		if currentCharacter then
			local skinInfo
			if skinId == nil then
				skinInfo = nil
			else
				skinInfo = Cosmetics[skinId]
			end
			if skinInfo and (skinInfo.Type == "Skin" and skinInfo.DualWield) or heldItem.DualWield == true then
				ToolUtil.weldTool(currentCharacter, tool:Clone(), false)
				ToolUtil.weldTool(currentCharacter, tool:Clone(), true)
			else
				local leftHanded = heldItem.LeftHanded
				if leftHanded == nil then
					leftHanded = false
				end
				ToolUtil.weldTool(currentCharacter, tool, leftHanded)
			end
		end
	end
	self.ActiveItemUpdated:fire({
		["heldItemInfo"] = heldItem,
		["slotId"] = activeSlot,
		["lastHeldItem"] = self.lastHeldItem,
		["lastActiveSlot"] = self.lastActiveSlot
	})
	self.lastHeldItem = heldItem
	self.lastActiveSlot = activeSlot
	if not silent then
		Events.HeldItemChanged:fire(prevHeldItemName)
	end
	return heldItem
end

function HotbarController.getSlotFromKey(self: HotbarController, keyCode: Enum.KeyCode): number?
	local slot = keyCode.Value - Enum.KeyCode.One.Value
	if slot < 0 or slot > 7 then
		return nil
	else
		return slot
	end
end

Reflect.defineMetadata(HotbarController, "identifier", "Dqk")
Reflect.defineMetadata(HotbarController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(HotbarController, "flamework:implements", { "$:flamework@OnStart", "VNB" })
Reflect.decorate(HotbarController, "$:flamework@Controller", Controller, {})
return {
	["HotbarController"] = HotbarController
}
