-- RadialPromptItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local ItemViewport = RuntimeLib.import(script, script.Parent.Parent.Parent, "viewport", "item-viewport").ItemViewport
local GameCurrencyItem =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "blacksmith-shop", "game-currency-item").GameCurrencyItem
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type RadialPromptItemProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	ShopItem: {
		ItemType: string,
		CurrencyType: string,
		Price: number,
	},
	CanPurchaseItem: (shopItem: { ItemType: string, CurrencyType: string, Price: number }) -> boolean,
}

return {
	["RadialPromptItem"] = function(props: RadialPromptItemProps)
		return React.createElement(
			Grid,
			{
				["key"] = "RadialPromptItem",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(100, 100),
			},
			React.createElement(ItemViewport, {
				["ItemType"] = nil,
				["ZIndex"] = 2,
				["Greyscale"] = nil,
				["ItemType"] = props.ShopItem.ItemType,
				["Greyscale"] = not props.CanPurchaseItem(props.ShopItem),
			}),
			React.createElement(GameCurrencyItem, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TextSize"] = 18,
				["CurrencyType"] = nil,
				["Quantity"] = nil,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.new(1, -10, 0, 10),
				["Size"] = UDim2.fromOffset(40, 40),
				["CurrencyType"] = props.ShopItem.CurrencyType,
				["Quantity"] = props.ShopItem.Price,
			})
		)
	end,
}
