-- MissionGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local MissionList = RuntimeLib.import(script, script.Parent, "mission-list").MissionList
local MissionUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "mission-util").MissionUtil
local SeededPoolModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "seeded-pool", "seeded-pool")
local Period = SeededPoolModule.Period
local SeededPool = SeededPoolModule.SeededPool
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile

type MissionGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["MissionGui"] = function(props: MissionGuiProps)
		local profile = useProfile()
		local dailyMissions = MissionUtil.getMissions(Period.Daily)
		local weeklyMissions = MissionUtil.getMissions(Period.Weekly)
		return React.createElement(
			Window,
			{
				["key"] = "Mission",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleText"] = "MISSIONS",
				["TitleImage"] = nil,
				["TitlePosition"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(1240, 710),
				["TitleImage"] = RobloxImage.Icon.ARROW,
				["TitlePosition"] = UDim2.fromOffset(20, 20),
			},
			React.createElement(MissionList, {
				["Position"] = nil,
				["Profile"] = nil,
				["Title"] = "DAILY MISSIONS",
				["Timestamp"] = nil,
				["Missions"] = nil,
				["Position"] = UDim2.fromOffset(20, 62),
				["Profile"] = profile,
				["Timestamp"] = SeededPool.getNextPeriodTime(Period.Daily),
				["Missions"] = dailyMissions,
			}),
			React.createElement(MissionList, {
				["Position"] = nil,
				["Profile"] = nil,
				["Title"] = "WEEKLY MISSIONS",
				["Timestamp"] = nil,
				["Missions"] = nil,
				["Position"] = UDim2.fromOffset(630, 62),
				["Profile"] = profile,
				["Timestamp"] = SeededPool.getNextPeriodTime(Period.Weekly),
				["Missions"] = weeklyMissions,
			})
		)
	end,
}
