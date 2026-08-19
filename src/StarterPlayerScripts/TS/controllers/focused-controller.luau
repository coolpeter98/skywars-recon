-- FocusedController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local ContextActionService: ContextActionService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ContextActionService

type FocusedController = {
	coreController: any,
	effectController: any,
	topbarController: any,
	focused: boolean,
}

local FocusedController = setmetatable({}, {
	["__tostring"] = function()
		return "FocusedController"
	end
})
FocusedController.__index = FocusedController

function FocusedController.new(...)
	local self = FocusedController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function FocusedController.constructor(self: FocusedController, coreController: any, effectController: any, topbarController: any)
	self.coreController = coreController
	self.effectController = effectController
	self.topbarController = topbarController
	self.focused = false
end

function FocusedController.enableFocus(self: FocusedController, allowMovement: boolean, noBlur: boolean)
	if not allowMovement then
		local sinkActions = {}
		local initialCount = #sinkActions
		local playerActions = Enum.PlayerActions:GetEnumItems()
		local playerActionCount = #playerActions
		table.move(playerActions, 1, playerActionCount, initialCount + 1, sinkActions)
		local sinkActionCount = initialCount + playerActionCount
		sinkActions[sinkActionCount + 1] = Enum.KeyCode.Thumbstick1
		sinkActions[sinkActionCount + 2] = Enum.KeyCode.Thumbstick2
		sinkActions[sinkActionCount + 3] = Enum.KeyCode.ButtonR2
		ContextActionService:BindAction("SinkAction", function()
			return Enum.ContextActionResult.Sink
		end, false, unpack(sinkActions))
		Flamework.resolveDependency("Zw"):addJumpModifier("UiLock", 0)
		Flamework.resolveDependency("Zw"):addSpeedModifier("UiLock", 0)
	end
	local contextActionService = ContextActionService
	local priority = Enum.ContextActionPriority.High.Value
	local panInputTypes = { Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseWheel }
	contextActionService:BindActionAtPriority("SinkPan", function()
		return Enum.ContextActionResult.Sink
	end, false, priority, unpack(panInputTypes))
	self.coreController:disableJoystick()
	self.coreController:disableChat()
	self.coreController:disableProximityPrompts()
	self.topbarController:disableTopbar()
	if not noBlur then
		self.effectController:springBlur(20, 1, 3)
	end
	self.focused = true
end

function FocusedController.disableFocus(self: FocusedController)
	Flamework.resolveDependency("Zw"):removeJumpModifier("UiLock")
	Flamework.resolveDependency("Zw"):removeSpeedModifier("UiLock")
	ContextActionService:UnbindAction("SinkAction")
	ContextActionService:UnbindAction("SinkPan")
	self.coreController:enableJoystick()
	self.coreController:enableChat()
	self.coreController:enableProximityPrompts()
	self.topbarController:enableTopbar()
	self.effectController:removeBlur()
	self.focused = false
end

function FocusedController.isFocused(self: FocusedController): boolean
	return self.focused
end

Reflect.defineMetadata(FocusedController, "identifier", "Z6E")
Reflect.defineMetadata(FocusedController, "flamework:parameters", { "lw", "Or", "xWL" })
Reflect.decorate(FocusedController, "$:flamework@Controller", Controller, {})
return {
	["FocusedController"] = FocusedController
}
