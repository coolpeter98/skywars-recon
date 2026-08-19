-- ShopHomeImage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useEffect = React.useEffect
local useRef = React.useRef
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
local useHovering = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-hovering").useHovering
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local CosmeticsShopItem =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "cosmetics-shop", "cosmetics-shop-item").CosmeticsShopItem
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text

type Props = {
	Text: string,
	AnchorPoint: Vector2,
	Position: UDim2,
	Size: UDim2?,
	Color: Color3,
	Image: string,
	TabId: number,
	Activated: (() -> ())?,
	children: any,
	TextPosition: UDim2?,
	TextSize: number,
}

return {
	["ShopHomeImage"] = function(props: Props)
		local hoverRef = useRef()
		local frameRef = useRef()
		local hovering = useHovering(hoverRef)
		local shopContext = useContext(NewShopContext)
		useEffect(function()
			if not frameRef.current then
				return nil
			end
			local tweenProps = {
				["Scale"] = hovering and 1.02 or 1,
			}
			TweenService
				:Create(
					frameRef.current,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					tweenProps
				)
				:Play()
		end, { hovering })
		local frameProps = {
			["key"] = props.Text,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
		}
		local sizeXOffset = props.Size
		if sizeXOffset ~= nil then
			sizeXOffset = sizeXOffset.X.Offset
		end
		local sizeYOffset = props.Size
		if sizeYOffset ~= nil then
			sizeYOffset = sizeYOffset.Y.Offset
		end
		frameProps.Size = Size.new(sizeXOffset, sizeYOffset)
		frameProps.Color = props.Color
		frameProps.Image = props.Image
		frameProps.FooterHeight = 0
		frameProps.StrokeThickness = 12
		frameProps.ScalingDisabled = false
		frameProps.ViewportClipsDescendants = true
		frameProps.CornerRadius = 20
		function frameProps.Activated()
			shopContext.SetSelectedTab(props.TabId)
			if props.Activated then
				props.Activated()
			end
		end
		local createElement = React.createElement
		local cosmeticsShopItem = CosmeticsShopItem
		local children = props.children
		local createElement = React.createElement
		local textComponent = Text
		local textProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0, 0),
			["Position"] = props.TextPosition or UDim2.new(0, ScreenConstants.PADDING_2, 0, ScreenConstants.PADDING_2),
			["Text"] = props.Text,
			["TextSize"] = props.TextSize,
		}
		local createElement = React.createElement
		local outlineComponent = Outline
		local outlineProps = {}
		local outlineThickness = props.TextSize / 12
		outlineProps.Thickness = math.round(outlineThickness)
		outlineProps.Color = props.Color
		return createElement(
			cosmeticsShopItem,
			frameProps,
			children,
			createElement(textComponent, textProps, createElement(outlineComponent, outlineProps))
		)
	end,
}
