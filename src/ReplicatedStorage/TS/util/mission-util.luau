-- MissionUtil

type Mission = {
	Permanent: boolean,
}

type Period = "Daily" | "Weekly"

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Missions: { [string]: { Mission } } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "mission", "missions").Missions
local SeededPoolModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "seeded-pool", "seeded-pool")
local Period = SeededPoolModule.Period
local SeededPool = SeededPoolModule.SeededPool
return {
	["MissionUtil"] = {
		["getMissions"] = function(period: Period): { Mission }
			local periodMissions = Missions[period]
			local missions = periodMissions == nil and {} or periodMissions
			local permanentCount = 0
			local permanentMissions = {}
			for index, mission in missions do
				local _ = index - 1
				if mission.Permanent == true then
					permanentCount = permanentCount + 1
					permanentMissions[permanentCount] = mission
				end
			end
			local temporaryCount = 0
			local temporaryMissions = {}
			for index, mission in missions do
				local _ = index - 1
				if not mission.Permanent == true then
					temporaryCount = temporaryCount + 1
					temporaryMissions[temporaryCount] = mission
				end
			end
			local _ = period == Period.Daily
			local rotationSize = 5
			local activeRotation = SeededPool.getActiveRotation(temporaryMissions, period, rotationSize)
			local result = {}
			local resultCount = #result
			local permanentMissionsCount = #permanentMissions
			table.move(permanentMissions, 1, permanentMissionsCount, resultCount + 1, result)
			local totalCount = resultCount + permanentMissionsCount
			table.move(activeRotation, 1, #activeRotation, totalCount + 1, result)
			return result
		end,
	},
}
