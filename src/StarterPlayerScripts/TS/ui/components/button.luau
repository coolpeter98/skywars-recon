-- Button

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local Outline = RuntimeLib.import(script, script.Parent, "outline").Outline
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local TextService: TextService = Services.TextService
local useButton = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-button").useButton
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef

type ColorPalette = {
	Primary: Color3,
	Light: Color3,
	Dark: Color3,
}

export type ButtonProps = {
	Disabled: boolean?,
	Activated: (() -> ())?,
	Muted: boolean?,
	Color: ColorPalette?,
	Size: { "auto" | number }?,
	TextSize: number?,
	Text: string?,
	Icon: string?,
	IconRotation: number?,
	ZIndex: number?,
	Id: string?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	LayoutOrder: number?,
	AbsorbInput: boolean?,
	CornerRadius: number?,
	Outline: boolean?,
	TextOffsetX: number?,
	TextOffsetY: number?,
	children: any?,
}

local getHoverColor: (color: ColorPalette) -> ColorPalette

local function Button(props: ButtonProps)
	local buttonState = useButton({
		["Disabled"] = props.Disabled,
		["Activated"] = props.Activated,
		["Muted"] = props.Muted,
	})
	local topRef = useRef()
	local middleRef = useRef()
	local bottomRef = useRef()
	local iconRef = useRef()
	local buttonColor = props.Color or Color.Button.Green
	local size = props.Size or { 160, 50 }
	local textSize = props.TextSize
	local fontSize = textSize == nil and 24 or textSize
	local bodyColor
	if props.Disabled then
		bodyColor = Color.Button.Grey
	else
		bodyColor = props.Color or buttonColor
	end
	local text = props.Text
	local measuredTextSize = TextService:GetTextSize(
		text == nil and "" or text,
		fontSize,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	local height = size[2]
	local iconSizeRaw = height * 0.55
	local iconSize = math.round(iconSizeRaw)
	local smallIconSizeRaw = iconSize * 0.45
	local smallIconSize = math.round(smallIconSizeRaw)
	local width
	if size[1] == "auto" then
		local icon = props.Icon
		if icon == "" or not icon then
			width = 18 + measuredTextSize.X + 18
		else
			width = iconSize + 15 + 15 + measuredTextSize.X + 18
		end
	else
		width = size[1]
	end
	local buttonSize = UDim2.fromOffset(width, height)
	local fromOffset = UDim2.fromOffset
	local bodyHeight = height * 0.85
	local bodySize = fromOffset(width, math.round(bodyHeight))
	local fromOffsetPressed = UDim2.fromOffset
	local pressedHeight = height * 0.95
	local pressedSize = fromOffsetPressed(width, math.round(pressedHeight))
	local zIndex = props.ZIndex
	local resolvedZIndex = zIndex == nil and 10 or zIndex
	local rootProps = {}
	local id = props.Id
	rootProps.key = id == nil and "Button" or id
	rootProps.Selectable = true
	rootProps.AnchorPoint = props.AnchorPoint
	rootProps.Position = props.Position
	rootProps.Size = buttonSize
	local automaticSize
	if size[1] == "auto" then
		automaticSize = Enum.AutomaticSize.X
	else
		automaticSize = Enum.AutomaticSize.None
	end
	rootProps.AutomaticSize = automaticSize
	rootProps.BackgroundTransparency = 1
	rootProps.LayoutOrder = props.LayoutOrder
	rootProps.ZIndex = resolvedZIndex
	local absorbInput = props.AbsorbInput
	if absorbInput == nil then
		absorbInput = false
	end
	rootProps.Active = absorbInput
	rootProps.Activated = buttonState.Activated
	rootProps.Event = {
		["MouseEnter"] = function()
			if not (topRef.current and (middleRef.current and bottomRef.current)) then
				return nil
			end
			if props.Disabled then
				return nil
			end
			local hoverColor = getHoverColor(buttonColor)
			topRef.current.BackgroundColor3 = hoverColor.Primary
			middleRef.current.BackgroundColor3 = hoverColor.Light
			bottomRef.current.BackgroundColor3 = hoverColor.Dark
			if iconRef.current then
				iconRef.current.BackgroundColor3 = hoverColor.Dark
			end
		end,
		["MouseLeave"] = function()
			if not (topRef.current and (middleRef.current and bottomRef.current)) then
				return nil
			end
			if props.Disabled then
				return nil
			end
			topRef.current.BackgroundColor3 = buttonColor.Primary
			middleRef.current.BackgroundColor3 = buttonColor.Light
			bottomRef.current.BackgroundColor3 = buttonColor.Dark
			if iconRef.current then
				iconRef.current.BackgroundColor3 = buttonColor.Dark
			end
		end,
	}
	local wrapperRadiusProps = {}
	local wrapperRadius = props.CornerRadius
	wrapperRadiusProps.Radius = wrapperRadius == nil and 10 or wrapperRadius
	local wrapperRadiusElement = React.createElement(CornerRadius, wrapperRadiusProps)
	local outlineElement
	if props.Outline then
		outlineElement = React.createElement(Outline, {
			["Thickness"] = 3,
		})
	else
		outlineElement = nil
	end
	local icon = props.Icon
	local iconElement
	if icon == "" or not icon then
		iconElement = nil
	else
		local text = props.Text
		if text == "" or not text then
			iconElement = React.createElement(
				React.Fragment,
				nil,
				React.createElement(Image, {
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(iconSize, iconSize),
					["Image"] = props.Icon,
					["Rotation"] = props.IconRotation,
					["ZIndex"] = resolvedZIndex - 4,
				}),
				React.createElement(Image, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["Rotation"] = nil,
					["ImageColor3"] = nil,
					["ImageTransparency"] = 0.75,
					["ZIndex"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.new(0.5, 0, 0.5, 2),
					["Size"] = UDim2.fromOffset(iconSize, iconSize),
					["Image"] = props.Icon,
					["Rotation"] = props.IconRotation,
					["ImageColor3"] = Color.Black,
					["ZIndex"] = resolvedZIndex - 5,
				})
			)
		else
			local iconFrameProps = {
				["key"] = "Icon",
			}
			local text = props.Text
			iconFrameProps.AnchorPoint = Vector2.new((text == "" or not text) and 0.5 or 0, 0.5)
			local text2 = props.Text
			local iconAnchorX = (text2 == "" or not text2) and 0.5 or 0
			local text3 = props.Text
			iconFrameProps.Position = UDim2.new(iconAnchorX, (text3 == "" or not text3) and 0 or 15, 0.5, 0)
			iconFrameProps.Size = UDim2.fromOffset(iconSize, iconSize)
			iconFrameProps.BackgroundColor3 = bodyColor.Dark
			iconFrameProps.ZIndex = resolvedZIndex - 6
			iconFrameProps.Ref = iconRef
			iconElement = React.createElement(
				Grid,
				iconFrameProps,
				React.createElement(Image, {
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(smallIconSize, smallIconSize),
					["Image"] = props.Icon,
					["Rotation"] = props.IconRotation,
					["ZIndex"] = resolvedZIndex - 5,
				}),
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			)
		end
	end
	local buttonText = props.Text
	local textElement
	if buttonText == "" or not buttonText then
		textElement = nil
	else
		local textElementProps = {}
		local icon = props.Icon
		textElementProps.AnchorPoint = Vector2.new((icon == "" or not icon) and 0.5 or 0, 0.5)
		local icon2 = props.Icon
		local textAnchorX = (icon2 == "" or not icon2) and 0.5 or 0
		local icon3 = props.Icon
		local iconOffset = (icon3 == "" or not icon3) and 0 or iconSize + 15 + 15
		local offsetX = props.TextOffsetX
		local textOffsetX = iconOffset + (offsetX == nil and 0 or offsetX)
		local offsetY = props.TextOffsetY
		local textOffsetY = offsetY == nil and 0 or offsetY
		textElementProps.Position = UDim2.new(textAnchorX, textOffsetX, 0.5, textOffsetY)
		local textElementSize
		if size[1] == "auto" then
			textElementSize = UDim2.fromOffset(measuredTextSize.X, measuredTextSize.Y)
		else
			local icon = props.Icon
			textElementSize = UDim2.new(1, (icon == "" or not icon) and 0 or -(iconSize + 15 + 15), 1, 0)
		end
		textElementProps.Size = textElementSize
		textElementProps.TextXAlignment = Enum.TextXAlignment.Center
		textElementProps.TextYAlignment = Enum.TextYAlignment.Center
		textElementProps.Text = props.Text
		textElementProps.TextSize = fontSize
		textElementProps.Font = Enum.Font.GothamBlack
		textElementProps.FixSize = true
		textElementProps.DropShadow = Vector2.new(0, height >= 100 and 3 or 2)
		textElementProps.ZIndex = resolvedZIndex - 4
		textElementProps.RichText = true
		textElement = React.createElement(Text, textElementProps)
	end
	local children = props.children
	local iconOrText = props.Icon
	if iconOrText == "" or not iconOrText then
		iconOrText = props.Text
	end
	local paddingElement
	if iconOrText == "" or not iconOrText then
		paddingElement = nil
	else
		local paddingProps = {}
		local icon = props.Icon
		paddingProps.PaddingLeft = UDim.new(0, (icon == "" or not icon) and 18 or 0)
		local text = props.Text
		paddingProps.PaddingRight = UDim.new(0, (text == "" or not text) and 0 or 18)
		paddingElement = React.createElement("uipadding", paddingProps)
	end
	local topRadiusProps = {}
	local topRadius = props.CornerRadius
	topRadiusProps.Radius = topRadius == nil and 10 or topRadius
	local topElement = React.createElement(Grid, {
		["key"] = "Top",
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["ZIndex"] = nil,
		["Ref"] = nil,
		["Size"] = bodySize,
		["BackgroundColor3"] = bodyColor.Primary,
		["ZIndex"] = resolvedZIndex - 7,
		["Ref"] = topRef,
	}, iconElement, textElement, children, paddingElement, React.createElement(CornerRadius, topRadiusProps))
	local middleRadiusProps = {}
	local middleRadius = props.CornerRadius
	middleRadiusProps.Radius = middleRadius == nil and 10 or middleRadius
	local middleWrapperElement = React.createElement(
		Grid,
		{
			["key"] = "Middle Wrapper",
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["ZIndex"] = nil,
			["Position"] = UDim2.fromOffset(0, 13),
			["Size"] = bodySize,
			["ZIndex"] = resolvedZIndex - 8,
		},
		React.createElement(Grid, {
			["key"] = "Middle",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["ZIndex"] = nil,
			["Ref"] = nil,
			["Position"] = UDim2.fromOffset(0, -10),
			["Size"] = bodySize,
			["BackgroundColor3"] = bodyColor.Light,
			["ZIndex"] = resolvedZIndex - 8,
			["Ref"] = middleRef,
		}, React.createElement(CornerRadius, middleRadiusProps))
	)
	local bottomRadiusProps = {}
	local bottomRadius = props.CornerRadius
	bottomRadiusProps.Radius = bottomRadius == nil and 10 or bottomRadius
	local createElement = React.createElement
	local grid = Grid
	local createElementWrapper = React.createElement
	local gridWrapper = Grid
	local wrapperProps = {
		["key"] = "Wrapper",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["ZIndex"] = nil,
		["AnchorPoint"] = Vector2.new(0, 1),
		["Position"] = UDim2.fromScale(0, 1),
	}
	local wrapperSize
	if buttonState.Pressed then
		wrapperSize = pressedSize
	else
		wrapperSize = buttonSize
	end
	wrapperProps.Size = wrapperSize
	wrapperProps.ZIndex = resolvedZIndex - 7
	local createElementBottom = React.createElement
	local gridBottom = Grid
	local bottomProps = {
		["key"] = "Bottom",
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["ZIndex"] = nil,
		["Ref"] = nil,
	}
	if buttonState.Pressed then
		buttonSize = pressedSize
	end
	bottomProps.Size = buttonSize
	bottomProps.BackgroundColor3 = bodyColor.Dark
	bottomProps.ZIndex = resolvedZIndex - 9
	bottomProps.Ref = bottomRef
	return createElement(
		grid,
		rootProps,
		createElementWrapper(
			gridWrapper,
			wrapperProps,
			wrapperRadiusElement,
			outlineElement,
			topElement,
			middleWrapperElement,
			createElementBottom(gridBottom, bottomProps, React.createElement(CornerRadius, bottomRadiusProps))
		)
	)
end

local getShade: (color: Color3, factor: number) -> Color3
getHoverColor = function(color: ColorPalette)
	return {
		["Primary"] = getShade(color.Primary, 0.9),
		["Light"] = getShade(color.Light, 0.9),
		["Dark"] = getShade(color.Dark, 0.9),
	}
end
getShade = function(color: Color3, factor: number)
	return Color3.new(color.R * factor, color.G * factor, color.B * factor)
end
return {
	["Button"] = Button,
}
