-- CosmeticsShopItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CosmeticViewport =
	RuntimeLib.import(script, script.Parent.Parent, "viewport", "cosmetic-viewport").CosmeticViewport
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local GradientCard = RuntimeLib.import(script, script.Parent.Parent, "components", "gradient-card").GradientCard
local Price = RuntimeLib.import(script, script.Parent.Parent, "components", "price").Price
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CosmeticsShopItemProps = {
	StrokeThickness: number?,
	DisplayNameTextSize: number?,
	DisplayName: string?,
	CornerRadius: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2,
	Color: Color3?,
	LayoutOrder: number?,
	Activated: (() -> ())?,
	FooterHeight: number?,
	ScalingDisabled: boolean?,
	ViewportClipsDescendants: boolean?,
	ViewportIncludeFooter: boolean?,
	HidePrice: boolean?,
	PriceInRobux: number?,
	PriceInGems: number?,
	DisplayNameDropShadow: Vector2?,
	Image: string?,
	CosmeticId: string?,
	ImageAnchorPoint: Vector2?,
	ImagePosition: UDim2?,
	ImageSize: UDim2?,
	ImageScaleType: Enum.ScaleType?,
	children: { any }?,
}

return {
	["CosmeticsShopItem"] = function(props: CosmeticsShopItemProps)
		local strokeThickness = props.StrokeThickness
		local resolvedStrokeThickness = strokeThickness == nil and 12 or strokeThickness
		local displayNameTextSize = props.DisplayNameTextSize
		local resolvedDisplayNameTextSize = displayNameTextSize == nil and 24 or displayNameTextSize
		local textFrameSize =
			Vector2.new(props.Size.X - resolvedStrokeThickness * 2 - 10, resolvedDisplayNameTextSize * 3)
		local displayName = props.DisplayName
		local nameTextProps
		if displayName == "" or not displayName then
			nameTextProps = nil
		else
			nameTextProps = getTextProps({
				["Text"] = nil,
				["TextSize"] = nil,
				["Bold"] = true,
				["FrameSize"] = nil,
				["Text"] = props.DisplayName,
				["TextSize"] = resolvedDisplayNameTextSize,
				["FrameSize"] = textFrameSize,
			})
		end
		local cornerRadius = props.CornerRadius
		local resolvedCornerRadius = cornerRadius == nil and 20 or cornerRadius
		local gradientCardProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = nil,
			["Selectable"] = true,
			["Activated"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["Color"] = props.Color,
			["LayoutOrder"] = props.LayoutOrder,
			["Activated"] = props.Activated,
		}
		local footerHeight = props.FooterHeight
		gradientCardProps.FooterHeight = footerHeight == nil and 48 or footerHeight
		gradientCardProps.StrokeThickness = resolvedStrokeThickness
		gradientCardProps.ScalingDisabled = props.ScalingDisabled
		gradientCardProps.ViewportClipsDescendants = props.ViewportClipsDescendants
		gradientCardProps.ViewportIncludeFooter = props.ViewportIncludeFooter
		gradientCardProps.CornerRadius = resolvedCornerRadius
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
		local priceElement
		if props.HidePrice then
			priceElement = nil
		else
			priceElement = createElement(Price, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["PriceInRobux"] = nil,
				["PriceInGems"] = nil,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["PriceInRobux"] = props.PriceInRobux,
				["PriceInGems"] = props.PriceInGems,
			})
		end
		gradientCardProps.FooterComponent = createElement(Fragment, fragmentProps, priceElement)
		local nameTextElement
		if nameTextProps then
			local textProps = {
				["key"] = "ItemNameText",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["TextWrapped"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 10),
			}
			for key, value in nameTextProps do
				textProps[key] = value
			end
			textProps.Size = UDim2.fromOffset(textFrameSize.X, nameTextProps.Size.Y.Offset)
			textProps.DropShadow = props.DisplayNameDropShadow or Vector2.new(0, 3)
			textProps.ZIndex = 5
			nameTextElement = createElement(Text, textProps)
		else
			nameTextElement = nil
		end
		local image = props.Image
		local createElement = React.createElement
		local gradientCard = GradientCard
		local cosmeticElement
		if image == "" or not image then
			if props.CosmeticId then
				cosmeticElement = createElement(CosmeticViewport, {
					["key"] = "CosmeticViewport",
					["Position"] = nil,
					["Size"] = nil,
					["CosmeticId"] = nil,
					["ZIndex"] = 3,
					["LayoutOrder"] = 1,
					["Position"] = UDim2.fromOffset(0, 20),
					["Size"] = UDim2.fromScale(1, 1),
					["CosmeticId"] = props.CosmeticId,
				})
			else
				cosmeticElement = nil
			end
		else
			cosmeticElement = createElement(
				Image,
				{
					["key"] = "CosmeticImage",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["ZIndex"] = 3,
					["ScaleType"] = nil,
					["AnchorPoint"] = props.ImageAnchorPoint or Vector2.new(0.5, 0.5),
					["Position"] = props.ImagePosition or UDim2.fromScale(0.5, 0.5),
					["Size"] = props.ImageSize or UDim2.fromScale(1, 1),
					["Image"] = props.Image,
					["ScaleType"] = props.ImageScaleType or Enum.ScaleType.Crop,
				},
				createElement(CornerRadius, {
					["Radius"] = resolvedCornerRadius - resolvedStrokeThickness,
				})
			)
		end
		return createElement(gradientCard, gradientCardProps, nameTextElement, cosmeticElement, props.children)
	end,
}
