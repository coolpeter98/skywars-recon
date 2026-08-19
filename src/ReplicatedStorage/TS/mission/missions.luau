-- Missions

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local MissionTracker =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "mission", "mission").MissionTracker
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Period =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "seeded-pool", "seeded-pool").Period

type MissionDefinition = {
	Name: string,
	Icon: unknown,
	Period: unknown,
	Reward: {
		RewardType: string,
		Quantity: number,
	},
	Tracker: unknown,
	Progress: number,
	Permanent: boolean,
}

local function playGamesMission(
	count: number,
	period: "Daily" | "Weekly",
	quantity: number,
	rewardType: string?,
	permanent: boolean?
): MissionDefinition
	local rewardType = rewardType == nil and "Experience" or rewardType
	if permanent == nil then
		permanent = false
	end
	return {
		["Name"] = ("Play %* %*"):format(count, count == 1 and "game" or "games"),
		["Icon"] = RobloxImage.Icon.JOYSTICK,
		["Period"] = period,
		["Reward"] = {
			["RewardType"] = rewardType,
			["Quantity"] = quantity,
		},
		["Tracker"] = MissionTracker.GamesPlayed,
		["Progress"] = count,
		["Permanent"] = permanent,
	}
end
local function winGamesMission(
	count: number,
	period: "Daily" | "Weekly",
	quantity: number,
	rewardType: string?,
	permanent: boolean?
): MissionDefinition
	local rewardType = rewardType == nil and "Experience" or rewardType
	if permanent == nil then
		permanent = false
	end
	return {
		["Name"] = ("Win %* %*"):format(count, count == 1 and "game" or "games"),
		["Icon"] = RobloxImage.Icon.TROPHY,
		["Period"] = period,
		["Reward"] = {
			["RewardType"] = rewardType,
			["Quantity"] = quantity,
		},
		["Tracker"] = MissionTracker.Wins,
		["Progress"] = count,
		["Permanent"] = permanent,
	}
end
local function killPlayersMission(
	count: number,
	period: "Daily" | "Weekly",
	quantity: number,
	rewardType: string?,
	permanent: boolean?
): MissionDefinition
	local rewardType = rewardType == nil and "Experience" or rewardType
	if permanent == nil then
		permanent = false
	end
	return {
		["Name"] = ("Kill %* %*"):format(count, count == 1 and "player" or "players"),
		["Icon"] = RobloxImage.Icon.SWORDS,
		["Period"] = period,
		["Reward"] = {
			["RewardType"] = rewardType,
			["Quantity"] = quantity,
		},
		["Tracker"] = MissionTracker.Kills,
		["Progress"] = count,
		["Permanent"] = permanent,
	}
end
local function lootChestsMission(
	count: number,
	period: "Daily" | "Weekly",
	quantity: number,
	rewardType: string?,
	permanent: boolean?
): MissionDefinition
	local rewardType = rewardType == nil and "Experience" or rewardType
	if permanent == nil then
		permanent = false
	end
	return {
		["Name"] = ("Loot %* %*"):format(count, count == 1 and "chest" or "chests"),
		["Icon"] = RobloxImage.Icon.CHEST,
		["Period"] = period,
		["Reward"] = {
			["RewardType"] = rewardType,
			["Quantity"] = quantity,
		},
		["Tracker"] = MissionTracker.ChestsLooted,
		["Progress"] = count,
		["Permanent"] = permanent,
	}
end
local missions: { [string]: { MissionDefinition } } = {}
for _, mission in
	{
		playGamesMission(1, Period.Daily, 50, "Gems", true),
		playGamesMission(5, Period.Daily, 150, "Gems", true),
		playGamesMission(10, Period.Daily, 50, "Gems", true),
		playGamesMission(5, Period.Daily, 2000),
		playGamesMission(10, Period.Daily, 4000),
		playGamesMission(15, Period.Daily, 5000),
		killPlayersMission(10, Period.Daily, 1500),
		killPlayersMission(15, Period.Daily, 2000),
		winGamesMission(1, Period.Daily, 1000),
		winGamesMission(2, Period.Daily, 2000),
		lootChestsMission(10, Period.Daily, 2000),
		lootChestsMission(15, Period.Daily, 2500),
		lootChestsMission(25, Period.Daily, 3000),
		playGamesMission(30, Period.Weekly, 8000),
		playGamesMission(35, Period.Weekly, 10000),
		playGamesMission(40, Period.Weekly, 12000),
		winGamesMission(5, Period.Weekly, 8000),
		winGamesMission(8, Period.Weekly, 10000),
		winGamesMission(10, Period.Weekly, 12000),
		killPlayersMission(40, Period.Weekly, 8000),
		killPlayersMission(50, Period.Weekly, 12000),
		lootChestsMission(45, Period.Weekly, 8000),
		lootChestsMission(50, Period.Weekly, 10000),
		lootChestsMission(55, Period.Weekly, 12000),
	}
do
	if missions[mission.Period] == nil then
		missions[mission.Period] = {}
	end
	local periodMissions: { MissionDefinition } = missions[mission.Period]
	table.insert(periodMissions, mission)
end
return {
	["Missions"] = missions,
}
