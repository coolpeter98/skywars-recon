-- ScreenController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local GuiService: GuiService = Services.GuiService
local Players: Players = Services.Players
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local getScreenOptions = RuntimeLib.import(script, script.Parent.Parent, "ui", "screen-decorator").getScreenOptions
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

type ScreenHandler = {
	Handler: {
		ScreenId: string,
		ScreenName: string,
		Options: {
			AllowMultiple: boolean?,
			Focused: boolean?,
			DisableCrosshair: boolean?,
			FocusedAllowMovement: boolean?,
			FocusedNoBlur: boolean?,
			IsInventoryGroup: boolean?,
			CloseOnDeath: boolean?,
			DisableHealthBar: boolean?,
			LockCursor: boolean?,
		},
	},
	open: () -> (),
	close: () -> (),
	addCloseHandler: (callback: () -> ()) -> (),
}

type ScreenController = {
	ScreenOpenedEvent: any,
	ScreenClosedEvent: any,
	screens: { [string]: { [string]: ScreenHandler } },
	disableCrosshair: number,
}

local ScreenController = setmetatable({}, {
	["__tostring"] = function()
		return "ScreenController"
	end
})
ScreenController.__index = ScreenController

function ScreenController.new(...)
	local self = ScreenController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function ScreenController.constructor(self: ScreenController)
	self.ScreenOpenedEvent = AsyncEvent.new()
	self.ScreenClosedEvent = AsyncEvent.new()
	self.screens = {}
	self.disableCrosshair = 0
end

function ScreenController.onStart(self: ScreenController)
	Flamework.resolveDependency("rB8").GameEnded:bind(function()
		self:handleDeath()
	end)
	Events.Spectate:connect(function()
		self:handleDeath()
	end)
	Events.PlayerEliminated:connect(function(player)
		if Players.LocalPlayer == player then
			self:handleDeath()
		end
	end)
end

function ScreenController.handleDeath(self: ScreenController)
	local screensToClose = {}
	for screenId, screenHandlers in self.screens do
		for _, screenHandler in screenHandlers do
			if screenHandler.Handler.Options.CloseOnDeath then
				screensToClose[screenId] = true
			end
		end
	end
	for screenId in screensToClose do
		self:closeScreenId(screenId)
	end
end

function ScreenController.open(self: ScreenController, screenController, args)
	local screenHandler = screenController.new(args)
	local options = screenHandler.Handler.Options
	local screenId = options.ScreenId
	if not options.AllowMultiple and self.screens[screenId] ~= nil then
		self:close(screenController)
	end
	if options.Focused then
		self:closeFocusedScreens()
	end
	if options.DisableCrosshair then
		self.disableCrosshair = self.disableCrosshair + 1
	end
	screenHandler:addCloseHandler(function()
		if options.Focused then
			self:disableFocus()
		end
		if options.DisableCrosshair then
			local self = self
			self.disableCrosshair = self.disableCrosshair - 1
		end
		self:delete(screenHandler)
		self.ScreenClosedEvent:fire({
			["screenHandler"] = screenHandler.Handler
		})
	end)
	self:save(screenHandler)
	screenHandler:open()
	if options.Focused then
		self:enableFocus(screenHandler)
	end
	self.ScreenOpenedEvent:fire({
		["screenHandler"] = screenHandler.Handler
	})
	return screenHandler
end

function ScreenController.close(self: ScreenController, screenController)
	return self:closeScreenId(getScreenOptions(screenController)[1].ScreenId)
end

function ScreenController.closeScreenId(self: ScreenController, screenId: string): boolean
	local screenHandlers = self.screens[screenId]
	if not screenHandlers then
		return false
	end
	for _, screenHandler in screenHandlers do
		screenHandler:close()
	end
	return true
end

function ScreenController.toggle(self: ScreenController, screenController): boolean
	if self:isOpen(getScreenOptions(screenController)[1].ScreenId) then
		self:close(screenController)
		return false
	else
		self:open(screenController, {})
		return true
	end
end

function ScreenController.isOpen(self: ScreenController, screenId: string): boolean
	return self.screens[screenId] ~= nil
end

function ScreenController.getOpenCount(self: ScreenController, screenId: string): number
	local screens = self.screens[screenId]
	if screens ~= nil then
		screens = 0
		for _ in screens do
			screens = screens + 1
		end
	end
	return screens == nil and 0 or screens
end

function ScreenController.save(self: ScreenController, screenHandler: ScreenHandler)
	local screenId = screenHandler.Handler.ScreenId
	if self.screens[screenId] == nil then
		self.screens[screenId] = {}
	end
	self.screens[screenId][screenHandler.Handler.ScreenName] = screenHandler
end

