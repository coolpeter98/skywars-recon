-- ShopBundle

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
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local GameProducts =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").GameProducts
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CosmeticViewport =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "viewport", "cosmetic-viewport").CosmeticViewport
local BundleUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"bundle-util"
).BundleUtil
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local CosmeticsShopItem =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "cosmetics-shop", "cosmetics-shop-item").CosmeticsShopItem
local ShopSeasonPassBuyButton =
	RuntimeLib.import(script, script.Parent, "shop-season-pass-buy-button").ShopSeasonPassBuyButton

type ShopBundleProps = {
	ProductId: number,
	LayoutOrder: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["ShopBundle"] = function(props: ShopBundleProps)
		local shopContext: { PageSize: Vector2 } = useContext(NewShopContext)
		local bundleProduct
		if RunService:IsRunning() then
			bundleProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		else
			bundleProduct = GameProducts[props.ProductId]
		end
		local bundle = Bundles[bundleProduct.BundleId]
		local armourCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Armour")
		local weaponsCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Weapons")
		local armourCosmetic = Cosmetics[armourCosmeticId]
		local weaponsCosmetic = Cosmetics[weaponsCosmeticId]
		local armourProduct
		if RunService:IsRunning() then
			armourProduct = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.ARMOUR_SINGLE)
		else
			armourProduct = GameProducts[ProductId.ARMOUR_SINGLE]
		end
		local weaponsProduct
		if RunService:IsRunning() then
			weaponsProduct = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.WEAPONS_SINGLE)
		else
			weaponsProduct = GameProducts[ProductId.WEAPONS_SINGLE]
		end
		local contentWidth = shopContext.PageSize.X - ScreenConstants.PADDING_2 - 10
		local columnsWidth = contentWidth - ScreenConstants.PADDING_2 * 3
		local bundleWidth = columnsWidth * 0.46
		local armourX = bundleWidth + ScreenConstants.PADDING_2
		local itemWidth = columnsWidth * 0.27
		local weaponsX = armourX + itemWidth + ScreenConstants.PADDING_2
		return React.createElement(
			Grid,
			{
				["key"] = props.ProductId,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(contentWidth, 400),
				["LayoutOrder"] = props.LayoutOrder,
			},
			React.createElement(
				CosmeticsShopItem,
				{
					["key"] = "Bundle",
					["Size"] = nil,
					["Color"] = nil,
					["DisplayName"] = nil,
					["DisplayNameTextSize"] = 48,
					["Image"] = nil,
					["FooterHeight"] = 0,
					["ScalingDisabled"] = true,
					["ViewportClipsDescendants"] = false,
					["Size"] = Size.new(bundleWidth, 400),
					["Color"] = Color.Shop.BundleGreen,
					["DisplayName"] = bundleProduct.DisplayName,
					["Image"] = bundle.Image,
				},
				React.createElement(ShopSeasonPassBuyButton, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ProductId"] = nil,
					["PrimedCosmeticId"] = nil,
					["TextSize"] = 36,
					["TextPadding"] = 12,
					["CornerRadius"] = 12,
					["ZIndex"] = 10,
					["CornerRadiusTopCorner"] = false,
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.new(0, -12, 1, 12),
					["Size"] = UDim2.fromOffset(bundleWidth, 75),
					["ProductId"] = bundleProduct.ProductId,
					["PrimedCosmeticId"] = weaponsCosmeticId,
				})
			),
			React.createElement(
				CosmeticsShopItem,
				{
					["key"] = "Armour",
					["Position"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["DisplayName"] = nil,
					["DisplayNameTextSize"] = 36,
					["FooterHeight"] = 0,
					["ScalingDisabled"] = true,
					["ViewportClipsDescendants"] = false,
					["Position"] = UDim2.fromOffset(armourX, 0),
					["Size"] = Size.new(itemWidth, 400),
					["Color"] = Color.Shop.BundleGreen,
					["DisplayName"] = armourCosmetic.Name,
				},
				React.createElement(CosmeticViewport, {
					["key"] = "CosmeticViewport",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["CosmeticId"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(
						itemWidth - ScreenConstants.PADDING_2 * 2,
						400 - ScreenConstants.PADDING_2 * 3 - 48
					),
					["CosmeticId"] = armourCosmeticId,
				}),
				React.createElement(ShopSeasonPassBuyButton, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ProductId"] = nil,
					["PrimedCosmeticId"] = nil,
					["TextSize"] = 36,
					["TextPadding"] = 12,
					["CornerRadius"] = 12,
					["CornerRadiusTopCorner"] = false,
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.new(0, -12, 1, 12),
					["Size"] = UDim2.fromOffset(itemWidth, 75),
					["ProductId"] = armourProduct.ProductId,
					["PrimedCosmeticId"] = armourCosmeticId,
				})
			),
			React.createElement(
				CosmeticsShopItem,
				{
					["key"] = "Weapons",
					["Position"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["DisplayName"] = nil,
					["DisplayNameTextSize"] = 36,
					["FooterHeight"] = 0,
					["ScalingDisabled"] = true,
					["ViewportClipsDescendants"] = false,
					["Position"] = UDim2.fromOffset(weaponsX, 0),
					["Size"] = Size.new(itemWidth, 400),
					["Color"] = Color.Shop.BundleGreen,
					["DisplayName"] = weaponsCosmetic.Name,
				},
				React.createElement(CosmeticViewport, {
					["key"] = "CosmeticViewport",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["CosmeticId"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(
						itemWidth - ScreenConstants.PADDING_2 * 2,
						400 - ScreenConstants.PADDING_2 * 3 - 48
					),
					["CosmeticId"] = weaponsCosmeticId,
				}),
				React.createElement(ShopSeasonPassBuyButton, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ProductId"] = nil,
					["PrimedCosmeticId"] = nil,
					["TextSize"] = 36,
					["TextPadding"] = 12,
					["CornerRadius"] = 12,
					["CornerRadiusTopCorner"] = false,
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.new(0, -12, 1, 12),
					["Size"] = UDim2.fromOffset(itemWidth, 75),
					["ProductId"] = weaponsProduct.ProductId,
					["PrimedCosmeticId"] = weaponsCosmeticId,
				})
			)
		)
	end,
}
