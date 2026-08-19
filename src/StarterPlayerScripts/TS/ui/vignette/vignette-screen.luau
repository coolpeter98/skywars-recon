-- VignetteScreen

type VignetteScreen = {
	Component: () -> (),
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local VignetteScreen = setmetatable({}, {
	["__tostring"] = function()
		return "VignetteScreen"
	end,
	["__index"] = Screen
})
VignetteScreen.__index = VignetteScreen
function VignetteScreen.new(...): VignetteScreen
	local class = VignetteScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function VignetteScreen.constructor(self: VignetteScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local transparencySequence: NumberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.1, 1), NumberSequenceKeypoint.new(1, 1) })
		return React.createElement(React.Fragment, nil, React.createElement(Grid, {
			["key"] = "LeftCornerUpper",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = 45,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "LeftCornerLower",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = -45,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "RightCornerUpper",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = 135,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "RightCornerLower",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = -135,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "Top",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = 90,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "Bottom",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = -90,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "Left",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = 0,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})), React.createElement(Grid, {
			["key"] = "Right",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["BackgroundColor3"] = nil,
			["Active"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White
		}, React.createElement("uigradient", {
			["Rotation"] = 180,
			["Transparency"] = nil,
			["Transparency"] = transparencySequence
		})))
	end
end
Reflect.defineMetadata(VignetteScreen, "identifier", "bmx")
Reflect.decorate(VignetteScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Vignette",
		["DisplayOrder"] = -10
	}
})
return {
	["VignetteScreen"] = VignetteScreen
}