function ScreenController.delete(self: ScreenController, screenHandler: ScreenHandler)
	local screenId = screenHandler.Handler.ScreenId
	local screenHandlers = self.screens[screenId]
	if not screenHandlers then
		return nil
	end
	local screenName = screenHandler.Handler.ScreenName
	local existed = screenHandlers[screenName] ~= nil
	screenHandlers[screenName] = nil
	if not existed then
		return nil
	end
	if next(screenHandlers) == nil then
		self.screens[screenId] = nil
	end
end

function ScreenController.closeFocusedScreens(self: ScreenController): boolean
	local closedAny = false
	for screenId in self.screens do
		local screenInfo = getScreenOptions(screenId)
		local options = screenInfo[1]
		local screenController = screenInfo[2]
		if options.Focused then
			self:close(screenController)
			closedAny = true
		end
	end
	return closedAny
end

function ScreenController.enableFocus(self: ScreenController, screenHandler: ScreenHandler)
	local options = screenHandler.Handler.Options
	local allowMovement
	if options.FocusedAllowMovement == true then
		allowMovement = not InputUtil.isGamepadEnabled()
	else
		allowMovement = false
	end
	local noBlur = options.FocusedNoBlur == true
	Flamework.resolveDependency("Z6E"):enableFocus(allowMovement, noBlur)
	if InputUtil.isGamepadEnabled() then
		self:enableGamepadFocus(screenHandler)
	end
end

function ScreenController.disableFocus(_)
	Flamework.resolveDependency("Z6E"):disableFocus()
	if InputUtil.isGamepadEnabled() then
		GuiService:RemoveSelectionGroup("FocusGroup")
		GuiService.SelectedObject = nil
	end
end

function ScreenController.enableGamepadFocus(_, screenHandler: ScreenHandler)
	local playerGui = Players.LocalPlayer.PlayerGui
	local isInventoryGroup = screenHandler.Handler.Options.IsInventoryGroup == true
	local screenGui = playerGui:FindFirstChild(screenHandler.Handler.ScreenName)
	if screenGui then
		local count = 0
		local selectableObjects = {}
		for index, object in screenGui:GetDescendants() do
			local _ = index - 1
			local isSelectable = object:IsA("GuiObject")
			if isSelectable then
				isSelectable = object.Selectable
			end
			if isSelectable == true then
				count = count + 1
				selectableObjects[count] = object
			end
		end
		local guiService = GuiService
		local firstObject
		if #selectableObjects > 0 then
			firstObject = selectableObjects[1]
		else
			firstObject = nil
		end
		guiService.SelectedObject = firstObject
		local selectedObject = guiService.SelectedObject
		if selectedObject ~= nil then
			selectedObject = selectedObject.Name
		end
		print((("FORCED SELECTED OBJECT TO: %*"):format(selectedObject)))
		if not isInventoryGroup then
			print("ADDING SELECTION GROUP: " .. screenHandler.Handler.ScreenName)
			local rootCount = 0
			local frames = {}
			for index, frame in screenGui:GetChildren() do
				local _ = index - 1
				local isRoot = frame:IsA("Frame")
				if isRoot then
					isRoot = frame.Name ~= "CloseFrame"
				end
				if isRoot == true then
					rootCount = rootCount + 1
					frames[rootCount] = frame
				end
			end
			if #frames ~= 1 then
				print((("UNABLE TO FIND SELECTION ROOT %*"):format(#frames)))
				return
			end
			local rootIndex = #frames
			local selectionRoot = frames[rootIndex]
			frames[rootIndex] = nil
			print("PRI: " .. selectionRoot.Name)
			GuiService:AddSelectionParent("FocusGroup", selectionRoot)
		end
	end
end

function ScreenController.isFocused(_): boolean
	return Flamework.resolveDependency("Z6E"):isFocused()
end

function ScreenController.isHealthBarDisabled(self: ScreenController): boolean
	for _, screenHandlers in self.screens do
		for _, screenHandler in screenHandlers do
			if screenHandler.Handler.Options.DisableHealthBar then
				return true
			end
		end
	end
	return false
end

function ScreenController.isCursorLocked(self: ScreenController): boolean
	for _, screenHandlers in self.screens do
		for _, screenHandler in screenHandlers do
			if screenHandler.Handler.Options.LockCursor then
				return true
			end
		end
	end
	return false
end

function ScreenController.shouldHideCrosshair(self: ScreenController): boolean
	return self:isFocused() or Flamework.resolveDependency("XNg"):isInWinEffect() or self.disableCrosshair > 0
end

Reflect.defineMetadata(ScreenController, "identifier", "lB5")
Reflect.defineMetadata(ScreenController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ScreenController, "$:flamework@Controller", Controller, {})
return {
	["ScreenController"] = ScreenController
}
