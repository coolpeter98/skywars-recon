-- test_regeneration.luau — Lune unit tests for the natural-regeneration
-- tick math (ServerScriptService/server/combat/RegenerationRules). The
-- module is pure Luau: it only computes tick groups, per-tick heal amounts,
-- and single clock steps; RegenerationService drives it with Roblox objects.
--
-- Run with:  lune run tools/test_regeneration.luau
--
-- Spec under test (user-provided):
--   * 1 second = 1 tick; getting hurt resets the tick clock.
--   * Ticks are grouped in groups of four ("tick groups", tg):
--       1st tg (ticks 1..4)   -> 0 hp regenerated
--       2nd tg (ticks 5..8)   -> 1 hp per tick
--       3rd tg (ticks 9..12)  -> 2 hp per tick
--       4th tg (ticks 13..16) -> 3 hp per tick
--       5th tg (ticks 17..20) -> 4 hp per tick, and so on.

local RegenerationRules = require("../src/ServerScriptService/server/combat/RegenerationRules")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

-- 1. Clock constants: one tick per second, four ticks per group.
do
	check(RegenerationRules.TICK_SECONDS == 1, "TICK_SECONDS is 1")
	check(RegenerationRules.TICKS_PER_GROUP == 4, "TICKS_PER_GROUP is 4")
end

-- 2. Tick groups: ticks 1..4 are group 1, 5..8 group 2, 9..12 group 3,
--    13..16 group 4, 17..20 group 5; reset clocks belong to no group.
do
	for tick = 1, 4 do
		check(RegenerationRules.getTickGroup(tick) == 1, ("tick %d is tick group 1"):format(tick))
	end
	for tick = 5, 8 do
		check(RegenerationRules.getTickGroup(tick) == 2, ("tick %d is tick group 2"):format(tick))
	end
	for tick = 9, 12 do
		check(RegenerationRules.getTickGroup(tick) == 3, ("tick %d is tick group 3"):format(tick))
	end
	for tick = 13, 16 do
		check(RegenerationRules.getTickGroup(tick) == 4, ("tick %d is tick group 4"):format(tick))
	end
	for tick = 17, 20 do
		check(RegenerationRules.getTickGroup(tick) == 5, ("tick %d is tick group 5"):format(tick))
	end
	check(RegenerationRules.getTickGroup(0) == 0, "tick 0 (fresh reset) belongs to no group")
	check(RegenerationRules.getTickGroup(-3) == 0, "negative clocks belong to no group")
end

-- 3. Per-tick regeneration: group 1 heals 0/tick, group 2 heals 1/tick,
--    group 3 heals 2/tick, group 4 heals 3/tick, group 5 heals 4/tick.
do
	-- Expected heal on each tick, indexed by tick number: tick 0 (the reset
	-- clock) and tick group 1 (ticks 1..4) heal nothing; then four ticks per
	-- group at 1, 2, 3, and 4 hp/tick for groups 2 through 5.
	local expected = {
		0,
		0,
		0,
		0,
		0,
		1,
		1,
		1,
		1,
		2,
		2,
		2,
		2,
		3,
		3,
		3,
		3,
		4,
		4,
		4,
		4,
	}
	for tick, amount in expected do
		check(
			RegenerationRules.getRegenerationAmount(tick - 1) == amount,
			("tick %d regenerates %d hp"):format(tick - 1, amount)
		)
	end
	check(RegenerationRules.getRegenerationAmount(-1) == 0, "negative clocks regenerate nothing")
	check(RegenerationRules.getRegenerationAmount(100) == 24, "tick 100 regenerates floor(99/4) = 24 hp")
	check(RegenerationRules.getRegenerationAmount(101) == 25, "tick 101 regenerates floor(100/4) = 25 hp")
end

-- 4. advance: one clock step returns (nextTicks, healAmount) and clamps
--    negative clocks up to tick 1.
do
	local ticks, heal = RegenerationRules.advance(0)
	check(ticks == 1 and heal == 0, "advance(0) -> (1, 0): first tick heals nothing")
	ticks, heal = RegenerationRules.advance(4)
	check(ticks == 5 and heal == 1, "advance(4) -> (5, 1): first tick of group 2 heals 1")
	ticks, heal = RegenerationRules.advance(8)
	check(ticks == 9 and heal == 2, "advance(8) -> (9, 2): first tick of group 3 heals 2")
	ticks, heal = RegenerationRules.advance(12)
	check(ticks == 13 and heal == 3, "advance(12) -> (13, 3): first tick of group 4 heals 3")
	ticks, heal = RegenerationRules.advance(16)
	check(ticks == 17 and heal == 4, "advance(16) -> (17, 4): first tick of group 5 heals 4")
	ticks, heal = RegenerationRules.advance(-2)
	check(ticks == 1 and heal == 0, "advance(-2) clamps up to (1, 0)")
end

-- 5. End-to-end clock simulation: a player reset to 0, advanced once per
--    second, heals nothing for 4 seconds then 1/2/3/4 hp/s until full.
--    The reset on damage is exercised too: after a mid-ramp reset the clock
--    starts over from group 1.
do
	local MAX_HEALTH = 100

	local function simulate(health, seconds)
		local ticks = 0
		for _ = 1, seconds do
			local nextTicks, heal = RegenerationRules.advance(ticks)
			ticks = nextTicks
			health = math.min(MAX_HEALTH, health + heal)
		end
		return health, ticks
	end

	local health, ticks = simulate(80, 4)
	check(health == 80 and ticks == 4, "4 unhurt seconds (tick group 1) heal nothing")

	health = simulate(80, 8)
	check(health == 84, "8 unhurt seconds heal 1/tick for the last 4 (80 -> 84)")

	health = simulate(80, 12)
	check(health == 92, "12 unhurt seconds heal 1/tick then 2/tick (80 -> 92)")

	health = simulate(80, 16)
	check(health == 100, "16 unhurt seconds cap at max health (0+1+2+3 hp/s)")

	health = simulate(80, 200)
	check(health == 100, "200 unhurt seconds stay capped at max health")

	-- Ramp 5 seconds from 90 health: only tick 5 (first of group 2) heals.
	local totalHealed = 0
	health = 90
	local ticksAfterHit = 0
	for _ = 1, 5 do
		local nextTicks, heal = RegenerationRules.advance(ticksAfterHit)
		ticksAfterHit = nextTicks
		local healthBefore = health
		health = math.min(MAX_HEALTH, health + heal)
		totalHealed += health - healthBefore
	end
	check(totalHealed == 1, "5 unhurt seconds heal exactly 1 hp (only tick 5, the first of group 2)")

	ticksAfterHit = 0 -- getting hurt resets the tick clock
	for _ = 1, 4 do
		ticksAfterHit = RegenerationRules.advance(ticksAfterHit)
	end
	local healAfterReset = select(2, RegenerationRules.advance(ticksAfterHit))
	check(healAfterReset == 1, "after a reset, tick group 1 heals nothing and group 2 resumes at 1/tick")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
