--!strict
-- PlayerDataRules
--
-- Pure mapping between the persisted PlayerData document and the runtime
-- client profile. No Roblox API dependencies, so this runs under Lune
-- (tools/test_player_data_rules.luau).
--
-- The persisted document is deliberately NOT the raw client profile shape:
-- progression lives under a versioned Stats namespace (see PlayerDataSchema)
-- so future systems (missions, per-mode history, new season formats) can
-- evolve the document without touching the client's runtime profile.

export type QueueStats = {
	Wins: number,
	WinStreak: number,
	Losses: number,
	Kills: number,
	Deaths: number,
	DamageDealt: number,
	DamageTaken: number,
}

export type PlayerData = {
	Stats: {
		Experience: number,
		SeasonExperience: { [string]: number },
		Queues: { [string]: QueueStats },
	},
}

local QUEUE_STAT_FIELDS = {
	"Wins",
	"WinStreak",
	"Losses",
	"Kills",
	"Deaths",
	"DamageDealt",
	"DamageTaken",
}

local function toNumber(value: any, fallback: number): number
	return if type(value) == "number" then value else fallback
end

function emptyQueueStats(): QueueStats
	return {
		Wins = 0,
		WinStreak = 0,
		Losses = 0,
		Kills = 0,
		Deaths = 0,
		DamageDealt = 0,
		DamageTaken = 0,
	}
end

function initialPlayerData(): PlayerData
	return {
		Stats = {
			Experience = 0,
			SeasonExperience = {},
			Queues = {},
		},
	}
end

function copyQueueStats(source: { [string]: any }): QueueStats
	local copy = emptyQueueStats()
	for _, field in QUEUE_STAT_FIELDS do
		copy[field] = toNumber(source[field], 0)
	end
	return copy
end

-- Applies a loaded document onto the runtime profile. Only the fields the
-- document owns are touched; everything else keeps the client's defaults.
function applyPlayerData(profile: { [string]: any }, data: PlayerData)
	local stats = data.Stats
	profile.Experience = toNumber(stats.Experience, 0)

	local season = profile.Season
	if type(season) == "table" then
		local seasonData = season.SeasonData
		if type(seasonData) ~= "table" then
			seasonData = {}
			season.SeasonData = seasonData
		end
		for seasonId, experience in stats.SeasonExperience do
			if type(experience) == "number" then
				local entry = seasonData[seasonId]
				if type(entry) ~= "table" then
					entry = {
						Experience = 0,
						CurrentTierId = 1,
						AwardedTiers = {},
					}
					seasonData[seasonId] = entry
				end
				entry.Experience = experience
			end
		end
	end

	local profileStats = profile.Stats
	if type(profileStats) == "table" then
		for queueId, queueStats in stats.Queues do
			if type(queueStats) == "table" then
				profileStats[queueId] = copyQueueStats(queueStats)
			end
		end
	end
end

-- Captures the runtime profile back into a fresh document, preserving
-- anything the document holds that the profile does not model (e.g. seasons
-- other than the current one).
function capturePlayerData(profile: { [string]: any }, currentData: PlayerData): PlayerData
	local currentStats = currentData.Stats

	local seasonExperience: { [string]: number } = {}
	for seasonId, experience in currentStats.SeasonExperience do
		if type(experience) == "number" then
			seasonExperience[seasonId] = experience
		end
	end
	local season = profile.Season
	if type(season) == "table" and type(season.SeasonData) == "table" then
		for seasonId, entry in season.SeasonData do
			if type(entry) == "table" then
				local experience = entry.Experience
				if type(experience) == "number" then
					seasonExperience[seasonId] = experience
				end
			end
		end
	end

	local queues: { [string]: QueueStats } = {}
	for queueId, queueStats in currentStats.Queues do
		if type(queueStats) == "table" then
			queues[queueId] = copyQueueStats(queueStats)
		end
	end
	local profileStats = profile.Stats
	if type(profileStats) == "table" then
		for queueId, queueStats in profileStats do
			if type(queueStats) == "table" then
				queues[queueId] = copyQueueStats(queueStats)
			end
		end
	end

	return {
		Stats = {
			Experience = toNumber(profile.Experience, 0),
			SeasonExperience = seasonExperience,
			Queues = queues,
		},
	}
end

return {
	QUEUE_STAT_FIELDS = QUEUE_STAT_FIELDS,
	applyPlayerData = applyPlayerData,
	capturePlayerData = capturePlayerData,
	copyQueueStats = copyQueueStats,
	emptyQueueStats = emptyQueueStats,
	initialPlayerData = initialPlayerData,
}
