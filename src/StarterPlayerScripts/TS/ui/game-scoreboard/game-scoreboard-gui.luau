-- GameScoreboardGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes
local DuelsScoreboard = RuntimeLib.import(script, script.Parent.Parent, "game", "duels-scoreboard").DuelsScoreboard
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GameTimer = RuntimeLib.import(script, script.Parent, "game-timer").GameTimer
local AlivePlayers = RuntimeLib.import(script, script.Parent, "alive-players").AlivePlayers
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
local GameStatus = RuntimeLib.import(script, script.Parent, "game-status").GameStatus

type GameScoreboardGuiProps = {
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["GameScoreboardGui"] = function(props: GameScoreboardGuiProps)
		local gameState = useGlobalStore("GameState")
		local gameStateChangeTime = useGlobalStore("GameStateChangeTime")
		local gameSettings = useGlobalStore("GameSettings")
		local players = useGlobalStore("Players")
		local duelsScore = useGlobalStore("DuelsScore")
		local spectating = useGlobalStore("Spectating")
		local customGame = useGlobalStore("CustomGame")
		if gameSettings ~= nil then
			gameSettings = gameSettings.MaxPlayers
		end
		local isDuelsServer = PlaceUtil.isDuelsServer()
		if isDuelsServer then
			customGame = isDuelsServer
		elseif customGame then
			customGame = GameModes[customGame.ServerData.Settings.GameMode].GameType == "Duels"
		end
		local scoreboardElement
		if customGame then
			scoreboardElement = React.createElement(DuelsScoreboard, {
				["DuelsScore"] = duelsScore or {}
			})
		else
			local alivePlayersProps = {
				["Alive"] = #players,
				["Total"] = gameSettings == nil and 0 or gameSettings
			}
			scoreboardElement = React.createElement(AlivePlayers, alivePlayersProps)
		end
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}
		local timerElement
		if gameState == GameState.InGame then
			timerElement = React.createElement(GameTimer, {
				["StartTime"] = gameStateChangeTime
			})
		else
			timerElement = nil
		end
		local contentLayout = createElement(grid, gridProps, scoreboardElement, timerElement, React.createElement(List, {
			["Vertical"] = customGame,
			["VerticalAlignment"] = Enum.VerticalAlignment.Top
		}))
		local gameStatusProps = {
			["GameState"] = gameState,
			["GameStateChangeTime"] = gameStateChangeTime
		}
		if spectating ~= nil then
			spectating = spectating.Name
		end
		gameStatusProps.Spectating = spectating
		return React.createElement(Grid, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, contentLayout, React.createElement(GameStatus, gameStatusProps), React.createElement(List, {
			["Vertical"] = true
		}))
	end
}
