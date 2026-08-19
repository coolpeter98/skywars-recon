-- Text

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local RoactUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "roact-util").RoactUtil
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local DEFAULT_FONT = Enum.Font.Gotham
local DEFAULT_BOLD_FONT = Enum.Font.GothamBlack

type TextProps = {
	Bold: boolean?,
	DropShadow: Vector2?,
	DropShadowStripRichText: boolean?,
	FixSize: boolean?,
	DropShadowRef: GuiObject?,
	Ref: GuiObject?,
	RichText: any?,
	Text: string?,
	TextSize: number?,
	TextTransparency: number?,
	ZIndex: number?,
	Font: any?,
	Position: any?,
	[string]: any,
}

return {
	["Text"] = function(props: TextProps)
		local labelProps = table.clone(props)
		setmetatable(labelProps, nil)
		labelProps.Bold = nil
		labelProps.DropShadow = nil
		labelProps.DropShadowStripRichText = nil
		labelProps.FixSize = nil
		labelProps.DropShadowRef = nil
		labelProps.Ref = nil
		local font = props.Font
		local isStaticFont = typeof(font) == "EnumItem"
		if not isStaticFont then
			local fontCheck = props.Font
			isStaticFont = type(fontCheck) == "string"
		end
		local resolvedFont
		if isStaticFont then
			resolvedFont = props.Font
		else
			resolvedFont = props.Font
			if resolvedFont ~= nil then
				resolvedFont = resolvedFont:getValue()
			end
		end
		if resolvedFont == nil then
			resolvedFont = props.Bold
		end
		local labelFont
		if resolvedFont then
			labelFont = DEFAULT_BOLD_FONT
		else
			labelFont = DEFAULT_FONT
		end
		local text
		if RoactUtil.getBinding(props.RichText) then
			text = StringUtil.stripRichText(props.Text)
		else
			text = props.Text
		end
		local textSize = props.TextSize
		local measuredSize =
			TextService:GetTextSize(text, textSize == nil and 24 or textSize, labelFont, Vector2.new(1920, 1080))
		local positionBinding = RoactUtil.getBinding(props.Position)
		local labelProperties = {}
		local size
		if props.FixSize then
			size = UDim2.fromOffset(measuredSize.X, measuredSize.Y)
		else
			size = nil
		end
		labelProperties.Size = size
		local automaticSize
		if props.FixSize then
			automaticSize = nil
		else
			automaticSize = Enum.AutomaticSize.XY
		end
		labelProperties.AutomaticSize = automaticSize
		labelProperties.Font = labelFont
		labelProperties.TextColor3 = Color.White
		local labelTextSize = props.TextSize
		labelProperties.TextSize = labelTextSize == nil and 24 or labelTextSize
		labelProperties.TextTransparency = 0
		labelProperties.BackgroundTransparency = 1
		labelProperties.BorderSizePixel = 0
		labelProperties.ref = props.Ref
		for key, value in labelProps do
			labelProperties[key] = value
		end
		local labelElement = React.createElement("textlabel", labelProperties)
		local shadowElement
		if props.DropShadow then
			local shadowProps = {}
			local shadowSize
			if props.FixSize then
				shadowSize = UDim2.fromOffset(measuredSize.X, measuredSize.Y)
			else
				shadowSize = nil
			end
			shadowProps.Size = shadowSize
			local shadowAutomaticSize
			if props.FixSize then
				shadowAutomaticSize = nil
			else
				shadowAutomaticSize = Enum.AutomaticSize.XY
			end
			shadowProps.AutomaticSize = shadowAutomaticSize
			shadowProps.Font = labelFont
			local shadowTextSize = props.TextSize
			shadowProps.TextSize = shadowTextSize == nil and 24 or shadowTextSize
			shadowProps.BackgroundTransparency = 1
			shadowProps.BorderSizePixel = 0
			for key, value in labelProps do
				shadowProps[key] = value
			end
			shadowProps.Position = (positionBinding or UDim2.new())
				+ UDim2.fromOffset(props.DropShadow.X, props.DropShadow.Y)
			if not props.DropShadowStripRichText then
				text = props.Text
			end
			shadowProps.Text = text
			shadowProps.TextColor3 = Color.Black
			local textTransparency = props.TextTransparency
			shadowProps.TextTransparency = 0.75 + (textTransparency == nil and 0 or textTransparency) * 0.25
			local zIndex = props.ZIndex
			shadowProps.ZIndex = (zIndex == nil and 1 or zIndex) - 1
			shadowProps.ref = props.DropShadowRef
			shadowElement = React.createElement("textlabel", shadowProps)
		else
			shadowElement = nil
		end
		return React.createElement(React.Fragment, nil, labelElement, shadowElement)
	end,
	["DEFAULT_FONT"] = DEFAULT_FONT,
	["DEFAULT_BOLD_FONT"] = DEFAULT_BOLD_FONT,
}
