-- WizardShopItems

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local GameShop = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop")
local Shops = GameShop.Shops
local ShopType = GameShop.ShopType
local WizardShopItem = RuntimeLib.import(script, script.Parent, "wizard-shop-item").WizardShopItem
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
return {
	["WizardShopItems"] = function(props)
		local merchantShop = Shops[ShopType.Merchant]
		local teamUpgradeList = ObjectUtils.values(merchantShop.TeamUpgrades)
		local itemElements = table.create(#teamUpgradeList)
		for index, teamUpgrade in teamUpgradeList do
			local _ = index - 1
			itemElements[index] = React.createElement(WizardShopItem, {
				["TeamUpgrade"] = teamUpgrade,
				["CanPurchaseItem"] = props.CanPurchaseItem,
				["TeamUpgrades"] = props.TeamUpgrades,
			})
		end
		return React.createElement(
			Grid,
			{
				["key"] = "UpgradeableItemList",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(ScreenUtil.getGridSize(350, 10, 3), ScreenUtil.getGridSize(200, 10, 2)),
			},
			itemElements,
			React.createElement("uigridlayout", {
				["key"] = "GridLayout",
				["FillDirection"] = nil,
				["FillDirectionMaxCells"] = 3,
				["CellPadding"] = nil,
				["CellSize"] = nil,
				["SortOrder"] = nil,
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["CellPadding"] = UDim2.fromOffset(10, 10),
				["CellSize"] = UDim2.fromOffset(350, 200),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			})
		)
	end,
}
