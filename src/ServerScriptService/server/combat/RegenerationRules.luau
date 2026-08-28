--!strict

-- Pure regeneration tick math (no Roblox API; Lune-tested via tools/test_regeneration.luau).
-- 1 tick/second; damage resets the counter. Ticks group in fours and heal rate ramps
-- one hp/tick per group: group 1 (ticks 1..4) -> 0, group 2 -> 1, group 3 -> 2, ...
-- i.e. tick n heals floor((n-1)/4).

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

-- 1-indexed tick group; 0 for a freshly reset counter.
function RegenerationRules.getTickGroup(ticksSinceDamage: number): number
	if ticksSinceDamage < 1 then
		return 0
	end
	return math.floor((ticksSinceDamage - 1) / RegenerationRules.TICKS_PER_GROUP) + 1
end

-- Healed on tick n = floor((n-1)/4); 0 for the first group or reset clocks.
function RegenerationRules.getRegenerationAmount(ticksSinceDamage: number): number
	if ticksSinceDamage < 1 then
		return 0
	end
	return math.floor((ticksSinceDamage - 1) / RegenerationRules.TICKS_PER_GROUP)
end

-- One clock step: (advanced counter, heal amount). Negative counters clamp to tick 1.
function RegenerationRules.advance(ticksSinceDamage: number): (number, number)
	local nextTicks = math.max(0, ticksSinceDamage) + 1
	return nextTicks, RegenerationRules.getRegenerationAmount(nextTicks)
end

return RegenerationRules
