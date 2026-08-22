-- test_fall_damage.luau — Lune unit tests for the fall-damage curve and
-- block-level math (ServerScriptService/server/combat/FallDamageRules). The
-- module is pure Luau: it only maps block levels and blocks-fallen counts
-- to damage; FallDamageService drives it with Roblox objects.
--
-- Run with:  lune run tools/test_fall_damage.luau
--
-- Spec under test (user-measured in the actual game):
--   * Fall damage is not computed from velocity: the game compares the Y
--     level of the block fallen from with the Y level of the landing block.
--   * Falls shorter than 10 blocks deal no damage at all.
--   * Measured curve (approximate — some re-runs under-measured):
--       10 -> 17   11 -> 18   12 -> 18   13 -> 18   14 -> 19
--       15 -> 25   16 -> 25   17 -> 27   18 -> 27   19 -> 29
--       20 -> 33   21 -> 33

local FallDamageRules = require("../src/ServerScriptService/server/combat/FallDamageRules")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

-- 1. Constants: the client's 3-stud block grid, the 10-block minimum
--    (verified in the real game), and the damage cap at max health.
do
	check(FallDamageRules.BLOCK_SIZE == 3, "BLOCK_SIZE is 3 (the client's block grid)")
	check(FallDamageRules.MIN_FALL_BLOCKS == 10, "MIN_FALL_BLOCKS is 10 (sub-10-block falls are free)")
	check(FallDamageRules.MAX_FALL_DAMAGE == 100, "MAX_FALL_DAMAGE is 100 (full health bar)")
end

-- 2. Block levels: block tops sit at world Y ≡ 1.5 (mod 3), so a surface
--    resolves to level floor(Y / 3).
do
	check(FallDamageRules.getBlockLevel(64.5) == 21, "block top 64.5 is level 21")
	check(FallDamageRules.getBlockLevel(63) == 21, "Y 63 (mid-block) is still level 21")
	check(FallDamageRules.getBlockLevel(1.5) == 0, "block top 1.5 is level 0")
	check(FallDamageRules.getBlockLevel(4.5) == 1, "block top 4.5 is level 1")
	check(FallDamageRules.getBlockLevel(0) == 0, "Y 0 is level 0")
	check(FallDamageRules.getBlockLevel(-1.5) == -1, "Y -1.5 is level -1")
end

-- 3. Root levels: a root part standing on block k sits at the block top
--    plus a hip height well under one block, so subtracting the 1.5-stud
--    grid offset resolves it back to level k.
do
	check(FallDamageRules.getRootLevel(66) == 21, "root at 66 (top 64.5 + hip 1.5) is level 21")
	check(FallDamageRules.getRootLevel(67.4) == 21, "root at 67.4 (hip 2.9) is still level 21")
	check(FallDamageRules.getRootLevel(3) == 0, "root at 3 on the ground block is level 0")
	check(FallDamageRules.getRootLevel(69) == 22, "root at 69 (hip 1.5 over top 67.5) is level 22")
end

-- 4. Sub-10-block falls deal nothing, in whole blocks and near the line.
do
	for blocksFallen = 0, 9 do
		check(FallDamageRules.getFallDamage(blocksFallen) == 0, ("a %d-block fall deals 0 damage"):format(blocksFallen))
	end
	check(FallDamageRules.getFallDamage(9.9) == 0, "a 9.9-block fall still deals 0 damage")
	check(FallDamageRules.getFallDamage(10) == 17, "the first damaging fall (10 blocks) deals 17")
end

-- 5. The measured anchor curve, exactly at each measured block count.
do
	local anchors = {
		{ 10, 17 },
		{ 11, 18 },
		{ 12, 18 },
		{ 13, 18 },
		{ 14, 19 },
		{ 15, 25 },
		{ 16, 25 },
		{ 17, 27 },
		{ 18, 27 },
		{ 19, 29 },
		{ 20, 33 },
		{ 21, 33 },
	}
	for _, anchor in anchors do
		local blocksFallen, damage = anchor[1], anchor[2]
		check(
			FallDamageRules.getFallDamage(blocksFallen) == damage,
			("a %d-block fall deals %d damage (measured anchor)"):format(blocksFallen, damage)
		)
	end
end

-- 6. Interpolation between anchors (fractional block counts round to the
--    nearest integer).
do
	check(FallDamageRules.getFallDamage(10.5) == 18, "10.5 blocks interpolate 17 -> 18")
	check(FallDamageRules.getFallDamage(12.5) == 18, "12.5 blocks stay on the 18 plateau")
	check(FallDamageRules.getFallDamage(14.5) == 22, "14.5 blocks interpolate 19 -> 25 as 22")
	check(FallDamageRules.getFallDamage(19.5) == 31, "19.5 blocks interpolate 29 -> 33 as 31")
	check(FallDamageRules.getFallDamage(20.5) == 33, "20.5 blocks stay on the 33 plateau")
end

-- 7. Beyond the last measured anchor (21 blocks) damage ramps +2 per block
--    and caps at MAX_FALL_DAMAGE.
do
	check(FallDamageRules.getFallDamage(22) == 35, "22 blocks extend to 33 + 2 = 35")
	check(FallDamageRules.getFallDamage(25) == 41, "25 blocks extend to 33 + 8 = 41")
	check(FallDamageRules.getFallDamage(30) == 51, "30 blocks extend to 33 + 18 = 51")
	check(FallDamageRules.getFallDamage(60) == 100, "60 blocks cap at MAX_FALL_DAMAGE 100")
	check(FallDamageRules.getFallDamage(100) == 100, "100 blocks stay capped at 100")
end

-- 8. The curve is monotonic: one more block never deals less damage.
do
	local previous = FallDamageRules.getFallDamage(0)
	for blocksFallen = 1, 60 do
		local damage = FallDamageRules.getFallDamage(blocksFallen)
		check(
			damage >= previous,
			("damage at %d blocks (%d) is not below damage at %d blocks (%d)"):format(
				blocksFallen,
				damage,
				blocksFallen - 1,
				previous
			)
		)
		previous = damage
	end
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
