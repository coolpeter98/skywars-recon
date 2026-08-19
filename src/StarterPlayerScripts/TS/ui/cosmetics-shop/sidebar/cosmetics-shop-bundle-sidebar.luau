-- CosmeticsShopBundleSidebar

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
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local ShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "shop-context").ShopContext
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local PurchaseType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PurchaseType
local CosmeticsShopSidebarButton =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-button").CosmeticsShopSidebarButton
local CosmeticsShopSidebarList =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-list").CosmeticsShopSidebarList
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local BundleUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"bundle-util"
).BundleUtil
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

return {
	["CosmeticsShopBundleSidebar"] = function(_)
		local shopContext = useContext(ShopContext)
		local selectedProductData = shopContext.SelectedProductData
		local productType: string?
		if selectedProductData ~= nil then
			productType = selectedProductData.ProductType
		end
		if productType ~= "Bundle" then
			return React.createElement(React.Fragment)
		end

		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(shopContext.SelectedProductData.ProductId)
		local primedCosmeticType = shopContext.SelectedProductData.PrimedCosmeticType
		local bundle = Bundles[gameProduct.BundleId]

		local product
		if primedCosmeticType then
			product = Flamework.resolveDependency("1EA"):getPrimedCosmeticProduct(primedCosmeticType)
		else
			product = gameProduct
		end

		local primedCosmeticId: string?
		if primedCosmeticType then
			primedCosmeticId = BundleUtil.getBundlePrimedCosmeticId(bundle.BundleId, primedCosmeticType)
		else
			primedCosmeticId = nil
		end

		local primedCosmetic
		if primedCosmeticId then
			primedCosmetic = Cosmetics[primedCosmeticId]
		else
			primedCosmetic = nil
		end

		local title: string?
		if primedCosmetic == nil then
			title = primedCosmetic
		else
			title = primedCosmetic.Name
		end
		if title == nil then
			title = gameProduct.DisplayName
		end

		local offset: number = (product.PriceInGems == nil and 130 or 240) + 20

		local isMobile: boolean = ScreenUtil.isMobile()
		if isMobile then
			isMobile = not ScreenUtil.isTablet()
		end

		local cosmeticType: string?
		if primedCosmetic == nil then
			cosmeticType = primedCosmetic
		else
			cosmeticType = primedCosmetic.Type
		end

		local cosmetics
		if cosmeticType == "Package" then
			cosmetics = primedCosmetic.Cosmetics
		else
			cosmetics = BundleUtil.getBundleCosmetics(bundle, nil)
		end

		local function promptPurchase(purchaseType)
			if primedCosmeticType and primedCosmeticId then
				return Flamework.resolveDependency("YOK")
					:promptPrimedCosmeticPurchase(primedCosmeticId, primedCosmeticType, purchaseType)
			else
				return Flamework.resolveDependency("YOK"):promptPurchase(gameProduct.ProductId, purchaseType)
			end
		end

		local titleElement = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 32,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 20),
			["Text"] = title,
		})

		local descriptionProps = {
			["Position"] = UDim2.fromOffset(34, 72),
			["Size"] = UDim2.fromOffset(374, 60),
			["AutomaticSize"] = Enum.AutomaticSize.None,
		}
		local description: string? = bundle.Description
		descriptionProps.Text = description == nil and "" or description
		descriptionProps.TextSize = 20
		descriptionProps.TextWrapped = true
		descriptionProps.Bold = true
		descriptionProps.TextYAlignment = Enum.TextYAlignment.Top

		local descriptionElement = React.createElement(Text, descriptionProps)

		local imageElement
		if isMobile then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 152),
				["Size"] = UDim2.fromOffset(374, 210),
				["Image"] = bundle.Image,
			})
		end

		local listProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, isMobile and 152 or 382),
			["Size"] = UDim2.new(0, 374, 1, -((isMobile and 152 or 382) + offset)),
		}
		local cosmeticData = table.create(#cosmetics)
		for index: number, cosmeticId: string in cosmetics do
			cosmeticData[index] = {
				["CosmeticId"] = cosmeticId,
				["LayoutOrder"] = index - 1,
			}
		end
		listProps.Cosmetics = cosmeticData

		local createElement = React.createElement
		local fragment = React.Fragment
		local fragmentProps = nil
		local listElement = React.createElement(CosmeticsShopSidebarList, listProps)

		local gemsButton
		if product.PriceInGems == nil then
			gemsButton = nil
		else
			local createElement = React.createElement
			local sidebarButton = CosmeticsShopSidebarButton
			local buttonProps = {
				["Position"] = nil,
				["Text"] = "Buy",
				["Price"] = nil,
				["PurchaseType"] = nil,
				["Disabled"] = nil,
				["Activated"] = nil,
				["Position"] = UDim2.new(0, 30, 1, -240),
				["Price"] = product.PriceInGems,
				["PurchaseType"] = PurchaseType.Gems,
			}
			local purchaseType = PurchaseType.Gems
			local canPurchase: boolean
			if primedCosmeticType and primedCosmeticId then
				canPurchase = Flamework.resolveDependency("YOK")
					:canPurchasePrimedCosmetic(primedCosmeticId, primedCosmeticType, purchaseType)
			else
				canPurchase = Flamework.resolveDependency("YOK"):canPurchase(gameProduct.ProductId, purchaseType)
			end
			buttonProps.Disabled = not canPurchase
			function buttonProps.Activated()
				return promptPurchase(PurchaseType.Gems)
			end
			gemsButton = createElement(sidebarButton, buttonProps)
		end

		local createElement = React.createElement
		local sidebarButton = CosmeticsShopSidebarButton
		local buttonProps = {
			["Position"] = nil,
			["Text"] = "Buy",
			["Price"] = nil,
			["PurchaseType"] = nil,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.new(0, 30, 1, -130),
			["Price"] = product.PriceInRobux,
			["PurchaseType"] = PurchaseType.Robux,
		}
		local purchaseType = PurchaseType.Robux
		local canPurchase: boolean
		if primedCosmeticType and primedCosmeticId then
			canPurchase = Flamework.resolveDependency("YOK")
				:canPurchasePrimedCosmetic(primedCosmeticId, primedCosmeticType, purchaseType)
		else
			canPurchase = Flamework.resolveDependency("YOK"):canPurchase(gameProduct.ProductId, purchaseType)
		end
		buttonProps.Disabled = not canPurchase
		function buttonProps.Activated()
			return promptPurchase(PurchaseType.Robux)
		end

		return createElement(
			fragment,
			fragmentProps,
			titleElement,
			descriptionElement,
			imageElement,
			listElement,
			gemsButton,
			createElement(sidebarButton, buttonProps)
		)
	end,
}
