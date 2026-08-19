-- QuickShopScreen

type QuickShopScreen = {
	new: (...any) -> QuickShopScreen,
	constructor: (QuickShopScreen, ...any) -> (),
	Component: (QuickShopScreen, any) -> any,
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
local QuickShopGui = RuntimeLib.import(script, script.Parent, "quick-shop-gui").QuickShopGui
local RadialPrompt =
	RuntimeLib.import(script, script.Parent.Parent, "components", "radial-prompt", "radial-prompt").RadialPrompt

local QuickShopScreen: QuickShopScreen = setmetatable({}, {
	["__tostring"] = function()
		return "QuickShopScreen"
	end,
	["__index"] = Screen,
})
QuickShopScreen.__index = QuickShopScreen

function QuickShopScreen.new(...)
	local class = QuickShopScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function QuickShopScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(RadialPrompt, {
			["Model"] = props.Model,
		}, React.createElement(QuickShopGui))
	end
end

Reflect.defineMetadata(QuickShopScreen, "identifier", "5Bg")
Reflect.decorate(QuickShopScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "QuickShop",
		["Focused"] = true,
		["FocusedNoBlur"] = true,
		["FocusedAllowClose"] = false,
		["LockCursor"] = true,
	},
})

return {
	["QuickShopScreen"] = QuickShopScreen,
}
