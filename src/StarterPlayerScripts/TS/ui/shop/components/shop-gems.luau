-- ShopGems

type GameProduct = {
	ProductId: string,
	DisplayName: string,
	Image: string?,
	PriceInRobux: number?,
	GemsReward: number?,
}

type Props = {
	GameProduct: GameProduct,
	Size: UDim2,
	Color: Color3,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
local CosmeticsShopItem =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "cosmetics-shop", "cosmetics-shop-item").CosmeticsShopItem
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local ProductId = GameProduct.ProductId
local PurchaseType = GameProduct.PurchaseType
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants

local GEM_IMAGE_SIZE = Vector2.new(64, 64)
return {
	["ShopGems"] = function(props: Props)
		local shopContext = useContext(NewShopContext)
		if props.GameProduct.GemsReward == nil then
			return React.createElement(React.Fragment)
		end
		local gemsTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 64,
			["Bold"] = true,
			["Color"] = nil,
			["Text"] = StringUtil.formatNumber(props.GameProduct.GemsReward),
			["Color"] = Color.Green,
		})
		local robuxTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(props.GameProduct.PriceInRobux),
		})
		local gemsRowWidth = GEM_IMAGE_SIZE.X + 12 + gemsTextProps.Size.X.Offset
		local robuxRowWidth = 68 + robuxTextProps.Size.X.Offset
		local tier1Product = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.GEMS_TIER_1)
		local tier1PricePerGem = tier1Product.PriceInRobux / tier1Product.GemsReward
		local savePercentRaw = (1 - props.GameProduct.PriceInRobux / (tier1PricePerGem * props.GameProduct.GemsReward))
			* 100
			/ 5
		local savePercent = math.round(savePercentRaw) * 5
		local saveTextSize = savePercent / 100 * 36 + 24
		local saveTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["Text"] = ("SAVE %*%%"):format(savePercent),
			["TextSize"] = saveTextSize,
		})
		local gemsImage = React.createElement(Image, {
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = 5,
			["Position"] = UDim2.new(0.5, -gemsRowWidth / 2, 0, 68),
			["Size"] = UDim2.fromOffset(GEM_IMAGE_SIZE.X, GEM_IMAGE_SIZE.Y),
			["Image"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256,
		})
		local gemsCountTextProps = {
			["Position"] = nil,
			["ZIndex"] = 5,
			["Position"] = UDim2.new(0.5, -gemsRowWidth / 2 + GEM_IMAGE_SIZE.X + 12, 0, 68),
		}
		for key, value in gemsTextProps do
			gemsCountTextProps[key] = value
		end
		local gemsText = React.createElement(
			Text,
			gemsCountTextProps,
			React.createElement(Outline, {
				["Thickness"] = 5,
				["Color"] = nil,
				["Color"] = Color3.fromRGB(0, 89, 42),
			})
		)
		local saveBadge
		if savePercent >= 5 then
			local saveBadgeTextProps = {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["ZIndex"] = 6,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
			}
			for key, value in saveTextProps do
				saveBadgeTextProps[key] = value
			end
			saveBadge = React.createElement(Grid, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["CornerRadius"] = 10,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -(75 + ScreenConstants.PADDING_1 - 12)),
				["Size"] = UDim2.fromOffset(saveTextProps.Size.X.Offset + 20, saveTextProps.Size.Y.Offset + 10),
				["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
			}, React.createElement(Text, saveBadgeTextProps))
		else
			saveBadge = nil
		end
		local robuxIcon = React.createElement(Image, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Image"] = nil,
			["Size"] = nil,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (props.Size.X - robuxRowWidth) / 2, 0.5, 10),
			["Image"] = RobloxImage.Icon.ROBUX,
			["Size"] = UDim2.fromOffset(48, 48),
		})
		local robuxPriceTextProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (props.Size.X - robuxRowWidth) / 2 + 48 + 20, 0.5, 10),
		}
		for key, value in robuxTextProps do
			robuxPriceTextProps[key] = value
		end
		local createElement = React.createElement
		local shopItemComponent = CosmeticsShopItem
		local itemProps = {
			["key"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["DisplayName"] = nil,
			["DisplayNameTextSize"] = 48,
			["DisplayNameDropShadow"] = nil,
			["Image"] = nil,
			["ImageScaleType"] = nil,
			["LayoutOrder"] = nil,
			["FooterHeight"] = 0,
			["StrokeThickness"] = 12,
			["ScalingDisabled"] = true,
			["ViewportClipsDescendants"] = false,
			["CornerRadius"] = 20,
			["Activated"] = nil,
			["key"] = props.GameProduct.ProductId,
			["Size"] = props.Size,
			["Color"] = props.Color,
			["DisplayName"] = props.GameProduct.DisplayName,
			["DisplayNameDropShadow"] = Vector2.new(0, 6),
			["Image"] = props.GameProduct.Image,
		}
		local imageScaleType
		if
			props.GameProduct.ProductId == ProductId.GEMS_TIER_5
			or props.GameProduct.ProductId == ProductId.GEMS_TIER_6
		then
			imageScaleType = nil
		else
			imageScaleType = Enum.ScaleType.Fit
		end
		itemProps.ImageScaleType = imageScaleType
		itemProps.LayoutOrder = props.GameProduct.GemsReward
		function itemProps.Activated()
			shopContext.Purchase(props.GameProduct.ProductId, PurchaseType.Robux)
		end
		return createElement(
			shopItemComponent,
			itemProps,
			gemsImage,
			gemsText,
			saveBadge,
			React.createElement(
				Grid,
				{
					["key"] = "Clipping",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ClipsDescendants"] = true,
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.new(0, -12, 1, 12),
					["Size"] = UDim2.fromOffset(props.Size.X, 75),
				},
				React.createElement(Button, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["CornerRadius"] = 20,
					["Activated"] = nil,
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.fromScale(0, 1),
					["Size"] = { props.Size.X, 95 },
					["Color"] = Color.Button.Green,
					["Activated"] = function()
						shopContext.Purchase(props.GameProduct.ProductId, PurchaseType.Robux)
					end,
				}, robuxIcon, React.createElement(Text, robuxPriceTextProps))
			)
		)
	end,
}
