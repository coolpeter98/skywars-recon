-- LeaderboardUtil

return {
	["LeaderboardUtil"] = {
		["getCacheKey"] = function(leaderboardType: string, statId: string, statGranularity: string): string
			return ("%*-%*-%*"):format(leaderboardType, statId, statGranularity)
		end,
	},
}
