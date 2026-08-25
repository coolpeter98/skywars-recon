--!strict

local BridgeRules = {
	ArrowInterval = 3,
	CageResetDuration = 5,
	ScoreToWin = 3,
}

function BridgeRules.advanceArrowClock(elapsed: number, deltaTime: number, running: boolean): (number, number)
	if not running then
		return math.max(elapsed, 0), 0
	end
	local nextElapsed = math.max(elapsed, 0) + math.max(deltaTime, 0)
	local ticks = math.floor(nextElapsed / BridgeRules.ArrowInterval)
	return nextElapsed - ticks * BridgeRules.ArrowInterval, ticks
end

function BridgeRules.recordScore(currentScore: number): (number, boolean)
	local score = math.max(0, math.floor(currentScore)) + 1
	return score, score >= BridgeRules.ScoreToWin
end

return BridgeRules
