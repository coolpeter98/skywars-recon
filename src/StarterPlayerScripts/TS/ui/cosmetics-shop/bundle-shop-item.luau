-- BundleShopItem

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
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local CosmeticsShopItem = RuntimeLib.import(script, script.Parent, "cosmetics-shop-item").CosmeticsShopItem
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local PrimedCosmeticType = GameProduct.PrimedCosmeticType
local ProductId = GameProduct.ProductId
local ShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "shop-context").ShopContext
local BundleUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"bundle-util"
).BundleUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

type BundleShopItemProps = {
	ProductId: string,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Color: Color3?,
	LayoutOrder: number?,
}

return {
	["BundleShopItem"] = function(props: BundleShopItemProps)
		local shopContext = useContext(ShopContext)
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		if not gameProduct.BundleId then
			return React.createElement(React.Fragment)
		end
		local bundle = Bundles[gameProduct.BundleId]
		local armourCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Armour")
		local weaponsCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Weapons")
		local armourGameProduct = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.ARMOUR_SINGLE)
		local weaponsGameProduct = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.WEAPONS_SINGLE)
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["LayoutOrder"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 20,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1180, 280),
			["LayoutOrder"] = props.LayoutOrder,
		}
		local createElement = React.createElement
		local shopItem = CosmeticsShopItem
		local itemProps = {
			["Size"] = nil,
			["Color"] = nil,
			["DisplayName"] = nil,
			["Image"] = nil,
			["ImagePosition"] = nil,
			["ImageSize"] = nil,
			["PriceInRobux"] = nil,
			["PriceInGems"] = nil,
			["LayoutOrder"] = 1,
			["FooterHeight"] = 40,
			["StrokeThickness"] = 12,
			["ScalingDisabled"] = true,
			["ViewportIncludeFooter"] = true,
			["CornerRadius"] = 20,
			["Activated"] = nil,
			["Size"] = Size.new(580, 280),
			["Color"] = props.Color,
			["DisplayName"] = gameProduct.DisplayName,
			["Image"] = bundle.Image,
		}
		local imagePosition: UDim2
		if bundle.BundleId == "Dwarven" then
			imagePosition = UDim2.new(0.5, 0, 0.5, 20)
		else
			imagePosition = UDim2.fromScale(0.5, 0.5)
		end
		itemProps.ImagePosition = imagePosition
		itemProps.ImageSize = UDim2.fromOffset(556, 312.75)
		itemProps.PriceInRobux = gameProduct.PriceInRobux
		itemProps.PriceInGems = gameProduct.PriceInGems
		function itemProps.Activated()
			return shopContext.SetSelectedProductData({
				["ProductType"] = "Bundle",
				["ProductId"] = nil,
				["PrimedCosmeticType"] = nil,
				["ProductId"] = props.ProductId,
			})
		end
		return createElement(
			grid,
			gridProps,
			createElement(shopItem, itemProps),
			React.createElement(CosmeticsShopItem, {
				["Size"] = nil,
				["Color"] = nil,
				["DisplayName"] = nil,
				["CosmeticId"] = nil,
				["PriceInRobux"] = nil,
				["PriceInGems"] = nil,
				["LayoutOrder"] = 2,
				["FooterHeight"] = 40,
				["StrokeThickness"] = 12,
				["ScalingDisabled"] = true,
				["CornerRadius"] = 20,
				["Activated"] = nil,
				["Size"] = Size.new(280, 280),
				["Color"] = props.Color,
				["DisplayName"] = ("%* Armour"):format(bundle.BundleId),
				["CosmeticId"] = armourCosmeticId,
				["PriceInRobux"] = armourGameProduct.PriceInRobux,
				["PriceInGems"] = armourGameProduct.PriceInGems,
				["Activated"] = function()
					return shopContext.SetSelectedProductData({
						["ProductType"] = "Bundle",
						["ProductId"] = nil,
						["PrimedCosmeticType"] = nil,
						["ProductId"] = props.ProductId,
						["PrimedCosmeticType"] = PrimedCosmeticType.Armour,
					})
				end,
			}),
			React.createElement(CosmeticsShopItem, {
				["Size"] = nil,
				["Color"] = nil,
				["DisplayName"] = nil,
				["CosmeticId"] = nil,
				["PriceInRobux"] = nil,
				["PriceInGems"] = nil,
				["LayoutOrder"] = 3,
				["FooterHeight"] = 40,
				["StrokeThickness"] = 12,
				["ScalingDisabled"] = true,
				["CornerRadius"] = 20,
				["Activated"] = nil,
				["Size"] = Size.new(280, 280),
				["Color"] = props.Color,
				["DisplayName"] = ("%* Weapons"):format(bundle.BundleId),
				["CosmeticId"] = weaponsCosmeticId,
				["PriceInRobux"] = weaponsGameProduct.PriceInRobux,
				["PriceInGems"] = weaponsGameProduct.PriceInGems,
				["Activated"] = function()
					return shopContext.SetSelectedProductData({
						["ProductType"] = "Bundle",
						["ProductId"] = nil,
						["PrimedCosmeticType"] = nil,
						["ProductId"] = props.ProductId,
						["PrimedCosmeticType"] = PrimedCosmeticType.Weapons,
					})
				end,
			}),
			React.createElement(List, {
				["Padding"] = UDim.new(0, 20),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			})
		)
	end,
}
