-- GameCurrencyScreen

type GameCurrencyScreen = typeof(GameCurrencyScreen)

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local GameCurrencyGui = RuntimeLib.import(script, script.Parent, "game-currency-gui").GameCurrencyGui
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local GameCurrencyScreen = setmetatable({}, {
	["__tostring"] = function()
		return "GameCurrencyScreen"
	end,
	["__index"] = Screen
})
GameCurrencyScreen.__index = GameCurrencyScreen

function GameCurrencyScreen.new(...)
	local self = GameCurrencyScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function GameCurrencyScreen.constructor(self: GameCurrencyScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		if PlaceUtil.isEggWarsServer() then
			return React.createElement(GameCurrencyGui, {
				["AnchorPoint"] = Vector2.new(1, 1),
				["Position"] = UDim2.new(0.5, 487, 1, -176)
			})
		else
			return React.createElement(React.Fragment)
		end
	end
end

Reflect.defineMetadata(GameCurrencyScreen, "identifier", "z6y")
Reflect.decorate(GameCurrencyScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "GameCurrency"
	}
})

return {
	["GameCurrencyScreen"] = GameCurrencyScreen
}
