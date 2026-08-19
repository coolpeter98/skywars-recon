-- LeaderboardList

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local LeaderboardScrollingFrame = RuntimeLib.import(script, script.Parent, "leaderboard-scrolling-frame").LeaderboardScrollingFrame
return {
	["LeaderboardList"] = function(props)
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 10,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(620, 558)
		}, React.createElement(LeaderboardScrollingFrame, {
			["Position"] = UDim2.fromOffset(20, 20),
			["Size"] = UDim2.fromOffset(580, 518),
			["Image"] = props.Image,
			["LeaderboardType"] = props.LeaderboardType,
			["StatId"] = props.StatId,
			["StatGranularity"] = props.StatGranularity,
			["TextFilter"] = props.TextFilter,
			["ScrollingFrameRef"] = props.ScrollingFrameRef
		}))
	end
}
