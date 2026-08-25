-- test_experience_rules.luau — Lune unit tests for match XP math
-- (ServerScriptService/server/experience/ExperienceRules). The module is
-- pure Luau: per-mode resolution with fallbacks, position/time XP, and the
-- end-of-match breakdown the GameStats payload consumes.
--
-- Run with:  lune run tools/test_experience_rules.luau

local ExperienceRules = require("../src/ServerScriptService/server/experience/ExperienceRules")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

-- Minimal GameModes-shaped table mirroring the shared client module.
local soloExperience = {
	ExperiencePerKill = 50,
	ExperiencePerAssist = 25,
	ExperiencePerPosition = { 750, 550, 475, 350, 250, 175, 150, 125, 75, 60, 45, 35 },
}
local duosExperience = {
	ExperiencePerKill = 50,
	ExperiencePerAssist = 25,
	ExperiencePerPosition = {
		750,
		750,
		550,
		550,
		475,
		475,
		350,
		350,
		250,
		250,
		175,
		175,
		150,
		150,
		125,
		125,
		75,
		75,
		60,
		60,
		45,
		45,
		35,
		35,
	},
}
local eggWarsExperience = {
	ExperiencePerKill = 30,
	ExperiencePerAssist = 15,
	ExperiencePerPosition = {
		1600,
		1600,
		1600,
		1600,
		1250,
		1250,
		1250,
		1250,
		750,
		750,
		750,
		750,
		550,
		550,
		550,
		550,
	},
}
local gameModes = {
	SkyWarsSolo = { Experience = soloExperience },
	SkyWarsDuos = { Experience = duosExperience },
	SkyWarsTrios = {},
	SkyWarsQuads = {},
	SkyWarsOctos = {},
	DuelsSolo = {},
	DuelsDuos = {},
	EggWarsQuads = { Experience = eggWarsExperience },
}

-- 1. Mode resolution: shipped tables win, missing tables fall back to Duos,
--    Duels use the fixed 50/500 table, unknown modes award nothing.
do
	check(
		ExperienceRules.resolveExperience("SkyWarsSolo", gameModes) == soloExperience,
		"Solo resolves to its own shipped table"
	)
	check(
		ExperienceRules.resolveExperience("SkyWarsDuos", gameModes) == duosExperience,
		"Duos resolves to its own shipped table"
	)
	check(ExperienceRules.resolveExperience("SkyWarsTrios", gameModes) == duosExperience, "Trios falls back to Duos")
	check(ExperienceRules.resolveExperience("SkyWarsQuads", gameModes) == duosExperience, "Quads falls back to Duos")
	check(ExperienceRules.resolveExperience("SkyWarsOctos", gameModes) == duosExperience, "Octos falls back to Duos")
	check(
		ExperienceRules.resolveExperience("EggWarsQuads", gameModes) == eggWarsExperience,
		"EggWars resolves to its own shipped table"
	)
	local duels = ExperienceRules.resolveExperience("DuelsSolo", gameModes)
	check(
		duels ~= nil
			and duels.ExperiencePerKill == 50
			and duels.ExperiencePerAssist == 0
			and duels.ExperiencePerPosition[1] == 500,
		"DuelsSolo uses the fixed 50 XP/kill, 500 XP/win table"
	)
	check(ExperienceRules.resolveExperience("DuelsDuos", gameModes) == duels, "DuelsDuos uses the same fixed table")
	check(ExperienceRules.resolveExperience("SomeFutureMode", gameModes) == nil, "unknown modes award nothing")
end

-- 2. Position XP: 1-based placement, clamping past the table, nil/zero guards.
do
	check(ExperienceRules.getPositionExperience(soloExperience, 1) == 750, "Solo 1st place = 750")
	check(ExperienceRules.getPositionExperience(soloExperience, 2) == 550, "Solo 2nd place = 550")
	check(ExperienceRules.getPositionExperience(soloExperience, 12) == 35, "Solo 12th place = 35")
	check(
		ExperienceRules.getPositionExperience(soloExperience, 13) == 35,
		"positions past the table clamp to the last entry"
	)
	check(ExperienceRules.getPositionExperience(soloExperience, nil) == 0, "nil position awards nothing")
	check(ExperienceRules.getPositionExperience(soloExperience, 0) == 0, "zero position awards nothing")
	check(ExperienceRules.getPositionExperience(duosExperience, 2) == 750, "Duos 2nd-place team member shares the 750")
	check(ExperienceRules.getPositionExperience(eggWarsExperience, 5) == 1250, "EggWars 5th place = 1250")
end

-- 3. Time played: 10 XP/minute, half-up rounding, 100 XP cap.
do
	check(ExperienceRules.getTimePlayedExperience(0) == 0, "no time awards nothing")
	check(ExperienceRules.getTimePlayedExperience(-5) == 0, "negative time awards nothing")
	check(ExperienceRules.getTimePlayedExperience(60) == 10, "60s = 10 XP")
	check(ExperienceRules.getTimePlayedExperience(90) == 15, "90s = 15 XP")
	check(ExperienceRules.getTimePlayedExperience(66) == 11, "66s rounds half-up to 11 XP")
	check(ExperienceRules.getTimePlayedExperience(600) == 100, "600s hits the cap")
	check(ExperienceRules.getTimePlayedExperience(7200) == 100, "long matches stay capped at 100")
end

-- 4. Match breakdown: kills + assists + placement + time across modes.
do
	local solo = ExperienceRules.computeMatchExperience(soloExperience, 3, 2, 1, 300)
	check(solo.Breakdown.PlayerKill == 200, "Solo 3 kills + 2 assists = 3*50 + 2*25 = 200")
	check(solo.Breakdown.PodiumPosition == 750, "Solo win podium = 750")
	check(solo.Breakdown.TimePlayed == 50, "300s played = 50")
	check(solo.Total == 1000, "Solo total = 200 + 750 + 50 = 1000")
	for _, cause in ExperienceRules.CAUSE_KEYS do
		check(solo.Breakdown[cause] ~= nil, ("breakdown carries cause %s"):format(cause))
	end
	check(solo.Breakdown.EggKill == 0, "unimplemented causes report 0")

	local duels = ExperienceRules.resolveExperience("DuelsSolo", gameModes)
	local duelWin = ExperienceRules.computeMatchExperience(duels, 2, 0, 1, 60)
	check(duelWin.Breakdown.PlayerKill == 100, "Duels 2 kills = 100")
	check(duelWin.Breakdown.PodiumPosition == 500, "Duels win = 500")
	check(duelWin.Total == 610, "Duels win total = 100 + 500 + 10 = 610")
	local duelLoss = ExperienceRules.computeMatchExperience(duels, 1, 0, 2, 60)
	check(duelLoss.Breakdown.PodiumPosition == 0, "Duels loss awards no position XP")
	check(duelLoss.Total == 60, "Duels loss total = 50 + 0 + 10 = 60")

	local eggWars = ExperienceRules.computeMatchExperience(eggWarsExperience, 4, 1, 3, 120)
	check(eggWars.Breakdown.PlayerKill == 135, "EggWars 4 kills + 1 assist = 4*30 + 15 = 135")
	check(eggWars.Breakdown.PodiumPosition == 1600, "EggWars 3rd place = 1600")
	check(eggWars.Breakdown.TimePlayed == 20, "120s played = 20")
	check(eggWars.Total == 1755, "EggWars total = 135 + 1600 + 20 = 1755")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
