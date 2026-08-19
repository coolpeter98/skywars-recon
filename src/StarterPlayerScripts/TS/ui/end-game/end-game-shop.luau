-- EndGameShop

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local EndGameWindow = RuntimeLib.import(script, script.Parent, "end-game-window").EndGameWindow
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local CosmeticsShopItem = RuntimeLib.import(script, script.Parent.Parent, "cosmetics-shop", "cosmetics-shop-item").CosmeticsShopItem
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local ProductId = GameProduct.ProductId
local PurchaseType = GameProduct.PurchaseType
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local BundleUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundle-util").BundleUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useMemo = React.useMemo
local useState = React.useState
local FEATURED_BUNDLE_IDS = {
	ProductId.PLASMA_TITAN_BUNDLE,
	ProductId.SPACEMAN,
	ProductId.DWARVEN,
	ProductId.CRUSADER
}
return {
	["EndGameShop"] = function(props)
		local lastClickTime = useState(os.clock())
		local ownedProductTypes = useMemo(function()
			local ownedProducts = props.OwnedProducts
			local productTypes = table.create(#ownedProducts)
			for index, ownedProduct in ownedProducts do
				local _ = index - 1
				productTypes[index] = ownedProduct.Type
			end
			return productTypes
		end, props.OwnedProducts)
		local selectedProductId = nil
		for index, productId in FEATURED_BUNDLE_IDS do
			local _ = index - 1
			if table.find(ownedProductTypes, productId) == nil == true then
				selectedProductId = productId
				break
			end
		end
		if selectedProductId == nil then
			selectedProductId = ProductId.SPACEMAN
		end
		local bundleGameProduct = Flamework.resolveDependency("1EA"):getGameProduct(selectedProductId)
		local armourCosmeticId = BundleUtil.getPackageCosmeticId(bundleGameProduct.BundleId, "Armour")
		local ninjaCrate = Crates.NinjaCrate
		local crateProduct = nil
		for index, product in ninjaCrate.Products do
			local _ = index - 1
			if product.Quantity == 1 == true then
				crateProduct = product
				break
			end
		end
		local crateProductId = crateProduct.ProductId
		local crateGameProduct = Flamework.resolveDependency("1EA"):getGameProduct(crateProductId)
		local function promptPurchase(productId)
			if TimeUtil.elapsed(lastClickTime, 0.5) then
				Flamework.resolveDependency("YOK"):promptPurchase(productId, PurchaseType.Robux)
			end
		end
		return React.createElement(EndGameWindow, {
			["key"] = "EndGameShop",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleText"] = "SHOP",
			["TitleImage"] = nil,
			["Visible"] = nil,
			["FrameRef"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(542, 520),
			["TitleImage"] = RobloxImage.Icon.SHOPPING_CART,
			["Visible"] = props.Visible,
			["FrameRef"] = props.FrameRef
		}, React.createElement(CosmeticsShopItem, {
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["DisplayName"] = nil,
			["CosmeticId"] = nil,
			["PriceInRobux"] = nil,
			["FooterHeight"] = 40,
			["ScalingDisabled"] = true,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(20, 42),
			["Size"] = Size.new(268, 458),
			["Color"] = Color3.fromRGB(241, 197, 18),
			["DisplayName"] = bundleGameProduct.DisplayName,
			["CosmeticId"] = armourCosmeticId,
			["PriceInRobux"] = bundleGameProduct.PriceInRobux,
			["Activated"] = function()
				return promptPurchase(selectedProductId)
			end
		}), React.createElement(CosmeticsShopItem, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["DisplayName"] = nil,
			["Image"] = nil,
			["ImagePosition"] = nil,
			["ImageSize"] = nil,
			["PriceInRobux"] = nil,
			["FooterHeight"] = 40,
			["StrokeThickness"] = 12,
			["ScalingDisabled"] = true,
			["CornerRadius"] = 20,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, -20, 0, 42),
			["Size"] = Size.new(224, 398),
			["Color"] = Color.Blue,
			["DisplayName"] = ninjaCrate.DisplayName,
			["Image"] = ninjaCrate.Image,
			["ImagePosition"] = UDim2.new(0.5, 0, 0.5, 20),
			["ImageSize"] = UDim2.fromOffset(166, 178),
			["PriceInRobux"] = crateGameProduct.PriceInRobux,
			["Activated"] = function()
				return promptPurchase(crateGameProduct.ProductId)
			end
		}), React.createElement(Button, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Text"] = "Open Shop",
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 1),
			["Position"] = UDim2.new(1, -20, 1, -20),
			["Size"] = { 224, 50 },
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				return Flamework.resolveDependency("vbD"):openShop()
			end
		}))
	end
}
