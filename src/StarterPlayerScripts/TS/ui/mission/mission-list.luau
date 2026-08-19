-- MissionList

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local MissionItem = RuntimeLib.import(script, script.Parent, "mission-item").MissionItem
local useTimer = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-timer").useTimer
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil

type MissionListProps = {
	Timestamp: number,
	Missions: { { Reward: { Quantity: number, RewardType: string } } },
	Title: string,
	Profile: any,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["MissionList"] = function(props: MissionListProps)
		local textRef: { current: TextLabel? } = useRef()
		local time: number = useTimer({
			["EndTime"] = nil,
			["Refs"] = nil,
			["IncludeImage"] = true,
			["EndTime"] = props.Timestamp,
			["Refs"] = { textRef },
		})
		local gridSize: number = ScreenUtil.getGridSize(100, 10, #props.Missions)
		local header = React.createElement(
			Grid,
			{
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(Text, {
				["Text"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["Text"] = props.Title,
			}),
			React.createElement(Text, {
				["Text"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["Ref"] = nil,
				["Text"] = TimeUtil.formatTime(time, false),
				["Ref"] = textRef,
			}),
			React.createElement(List, {
				["Padding"] = UDim.new(0, 20),
			})
		)
		local missions = props.Missions
		local missionElements = table.create(#missions)
		local function createMissionItem(mission)
			return React.createElement(MissionItem, {
				["Profile"] = props.Profile,
				["Mission"] = mission,
				["LayoutOrder"] = mission.Reward.Quantity / #props.Missions
					+ (mission.Reward.RewardType == "Experience" and 100 or 0),
			})
		end
		for index, mission in missions do
			missionElements[index] = createMissionItem(mission, index - 1, missions)
		end
		return React.createElement(
			Grid,
			{
				["key"] = "MissionList",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["AutomaticSize"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			header,
			React.createElement(
				"scrollingframe",
				{
					["key"] = "ScrollingFrame",
					["Position"] = nil,
					["Size"] = nil,
					["CanvasSize"] = nil,
					["ScrollingDirection"] = nil,
					["ScrollBarThickness"] = 6,
					["ScrollBarImageColor3"] = nil,
					["BackgroundTransparency"] = 1,
					["BorderSizePixel"] = 0,
					["Selectable"] = false,
					["Position"] = UDim2.fromOffset(0, 47),
					["Size"] = UDim2.fromOffset(590, 581),
					["CanvasSize"] = UDim2.fromOffset(0, gridSize),
					["ScrollingDirection"] = Enum.ScrollingDirection.Y,
					["ScrollBarImageColor3"] = Color.White,
				},
				missionElements,
				React.createElement(List, {
					["Vertical"] = true,
					["HorizontalAlignment"] = nil,
					["VerticalAlignment"] = nil,
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
					["VerticalAlignment"] = Enum.VerticalAlignment.Top,
				})
			)
		)
	end,
}
