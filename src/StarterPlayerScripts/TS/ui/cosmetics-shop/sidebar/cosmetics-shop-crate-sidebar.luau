-- CosmeticsShopCrateSidebar

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
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local ShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "shop-context").ShopContext
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local PurchaseType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PurchaseType
local CosmeticsShopSidebarButton =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-button").CosmeticsShopSidebarButton
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local CosmeticsShopSidebarList =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-list").CosmeticsShopSidebarList
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
return {
	["CosmeticsShopCrateSidebar"] = function(_)
		local shopContext = useContext(ShopContext)
		local productType = shopContext.SelectedProductData
		if productType ~= nil then
			productType = productType.ProductType
		end
		if productType ~= "Crate" then
			return React.createElement(React.Fragment)
		end
		local crateId = shopContext.SelectedProductData.CrateId
		local quantity = shopContext.SelectedProductData.Quantity
		local crate = Crates[crateId]
		local selectedProduct = nil
		for index, product in crate.Products do
			local _ = index - 1
			if product.Quantity == quantity == true then
				selectedProduct = product
				break
			end
		end
		local productId = selectedProduct.ProductId
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(productId)
		local rewards = crate.Rewards
		local probabilities: { number } = table.create(#rewards)
		for index, reward in rewards do
			local _ = index - 1
			probabilities[index] = reward.Probability
		end
		local totalProbability: number = ArrayUtil.sum(probabilities)
		local isMobile: boolean = ScreenUtil.isMobile()
		if isMobile then
			isMobile = not ScreenUtil.isTablet()
		end
		local titleElement = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 32,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 30),
			["Text"] = gameProduct.DisplayName,
		})
		local imageElement
		if isMobile then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 75),
				["Size"] = UDim2.fromOffset(200, 200),
				["Image"] = crate.Image,
			})
		end
		local listProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, isMobile and 75 or 295),
			["Size"] = UDim2.new(0, 374, 1, -((isMobile and 75 or 295) + 240 + 20)),
		}
		local rewards = crate.Rewards
		local cosmetics = table.create(#rewards)
		for index, reward in rewards do
			local _ = index - 1
			local probabilityPercent: number = reward.Probability / totalProbability * 100
			cosmetics[index] = {
				["CosmeticId"] = reward.CosmeticId,
				["SubText"] = ("%*%%"):format((string.format("%.1f", probabilityPercent))),
			}
		end
		listProps.Cosmetics = cosmetics
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
		local listElement = React.createElement(CosmeticsShopSidebarList, listProps)
		local gemsButtonElement
		if gameProduct.PriceInGems == nil then
			gemsButtonElement = nil
		else
			gemsButtonElement = React.createElement(CosmeticsShopSidebarButton, {
				["Position"] = nil,
				["Text"] = "Open",
				["Price"] = nil,
				["PurchaseType"] = nil,
				["Disabled"] = nil,
				["Activated"] = nil,
				["Position"] = UDim2.new(0, 30, 1, -240),
				["Price"] = gameProduct.PriceInGems,
				["PurchaseType"] = PurchaseType.Gems,
				["Disabled"] = not Flamework.resolveDependency("YOK")
					:canPurchase(gameProduct.ProductId, PurchaseType.Gems),
				["Activated"] = function()
					return shopContext.Purchase(gameProduct.ProductId, PurchaseType.Gems)
				end,
			})
		end
		return createElement(
			Fragment,
			fragmentProps,
			titleElement,
			imageElement,
			listElement,
			gemsButtonElement,
			React.createElement(CosmeticsShopSidebarButton, {
				["Position"] = nil,
				["Text"] = "Open",
				["Price"] = nil,
				["PurchaseType"] = nil,
				["Disabled"] = nil,
				["Activated"] = nil,
				["Position"] = UDim2.new(0, 30, 1, -130),
				["Price"] = gameProduct.PriceInRobux,
				["PurchaseType"] = PurchaseType.Robux,
				["Disabled"] = not Flamework.resolveDependency("YOK")
					:canPurchase(gameProduct.ProductId, PurchaseType.Robux),
				["Activated"] = function()
					return shopContext.Purchase(gameProduct.ProductId, PurchaseType.Robux)
				end,
			})
		)
	end,
}
