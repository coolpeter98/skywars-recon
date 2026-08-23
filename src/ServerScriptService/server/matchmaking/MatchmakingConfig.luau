--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameModeModule = require(ReplicatedStorage.TS.game["game-mode"])
local GameModes = GameModeModule.GameModes
local ModeRegistry = require(script.Parent.Parent.modes.ModeRegistry)

export type ModeConfig = {
	GameMode: string,
	QueueId: string,
	TeamSize: number,
	MinimumPlayers: number,
	MaximumPlayers: number,
}

local MODE_ORDER = ModeRegistry.getQueueableGameModes()

local MatchmakingConfig = {
	StoreNamespace = "skywars-matchmaking-v1",
	TicketLifetime = 180,
	MatchLifetime = 300,
	QueueInvisibilityTimeout = 15,
	CoordinatorLeaseDuration = 8,
	MaximumWaitTime = 20,
	PollInterval = 1,
	WorkerInterval = 2,
	RetryDelays = { 0, 0.25, 0.75, 1.5 },
	ModeOrder = MODE_ORDER,
}

local modeConfigs: { [string]: ModeConfig } = {}
for _, gameMode in MODE_ORDER do
	local definition = GameModes[gameMode]
	local maximumPlayers = definition.TeamSize * definition.MaxTeams
	local minimumPlayers = math.min(maximumPlayers, definition.TeamSize * 2)
	if definition.GameType == "Duels" then
		minimumPlayers = maximumPlayers
	end
	modeConfigs[gameMode] = {
		GameMode = gameMode,
		QueueId = definition.Queue.Production,
		TeamSize = definition.TeamSize,
		MinimumPlayers = minimumPlayers,
		MaximumPlayers = maximumPlayers,
	}
end

function MatchmakingConfig.getMode(gameMode: string): ModeConfig?
	return modeConfigs[gameMode]
end

return MatchmakingConfig
