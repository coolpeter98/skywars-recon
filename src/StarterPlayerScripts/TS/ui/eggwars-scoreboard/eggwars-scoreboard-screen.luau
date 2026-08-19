-- EggwarsScoreboardScreen

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
local EggwarsScoreboardGui = RuntimeLib.import(script, script.Parent, "eggwars-scoreboard-gui").EggwarsScoreboardGui
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local GameScoreboardGui =
	RuntimeLib.import(script, script.Parent.Parent, "game-scoreboard", "game-scoreboard-gui").GameScoreboardGui
local useScreenDependency =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-screen-dependency").useScreenDependency

local EggwarsScoreboardScreen = setmetatable({}, {
	["__tostring"] = function()
		return "EggwarsScoreboardScreen"
	end,
	["__index"] = Screen,
})
EggwarsScoreboardScreen.__index = EggwarsScoreboardScreen

type EggwarsScoreboardScreen = typeof(EggwarsScoreboardScreen)

function EggwarsScoreboardScreen.new(...)
	local self = setmetatable({}, EggwarsScoreboardScreen)
	return self:constructor(...) or self
end

function EggwarsScoreboardScreen.constructor(self: EggwarsScoreboardScreen, ...)
	Screen.constructor(self, ...)

	function self.Component()
		local gameState = useGlobalStore("GameState")
		local screenDependency = useScreenDependency({
			["ScreenId"] = "Lobby",
		})

		if gameState == GameState.Pregame then
			return React.createElement(GameScoreboardGui, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, screenDependency.IsOpen and 198 or 15),
			})
		else
			return React.createElement(EggwarsScoreboardGui, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, screenDependency.IsOpen and 198 or 15),
			})
		end
	end
end

Reflect.defineMetadata(EggwarsScoreboardScreen, "identifier", "698")
Reflect.decorate(EggwarsScoreboardScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "EggwarsScoreboard",
	},
})

return {
	["EggwarsScoreboardScreen"] = EggwarsScoreboardScreen,
}
