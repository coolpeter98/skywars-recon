-- WizardShopScreen

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
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local WizardShopGui = RuntimeLib.import(script, script.Parent, "wizard-shop-gui").WizardShopGui

export type WizardShopScreen = {}

local WizardShopScreen = setmetatable({}, {
	["__tostring"] = function()
		return "WizardShopScreen"
	end,
	["__index"] = Screen,
})
WizardShopScreen.__index = WizardShopScreen

function WizardShopScreen.new(...): WizardShopScreen
	local self = setmetatable({}, WizardShopScreen)
	return self:constructor(...) or self
end

function WizardShopScreen.constructor(self: WizardShopScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(WizardShopGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
		})
	end
end

Reflect.defineMetadata(WizardShopScreen, "identifier", "q8b")
Reflect.decorate(WizardShopScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "WizardShop",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["IsInventoryGroup"] = true,
		["CloseOnDeath"] = true,
	},
})

return {
	["WizardShopScreen"] = WizardShopScreen,
}
