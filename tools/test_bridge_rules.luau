-- test_bridge_rules.luau — Lune unit tests for Bridge score and arrow clocks.

local BridgeRules = require("../src/ServerScriptService/server/modes/BridgeRules")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

check(BridgeRules.ArrowInterval == 3, "arrows use a three-second shared clock")
check(BridgeRules.CageResetDuration == 5, "point resets use five-second cages")
check(BridgeRules.ScoreToWin == 3, "the first team to three points wins")

do
	local elapsed, ticks = BridgeRules.advanceArrowClock(0, 2.9, true)
	check(ticks == 0 and elapsed == 2.9, "no arrow tick before three running seconds")
	elapsed, ticks = BridgeRules.advanceArrowClock(elapsed, 0.1, true)
	check(ticks == 1 and math.abs(elapsed) < 0.0001, "the clock ticks at three seconds")
	check(ticks == 1, "the clock tick is independent of when an arrow was consumed")
end

do
	local elapsed, ticks = BridgeRules.advanceArrowClock(2.75, 20, false)
	check(ticks == 0 and elapsed == 2.75, "pregame and cages pause the arrow clock phase")
	elapsed, ticks = BridgeRules.advanceArrowClock(elapsed, 0.25, true)
	check(ticks == 1 and math.abs(elapsed) < 0.0001, "the paused phase resumes after cages")
end

do
	local elapsed, ticks = BridgeRules.advanceArrowClock(0.5, 6.75, true)
	check(ticks == 2 and math.abs(elapsed - 1.25) < 0.0001, "delayed frames preserve every clock tick")
end

do
	local score, won = BridgeRules.recordScore(0)
	check(score == 1 and not won, "first point continues the round")
	score, won = BridgeRules.recordScore(score)
	check(score == 2 and not won, "second point continues the round")
	score, won = BridgeRules.recordScore(score)
	check(score == 3 and won, "third point wins the round")
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
