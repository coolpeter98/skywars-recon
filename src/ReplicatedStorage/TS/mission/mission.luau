-- MissionTracker attribute keys, indexed by mission stat name.

type MissionTracker = {
	GamesPlayed: string,
	Wins: string,
	Kills: string,
	ChestsLooted: string,
}

local missionTracker: { MissionTracker: MissionTracker } = {
	MissionTracker = {
		GamesPlayed = "GamesPlayed",
		Wins = "Wins",
		Kills = "Kills",
		ChestsLooted = "ChestsLooted",
	},
}

return missionTracker
