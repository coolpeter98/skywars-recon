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
	-- Roblox servers currently cap at 100 players; the largest registered mode
	-- (SkyWars Octos) uses 96.
	MaximumServerPlayers = 96,
}

return CustomGameConfig
