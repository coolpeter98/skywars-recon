-- BlacksmithItems

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local BlacksmithShopItem = RuntimeLib.import(script, script.Parent, "blacksmith-shop-item").BlacksmithShopItem
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local GameShop = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop")
local Shops = GameShop.Shops
local ShopType = GameShop.ShopType
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type BlacksmithItemsProps = {
	AnchorPoint: Vector2?,
	CanPurchaseItem: ((shopItem: any) -> boolean)?,
	Position: UDim2?,
	SetSelectedItem: ((shopItem: any) -> ())?,
}

return {
	["BlacksmithItems"] = function(props: BlacksmithItemsProps)
		local shop = Shops[ShopType.Blacksmith]
		local items = ObjectUtils.values(shop.Items)
		local itemElements = table.create(#items)
		for index, item in items do
			local _ = index - 1
			itemElements[index] = React.createElement(BlacksmithShopItem, {
				["ShopItem"] = nil,
				["Upgradeable"] = false,
				["CanPurchaseItem"] = nil,
				["SetSelectedItem"] = nil,
				["ShopItem"] = item,
				["CanPurchaseItem"] = props.CanPurchaseItem,
				["SetSelectedItem"] = props.SetSelectedItem,
			})
		end
		return React.createElement(
			Window,
			{
				["key"] = "BlacksmithItems",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleImage"] = nil,
				["TitleText"] = "ITEMS",
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(800, 640),
				["TitleImage"] = RobloxImage.Icon.ARROW,
			},
			React.createElement(
				Grid,
				{
					["key"] = "ItemList",
					["Position"] = nil,
					["Size"] = nil,
					["Position"] = UDim2.fromOffset(30, 62),
					["Size"] = UDim2.fromOffset(740, 548),
				},
				itemElements,
				React.createElement("uigridlayout", {
					["key"] = "GridLayout",
					["FillDirection"] = nil,
					["FillDirectionMaxCells"] = 5,
					["CellPadding"] = nil,
					["CellSize"] = nil,
					["SortOrder"] = nil,
					["FillDirection"] = Enum.FillDirection.Horizontal,
					["CellPadding"] = UDim2.fromOffset(10, 10),
					["CellSize"] = UDim2.fromOffset(140, 176),
					["SortOrder"] = Enum.SortOrder.LayoutOrder,
				})
			)
		)
	end,
}
