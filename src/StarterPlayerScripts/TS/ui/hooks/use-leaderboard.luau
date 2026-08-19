-- useLeaderboard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").GlobalStore
local LeaderboardUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "leaderboard", "leaderboard-util").LeaderboardUtil
local LeaderboardType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "leaderboard", "leaderboard").LeaderboardType

type LeaderboardEntry = {
	UserId: number,
	DisplayName: string,
	Value: number,
	Position: number,
}

type Leaderboard = {
	Players: { LeaderboardEntry }?,
	Loading: boolean,
}

type LeaderboardHookOptions = {
	LeaderboardType: unknown,
	StatId: unknown,
	StatGranularity: unknown,
	TextFilter: string,
}

local mockLeaderboard: Leaderboard = {
	["Players"] = nil,
	["Loading"] = false,
	["Players"] = {
		{
			["UserId"] = 1800687521,
			["DisplayName"] = "Player 1",
			["Value"] = 100,
			["Position"] = 0
		},
		{
			["UserId"] = 1730213868,
			["DisplayName"] = "Player 2",
			["Value"] = 50,
			["Position"] = 1
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player 3",
			["Value"] = 10,
			["Position"] = 2
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 3
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 4
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 5
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 5
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 6
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 7
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 8
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 9
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 10
		},
		{
			["UserId"] = 1781985652,
			["DisplayName"] = "Player ...",
			["Value"] = 1,
			["Position"] = 11
		}
	}
}
local getOrPollLeaderboard

local function useLeaderboard(options: LeaderboardHookOptions): Leaderboard
	local leaderboard
	if RunService:IsRunning() then
		leaderboard = getOrPollLeaderboard(options.LeaderboardType, options.StatId, options.StatGranularity)
	else
		leaderboard = mockLeaderboard
	end
	local players = leaderboard.Players
	local function matchesFilter(player: LeaderboardEntry): boolean
		local textFilter = options.TextFilter
		if textFilter == "" then
			textFilter = false
		end
		local passesFilter = not textFilter
		if not passesFilter then
			local lowerDisplayName = string.lower(player.DisplayName)
			local lowerTextFilter = string.lower(options.TextFilter)
			local matchResult = string.match(lowerDisplayName, lowerTextFilter)
			if matchResult == 0 or matchResult ~= matchResult then
				matchResult = false
			elseif matchResult == "" then
				matchResult = false
			end
			passesFilter = matchResult and true or false
		end
		return passesFilter
	end
	local count = 0
	local filteredPlayers = {}
	local result = {}
	for index, player in players do
		if matchesFilter(player, index - 1, players) == true then
			count = count + 1
			filteredPlayers[count] = player
		end
	end
	result.Players = filteredPlayers
	result.Loading = leaderboard.Loading
	return result
end
getOrPollLeaderboard = function(leaderboardType, statId, statGranularity)
	local cachedLeaderboard = GlobalStore:getState().Leaderboards[LeaderboardUtil.getCacheKey(leaderboardType, statId, statGranularity)]
	if not cachedLeaderboard then
		print((("Missing leaderboard, polling %* %* %*"):format(leaderboardType, statId, statGranularity)))
		Flamework.resolveDependency("xBL"):pollLeaderboard(leaderboardType, statId, statGranularity, leaderboardType ~= LeaderboardType.Friends and {} or GlobalStore:getState().FriendIds)
		return {
			["Players"] = nil,
			["Loading"] = true,
			["Players"] = {}
		}
	end
	local stats = cachedLeaderboard.Stats
	local players = table.create(#stats)
	local result = {}
	for index, stat in stats do
		local _ = index - 1
		players[index] = {
			["UserId"] = stat.PlayerId,
			["DisplayName"] = stat.DisplayName,
			["Value"] = stat.Value,
			["Position"] = stat.Position
		}
	end
	result.Players = players
	result.Loading = false
	return result
end
return {
	["useLeaderboard"] = useLeaderboard
}
