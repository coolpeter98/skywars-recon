-- ActionBarItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local ACTION_BAR_DURATION = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "action-bar", "action-bar").ACTION_BAR_DURATION
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type ActionBarItemProps = {
	Text: string,
	Color: Color3?,
	AnchorPoint: Vector2,
	Position: UDim2,
	Image: string,
	Removed: boolean,
	ActionBarId: string,
}

local animateFrameIn = nil
local animateTextTransparency = nil
local animateFrameOut = nil

local function ActionBarItem(props: ActionBarItemProps)
	local frameRef = useRef()
	local imageRef = useRef()
	local textRef = useRef()
	local textProps = getTextProps({
		["Text"] = nil,
		["TextSize"] = 20,
		["Bold"] = true,
		["Text"] = props.Text
	})
	local color = props.Color or Color.Red
	local frameWidth = 46 + textProps.Size.X.Offset + 10
	useEffect(function()
		local frame = frameRef.current
		local image = imageRef.current
		local text = textRef.current
		if not (frame and (image and text)) then
			return nil
		end
		task.spawn(function()
			animateFrameIn(frame, frameWidth, color).Completed:Wait()
			animateTextTransparency(image, text, 0)
			task.wait(ACTION_BAR_DURATION)
			local frameOutTween = animateFrameOut(frame, frameWidth)
			animateTextTransparency(image, text, 1)
			frameOutTween.Completed:Wait()
			Flamework.resolveDependency("gkk"):removeActionBar(props.ActionBarId)
		end)
	end, {})
	local imageElement = React.createElement(Image, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["Image"] = nil,
		["ImageTransparency"] = 1,
		["Ref"] = nil,
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.new(0, 10, 0.5, 0),
		["Size"] = UDim2.fromOffset(26, 26),
		["Image"] = props.Image,
		["Ref"] = imageRef
	})
	local textElementProps = {
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.new(0, 46, 0.5, 0)
	}
	for key, value in textProps do
		textElementProps[key] = value
	end
	textElementProps.TextTransparency = 1
	textElementProps.Ref = textRef
	return React.createElement(Grid, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0.2,
		["Visible"] = nil,
		["CornerRadius"] = 10,
		["Ref"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = UDim2.fromOffset(400, 0),
		["BackgroundColor3"] = Color.White,
		["Visible"] = not props.Removed,
		["Ref"] = frameRef
	}, imageElement, React.createElement(Text, textElementProps))
end

animateFrameIn = function(frame: Frame, width: number, color: Color3)
	frame.Size = UDim2.fromOffset(400, 0)
	frame.BackgroundColor3 = Color.White
	local tween = TweenService:Create(frame, TweenInfo.new(0.1), {
		["Size"] = UDim2.fromOffset(width, 40),
		["BackgroundColor3"] = color
	})
	tween:Play()
	return tween
end

animateFrameOut = function(frame: Frame, width: number)
	local tween = TweenService:Create(frame, TweenInfo.new(0.1), {
		["Size"] = UDim2.fromOffset(width, 0),
		["BackgroundColor3"] = Color.White
	})
	tween:Play()
	return tween
end

animateTextTransparency = function(image: ImageLabel, text: TextLabel, transparency: number)
	local tweenInfo = TweenInfo.new(0.1)
	local imageTween = TweenService:Create(image, tweenInfo, {
		["ImageTransparency"] = transparency
	})
	local textTween = TweenService:Create(text, tweenInfo, {
		["TextTransparency"] = transparency
	})
	imageTween:Play()
	textTween:Play()
end

return {
	["ActionBarItem"] = nil,
	["ACTION_BAR_FRAME_HEIGHT"] = 40,
	["ActionBarItem"] = ActionBarItem
}
