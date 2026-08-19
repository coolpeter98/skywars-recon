-- AlertGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local AlertCircle = RuntimeLib.import(script, script.Parent, "alert-circle").AlertCircle
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local TextService: TextService = Services.TextService
local TweenService: TweenService = Services.TweenService
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

type AlertGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Icon: string,
	Text: string,
	Color: Color3,
}

local function AlertGui(props: AlertGuiProps)
	local textWidth = TextService:GetTextSize(
		StringUtil.stripRichText(props.Text),
		32,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	).X + 40
	local width, setWidth = useState(0)
	local scaleRef = useRef()

	useEffect(function()
		local isMounted = true
		task.spawn(function()
			local scale = scaleRef.current
			scale.Scale = 0
			local scaleTween =
				TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					["Scale"] = 1,
				})
			scaleTween:Play()
			scaleTween.Completed:Wait()
			if not isMounted then
				return nil
			end
			local slideTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenUtil.simple(width, textWidth, slideTweenInfo, function(newWidth)
				if isMounted then
					setWidth(newWidth)
				end
			end)
		end)
		return function()
			isMounted = false
		end
	end, {})

	local alertProps = {
		["key"] = "Alert",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = UDim2.fromOffset(width + 100, 100),
	}

	local circleProps = {
		["key"] = "Circle",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["ZIndex"] = 2,
		["AnchorPoint"] = Vector2.new(0.5, 0.5),
	}
	local circlePosition
	if width > 0 then
		circlePosition = UDim2.new()
	else
		circlePosition = UDim2.fromScale(0.5, 0.5)
	end
	circleProps.Position = circlePosition
	local circleSize
	if width > 0 then
		circleSize = UDim2.new()
	else
		circleSize = UDim2.fromOffset(100, 100)
	end
	circleProps.Size = circleSize

	local circleElement = React.createElement(
		Grid,
		circleProps,
		React.createElement(AlertCircle, {
			["Icon"] = props.Icon,
			["Color"] = props.Color,
			["TextBackgroundWidth"] = width,
		}),
		React.createElement("uiscale", {
			["Scale"] = 1,
			["ref"] = nil,
			["ref"] = scaleRef,
		})
	)

	local backgroundClippingProps = {
		["key"] = "TextBackgroundClipping",
		["Position"] = nil,
		["Size"] = nil,
		["ClipsDescendants"] = true,
		["Position"] = UDim2.fromOffset(80, 10),
		["Size"] = UDim2.fromOffset(width, 80),
	}

	local backgroundProps = {
		["key"] = "TextBackground",
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Position"] = UDim2.fromOffset(-10, 0),
		["Size"] = UDim2.fromOffset(width + 10, 80),
	}

	local textClippingProps = {
		["key"] = "TextClipping",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["ClipsDescendants"] = true,
		["AnchorPoint"] = Vector2.new(1, 0.5),
		["Position"] = UDim2.new(1, -20, 0.5, 0),
	}
	textClippingProps.Size = UDim2.fromOffset(math.max(width - 40, 0), 40)

	return React.createElement(
		Grid,
		alertProps,
		circleElement,
		React.createElement(
			Grid,
			backgroundClippingProps,
			React.createElement(
				Grid,
				backgroundProps,
				React.createElement(
					Grid,
					textClippingProps,
					React.createElement(Text, {
						["key"] = "Text",
						["Size"] = nil,
						["Text"] = nil,
						["TextSize"] = 32,
						["Bold"] = true,
						["RichText"] = true,
						["ZIndex"] = 2,
						["Size"] = UDim2.fromScale(1, 1),
						["Text"] = props.Text,
					}),
					React.createElement(CornerRadius, {
						["Radius"] = 10,
					})
				)
			)
		)
	)
end

return {
	["AlertGui"] = AlertGui,
}
