--!strict
-- Pure XP math for match rewards (no Roblox API; Lune-tested by
-- tools/test_experience_rules.luau).
-- Per-mode tables come from the shared client module TS/game/game-mode.
-- Trios/Quads/Octos and Duels never shipped tables — see the fallbacks below.
-- The TimePlayed rate is a reconstruction choice (original server lost).

export type ExperienceTable = {
	ExperiencePerKill: number,
	ExperiencePerAssist: number,
	ExperiencePerPosition: { number },
}

export type GameModeDefinition = {
	Experience: ExperienceTable?,
}

export type ExperienceBreakdown = { [string]: number }

export type MatchExperience = {
	Breakdown: ExperienceBreakdown,
	Total: number,
}

-- Bridge rounds award 50 XP per kill and 500 XP for a win; second place
-- awards nothing (user-provided spec, filling the client's missing table).
local DUELS_EXPERIENCE: ExperienceTable = {
	ExperiencePerKill = 50,
	ExperiencePerAssist = 0,
	ExperiencePerPosition = { 500, 0 },
}

local DUELS_MODE_NAMES = {
	["DuelsSolo"] = true,
	["DuelsDuos"] = true,
}

-- Trios/Quads/Octos reuse the Duos payouts (user-provided spec).
local FALLBACK_TO_DUOS_MODES = {
	["SkyWarsTrios"] = true,
	["SkyWarsQuads"] = true,
	["SkyWarsOctos"] = true,
}

local FALLBACK_TO_DUOS_MODE = "SkyWarsDuos"

-- 10 XP per minute of match participation, capped at 100 XP (10 minutes).
-- Reconstruction choice: no client or server data survived for this rate.
local TIME_PLAYED_XP_PER_SECOND = 1 / 6
local TIME_PLAYED_XP_CAP = 100

-- Every cause the client's ExperienceCauses knows about. Causes the server
-- does not compute yet (EggKill, Mission, LoginStreak, SummerScavengerHunt)
-- are reported as 0 so the wire shape always matches the schema.
local CAUSE_KEYS = {
	"TimePlayed",
	"PodiumPosition",
	"PlayerKill",
	"EggKill",
	"Mission",
	"LoginStreak",
	"SummerScavengerHunt",
}

-- Applies the per-mode fallbacks; nil means the mode awards nothing.
function resolveExperience(gameMode: string, gameModes: { [string]: GameModeDefinition }): ExperienceTable?
	local definition = gameModes[gameMode]
	if definition ~= nil and definition.Experience ~= nil then
		return definition.Experience
	end
	if FALLBACK_TO_DUOS_MODES[gameMode] then
		local duosDefinition = gameModes[FALLBACK_TO_DUOS_MODE]
		if duosDefinition ~= nil then
			return duosDefinition.Experience
		end
	end
	if DUELS_MODE_NAMES[gameMode] then
		return DUELS_EXPERIENCE
	end
	return nil
end

-- 1-based finish position; past-the-end positions clamp to the table's last
-- entry. nil/out-of-range positions award nothing.
function getPositionExperience(experience: ExperienceTable, position: number?): number
	if position == nil or position < 1 then
		return 0
	end
	local table = experience.ExperiencePerPosition
	if #table == 0 then
		return 0
	end
	return table[math.min(position, #table)] or 0
end

function getTimePlayedExperience(secondsPlayed: number): number
	if secondsPlayed <= 0 then
		return 0
	end
	return math.min(math.floor(secondsPlayed * TIME_PLAYED_XP_PER_SECOND + 0.5), TIME_PLAYED_XP_CAP)
end

-- Builds the per-cause breakdown the client's GameStats payload consumes.
function computeMatchExperience(
	experience: ExperienceTable,
	kills: number,
	assists: number,
	position: number?,
	secondsPlayed: number
): MatchExperience
	local breakdown: ExperienceBreakdown = {}
	local total = 0
	local function addCause(cause: string, amount: number)
		breakdown[cause] = amount
		total += amount
	end

	addCause("TimePlayed", getTimePlayedExperience(secondsPlayed))
	addCause("PodiumPosition", getPositionExperience(experience, position))
	addCause("PlayerKill", kills * experience.ExperiencePerKill + assists * experience.ExperiencePerAssist)
	for index = 4, #CAUSE_KEYS do
		breakdown[CAUSE_KEYS[index]] = 0
	end

	return {
		Breakdown = breakdown,
		Total = total,
	}
end

return {
	CAUSE_KEYS = CAUSE_KEYS,
	DUELS_EXPERIENCE = DUELS_EXPERIENCE,
	computeMatchExperience = computeMatchExperience,
	getPositionExperience = getPositionExperience,
	getTimePlayedExperience = getTimePlayedExperience,
	resolveExperience = resolveExperience,
}
