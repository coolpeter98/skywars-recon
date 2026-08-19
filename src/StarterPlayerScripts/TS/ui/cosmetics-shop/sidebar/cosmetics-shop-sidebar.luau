-- CosmeticsShopSidebar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "shop-context").ShopContext
local CosmeticsShopCrateSidebar =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-crate-sidebar").CosmeticsShopCrateSidebar
local CosmeticsShopSeasonPassSidebar =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-season-pass-sidebar").CosmeticsShopSeasonPassSidebar
local CosmeticsShopBundleSidebar =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-bundle-sidebar").CosmeticsShopBundleSidebar
local CosmeticsShopGemsSidebar =
	RuntimeLib.import(script, script.Parent, "cosmetics-shop-gems-sidebar").CosmeticsShopGemsSidebar
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

return {
	["CosmeticsShopSidebar"] = function(props)
		local shopContext = useContext(ShopContext)
		local productType = shopContext.SelectedProductData
		if productType ~= nil then
			productType = productType.ProductType
		end
		local content
		if productType == "SeasonPass" then
			content = React.createElement(CosmeticsShopSeasonPassSidebar, {
				["SeasonData"] = props.SeasonData,
				["OwnsPremium"] = props.OwnsPremium,
			})
		else
			local productType = shopContext.SelectedProductData
			if productType ~= nil then
				productType = productType.ProductType
			end
			if productType == "Bundle" then
				content = React.createElement(CosmeticsShopBundleSidebar)
			else
				local productType = shopContext.SelectedProductData
				if productType ~= nil then
					productType = productType.ProductType
				end
				if productType == "Crate" then
					content = React.createElement(CosmeticsShopCrateSidebar)
				else
					local productType = shopContext.SelectedProductData
					if productType ~= nil then
						productType = productType.ProductType
					end
					if productType == "Gems" then
						content = React.createElement(CosmeticsShopGemsSidebar)
					else
						content = nil
					end
				end
			end
		end
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 20,
			["Ref"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.new(0, 434, 1, 0),
			["Ref"] = props.FrameRef,
		}, content)
	end,
}
