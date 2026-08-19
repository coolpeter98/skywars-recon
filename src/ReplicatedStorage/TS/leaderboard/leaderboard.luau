-- Leaderboard: granularity & leaderboard-type labels, plus a granularity lookup map.

type Granularity = {
	All: string,
	Day: string,
	Week: string,
	Month: string,
	Year: string,
}

type LeaderboardType = {
	Global: string,
	Friends: string,
	Personal: string,
}

type GranularityEntry = {
	Text: string,
	Ordinal: number,
	Granularity: string,
}

local Granularity: Granularity = {
	["All"] = "ALL",
	["Day"] = "DAY",
	["Week"] = "WEEK",
	["Month"] = "MONTH",
	["Year"] = "YEAR",
}

local GranularityMap: { [string]: GranularityEntry } = {}

local LeaderboardType: LeaderboardType = {
	["Global"] = "Global",
	["Friends"] = "Friends",
	["Personal"] = "Personal",
}

for _, entry: GranularityEntry in
	{
		{
			["Granularity"] = nil,
			["Text"] = "ALL",
			["Ordinal"] = 0,
			["Granularity"] = Granularity.All,
		},
		{
			["Granularity"] = nil,
			["Text"] = "DAILY",
			["Ordinal"] = 1,
			["Granularity"] = Granularity.Day,
		},
		{
			["Granularity"] = nil,
			["Text"] = "WEEKLY",
			["Ordinal"] = 2,
			["Granularity"] = Granularity.Week,
		},
		{
			["Granularity"] = nil,
			["Text"] = "MONTHLY",
			["Ordinal"] = 3,
			["Granularity"] = Granularity.Month,
		},
		{
			["Granularity"] = nil,
			["Text"] = "YEARLY",
			["Ordinal"] = 4,
			["Granularity"] = Granularity.Year,
		},
	}
do
	GranularityMap[entry.Granularity] = entry
end

return {
	["LeaderboardType"] = LeaderboardType,
	["Granularity"] = Granularity,
	["GranularityMap"] = GranularityMap,
}
