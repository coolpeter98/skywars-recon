-- ShopScreen

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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ShopGui = RuntimeLib.import(script, script.Parent, "shop-gui").ShopGui

type ShopScreen = typeof(ShopScreen)

local ShopScreen: ShopScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ShopScreen"
	end,
	["__index"] = Screen,
})
ShopScreen.__index = ShopScreen

function ShopScreen.new(...)
	local self = ShopScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function ShopScreen.constructor(self: ShopScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(ShopGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0),
		})
	end
end

Reflect.defineMetadata(ShopScreen, "identifier", "LlE")
Reflect.decorate(ShopScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Shop",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["DisableDock"] = true,
		["ShowBackground"] = true,
		["MobileScale"] = 1,
	},
})

return {
	["ShopScreen"] = ShopScreen,
}
