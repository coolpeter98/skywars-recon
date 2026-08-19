-- ProgressBar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local ProgressBarUtil = RuntimeLib.import(script, script.Parent, "progress-bar-util").ProgressBarUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type ProgressBarProps = {
	Padding: number?,
	DisableText: boolean?,
	Signal: { Connect: (callback: () -> ()) -> { Disconnect: () -> () } }?,
	GetValue: () -> number,
	Size: Vector2,
	Colors: { Color3 },
	Range: { number } | ((value: number) -> { number }),
	TweenTime: number?,
	OnComplete: (() -> ())?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	children: any?,
}

return {
	ProgressBar = function(props: ProgressBarProps)
		local frameRef = useRef()
		local textLabelRef = useRef()
		local dropShadowRef = useRef()

		local rawPadding = props.Padding
		local padding: number = rawPadding == nil and 10 or rawPadding

		useEffect(function()
			if frameRef.current and (textLabelRef.current and dropShadowRef.current or props.DisableText) then
				return ProgressBarUtil.createProgressBar({
					["Signal"] = props.Signal,
					["GetValue"] = props.GetValue,
					["Size"] = {
						["X"] = props.Size.X - padding * 2,
						["Y"] = props.Size.Y - padding * 2,
					},
					["Colors"] = props.Colors,
					["Range"] = props.Range,
					["Frame"] = frameRef.current,
					["TextLabel"] = textLabelRef.current,
					["DropShadow"] = dropShadowRef.current,
					["TweenTime"] = props.TweenTime,
					["OnComplete"] = props.OnComplete,
				})
			else
				return nil
			end
		end, { frameRef.current, textLabelRef.current, dropShadowRef.current })

		local value: number = props.GetValue()
		local range = props.Range
		local resolvedRange: { number }
		if type(range) == "function" then
			resolvedRange = props.Range(value)
		else
			resolvedRange = props.Range
		end
		local min: number = resolvedRange[1]
		local max: number = resolvedRange[2]
		local percentage: number = (value - min) / (max - min)

		local barSize: UDim2 = UDim2.fromOffset((props.Size.X - padding * 2) * percentage, props.Size.Y - padding * 2)
		local fullSize: UDim2 = UDim2.fromOffset(props.Size.X, props.Size.Y)
		local barColor: Color3 = ProgressBarUtil.getBarColor(props.Colors, percentage)

		local frameProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = fullSize,
		}
		local barElement = React.createElement(
			Grid,
			{
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["ZIndex"] = 5,
				["Ref"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 10, 0.5, 0),
				["Size"] = barSize,
				["BackgroundColor3"] = barColor,
				["Ref"] = frameRef,
			},
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local textElement
		if props.DisableText then
			textElement = nil
		else
			textElement = React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextSize"] = 36,
				["Bold"] = true,
				["DropShadow"] = nil,
				["ZIndex"] = 10,
				["Ref"] = nil,
				["DropShadowRef"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0),
				["Text"] = ("%*"):format(value),
				["DropShadow"] = Vector2.new(3, 3),
				["Ref"] = textLabelRef,
				["DropShadowRef"] = dropShadowRef,
			})
		end
		return React.createElement(
			Grid,
			frameProps,
			barElement,
			textElement,
			props.children,
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
