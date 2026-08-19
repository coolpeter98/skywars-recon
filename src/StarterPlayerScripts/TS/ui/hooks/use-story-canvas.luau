-- useStoryCanvas

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type StoryCanvasInfo = {
	Scale: number,
	AspectRatio: number,
	ViewportSize: Vector2,
}

type StoryCanvasProps = {
	MobileScale: number,
	Target: GuiObject,
}

return {
	["useStoryCanvas"] = function(props: StoryCanvasProps)
		local function getStoryCanvas(): StoryCanvasInfo
			return {
				["Scale"] = ScreenUtil.getScale(props.MobileScale, 1920, 1080, props.Target.AbsoluteSize),
				["AspectRatio"] = props.Target.AbsoluteSize.X / props.Target.AbsoluteSize.Y,
				["ViewportSize"] = props.Target.AbsoluteSize,
			}
		end
		local canvasInfo, setCanvasInfo = useState(getStoryCanvas)
		useEffect(function()
			local absoluteSizeChangedConnection = props.Target:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				setCanvasInfo(getStoryCanvas)
			end)
			return function()
				return absoluteSizeChangedConnection:Disconnect()
			end
		end, { props.Target })
		return canvasInfo
	end,
}
