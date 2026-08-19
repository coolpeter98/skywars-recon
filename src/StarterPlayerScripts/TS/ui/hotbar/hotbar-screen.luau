-- HotbarScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local HotbarGui = RuntimeLib.import(script, script.Parent, "hotbar-gui").HotbarGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local HotbarScreen = setmetatable({}, {
	["__tostring"] = function()
		return "HotbarScreen"
	end,
	["__index"] = Screen
})
HotbarScreen.__index = HotbarScreen
function HotbarScreen.new(...)
	local cls = HotbarScreen
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end
function HotbarScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(HotbarGui, {
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(0.5, 0, 1, -15)
		})
	end
end
Reflect.defineMetadata(HotbarScreen, "identifier", "7Gl")
Reflect.decorate(HotbarScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Hotbar",
		["IsInventoryGroup"] = true
	}
})
return {
	["HotbarScreen"] = HotbarScreen
}
