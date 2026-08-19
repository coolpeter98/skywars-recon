-- GameScoreboardScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local GameScoreboardGui = RuntimeLib.import(script, script.Parent, "game-scoreboard-gui").GameScoreboardGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local useScreenDependency = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-screen-dependency").useScreenDependency
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState

local GameScoreboardScreen = setmetatable({}, {
	["__tostring"] = function()
		return "GameScoreboardScreen"
	end,
	["__index"] = Screen
})
GameScoreboardScreen.__index = GameScoreboardScreen

function GameScoreboardScreen.new(...)
	local self = GameScoreboardScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function GameScoreboardScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local screenDependency = useScreenDependency({
			["ScreenId"] = "Lobby"
		})
		if useGlobalStore("GameState") == GameState.Ended then
			return React.createElement(React.Fragment)
		else
			return React.createElement(GameScoreboardGui, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, screenDependency.IsOpen and 198 or 15)
			})
		end
	end
end

Reflect.defineMetadata(GameScoreboardScreen, "identifier", "8m")
Reflect.decorate(GameScoreboardScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "GameScoreboard"
	}
})

return {
	["GameScoreboardScreen"] = GameScoreboardScreen
}
