--!strict

local CustomGameConfig = {
	StoreNamespace = "skywars-custom-games-v1",
	RecordLifetime = 60 * 60 * 6,
	HeartbeatInterval = 10,
	-- Browser records are only leases. If a server misses several heartbeats
	-- (for example after an unclean shutdown), stop showing it rather than
	-- leaving an empty custom game listed for the full record lifetime.
	ServerStaleAfter = 45,
	AdmissionValidationTimeout = 5,
	AdmissionValidationInterval = 0.25,
	ServerListLimit = 100,
	PrivateServerKeyLength = 6,
	TeleportRetryDelays = { 0, 0.5, 1.5 },
	-- The caged countdown: 4 centre-screen Title beats (4, 3, 2, 1 — the
	-- first beat is silent, the recovered voice sounds follow from "3") and
	-- then GO with the cages dropping.
	CountdownDuration = 4,
	PostGameDuration = 10,
	-- SkyWars Octos is twelve teams of eight in the recovered client contract.
	MaximumServerPlayers = 96,
}

return CustomGameConfig
