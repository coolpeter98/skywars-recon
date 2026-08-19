-- CosmeticsShopGemsSidebar

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local ShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "shop-context").ShopContext
local PurchaseType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PurchaseType
local CosmeticsShopSidebarButton = RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-button").CosmeticsShopSidebarButton
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local StringUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

return {
	["CosmeticsShopGemsSidebar"] = function(_)
		local shopContext = useContext(ShopContext)
		local selectedProductData = shopContext.SelectedProductData
		local productType: string? = nil
		if selectedProductData ~= nil then
			productType = selectedProductData.ProductType
		end
		if productType ~= "Gems" then
			return React.createElement(React.Fragment)
		end
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(shopContext.SelectedProductData.ProductId)
		return React.createElement(React.Fragment, nil, React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 32,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 30),
			["Text"] = gameProduct.DisplayName
		}), React.createElement(Text, {
			["Position"] = nil,
			["Size"] = nil,
			["AutomaticSize"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["TextWrapped"] = true,
			["Bold"] = true,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(34, 82),
			["Size"] = UDim2.fromOffset(374, 20),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["Text"] = gameProduct.Description,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		}), React.createElement(Text, {
			["Position"] = nil,
			["Size"] = nil,
			["AutomaticSize"] = nil,
			["Text"] = nil,
			["TextSize"] = 48,
			["TextColor3"] = nil,
			["Bold"] = true,
			["Position"] = UDim2.fromOffset(34, 132),
			["Size"] = UDim2.fromOffset(374, 48),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["Text"] = ("%* GEMS"):format((StringUtil.formatNumber(gameProduct.GemsReward))),
			["TextColor3"] = Color.Green
		}, React.createElement(Outline, {
			["Thickness"] = 2
		})), React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 200),
			["Size"] = UDim2.fromOffset(374, 374),
			["Image"] = gameProduct.Image
		}), React.createElement(CosmeticsShopSidebarButton, {
			["Position"] = nil,
			["Text"] = "Buy",
			["Price"] = nil,
			["PurchaseType"] = nil,
			["Disabled"] = false,
			["Activated"] = nil,
			["Position"] = UDim2.new(0, 30, 1, -130),
			["Price"] = gameProduct.PriceInRobux,
			["PurchaseType"] = PurchaseType.Robux,
			["Activated"] = function()
				shopContext.Purchase(gameProduct.ProductId, PurchaseType.Robux)
			end
		}))
	end
}
