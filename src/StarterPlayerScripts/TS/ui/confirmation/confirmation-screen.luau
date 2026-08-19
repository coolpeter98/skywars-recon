-- ConfirmationScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Confirmation = RuntimeLib.import(script, script.Parent, "confirmation").Confirmation
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ConfirmationScreen = {
	new: (...any) -> ConfirmationScreen,
	constructor: (self: ConfirmationScreen, ...any) -> (),
	Component: (props: any) -> any
}

local ConfirmationScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ConfirmationScreen"
	end,
	["__index"] = Screen
})
ConfirmationScreen.__index = ConfirmationScreen
function ConfirmationScreen.new(...)
	local self = ConfirmationScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function ConfirmationScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(Confirmation, {
			["Text"] = props.Text,
			["OnConfirm"] = props.OnConfirm,
			["IsOpen"] = props.IsOpen,
			["Close"] = props.Close,
			["SubmittedText"] = props.SubmittedText,
			["CloseDelay"] = props.CloseDelay
		})
	end
end
Reflect.defineMetadata(ConfirmationScreen, "identifier", "w81")
Reflect.decorate(ConfirmationScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Confirmation",
		["Focused"] = true
	}
})
return {
	["ConfirmationScreen"] = ConfirmationScreen
}
