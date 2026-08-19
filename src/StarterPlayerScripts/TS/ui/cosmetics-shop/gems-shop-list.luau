-- GemsShopList

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
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CosmeticsShopItem = RuntimeLib.import(script, script.Parent, "cosmetics-shop-item").CosmeticsShopItem
local ShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "shop-context").ShopContext
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local GEM_TIER_PRODUCT_IDS = {
	ProductId.GEMS_TIER_1,
	ProductId.GEMS_TIER_2,
	ProductId.GEMS_TIER_3,
	ProductId.GEMS_TIER_4,
}
local GEM_TIER_COLORS = {
	Color3.fromRGB(176, 67, 67),
	Color3.fromRGB(188, 55, 55),
	Color3.fromRGB(200, 43, 43),
	Color3.fromRGB(219, 24, 24),
}
return {
	["GemsShopList"] = function(props)
		local shopContext = useContext(ShopContext)
		local items = table.create(#GEM_TIER_PRODUCT_IDS)
		local function createGemsShopItem(productId: number, index: number)
			local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(productId)
			if gameProduct.GemsReward == nil then
				return React.createElement(React.Fragment)
			end
			local textProps = getTextProps({
				["Text"] = nil,
				["TextSize"] = 32,
				["Bold"] = true,
				["Color"] = nil,
				["Text"] = StringUtil.formatNumber(gameProduct.GemsReward),
				["Color"] = Color.Green,
			})
			local textWidth = 40 + textProps.Size.X.Offset
			local tierColor = GEM_TIER_COLORS[index + 1]
			local gemIcon = React.createElement(Image, {
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = 5,
				["Position"] = UDim2.new(0.5, -textWidth / 2, 0, 42),
				["Size"] = UDim2.fromOffset(32, 32),
				["Image"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256,
			})
			local rewardTextProps = {
				["Position"] = nil,
				["ZIndex"] = 5,
				["Position"] = UDim2.new(0.5, -textWidth / 2 + 32 + 8, 0, 42),
			}
			for key, value in textProps do
				rewardTextProps[key] = value
			end
			return React.createElement(
				CosmeticsShopItem,
				{
					["key"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["DisplayName"] = nil,
					["Image"] = nil,
					["ImagePosition"] = nil,
					["PriceInRobux"] = nil,
					["LayoutOrder"] = nil,
					["FooterHeight"] = 40,
					["StrokeThickness"] = 12,
					["ScalingDisabled"] = true,
					["ViewportClipsDescendants"] = false,
					["CornerRadius"] = 20,
					["Activated"] = nil,
					["key"] = gameProduct.ProductId,
					["Size"] = Size.new(280, 280),
					["Color"] = tierColor,
					["DisplayName"] = gameProduct.DisplayName,
					["Image"] = gameProduct.Image,
					["ImagePosition"] = UDim2.new(0.5, 0, 0.5, 40),
					["PriceInRobux"] = gameProduct.PriceInRobux,
					["LayoutOrder"] = index,
					["Activated"] = function()
						shopContext.SetSelectedProductData({
							["ProductType"] = "Gems",
							["ProductId"] = nil,
							["ProductId"] = gameProduct.ProductId,
						})
					end,
				},
				gemIcon,
				React.createElement(
					Text,
					rewardTextProps,
					React.createElement(Outline, {
						["Thickness"] = 2,
						["Color"] = nil,
						["Color"] = Color3.fromRGB(0, 89, 42),
					})
				)
			)
		end
		for index: number, productId: number in GEM_TIER_PRODUCT_IDS do
			items[index] = createGemsShopItem(productId, index - 1, GEM_TIER_PRODUCT_IDS)
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(1150, 280),
				["LayoutOrder"] = props.LayoutOrder,
				["Ref"] = props.FrameRef,
			},
			items,
			React.createElement(List, {
				["Padding"] = UDim.new(0, 20),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			})
		)
	end,
}
