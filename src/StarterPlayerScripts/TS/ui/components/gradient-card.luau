-- GradientCard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Outline = RuntimeLib.import(script, script.Parent, "outline").Outline
local TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

local createGradient = nil
local tweenGradient = nil
local tweenScale = nil

type Props = {
	CornerRadius: number?,
	ScalingDisabled: boolean?,
	StrokeThickness: number,
	Size: UDim2,
	ViewportIncludeFooter: boolean?,
	FooterHeight: number,
	ViewportClipsDescendants: boolean?,
	Selectable: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Color: Color3?,
	LayoutOrder: number?,
	Activated: (() -> ())?,
	children: { any }?,
	FooterComponent: any?,
}

local function GradientCard(props: Props)
	local hovered, setHovered = useState(false)
	local uiScaleRef = useRef()
	local outlineRef = useRef()
	local gradientRef = useRef()
	local cornerRadius = props.CornerRadius
	local radius = cornerRadius == nil and 20 or cornerRadius
	useEffect(function()
		local gradient = gradientRef.current
		local outline = outlineRef.current
		local uiScale = uiScaleRef.current
		if gradient then
			tweenGradient(gradient, hovered)
		end
		if uiScale and (outline and props.ScalingDisabled ~= true) then
			tweenScale(uiScale, outline, hovered, props.StrokeThickness)
		end
	end, { hovered })
	local uiScaleElement = React.createElement("uiscale", {
		["key"] = "UIScale",
		["ref"] = nil,
		["Scale"] = 1,
		["ref"] = uiScaleRef
	})
	local whiteGradientElement = React.createElement(Grid, {
		["key"] = "WhiteGradient",
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["Size"] = UDim2.fromScale(1, 1),
		["BackgroundColor3"] = Color.White
	}, createGradient(0, 0.6), React.createElement(CornerRadius, {
		["Radius"] = radius
	}))
	local outlineElement = React.createElement(Grid, {
		["key"] = "OutlineFrame",
		["Position"] = nil,
		["Size"] = nil,
		["Position"] = UDim2.fromOffset(props.StrokeThickness, props.StrokeThickness),
		["Size"] = UDim2.fromOffset(props.Size.X - props.StrokeThickness * 2, props.Size.Y - props.StrokeThickness * 2)
	}, React.createElement(Outline, {
		["Thickness"] = props.StrokeThickness,
		["Ref"] = outlineRef
	}, createGradient(0.1, 0.5, gradientRef)), React.createElement(CornerRadius, {
		["Radius"] = radius - props.StrokeThickness
	}))
	local viewportProps = {
		["key"] = "Viewport",
		["Position"] = nil,
		["Size"] = nil,
		["Position"] = UDim2.fromOffset(props.StrokeThickness, props.StrokeThickness),
		["Size"] = UDim2.fromOffset(props.Size.X - props.StrokeThickness * 2, props.Size.Y - props.StrokeThickness * 2 - (props.ViewportIncludeFooter and 0 or props.FooterHeight))
	}
	local viewportClipsDescendants = props.ViewportClipsDescendants
	viewportProps.ClipsDescendants = viewportClipsDescendants == nil and true or viewportClipsDescendants
	return React.createElement(Grid, {
		["Selectable"] = props.Selectable,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = props.Size:ToUDim2(),
		["BackgroundColor3"] = props.Color,
		["LayoutOrder"] = props.LayoutOrder,
		["Activated"] = props.Activated,
		["ActivateReroute"] = props.Activated and true or false,
		["Event"] = {
			["MouseEnter"] = function()
				setHovered(true)
			end,
			["MouseLeave"] = function()
				setHovered(false)
			end
		}
	}, uiScaleElement, whiteGradientElement, outlineElement, React.createElement(Grid, viewportProps, props.children), React.createElement(Grid, {
		["key"] = "TextBackgroundClipping",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["ClipsDescendants"] = true,
		["AnchorPoint"] = Vector2.new(0, 1),
		["Position"] = UDim2.new(0, props.StrokeThickness, 1, -props.StrokeThickness),
		["Size"] = UDim2.fromOffset(props.Size.X - props.StrokeThickness * 2, props.FooterHeight)
	}, React.createElement(Grid, {
		["key"] = "TextBackground",
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0.6,
		["ZIndex"] = 4,
		["Position"] = UDim2.fromOffset(0, -(20 - props.StrokeThickness)),
		["Size"] = UDim2.fromOffset(props.Size.X - props.StrokeThickness * 2, props.FooterHeight + (20 - props.StrokeThickness)),
		["BackgroundColor3"] = Color.Black
	}, React.createElement("uigradient", {
		["key"] = "UIGradient",
		["Rotation"] = 270,
		["Transparency"] = nil,
		["Color"] = nil,
		["Transparency"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0.85, 0) }),
		["Color"] = ColorSequence.new(Color.Black)
	}), React.createElement(CornerRadius, {
		["Radius"] = radius - props.StrokeThickness
	})), props.FooterComponent), React.createElement(CornerRadius, {
		["Radius"] = radius
	}))
end

createGradient = function(transparencyStart, transparencyEnd, ref)
	return React.createElement("uigradient", {
		["key"] = "UIGradient",
		["Rotation"] = 270,
		["Transparency"] = nil,
		["Color"] = nil,
		["ref"] = nil,
		["Transparency"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1 - transparencyStart, 0), NumberSequenceKeypoint.new(1, 1 - transparencyEnd, 0) }),
		["Color"] = ColorSequence.new(Color.White),
		["ref"] = ref
	})
end

tweenGradient = function(gradient, hovered)
	TweenService:Create(gradient, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		["Rotation"] = hovered and 90 or 270
	}):Play()
end

tweenScale = function(uiScale, outline, hovered, strokeThickness)
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	if hovered then
		TweenService:Create(uiScale, tweenInfo, {
			["Scale"] = 1.02
		}):Play()
		TweenService:Create(outline, tweenInfo, {
			["Thickness"] = strokeThickness * 1.02
		}):Play()
	else
		TweenService:Create(uiScale, tweenInfo, {
			["Scale"] = 1
		}):Play()
		TweenService:Create(outline, tweenInfo, {
			["Thickness"] = strokeThickness
		}):Play()
	end
end

return {
	["GradientCard"] = GradientCard
}
