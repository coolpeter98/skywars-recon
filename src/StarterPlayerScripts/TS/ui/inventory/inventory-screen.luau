-- InventoryScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local InventoryGui = RuntimeLib.import(script, script.Parent, "inventory-gui").InventoryGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

type Screen = typeof(Screen)
type InventoryScreen = typeof(setmetatable({} :: {}, { __index = Screen })) & typeof(Screen)

local InventoryScreen = setmetatable({} :: {}, {
	["__tostring"] = function()
		return "InventoryScreen"
	end,
	["__index"] = Screen,
}) :: InventoryScreen

InventoryScreen.__index = InventoryScreen

function InventoryScreen.new(...): InventoryScreen
	local self = setmetatable({}, InventoryScreen)
	return self:constructor(...) or self
end

function InventoryScreen.constructor(self: InventoryScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(InventoryGui)
	end
end

Reflect.defineMetadata(InventoryScreen, "identifier", "Qy3")
Reflect.decorate(InventoryScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Inventory",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["IsInventoryGroup"] = true,
		["CloseOnDeath"] = true
	}
})

return {
	["InventoryScreen"] = InventoryScreen
}
