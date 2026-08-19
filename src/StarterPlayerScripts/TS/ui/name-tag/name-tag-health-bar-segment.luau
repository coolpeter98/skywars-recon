-- NameTagHealthBarSegment

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type NameTagHealthBarSegmentProps = {
	MaxHealth: number,
	SegmentId: number,
	CurrentHealth: number,
	SegmentWidth: number,
	ParentWidth: number,
	ParentHeight: number,
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["NameTagHealthBarSegment"] = function(props: NameTagHealthBarSegmentProps)
		local segmentCount = props.MaxHealth / HealthConstants.HEALTH_PER_SEGMENT
		local segmentStartHealth = (props.SegmentId - 1) * HealthConstants.HEALTH_PER_SEGMENT
		local segmentHealth = props.CurrentHealth - segmentStartHealth
		local segmentCapacity = HealthConstants.HEALTH_PER_SEGMENT
		local segmentFill = math.clamp(segmentHealth, 0, segmentCapacity)
		local segmentRatio = segmentFill / HealthConstants.HEALTH_PER_SEGMENT
		local isFull = segmentRatio >= 1
		local isWholeSegment = segmentRatio % 1 == 0
		local fillWidth = segmentRatio * props.SegmentWidth + 4
		local segmentWidth = props.SegmentWidth
		local clampedFillWidth = math.min(fillWidth, segmentWidth)
		local remainingWidth = HealthConstants.HEALTH_PER_SEGMENT - segmentFill + 4
		local remainingWidthCap = props.SegmentWidth
		math.min(remainingWidth, remainingWidthCap)
		local createElement = React.createElement
		local grid = Grid
		local frameProps = {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromScale(props.SegmentWidth / props.ParentWidth, 20 / props.ParentHeight),
			["LayoutOrder"] = props.SegmentId,
		}
		local leftClipping = React.createElement(
			grid,
			{
				["key"] = "LeftClipping",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Size"] = UDim2.fromScale(segmentRatio, 1),
			},
			React.createElement(
				grid,
				{
					["key"] = "Left",
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["BackgroundTransparency"] = 0,
					["ZIndex"] = 2,
					["Size"] = UDim2.fromScale(clampedFillWidth / (segmentRatio * props.SegmentWidth), 1),
					["BackgroundColor3"] = Color.Green,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(0, 4),
				})
			)
		)
		local background
		if isFull then
			background = nil
		else
			background = React.createElement(
				grid,
				{
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["BackgroundTransparency"] = 0.6,
					["AnchorPoint"] = Vector2.new(1, 0),
					["Position"] = UDim2.fromScale(1, 0),
					["Size"] = UDim2.fromScale(1, 1),
					["BackgroundColor3"] = Color.Green,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(0, 4),
				})
			)
		end
		return createElement(grid, frameProps, leftClipping, background)
	end,
}
