-- test_kill_log.luau — Lune unit tests for the server kill logger
-- (ServerScriptService/server/logging/KillLog). The module is pure Luau:
-- it formats, prints, and remembers kill entries; callers build the entries
-- from Roblox objects.
--
-- Run with:  lune run tools/test_kill_log.luau
--
-- Note: KillLog types Position as Vector3?; Lune has no Vector3, but the
-- formatter only reads .X/.Y/.Z, so the tests pass plain { X, Y, Z } tables
-- (type annotations are erased at runtime).

local KillLog = require("../src/ServerScriptService/server/logging/KillLog")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

local function contains(line, needle)
	check(string.find(line, needle, 1, true) ~= nil, ("line %q should contain %q"):format(line, needle))
end

local function rejects(line, needle)
	check(string.find(line, needle, 1, true) == nil, ("line %q should NOT contain %q"):format(line, needle))
end

-- 1. Player kill with a killer: the full structured line.
do
	local line = KillLog.format({
		Kind = "Player",
		Victim = "Bob",
		VictimUserId = 456,
		Killer = "Peter",
		KillerUserId = 123,
		DamageType = "Melee",
		Weapon = "IronSword",
		Position = { X = -12.5, Y = 63, Z = 8 },
		RoundId = 3,
		GameMode = "SkyWarsSolo",
		MapName = "Airport",
		Survivors = 7,
		Clock = 123.4,
		Timestamp = "2025-06-14 12:34:56",
	})
	contains(line, "[KillLog] 2025-06-14 12:34:56")
	contains(line, "R3 Airport (SkyWarsSolo)")
	contains(line, "Peter(123) killed Bob(456) [Melee, IronSword]")
	contains(line, "@ (-12.5, 63.0, 8.0)")
	contains(line, "survivors 7")
	contains(line, "t+123.4s")
end

-- 2. Environment kill (Void): no killer, no duplicated damage suffix.
do
	local line = KillLog.format({
		Kind = "Player",
		Victim = "Bob",
		VictimUserId = 456,
		DamageType = "Void",
		Position = { X = 10, Y = -4.5, Z = 2 },
		RoundId = 3,
		MapName = "Airport",
		Survivors = 6,
	})
	contains(line, "Bob(456) eliminated by Void")
	rejects(line, "killed")
	rejects(line, "[Void]")
	contains(line, "survivors 6")
end

-- 3. Entity kill (egg): quotes the entity name and reports the destroyer.
do
	local line = KillLog.format({
		Kind = "Entity",
		Victim = "TeamEgg",
		Killer = "Peter",
		KillerUserId = 123,
		DamageType = "Melee",
		Weapon = "IronSword",
		Position = { X = 5, Y = 63, Z = 0 },
	})
	contains(line, 'Peter(123) destroyed entity "TeamEgg" [Melee, IronSword]')
	contains(line, "@ (5.0, 63.0, 0.0)")
end

-- 4. Minimal entry: no optional fields, still a sane line.
do
	local line = KillLog.format({ Kind = "Player", Victim = "Bob" })
	contains(line, "[KillLog]")
	contains(line, "Bob eliminated")
end

-- 5. record fills Clock/Timestamp when nil, keeps provided values, and
--    prints by default.
local logger = KillLog.new()
logger:record({
	Kind = "Player",
	Victim = "Bob",
	Killer = "Peter",
	DamageType = "Melee",
})
logger:record({
	Kind = "Player",
	Victim = "Carol",
	DamageType = "Fall",
	Clock = 42,
	Timestamp = "custom-time",
}, true)
do
	local history = logger:getHistory()
	check(#history == 2, "history holds both records")
	check(type(history[1].Clock) == "number", "record fills Clock when nil")
	check(
		type(history[1].Timestamp) == "string" and string.find(history[1].Timestamp, "^%d%d%d%d%-") ~= nil,
		"record fills a year-prefixed Timestamp when nil"
	)
	check(history[2].Clock == 42, "record keeps a provided Clock")
	check(history[2].Timestamp == "custom-time", "record keeps a provided Timestamp")
end

-- 6. Bounded history: once past MAX_HISTORY (500) the oldest entry drops.
do
	local capped = KillLog.new()
	for index = 1, 501 do
		capped:record({ Kind = "Player", Victim = "Victim" .. tostring(index) }, true)
	end
	local history = capped:getHistory()
	check(#history == 500, "history is capped at 500 entries")
	check(history[1].Victim == "Victim2", "the oldest entry was dropped")
	check(history[500].Victim == "Victim501", "the newest entry is kept")
end

-- 7. getHistory returns a copy; clear empties the history.
do
	local history = logger:getHistory()
	table.clear(history)
	check(#logger:getHistory() == 2, "getHistory returns a copy, not the live table")
	logger:clear()
	check(#logger:getHistory() == 0, "clear empties the history")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
