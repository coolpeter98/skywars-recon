--!strict

local RuntimeContext = {
	Version = 1,
	TeleportDataKey = "SkyWarsContext",
	Attribute = {
		Role = "SkyWarsServerRole",
		GameMode = "SkyWarsGameMode",
		QueueId = "SkyWarsQueueId",
		MatchId = "SkyWarsMatchId",
		Production = "SkyWarsProduction",
	},
	Role = {
		Lobby = "Lobby",
		Game = "Game",
		Private = "Private",
	},
}

return {
	["RuntimeContext"] = RuntimeContext,
}
