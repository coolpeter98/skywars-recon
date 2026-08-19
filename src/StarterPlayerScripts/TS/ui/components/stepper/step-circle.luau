-- StepCircle

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type StepCircleProps = {
	Name: string?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	CircleSize: UDim2,
	BarSize: UDim2,
	Value: number,
	Active: boolean,
	LeftCircle: boolean?,
	RightCircle: boolean?,
	children: any,
}

return {
	["StepCircle"] = function(props: StepCircleProps)
		local gridProps = {}
		local name = props.Name
		gridProps.key = name == nil and "StepCircle" or name
		gridProps.AnchorPoint = props.AnchorPoint
		gridProps.Position = props.Position
		gridProps.Size = props.CircleSize:ToUDim2()
		gridProps.LayoutOrder = props.Value

		local textProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["DropShadow"] = nil,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		local value = props.Value
		textProps.Text = tostring(value)
		textProps.TextSize = 0.5333333333333333 * props.CircleSize.Y
		textProps.DropShadow = Vector2.new(0, 0.06666666666666667 * props.CircleSize.Y)
		local textElement = React.createElement(Text, textProps)

		local backgroundColor
		if props.Active then
			backgroundColor = Color.Green
		else
			backgroundColor = Color.Black
		end
		local circleTopElement = React.createElement(
			Grid,
			{
				["key"] = "CircleTop",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.fromScale(0.5, 0),
				["Size"] = props.CircleSize:sub(0, props.BarSize.Y / 2 + props.CircleSize.Y / 2):ToUDim2(),
			},
			React.createElement(
				Grid,
				{
					["key"] = "Circle",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["BackgroundTransparency"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.fromScale(0.5, 0),
					["Size"] = props.CircleSize:ToUDim2(),
					["BackgroundColor3"] = backgroundColor,
					["BackgroundTransparency"] = props.Active and 0 or 0.6,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				})
			)
		)

		local backgroundColor
		if props.Active then
			backgroundColor = Color.Green
		else
			backgroundColor = Color.Black
		end
		local circleBottomElement = React.createElement(
			Grid,
			{
				["key"] = "CircleBottom",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.fromScale(0.5, 1),
				["Size"] = props.CircleSize:sub(0, props.BarSize.Y / 2 + props.CircleSize.Y / 2):ToUDim2(),
			},
			React.createElement(
				Grid,
				{
					["key"] = "Circle",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["BackgroundTransparency"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 1),
					["Position"] = UDim2.fromScale(0.5, 1),
					["Size"] = props.CircleSize:ToUDim2(),
					["BackgroundColor3"] = backgroundColor,
					["BackgroundTransparency"] = props.Active and 0 or 0.6,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				})
			)
		)

		local backgroundColor
		if props.Active then
			backgroundColor = Color.Green
		else
			backgroundColor = Color.Black
		end
		local leftCircleCorner
		if props.LeftCircle then
			leftCircleCorner = React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1),
			})
		else
			leftCircleCorner = nil
		end
		local circleLeftElement = React.createElement(
			Grid,
			{
				["key"] = "CircleLeft",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Size"] = UDim2.fromOffset(props.CircleSize.X / 2, props.BarSize.Y),
			},
			React.createElement(Grid, {
				["key"] = "Circle",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Size"] = props.CircleSize:ToUDim2(),
				["BackgroundColor3"] = backgroundColor,
				["BackgroundTransparency"] = props.Active and 0 or 0.6,
			}, leftCircleCorner)
		)

		local backgroundColor
		if props.Active then
			backgroundColor = Color.Green
		else
			backgroundColor = Color.Black
		end
		local rightCircleCorner
		if props.RightCircle then
			rightCircleCorner = React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1),
			})
		else
			rightCircleCorner = nil
		end
		local circleRightElement = React.createElement(
			Grid,
			{
				["key"] = "CircleRight",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.fromScale(1, 0.5),
				["Size"] = UDim2.fromOffset(props.CircleSize.X / 2, props.BarSize.Y),
			},
			React.createElement(Grid, {
				["key"] = "Circle",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = nil,
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.fromScale(1, 0.5),
				["Size"] = props.CircleSize:ToUDim2(),
				["BackgroundColor3"] = backgroundColor,
				["BackgroundTransparency"] = props.Active and 0 or 0.6,
			}, rightCircleCorner)
		)

		return React.createElement(
			Grid,
			gridProps,
			props.children,
			textElement,
			circleTopElement,
			circleBottomElement,
			circleLeftElement,
			circleRightElement
		)
	end,
}
