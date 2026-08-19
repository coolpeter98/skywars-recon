-- BlacksmithShopScreen

type BlacksmithShopScreen = {
	new: (...any) -> BlacksmithShopScreen,
	constructor: (BlacksmithShopScreen, ...any) -> (),
	Component: (BlacksmithShopScreen) -> any,
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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local BlacksmithShopGui = RuntimeLib.import(script, script.Parent, "blacksmith-shop-gui").BlacksmithShopGui
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local BlacksmithShopScreen: BlacksmithShopScreen = setmetatable({}, {
	["__tostring"] = function()
		return "BlacksmithShopScreen"
	end,
	["__index"] = Screen,
})
BlacksmithShopScreen.__index = BlacksmithShopScreen

function BlacksmithShopScreen.new(...)
	local class = BlacksmithShopScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function BlacksmithShopScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(BlacksmithShopGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(0.5, 0, 0.5, -50),
		})
	end
end

Reflect.defineMetadata(BlacksmithShopScreen, "identifier", "QrM")
Reflect.decorate(BlacksmithShopScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "BlacksmithShop",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["IsInventoryGroup"] = true,
		["CloseOnDeath"] = true,
	},
})

return {
	["BlacksmithShopScreen"] = BlacksmithShopScreen,
}
