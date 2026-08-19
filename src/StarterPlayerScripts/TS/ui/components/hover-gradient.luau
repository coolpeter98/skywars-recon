-- HoverGradient

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

type HoverGradientProps = {
	Hovering: boolean,
	HoverHeight: Vector2?,
	NumberSequence: NumberSequence?,
	children: { any }?,
	[string]: any,
}

return {
	HoverGradient = function(props: HoverGradientProps)
		local hoverHeight: Vector2 = props.HoverHeight or Vector2.new(0.2, 0.3)
		local initialProgress
		if props.Hovering then
			initialProgress = hoverHeight.Y
		else
			initialProgress = hoverHeight.X
		end
		local progress: number, setProgress: (number) -> () = useState(initialProgress)
		local tweenRef: { current: Tween? } = useRef()
		useEffect(function()
			local tweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			if tweenRef.current then
				tweenRef.current:Cancel()
			end
			local active = true
			local targetProgress
			if props.Hovering then
				targetProgress = hoverHeight.Y
			else
				targetProgress = hoverHeight.X
			end
			tweenRef.current = TweenUtil.simple(progress, targetProgress, tweenInfo, function(value: number)
				if active then
					setProgress(value)
				end
			end, function()
				tweenRef.current = nil
			end)
			return function()
				active = false
			end
		end, { props.Hovering })
		local restProps = table.clone(props)
		setmetatable(restProps, nil)
		restProps.Hovering = nil
		restProps.NumberSequence = nil
		restProps.HoverHeight = nil
		restProps.children = nil
		local gridProps = {
			key = "Gradient",
			Size = UDim2.fromScale(1, 1),
		}
		for key, value in restProps do
			gridProps[key] = value
		end
		return React.createElement(
			Grid,
			gridProps,
			React.createElement("uigradient", {
				Rotation = 270,
				Transparency = props.NumberSequence or NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(progress, 1, 0),
					NumberSequenceKeypoint.new(1, 1, 0),
				}),
			}),
			React.createElement(CornerRadius, {
				Radius = 10,
			}),
			props.children
		)
	end,
}
