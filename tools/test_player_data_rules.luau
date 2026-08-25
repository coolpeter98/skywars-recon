-- test_player_data_rules.luau — Lune unit tests for the persisted
-- PlayerData document mapping (ServerScriptService/server/data/PlayerDataRules).
-- The module is pure Luau: it converts between the versioned on-disk document
-- and the runtime client profile without touching Roblox APIs.
--
-- Run with:  lune run tools/test_player_data_rules.luau

local PlayerDataRules = require("../src/ServerScriptService/server/data/PlayerDataRules")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

-- A minimal runtime-profile-shaped table (the real one is larger; the
-- mapping only touches the fields below).
local function makeProfile()
	return {
		Experience = 0,
		Season = {
			SeasonData = {
				["season-3"] = {
					Experience = 0,
					CurrentTierId = 1,
					AwardedTiers = {},
				},
			},
		},
		Stats = {
			["solo"] = { Wins = 0, WinStreak = 0, Losses = 0, Kills = 0, Deaths = 0, DamageDealt = 0, DamageTaken = 0 },
		},
	}
end

-- 1. Initial document shape.
do
	local data = PlayerDataRules.initialPlayerData()
	check(type(data.Stats) == "table", "initial document has a Stats table")
	check(data.Stats.Experience == 0, "initial Experience is 0")
	check(type(data.Stats.SeasonExperience) == "table", "initial SeasonExperience is a table")
	check(type(data.Stats.Queues) == "table", "initial Queues is a table")
end

-- 2. applyPlayerData: document fields land on the profile; missing fields
--    keep the profile's defaults.
do
	local profile = makeProfile()
	local data = {
		Stats = {
			Experience = 1234,
			SeasonExperience = {
				["season-3"] = 500,
				["season-2"] = 999, -- a season the profile does not model yet
			},
			Queues = {
				["solo"] = {
					Wins = 4,
					WinStreak = 2,
					Losses = 7,
					Kills = 30,
					Deaths = 12,
					DamageDealt = 500,
					DamageTaken = 60,
				},
			},
		},
	}
	PlayerDataRules.applyPlayerData(profile, data)
	check(profile.Experience == 1234, "Experience lands on the profile root")
	check(profile.Season.SeasonData["season-3"].Experience == 500, "current season XP lands on its entry")
	check(profile.Season.SeasonData["season-2"] ~= nil, "unmodeled seasons still get profile entries")
	check(profile.Season.SeasonData["season-2"].Experience == 999, "unmodeled season XP preserved")
	check(profile.Season.SeasonData["season-2"].CurrentTierId == 1, "created season entries use tier defaults")
	check(profile.Stats["solo"].Wins == 4, "queue wins land on the profile")
	check(profile.Stats["solo"].Deaths == 12, "queue deaths land on the profile")
end

-- 3. applyPlayerData sanitizes malformed stored values instead of poisoning
--    the runtime profile with non-numbers.
do
	local profile = makeProfile()
	local data = {
		Stats = {
			Experience = "corrupt",
			SeasonExperience = {
				["season-3"] = false,
			},
			Queues = {
				["solo"] = { Wins = nil, Kills = "many" },
			},
		},
	}
	PlayerDataRules.applyPlayerData(profile, data)
	check(profile.Experience == 0, "non-numeric Experience falls back to 0")
	check(profile.Season.SeasonData["season-3"].Experience == 0, "non-numeric season XP falls back to 0")
	check(profile.Stats["solo"].Wins == 0, "missing queue fields default to 0")
	check(profile.Stats["solo"].Kills == 0, "non-numeric queue fields default to 0")
end

-- 4. capturePlayerData: profile values overwrite the document; document-only
--    values (other seasons, other queues) survive.
do
	local profile = makeProfile()
	profile.Experience = 4321
	profile.Season.SeasonData["season-3"].Experience = 700
	profile.Stats["solo"].Wins = 9
	profile.Stats["solo"].Kills = 55
	local currentData = {
		Stats = {
			Experience = 0,
			SeasonExperience = {
				["season-3"] = 0,
				["season-2"] = 999,
			},
			Queues = {
				["duels_solo"] = {
					Wins = 2,
					WinStreak = 0,
					Losses = 3,
					Kills = 10,
					Deaths = 11,
					DamageDealt = 12,
					DamageTaken = 13,
				},
			},
		},
	}
	local captured = PlayerDataRules.capturePlayerData(profile, currentData)
	check(captured.Stats.Experience == 4321, "Experience captured from the profile")
	check(captured.Stats.SeasonExperience["season-3"] == 700, "current season XP captured from the profile")
	check(captured.Stats.SeasonExperience["season-2"] == 999, "document-only season XP survives the capture")
	check(captured.Stats.Queues["solo"].Wins == 9, "profile queue stats captured")
	check(captured.Stats.Queues["solo"].Kills == 55, "profile queue kills captured")
	check(captured.Stats.Queues["duels_solo"].Kills == 10, "document-only queue stats survive the capture")
	check(captured.Stats.Queues["duels_solo"].DamageTaken == 13, "document-only queue damage survives the capture")
	check(currentData.Stats.Queues["duels_solo"].Kills == 10, "capture does not mutate the source document")
end

-- 5. Round-trip: capture(apply(profile, data)) preserves every number.
do
	local profile = makeProfile()
	local data = {
		Stats = {
			Experience = 888,
			SeasonExperience = {
				["season-3"] = 111,
			},
			Queues = {
				["solo"] = {
					Wins = 1,
					WinStreak = 2,
					Losses = 3,
					Kills = 4,
					Deaths = 5,
					DamageDealt = 6,
					DamageTaken = 7,
				},
			},
		},
	}
	PlayerDataRules.applyPlayerData(profile, data)
	local recaptured = PlayerDataRules.capturePlayerData(profile, PlayerDataRules.initialPlayerData())
	check(recaptured.Stats.Experience == 888, "round-trip preserves Experience")
	check(recaptured.Stats.SeasonExperience["season-3"] == 111, "round-trip preserves season XP")
	check(recaptured.Stats.Queues["solo"].DamageDealt == 6, "round-trip preserves queue damage")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
