-- CosmeticsShopScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local CosmeticsShopGui = RuntimeLib.import(script, script.Parent, "cosmetics-shop-gui").CosmeticsShopGui
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CosmeticsShopScreen = {}

local CosmeticsShopScreen = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticsShopScreen"
	end,
	["__index"] = Screen
})
CosmeticsShopScreen.__index = CosmeticsShopScreen

function CosmeticsShopScreen.new(...)
	local class = CosmeticsShopScreen
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function CosmeticsShopScreen.constructor(self: CosmeticsShopScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(CosmeticsShopGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0)
		})
	end
end

Reflect.defineMetadata(CosmeticsShopScreen, "identifier", "NkX")
Reflect.decorate(CosmeticsShopScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "CosmeticsShop",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["DisableDock"] = true,
		["ShowBackground"] = true,
		["MobileScale"] = nil,
		["MobileScale"] = ScreenUtil.isTablet() and 1 or 1.24
	}
})

return {
	["CosmeticsShopScreen"] = CosmeticsShopScreen
}
