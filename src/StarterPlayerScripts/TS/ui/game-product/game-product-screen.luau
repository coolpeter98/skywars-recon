-- GameProductScreen

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
local GameProductGui = RuntimeLib.import(script, script.Parent, "game-product-gui").GameProductGui
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ComponentProps = {
	ProductId: string,
	Price: number,
}

local GameProductScreen = setmetatable({}, {
	["__tostring"] = function()
		return "GameProductScreen"
	end,
	["__index"] = Screen,
})
GameProductScreen.__index = GameProductScreen

function GameProductScreen.new(...)
	local self = setmetatable({}, GameProductScreen)
	return self:constructor(...) or self
end

function GameProductScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(props: ComponentProps)
		return React.createElement(GameProductGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
			["ProductId"] = props.ProductId,
			["Price"] = props.Price,
		})
	end
end

Reflect.defineMetadata(GameProductScreen, "identifier", "xPl")
Reflect.decorate(GameProductScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "GameProduct",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["GameProductScreen"] = GameProductScreen,
}
