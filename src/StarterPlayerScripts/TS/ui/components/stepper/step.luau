-- Step

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local StepCircle = RuntimeLib.import(script, script.Parent, "step-circle").StepCircle
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local useTween = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-tween").useTween
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type StepProps = {
	Name: string?,
	Value: number,
	BarSize: Vector2,
	CircleSize: Vector2,
	Progress: number,
	LastStep: boolean?,
}

return {
	["Step"] = function(props: StepProps)
		local progressTween: number = useTween(props.Progress, {
			["Time"] = 1,
		})
		local isActive = progressTween >= 1
		local gridProps = {}
		local name = props.Name
		gridProps.key = name == nil and "Step" or name
		gridProps.Size = props.CircleSize:add(props.BarSize.X, 0):ToUDim2()
		gridProps.LayoutOrder = props.Value
		return React.createElement(
			Grid,
			gridProps,
			React.createElement(Grid, {
				["key"] = "StepBar",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Size"] = props.BarSize:ToUDim2(),
			}),
			React.createElement(Grid, {
				["key"] = "Progress",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Size"] = props.BarSize:mul(math.clamp(progressTween, 0, 1), 1):ToUDim2(),
				["BackgroundColor3"] = Color.Green,
			}),
			React.createElement(StepCircle, {
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.fromScale(1, 0.5),
				["Value"] = props.Value,
				["BarSize"] = props.BarSize,
				["CircleSize"] = props.CircleSize,
				["Active"] = isActive,
				["RightCircle"] = props.LastStep,
			})
		)
	end,
}
