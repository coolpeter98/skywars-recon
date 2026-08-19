-- ChestScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local ChestGui = RuntimeLib.import(script, script.Parent, "chest-gui").ChestGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ChestScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ChestScreen"
	end,
	["__index"] = Screen
})
ChestScreen.__index = ChestScreen
function ChestScreen.new(...)
	local cls = ChestScreen
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end
function ChestScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(ChestGui)
	end
end
Reflect.defineMetadata(ChestScreen, "identifier", "8l7")
Reflect.decorate(ChestScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Chest",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["IsInventoryGroup"] = true,
		["CloseOnDeath"] = true
	}
})
return {
	["ChestScreen"] = ChestScreen
}
