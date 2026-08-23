--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage.TS.game["game-constants"]).GameConstants

local RoundConfig = {
	PregameDuration = GameConstants.PREGAME_DURATION,
	CountdownDuration = 4,
	PostGameDuration = 10,
	PublicArrivalTimeout = 20,
}

return RoundConfig
