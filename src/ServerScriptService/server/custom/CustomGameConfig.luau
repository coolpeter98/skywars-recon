--!strict

local CustomGameConfig = {
	StoreNamespace = "skywars-custom-games-v1",
	RecordLifetime = 60 * 60 * 6,
	HeartbeatInterval = 10,
	ServerListLimit = 100,
	PrivateServerKeyLength = 6,
	TeleportRetryDelays = { 0, 0.5, 1.5 },
	CountdownDuration = 5,
	PostGameDuration = 10,
	-- SkyWars Octos is twelve teams of eight in the recovered client contract.
	MaximumServerPlayers = 96,
}

return CustomGameConfig
