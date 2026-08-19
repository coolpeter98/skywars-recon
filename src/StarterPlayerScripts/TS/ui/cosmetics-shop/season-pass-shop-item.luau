-- SeasonPassShopItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CosmeticsShopItem = RuntimeLib.import(script, script.Parent, "cosmetics-shop-item").CosmeticsShopItem
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "shop-context").ShopContext
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local ProductId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

type SeasonPassShopItemProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	LayoutOrder: number?,
	Color: Color3?,
	SeasonPassTier: number,
	OwnsPremium: boolean,
}

return {
	["SeasonPassShopItem"] = function(props: SeasonPassShopItemProps)
		local shopContext = useContext(ShopContext)
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(ProductId.SEASON_TWO_PASS)
		return React.createElement(Grid, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1180, 280),
			["LayoutOrder"] = props.LayoutOrder
		}, React.createElement(CosmeticsShopItem, {
			["Size"] = nil,
			["Color"] = nil,
			["PriceInRobux"] = nil,
			["PriceInGems"] = nil,
			["LayoutOrder"] = 2,
			["FooterHeight"] = 40,
			["StrokeThickness"] = 12,
			["ScalingDisabled"] = true,
			["ViewportClipsDescendants"] = false,
			["CornerRadius"] = 20,
			["Activated"] = nil,
			["Size"] = Size.new(1180, 280),
			["Color"] = props.Color,
			["PriceInRobux"] = gameProduct.PriceInRobux,
			["PriceInGems"] = gameProduct.PriceInGems,
			["Activated"] = function()
				return shopContext.SetSelectedProductData({
					["ProductType"] = "SeasonPass"
				})
			end
		}, React.createElement(Image, {
			["Size"] = nil,
			["Image"] = nil,
			["ScaleType"] = nil,
			["ZIndex"] = 3,
			["Size"] = UDim2.fromOffset(428, 256),
			["Image"] = RobloxImage.GameProduct.AZAZEL_LARGE,
			["ScaleType"] = Enum.ScaleType.Crop
		}, React.createElement(CornerRadius, {
			["Radius"] = 8
		})), React.createElement(Text, {
			["Position"] = nil,
			["Text"] = "Premium Season Pass \226\128\162\nSeason 2",
			["TextSize"] = 28,
			["Bold"] = true,
			["TextWrapped"] = true,
			["RichText"] = true,
			["Size"] = nil,
			["DropShadow"] = nil,
			["TextXAlignment"] = nil,
			["ZIndex"] = 5,
			["Position"] = UDim2.fromOffset(452, 20),
			["Size"] = UDim2.fromOffset(384, 62),
			["DropShadow"] = Vector2.new(0, 2),
			["TextXAlignment"] = Enum.TextXAlignment.Left
		}), React.createElement(Text, {
			["key"] = "FeatureList",
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["TextWrapped"] = true,
			["RichText"] = true,
			["TextXAlignment"] = nil,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(452, 92),
			["Size"] = UDim2.fromOffset(388, 123),
			["Text"] = SeasonUtil.getFeatureList(props.SeasonPassTier, props.OwnsPremium),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		})), React.createElement(List, {
			["Padding"] = UDim.new(0, 20),
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Left
		}))
	end
}
