--!strict

-- Pure tick math for natural regeneration (no Roblox API — unit-testable
-- under Lune via tools/test_regeneration.luau).
--
-- The regeneration clock advances one tick per second, and taking damage
-- resets a player's tick counter to zero. Ticks are grouped in groups of
-- four ("tick groups"), and the health regenerated per tick ramps up with
-- the group number:
--
--   tick group 1 (ticks 1..4)    -> 0 health per tick
--   tick group 2 (ticks 5..8)    -> 1 health per tick
--   tick group 3 (ticks 9..12)   -> 2 health per tick
--   tick group 4 (ticks 13..16)  -> 3 health per tick
--   tick group 5 (ticks 17..20)  -> 4 health per tick
--   ... and so on.
--
-- So the amount healed on tick n is floor((n - 1) / TICKS_PER_GROUP): the
-- first four seconds after taking damage heal nothing, then regeneration
-- ramps up by one health per second every further four-second group.

export type RegenerationRules = {
	TICK_SECONDS: number,
	TICKS_PER_GROUP: number,
	getTickGroup: (ticksSinceDamage: number) -> number,
	getRegenerationAmount: (ticksSinceDamage: number) -> number,
	advance: (ticksSinceDamage: number) -> (number, number),
}

local RegenerationRules: RegenerationRules = {
	TICK_SECONDS = 1,
	TICKS_PER_GROUP = 4,
}

-- The 1-indexed tick group a tick belongs to: ticks 1..4 are group 1,
-- ticks 5..8 are group 2, and so on. A counter at zero (freshly reset)
-- belongs to no group yet.
function RegenerationRules.getTickGroup(ticksSinceDamage: number): number
	if ticksSinceDamage < 1 then
		return 0
	end
	return math.floor((ticksSinceDamage - 1) / RegenerationRules.TICKS_PER_GROUP) + 1
end

-- Health regenerated on tick n = group number - 1, i.e. floor((n-1)/4).
-- Returns 0 for the first tick group and for reset (non-positive) clocks.
function RegenerationRules.getRegenerationAmount(ticksSinceDamage: number): number
	if ticksSinceDamage < 1 then
		return 0
	end
	return math.floor((ticksSinceDamage - 1) / RegenerationRules.TICKS_PER_GROUP)
end

-- One clock step: returns the advanced tick counter and the amount of health
-- that tick regenerates. Negative clocks (never possible in practice, since
-- the service resets to zero) are clamped up to tick 1.
function RegenerationRules.advance(ticksSinceDamage: number): (number, number)
	local nextTicks = math.max(0, ticksSinceDamage) + 1
	return nextTicks, RegenerationRules.getRegenerationAmount(nextTicks)
end

return RegenerationRules
