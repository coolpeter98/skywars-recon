-- MissionItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local SeededPool =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "seeded-pool", "seeded-pool").SeededPool

type Period = "Daily" | "Weekly"

type MissionItemProps = {
	Profile: {
		Missions: { [Period]: {
			Timestamp: number,
			Progress: { [string]: number },
		} },
	},
	Mission: {
		Period: Period,
		Tracker: string,
		Progress: number,
		Name: string,
		Icon: string,
		Reward: {
			RewardType: string,
			Quantity: number,
		},
	},
	LayoutOrder: number?,
}

return {
	["MissionItem"] = function(props: MissionItemProps)
		local periodMission = props.Profile.Missions[props.Mission.Period]
		local nextPeriodTime = SeededPool.getNextPeriodTime(props.Mission.Period)
		local periodProgress
		if periodMission then
			periodProgress = periodMission.Timestamp == nextPeriodTime
		else
			periodProgress = periodMission
		end
		if periodProgress then
			periodProgress = periodMission.Progress[props.Mission.Tracker]
		end
		local progress = (periodProgress == 0 or (periodProgress ~= periodProgress or not periodProgress)) and 0
			or periodProgress
		local missionProgress = props.Mission.Progress
		local displayProgress = math.min(progress, missionProgress)
		local isCompleted = displayProgress == props.Mission.Progress
		local isExperience = props.Mission.Reward.RewardType == "Experience"
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = "Mission",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["LayoutOrder"] = nil,
			["Size"] = UDim2.fromOffset(564, 100),
			["LayoutOrder"] = props.LayoutOrder,
		}
		local iconElement = React.createElement(Image, {
			["key"] = "Image",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ImageColor3"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 20, 0.5, 0),
			["Size"] = UDim2.fromOffset(67, 60),
			["Image"] = props.Mission.Icon,
			["ImageColor3"] = Color.Yellow,
		})
		local createElement = React.createElement
		local grid = Grid
		local nameRowProps = {
			["key"] = "MissionName",
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["Position"] = UDim2.fromOffset(107, 20),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}
		local nameTextElement = createElement(Text, {
			["key"] = "Text",
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["FixSize"] = true,
			["Text"] = string.upper(props.Mission.Name),
		})
		local completedIconElement
		if isCompleted then
			completedIconElement = createElement(Image, {
				["key"] = "CompletedImage",
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["Size"] = UDim2.fromOffset(20, 20),
				["Image"] = RobloxImage.Icon.CIRCLE_CHECK,
				["ImageColor3"] = Color.Green,
			})
		else
			completedIconElement = nil
		end
		local nameRowElement =
			createElement(grid, nameRowProps, nameTextElement, completedIconElement, createElement(List))
		local createElement = React.createElement
		local progressBar = ProgressBarNew
		local progressBarProps = {
			["key"] = "ProgressBar",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Progress"] = nil,
			["Text"] = nil,
			["TextSize"] = 16,
			["Colors"] = nil,
			["CornerRadius"] = 5,
			["Outline"] = 0,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.new(0, 107, 1, -20),
			["Size"] = UDim2.fromOffset(437, 24),
			["Progress"] = displayProgress / props.Mission.Progress,
			["Text"] = isCompleted and "COMPLETED" or ("%*/%*"):format(displayProgress, props.Mission.Progress),
		}
		local progressColors
		if isCompleted then
			progressColors = { Color.Green }
		else
			progressColors = { Color.Level.TierOne }
		end
		progressBarProps.Colors = progressColors
		local progressBarElement = createElement(progressBar, progressBarProps)
		local createElement = React.createElement
		local grid = Grid
		local rewardRowProps = {
			["key"] = "Reward",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, -20, 0, 20),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}
		local rewardIconElement = createElement(Image, {
			["key"] = "Image",
			["Size"] = nil,
			["Image"] = nil,
			["LayoutOrder"] = 1,
			["Size"] = UDim2.fromOffset(16, 22),
			["Image"] = RobloxImage.Icon.AWARD,
		})
		local createElement = React.createElement
		local text = Text
		local xpTextProps = {
			["key"] = "XP",
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["TextColor3"] = nil,
			["FixSize"] = true,
			["LayoutOrder"] = 2,
			["Text"] = ("%* %*"):format(
				StringUtil.formatNumber(props.Mission.Reward.Quantity),
				isExperience and "XP" or "Gems"
			),
		}
		local xpTextColor
		if isExperience then
			xpTextColor = Color.Yellow
		else
			xpTextColor = Color.Green
		end
		xpTextProps.TextColor3 = xpTextColor
		return createElement(
			grid,
			gridProps,
			iconElement,
			nameRowElement,
			progressBarElement,
			createElement(
				grid,
				rewardRowProps,
				rewardIconElement,
				createElement(text, xpTextProps),
				createElement(List)
			),
			createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
