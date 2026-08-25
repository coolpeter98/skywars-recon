-- studio_smoke_test.luau — copy-paste verification for the XP/leveling +
-- Drop persistence work, to run by hand in Studio (the MCP execute_luau
-- bridge is currently broken).
--
-- How to run:
--   1. Press Play in the skywars place (Rojo-synced tree).
--   2. Open the Command Bar (View → Command Bar), set its dropdown to
--      "Server" (or run this as a Script under ServerScriptService).
--   3. Paste this file and run it. Every line prints PASS/FAIL.
--
-- Checks: Drop vendoring, XP fallback math, profile<->document mapping,
-- a real DataStore round-trip on a scratch store (needs Studio access to
-- API services, on by default in Play), and that the runtime modules the
-- server already constructed require cleanly.

local function check(name: string, condition: boolean, extra: string?)
	print(
		("[Smoke] %s: %s%s"):format(name, if condition then "PASS" else "FAIL", if extra then (" - " .. extra) else "")
	)
end

-- 1. Vendored Drop loads under the Rojo init convention.
local ServerStorage = game:GetService("ServerStorage")
local dropOk, dropResult = pcall(function()
	return require(ServerStorage.Drop)
end)
if not dropOk then
	print("[Smoke] Drop require failed, aborting:", dropResult)
	return
end
local Drop = dropResult
check("Drop loads", type(Drop.schema) == "function" and type(Drop.store) == "function")

-- 2. XP rules resolve with the documented fallbacks.
local ExperienceRules = require(game.ServerScriptService.server.experience.ExperienceRules)
local GameModes = require(game.ReplicatedStorage.TS.game["game-mode"]).GameModes
check(
	"Trios falls back to Duos",
	ExperienceRules.resolveExperience("SkyWarsTrios", GameModes) == GameModes.SkyWarsDuos.Experience
)
check(
	"Quads/Octos fall back to Duos",
	ExperienceRules.resolveExperience("SkyWarsQuads", GameModes) == GameModes.SkyWarsDuos.Experience
		and ExperienceRules.resolveExperience("SkyWarsOctos", GameModes) == GameModes.SkyWarsDuos.Experience
)
local duels = ExperienceRules.resolveExperience("DuelsSolo", GameModes)
check(
	"Duels 50 XP/kill + 500 XP/win",
	duels.ExperiencePerKill == 50 and duels.ExperiencePerAssist == 0 and duels.ExperiencePerPosition[1] == 500
)
local solo = ExperienceRules.computeMatchExperience(GameModes.SkyWarsSolo.Experience, 3, 2, 1, 300)
check("Solo win 3k/2a/5min = 1000 XP", solo.Total == 1000, tostring(solo.Total))
check("Breakdown has all causes", solo.Breakdown.TimePlayed == 50 and solo.Breakdown.PlayerKill == 200)

-- 3. Document <-> runtime profile mapping.
local PlayerDataRules = require(game.ServerScriptService.server.data.PlayerDataRules)
local profile = { Experience = 0, Season = { SeasonData = {} }, Stats = {} }
local document = PlayerDataRules.initialPlayerData()
document.Stats.Experience = 1234
PlayerDataRules.applyPlayerData(profile, document)
check("applyPlayerData sets Experience", profile.Experience == 1234)
local recaptured = PlayerDataRules.capturePlayerData(profile, PlayerDataRules.initialPlayerData())
check("capturePlayerData round-trips", recaptured.Stats.Experience == 1234)

-- 4. Real Drop datastore round-trip on a scratch store.
local scratchSchema = Drop.schema({ Value = 0 })
local scratchStore = Drop.store({ name = "SmokeTestScratch", schema = scratchSchema })
local readOk, readResult = pcall(function()
	return Drop.viewasync(scratchStore, "smoke-key")
end)
if readOk then
	check("fresh key reads initial value", readResult.Value == 0, tostring(readResult.Value))
	local writeOk, writeResult = pcall(function()
		return Drop.updateasync(scratchStore, "smoke-key", function(data)
			return { Value = data.Value + 1 }
		end)
	end)
	check(
		"updateasync increments",
		writeOk and writeResult.Value == 1,
		if writeOk then tostring(writeResult.Value) else tostring(writeResult)
	)
else
	print("[Smoke] DataStore read failed (Studio API services disabled?) -", readResult)
end

-- 5. The services the running server constructed require cleanly.
check(
	"PlayerDataService module loads",
	type(require(game.ServerScriptService.server.data.PlayerDataService).new) == "function"
)
check(
	"ExperienceService module loads",
	type(require(game.ServerScriptService.server.experience.ExperienceService).new) == "function"
)

print("[Smoke] done - also watch the Output for [PlayerDataService]/[ExperienceService] errors while playing.")
