-- CrateShopList

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
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local CosmeticsShopItem = RuntimeLib.import(script, script.Parent, "cosmetics-shop-item").CosmeticsShopItem
local ShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "shop-context").ShopContext
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local ProductConstants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"game-product",
	"product-constants"
).ProductConstants
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

export type CrateShopListProps = {
	CrateId: string,
	Color: Color3,
	AnchorPoint: Vector2,
	Position: UDim2,
	LayoutOrder: number,
}

return {
	["CrateShopList"] = function(props: CrateShopListProps)
		local shopContext = useContext(ShopContext)
		local products = Crates[props.CrateId].Products
		local productIds = table.create(#products)
		for index, product in products do
			local _ = index - 1
			productIds[index] = product.ProductId
		end
		local comingSoonItems = {}
		for i = 0, 4 - #productIds - 1 do
			local element = React.createElement(CosmeticsShopItem, {
				["key"] = nil,
				["Size"] = nil,
				["Color"] = nil,
				["DisplayName"] = "COMING SOON",
				["Image"] = nil,
				["HidePrice"] = true,
				["StrokeThickness"] = 12,
				["ScalingDisabled"] = true,
				["CornerRadius"] = 20,
				["LayoutOrder"] = nil,
				["FooterHeight"] = 0,
				["key"] = ("%*"):format(i),
				["Size"] = Size.new(280, 280),
				["Color"] = Color.Grey,
				["Image"] = RobloxImage.QUESTION_MARK_PATTERN,
				["LayoutOrder"] = #productIds + i,
			})
			table.insert(comingSoonItems, element)
		end
		local crateItems = table.create(#productIds)
		local function renderCrateItem(productId: string, _: number)
			local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(productId)
			local crate = Crates[gameProduct.Crate.Id]
			local singleProduct = nil
			for index, product in crate.Products do
				local _ = index - 1
				if product.Quantity == 1 == true then
					singleProduct = product
					break
				end
			end
			if singleProduct ~= nil then
				singleProduct = singleProduct.ProductId
			end
			local price
			if singleProduct then
				price = Flamework.resolveDependency("1EA"):getGameProduct(singleProduct)
			else
				price = nil
			end
			if singleProduct then
				if price ~= nil then
					price = price.PriceInRobux
				end
			else
				price = singleProduct
			end
			if price == nil then
				price = ProductConstants.DEFAULT_CRATE_PRICE_1_ROBUX
			end
			local rawDiscount = (1 - gameProduct.PriceInRobux / (price * gameProduct.Crate.Quantity)) * 100 / 5
			local discountPercent = math.round(rawDiscount) * 5
			local textProps = getTextProps({
				["Text"] = nil,
				["TextSize"] = 20,
				["Bold"] = true,
				["Text"] = ("SAVE %*%%"):format(discountPercent),
			})
			local quantityText = React.createElement(
				Text,
				{
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = nil,
					["TextSize"] = 48,
					["Bold"] = true,
					["TextColor3"] = nil,
					["ZIndex"] = 5,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 42),
					["Text"] = ("x%*"):format(gameProduct.Crate.Quantity),
					["TextColor3"] = Color.Yellow,
				},
				React.createElement(Outline, {
					["Thickness"] = 2,
					["Color"] = nil,
					["Color"] = ColorUtil.scaleValue(Color.Yellow, 0.5),
				})
			)
			local discountBadge
			if discountPercent >= 5 then
				local badgeTextProps = {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["ZIndex"] = 5,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
				}
				for key, value in textProps do
					badgeTextProps[key] = value
				end
				discountBadge = React.createElement(Grid, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["CornerRadius"] = nil,
					["ZIndex"] = 5,
					["AnchorPoint"] = Vector2.new(0.5, 1),
					["Position"] = UDim2.new(0.5, 0, 1, 0),
					["Size"] = UDim2.fromOffset(textProps.Size.X.Offset + 20, 30),
					["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
					["CornerRadius"] = {
						["TopLeft"] = 10,
						["TopRight"] = 10,
					},
				}, React.createElement(Text, badgeTextProps))
			else
				discountBadge = nil
			end
			return React.createElement(CosmeticsShopItem, {
				["key"] = nil,
				["Size"] = nil,
				["Color"] = nil,
				["DisplayName"] = nil,
				["Image"] = nil,
				["ImageAnchorPoint"] = nil,
				["ImageSize"] = nil,
				["ImagePosition"] = nil,
				["PriceInRobux"] = nil,
				["PriceInGems"] = nil,
				["LayoutOrder"] = nil,
				["FooterHeight"] = 40,
				["StrokeThickness"] = 12,
				["ScalingDisabled"] = true,
				["CornerRadius"] = 20,
				["Activated"] = nil,
				["key"] = crate.Id,
				["Size"] = Size.new(280, 280),
				["Color"] = props.Color,
				["DisplayName"] = crate.DisplayName,
				["Image"] = crate.Image,
				["ImageAnchorPoint"] = Vector2.new(0.5, 1),
				["ImageSize"] = UDim2.fromOffset(172, 172),
				["ImagePosition"] = UDim2.fromScale(0.5, 1),
				["PriceInRobux"] = gameProduct.PriceInRobux,
				["PriceInGems"] = gameProduct.PriceInGems,
				["LayoutOrder"] = gameProduct.Crate.Quantity,
				["Activated"] = function()
					shopContext.SetSelectedProductData({
						["ProductType"] = "Crate",
						["CrateId"] = nil,
						["Quantity"] = nil,
						["CrateId"] = crate.Id,
						["Quantity"] = gameProduct.Crate.Quantity,
					})
				end,
			}, quantityText, discountBadge)
		end
		for index, productId in productIds do
			crateItems[index] = renderCrateItem(productId, index - 1, productIds)
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(1150, 280),
				["LayoutOrder"] = props.LayoutOrder,
			},
			crateItems,
			comingSoonItems,
			React.createElement(List, {
				["Padding"] = UDim.new(0, 20),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			})
		)
	end,
}
