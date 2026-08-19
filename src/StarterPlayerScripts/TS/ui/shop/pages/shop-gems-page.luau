-- ShopGemsPage

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local NewShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ShopGems = RuntimeLib.import(script, script.Parent.Parent, "components", "shop-gems").ShopGems
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProduct.GameProducts
local ProductId = GameProduct.ProductId
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size

local GEM_PRODUCT_IDS = {
	ProductId.GEMS_TIER_1,
	ProductId.GEMS_TIER_2,
	ProductId.GEMS_TIER_3,
	ProductId.GEMS_TIER_4,
	ProductId.GEMS_TIER_5,
	ProductId.GEMS_TIER_6
}

local GEM_COLORS = {
	Color3.fromRGB(176, 67, 67),
	Color3.fromRGB(188, 55, 55),
	Color3.fromRGB(200, 43, 43),
	Color3.fromRGB(219, 24, 24),
	Color3.fromRGB(238, 22, 22),
	Color3.fromRGB(255, 20, 20)
}

return {
	["ShopGemsPage"] = function(props)
		local shopContext = useContext(NewShopContext)
		local pageWidth = shopContext.PageSize.X
		local pageHeight = shopContext.PageSize.Y
		local columnCount = #GEM_PRODUCT_IDS / 2
		local maxColumns = math.max(columnCount)
		local cellWidth = (pageWidth - ScreenConstants.PADDING_2 * (maxColumns - 1)) / maxColumns
		local cellHeight = (pageHeight - ScreenConstants.PADDING_2) / 2
		local children = table.create(#GEM_PRODUCT_IDS)

		local function renderGemSlot(productId, index)
			local gameProduct
			if RunService:IsRunning() then
				gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(productId)
			else
				gameProduct = GameProducts[productId]
			end
			if gameProduct.GemsReward == nil then
				return React.createElement(React.Fragment)
			end
			local color = GEM_COLORS[index + 1]
			return React.createElement(ShopGems, {
				["Size"] = Size.new(cellWidth, cellHeight),
				["GameProduct"] = gameProduct,
				["Color"] = color
			})
		end

		for index, productId in GEM_PRODUCT_IDS do
			children[index] = renderGemSlot(productId, index - 1, GEM_PRODUCT_IDS)
		end

		return React.createElement(Grid, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(shopContext.PageSize.X, shopContext.PageSize.Y)
		}, children, React.createElement("uigridlayout", {
			["CellSize"] = UDim2.fromOffset(cellWidth, cellHeight),
			["CellPadding"] = UDim2.fromOffset(ScreenConstants.PADDING_2, ScreenConstants.PADDING_2),
			["FillDirection"] = Enum.FillDirection.Horizontal,
			["FillDirectionMaxCells"] = maxColumns,
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		}))
	end
}
