-- ShopBundlesPage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useMemo = React.useMemo
local useProfile = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useProfile
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local ShopBundle = RuntimeLib.import(script, script.Parent.Parent, "components", "shop-bundle").ShopBundle
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List

local BUNDLE_PRODUCT_IDS = {
	ProductId.PLASMA_TITAN_BUNDLE,
	ProductId.SPACEMAN,
	ProductId.DWARVEN,
	ProductId.CRUSADER,
}

return {
	["ShopBundlesPage"] = function(_)
		useContext(NewShopContext)
		local profile = useProfile()
		local bundles = useMemo(function()
			local function isUnowned(productId)
				local ownedProduct = nil
				for index, product in profile.OwnedProducts do
					local _ = index - 1
					if product.Type == productId == true then
						ownedProduct = product
						break
					end
				end
				return not ownedProduct
			end

			local count = 0
			local unownedBundles = {}
			for index, bundleId in BUNDLE_PRODUCT_IDS do
				if isUnowned(bundleId, index - 1, BUNDLE_PRODUCT_IDS) == true then
					count = count + 1
					unownedBundles[count] = bundleId
				end
			end
			if #unownedBundles == 0 then
				return BUNDLE_PRODUCT_IDS
			else
				return unownedBundles
			end
		end, { profile.OwnedProducts })

		local bundleElements = table.create(#bundles)
		for index, bundleId in bundles do
			local bundleProps = {
				["key"] = bundleId,
				["ProductId"] = bundleId,
				["LayoutOrder"] = index - 1,
			}
			bundleElements[index] = React.createElement(ShopBundle, bundleProps)
		end
		return React.createElement(
			"scrollingframe",
			{
				["key"] = "Bundles",
				["Size"] = nil,
				["CanvasSize"] = nil,
				["ScrollBarImageTransparency"] = 0,
				["ScrollingDirection"] = nil,
				["ScrollBarThickness"] = 10,
				["ScrollBarImageColor3"] = nil,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Selectable"] = false,
				["Size"] = UDim2.fromScale(1, 1),
				["CanvasSize"] = UDim2.fromOffset(0, ScreenUtil.getGridSize(400, ScreenConstants.PADDING_2, #bundles)),
				["ScrollingDirection"] = Enum.ScrollingDirection.Y,
				["ScrollBarImageColor3"] = Color.White,
			},
			bundleElements,
			React.createElement(List, {
				["Vertical"] = true,
				["Padding"] = nil,
				["HorizontalAlignment"] = nil,
				["VerticalAlignment"] = nil,
				["Padding"] = UDim.new(0, ScreenConstants.PADDING_2),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			})
		)
	end,
}
