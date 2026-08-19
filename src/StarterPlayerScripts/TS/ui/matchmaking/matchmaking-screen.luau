-- MatchmakingScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local Searching = RuntimeLib.import(script, script.Parent.Parent, "game", "searching").Searching
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

local MatchmakingScreen = setmetatable({}, {
	["__tostring"] = function()
		return "MatchmakingScreen"
	end,
	["__index"] = Screen
})
type MatchmakingScreen = typeof(MatchmakingScreen)
MatchmakingScreen.__index = MatchmakingScreen

function MatchmakingScreen.new(...)
	local cls = MatchmakingScreen
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end

function MatchmakingScreen.constructor(self: MatchmakingScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local queueStartTime = useGlobalStore("QueueStartTime")
		local customGame = useGlobalStore("CustomGame")
		local gameState = useGlobalStore("GameState")
		local party = useGlobalStore("Party")
		if queueStartTime == nil then
			return React.createElement(React.Fragment)
		end
		local inLobby = PlaceUtil.isLobbyServer()
		if not inLobby then
			inLobby = PlaceUtil.isPrivateServer()
			if inLobby then
				if customGame ~= nil then
					customGame = customGame.ServerData.InGame
				end
				inLobby = customGame == false
			end
		end
		local hasGameEnded = gameState == GameState.Ended
		return React.createElement(Searching, {
			["QueueStartTime"] = queueStartTime,
			["InLobby"] = inLobby,
			["HasGameEnded"] = hasGameEnded,
			["Party"] = party
		})
	end
end

Reflect.defineMetadata(MatchmakingScreen, "identifier", "ry8")
Reflect.decorate(MatchmakingScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Matchmaking",
		["DisplayOrder"] = 2
	}
})

return {
	["MatchmakingScreen"] = MatchmakingScreen
}
