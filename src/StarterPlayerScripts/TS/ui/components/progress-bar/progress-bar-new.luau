-- ProgressBarNew

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local ProgressBarUtil = RuntimeLib.import(script, script.Parent, "progress-bar-util").ProgressBarUtil
local Outline = RuntimeLib.import(script, script.Parent.Parent, "outline").Outline
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local useTween = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-tween").useTween
local Image = RuntimeLib.import(script, script.Parent.Parent, "image").Image
local List = RuntimeLib.import(script, script.Parent.Parent, "list").List
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ProgressBarNewProps = {
	Progress: number,
	TweenTime: number?,
	Colors: any,
	ZIndex: number?,
	SecondaryProgress: number?,
	SecondaryProgressColor: Color3?,
	Text: string?,
	Image: string?,
	ImageSize: number?,
	TextSize: number?,
	CornerRadius: number?,
	Outline: number?,
	Size: UDim2,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	LayoutOrder: number?,
	children: any,
}

local getSizeOffset: (progress: number, width: number, padding: number) -> number

local function ProgressBarNew(props: ProgressBarNewProps): any
	local progress = props.Progress
	local clampedProgress = math.clamp(progress, 0, 1)

	local tweenInfo = {}
	local tweenTime = props.TweenTime
	tweenInfo.Time = tweenTime == nil and 0.5 or tweenTime
	tweenInfo.EasingStyle = Enum.EasingStyle.Quart

	local animatedProgress: number = useTween(clampedProgress, tweenInfo)
	local barColor: Color3 = ProgressBarUtil.getBarColor(props.Colors, animatedProgress)

	local color3New = Color3.new
	local red = barColor.R - 0.2
	local redClamped = math.max(red, 0)
	local green = barColor.G - 0.2
	local greenClamped = math.max(green, 0)
	local blue = barColor.B - 0.2
	local darkerColor: Color3 = color3New(redClamped, greenClamped, math.max(blue, 0))

	local zIndex = props.ZIndex
	local zIndexValue = zIndex == nil and 1 or zIndex

	local secondaryProgress = props.SecondaryProgress
	local animatedSecondaryProgress: number = useTween(secondaryProgress == nil and 0 or secondaryProgress, tweenInfo)

	local combinedProgress = animatedProgress + animatedSecondaryProgress
	local primaryProgress = math.min(combinedProgress, 1) - animatedSecondaryProgress

	local textOrImage = props.Text
	if textOrImage == "" or not textOrImage then
		textOrImage = props.Image
	end

	local content
	if textOrImage == "" or not textOrImage then
		content = nil
	else
		local image = props.Image
		local imageElement
		if image == "" or not image then
			imageElement = nil
		else
			local imageProps = {}
			local imageWidthSize = props.ImageSize
			local imageWidth = imageWidthSize == nil and 20 or imageWidthSize
			local imageHeightSize = props.ImageSize
			local imageHeight = imageHeightSize == nil and 20 or imageHeightSize
			imageProps.Size = UDim2.fromOffset(imageWidth, imageHeight)
			imageProps.Image = props.Image
			imageProps.DropShadow = Vector2.new(0, 2)
			imageProps.ZIndex = zIndexValue + 4
			imageProps.LayoutOrder = 1
			imageElement = React.createElement(Grid, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			}, React.createElement(Image, imageProps))
		end

		local text = props.Text
		local textElement
		if text == "" or not text then
			textElement = nil
		else
			local textProps = {
				["Text"] = props.Text,
			}
			local textSize = props.TextSize
			textProps.TextSize = textSize == nil and 24 or textSize
			textProps.Font = Enum.Font.GothamBlack
			textProps.ZIndex = zIndexValue + 4
			textProps.Bold = true
			textProps.DropShadow = Vector2.new(0, 2)
			textProps.RichText = true
			textProps.DropShadowStripRichText = true
			textProps.LayoutOrder = 2
			textElement = React.createElement(Grid, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			}, React.createElement(Text, textProps))
		end

		content = React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
				["ZIndex"] = zIndexValue + 2,
			},
			imageElement,
			textElement,
			React.createElement(List, {
				["Padding"] = UDim.new(0, 6),
			})
		)
	end

	local children = props.children

	local cornerRadiusProps = {}
	local cornerRadius = props.CornerRadius
	cornerRadiusProps.Radius = cornerRadius == nil and 10 or cornerRadius

	local primaryBar = React.createElement(
		Grid,
		{
			["key"] = "ProgressClipping",
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["ZIndex"] = nil,
			["Size"] = UDim2.fromScale(primaryProgress, 1),
			["ZIndex"] = props.ZIndex,
		},
		React.createElement(Grid, {
			["key"] = "Progress",
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["ZIndex"] = nil,
			["Size"] = UDim2.new(1, getSizeOffset(primaryProgress, props.Size.Width.Offset, 10), 1, 0),
			["BackgroundColor3"] = barColor,
			["ZIndex"] = props.ZIndex,
		}, React.createElement(CornerRadius, cornerRadiusProps))
	)

	local secondaryBar
	if animatedSecondaryProgress == nil then
		secondaryBar = nil
	else
		local secondaryCornerRadiusProps = {}
		local secondaryCornerRadius = props.CornerRadius
		secondaryCornerRadiusProps.Radius = secondaryCornerRadius == nil and 10 or secondaryCornerRadius
		secondaryBar = React.createElement(
			Grid,
			{
				["key"] = "ProgressClipping2",
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["ZIndex"] = nil,
				["Position"] = UDim2.fromScale(primaryProgress, 0),
				["Size"] = UDim2.fromScale(animatedSecondaryProgress, 1),
				["ZIndex"] = props.ZIndex,
			},
			React.createElement(Grid, {
				["key"] = "Progress2",
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["ZIndex"] = nil,
				["Position"] = UDim2.fromOffset(-10, 0),
				["Size"] = UDim2.new(
					1,
					10 + getSizeOffset(primaryProgress + animatedSecondaryProgress, props.Size.Width.Offset, 10),
					1,
					0
				),
				["BackgroundColor3"] = props.SecondaryProgressColor or Color.LightBlue,
				["ZIndex"] = props.ZIndex,
			}, React.createElement(CornerRadius, secondaryCornerRadiusProps))
		)
	end

	local barCornerRadiusProps = {}
	local barCornerRadius = props.CornerRadius
	barCornerRadiusProps.Radius = barCornerRadius == nil and 10 or barCornerRadius

	local barCornerRadiusElement = React.createElement(CornerRadius, barCornerRadiusProps)

	local outlineProps = {}
	local outlineThickness = props.Outline
	outlineProps.Thickness = outlineThickness == nil and 3 or outlineThickness

	return React.createElement(Grid, {
		["key"] = "ProgressBar",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0.5,
		["LayoutOrder"] = nil,
		["ZIndex"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = props.Size,
		["BackgroundColor3"] = darkerColor,
		["LayoutOrder"] = props.LayoutOrder,
		["ZIndex"] = zIndexValue,
	}, content, children, primaryBar, secondaryBar, barCornerRadiusElement, React.createElement(Outline, outlineProps))
end

getSizeOffset = function(progress: number, width: number, padding: number): number
	local overhang = progress * width - (width - padding)
	local minOverhang = -padding
	return padding - math.max(overhang, minOverhang)
end

return {
	["ProgressBarNew"] = ProgressBarNew,
}
