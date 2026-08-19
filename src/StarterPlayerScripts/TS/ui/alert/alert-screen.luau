-- AlertScreen

type AlertScreen = {
	new: (...any) -> AlertScreen,
	constructor: (AlertScreen, ...any) -> (),
	Component: (AlertScreen, { Icon: any, Text: any, Color: any }) -> any,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local AlertGui = RuntimeLib.import(script, script.Parent, "alert-gui").AlertGui

local AlertScreen: AlertScreen = setmetatable({}, {
	["__tostring"] = function()
		return "AlertScreen"
	end,
	["__index"] = Screen,
})
AlertScreen.__index = AlertScreen

function AlertScreen.new(...)
	local class = AlertScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function AlertScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(AlertGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 176),
			["Icon"] = props.Icon,
			["Text"] = props.Text,
			["Color"] = props.Color,
		})
	end
end

Reflect.defineMetadata(AlertScreen, "identifier", "Yjw")
Reflect.decorate(AlertScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Alert",
	},
})

return {
	["AlertScreen"] = AlertScreen,
}
