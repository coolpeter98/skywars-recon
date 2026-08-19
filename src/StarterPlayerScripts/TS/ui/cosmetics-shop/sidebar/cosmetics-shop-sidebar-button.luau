-- CosmeticsShopSidebarButton

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local PurchaseType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PurchaseType
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CosmeticsShopSidebarButtonProps = {
	Price: number,
	Text: string,
	PurchaseType: "Robux" | "Gems",
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Disabled: boolean?,
	Activated: (() -> ())?,
}

return {
	["CosmeticsShopSidebarButton"] = function(props: CosmeticsShopSidebarButtonProps)
		local getTextProps = getTextProps
		local priceTextProps = {
			["Text"] = nil,
			["TextSize"] = 32,
			["Bold"] = true,
		}
		local price = props.Price
		priceTextProps.Text = tostring(price)
		local priceText = getTextProps(priceTextProps)
		local labelElement = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["DropShadow"] = nil,
			["ZIndex"] = 6,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 40, 0.5, 0),
			["Text"] = props.Text,
			["DropShadow"] = Vector2.new(0, 4),
		})
		local createElement = React.createElement
		local image = Image
		local iconProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = 6,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -(40 + priceText.Size.X.Offset + 8), 0.5, 0),
			["Size"] = UDim2.fromOffset(32, 32),
		}
		local icon: string
		if props.PurchaseType == PurchaseType.Robux then
			icon = RobloxImage.Icon.ROBUX
		else
			icon = RobloxImage.Icon.GEM_GREEN_OUTLINE_256
		end
		iconProps.Image = icon
		local iconElement = createElement(image, iconProps)
		local priceLabelProps = {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -40, 0.5, 0),
		}
		for key, value in priceText do
			priceLabelProps[key] = value
		end
		priceLabelProps.DropShadow = Vector2.new(0, 4)
		priceLabelProps.ZIndex = 6
		return React.createElement(Button, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = { 374, 100 },
			["Color"] = Color.Button.Green,
			["Disabled"] = props.Disabled,
			["Activated"] = props.Activated,
		}, labelElement, iconElement, React.createElement(Text, priceLabelProps))
	end,
}
