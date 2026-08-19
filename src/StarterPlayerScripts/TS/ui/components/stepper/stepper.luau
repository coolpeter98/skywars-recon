-- Stepper

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local List = RuntimeLib.import(script, script.Parent.Parent, "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local Step = RuntimeLib.import(script, script.Parent, "step").Step
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local StepCircle = RuntimeLib.import(script, script.Parent, "step-circle").StepCircle
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type StepperProps = {
	BarSize: { X: number, Y: number },
	CircleSize: number,
	Length: number,
	Progress: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["Stepper"] = function(props: StepperProps)
		local barAndCircleWidth = props.BarSize.X + props.CircleSize
		local createSize = Size.new
		local circleRadius = props.CircleSize / 2
		local circleDiameter = math.round(circleRadius) * 2
		local circleRadiusY = props.CircleSize / 2
		local circleSize = createSize(circleDiameter, math.round(circleRadiusY) * 2)
		local createBarSize = Size.new
		local barWidth = barAndCircleWidth - circleSize.X
		local barHeightHalf = props.BarSize.Y / 2
		local barSize = createBarSize(barWidth, math.round(barHeightHalf) * 2)
		local firstStepCircle = React.createElement(StepCircle, {
			["Name"] = "Step0",
			["Value"] = 1,
			["BarSize"] = nil,
			["CircleSize"] = nil,
			["Active"] = true,
			["LeftCircle"] = true,
			["BarSize"] = barSize,
			["CircleSize"] = circleSize,
		})
		local stepIndices = ArrayUtil.fill(props.Length - 1)
		local stepElements = table.create(#stepIndices)
		local function renderStep(stepIndex)
			local stepValue = stepIndex + 2
			return React.createElement(Step, {
				["Name"] = ("Step%*"):format(stepIndex),
				["Value"] = stepIndex + 2,
				["BarSize"] = barSize,
				["CircleSize"] = circleSize,
				["Progress"] = props.Progress - stepIndex,
				["LastStep"] = stepValue == props.Length,
			})
		end
		for i, stepIndex in stepIndices do
			stepElements[i] = renderStep(stepIndex, i - 1, stepIndices)
		end
		return React.createElement(
			Grid,
			{
				["key"] = "Stepper",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(circleSize.X * props.Length + barSize.X * (props.Length - 1), circleSize.Y),
			},
			firstStepCircle,
			stepElements,
			React.createElement(List, {
				["Padding"] = UDim.new(),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			})
		)
	end,
}
