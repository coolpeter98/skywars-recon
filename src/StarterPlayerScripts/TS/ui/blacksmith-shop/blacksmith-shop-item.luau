-- BlacksmithShopItem

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
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ItemViewport = RuntimeLib.import(script, script.Parent.Parent, "viewport", "item-viewport").ItemViewport
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local GameCurrencyItem = RuntimeLib.import(script, script.Parent, "game-currency-item").GameCurrencyItem
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local GameShop = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop")
local ShopItemType = GameShop.ShopItemType
local ShopType = GameShop.ShopType
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CornerRadius = {
	Left: number?,
	Right: number?,
}

type ShopItem = {
	ItemIndex: number,
	ItemType: string,
	CurrencyType: string,
	Price: number,
}

type ShopItemUpgrade = {
	ItemIndex: number,
	Items: { ShopItem },
}

type BlacksmithShopItemProps = {
	CornerRadius: CornerRadius?,
	Upgradeable: boolean,
	ShopItem: ShopItem,
	ShopItemUpgrade: ShopItemUpgrade,
	SetSelectedItem: (selectedItem: { ShopItemType: any, ItemType: any }?) -> (),
	CanPurchaseItem: (item: ShopItem) -> boolean,
}

local getNextUpgradeableItem: ((props: BlacksmithShopItemProps) -> { any })? = nil

local function BlacksmithShopItem(props: BlacksmithShopItemProps)
	local nextUpgradeableItem = getNextUpgradeableItem(props)
	local item = nextUpgradeableItem[1]
	local isLastItem = nextUpgradeableItem[2]

	local cornerRadiusLeft = props.CornerRadius
	if cornerRadiusLeft ~= nil then
		cornerRadiusLeft = cornerRadiusLeft.Left
	end
	local leftCorner = cornerRadiusLeft == nil and true or cornerRadiusLeft

	local cornerRadiusRight = props.CornerRadius
	if cornerRadiusRight ~= nil then
		cornerRadiusRight = cornerRadiusRight.Right
	end
	local rightCorner = cornerRadiusRight == nil and true or cornerRadiusRight

	local createElement = React.createElement
	local grid = Grid
	local gridProps = {
		["key"] = item.ItemType,
		["Size"] = UDim2.fromOffset(140, 176),
	}
	local layoutOrder
	if props.Upgradeable then
		layoutOrder = props.ShopItemUpgrade.ItemIndex
	else
		layoutOrder = props.ShopItem.ItemIndex
	end
	gridProps.LayoutOrder = layoutOrder
	gridProps.Event = {
		["MouseEnter"] = function()
			task.defer(function()
				local setSelectedItem = props.SetSelectedItem
				local selectedItem = {}
				local shopItemType
				if props.Upgradeable then
					shopItemType = ShopItemType.ItemUpgrades
				else
					shopItemType = ShopItemType.Items
				end
				selectedItem.ShopItemType = shopItemType
				selectedItem.ItemType = item.ItemType
				setSelectedItem(selectedItem)
			end)
		end,
		["MouseLeave"] = function()
			return props.SetSelectedItem(nil)
		end,
	}

	local viewportBackground = React.createElement(
		Grid,
		{
			["key"] = "ViewportBackground",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = nil,
			["Size"] = UDim2.fromOffset(140, 126),
			["CornerRadius"] = {
				["TopLeft"] = nil,
				["TopRight"] = nil,
				["BottomLeft"] = 0,
				["BottomRight"] = 0,
				["TopLeft"] = leftCorner and 10 or 0,
				["TopRight"] = rightCorner and 10 or 0,
			},
		},
		React.createElement(ItemViewport, {
			["ItemType"] = nil,
			["ZIndex"] = 2,
			["ItemType"] = item.ItemType,
		})
	)

	local createElement = React.createElement
	local grid = Grid
	local buttonClippingProps = {
		["key"] = "ButtonClipping",
		["Position"] = nil,
		["Size"] = nil,
		["ClipsDescendants"] = true,
		["Position"] = UDim2.fromOffset(0, 126),
		["Size"] = UDim2.fromOffset(140, 50),
	}

	local createElement = React.createElement
	local button = Button
	local buttonProps = {
		["key"] = "Button",
		["Position"] = nil,
		["Size"] = nil,
		["Text"] = nil,
		["Color"] = nil,
		["Disabled"] = nil,
		["TextOffsetY"] = 5,
		["Activated"] = nil,
		["Position"] = UDim2.fromOffset(leftCorner and 0 or -10, -10),
		["Size"] = { ((rightCorner or leftCorner) and (rightCorner and leftCorner and 0 or 10) or 20) + 140, 60 },
		["Text"] = props.Upgradeable and "Upgrade" or "Buy",
	}
	local buttonColor
	if props.Upgradeable then
		buttonColor = Color.Button.Blue
	else
		buttonColor = Color.Button.Green
	end
	buttonProps.Color = buttonColor
	buttonProps.Disabled = isLastItem or not props.CanPurchaseItem(item)
	function buttonProps.Activated()
		if props.Upgradeable then
			Flamework.resolveDependency("ADv"):purchaseItemUpgrade(ShopType.Blacksmith, props.ShopItemUpgrade.ItemIndex)
		else
			Flamework.resolveDependency("ADv"):purchaseItem(ShopType.Blacksmith, props.ShopItem.ItemIndex)
		end
	end

	return createElement(
		grid,
		gridProps,
		viewportBackground,
		createElement(grid, buttonClippingProps, createElement(button, buttonProps)),
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
			["CurrencyType"] = item.CurrencyType,
			["Quantity"] = item.Price,
		})
	)
end

getNextUpgradeableItem = function(props: BlacksmithShopItemProps)
	if not props.Upgradeable then
		return { props.ShopItem, false }
	end
	if not RunService:IsRunning() then
		return { props.ShopItemUpgrade.Items[1], false }
	end
	local nextItem = Flamework.resolveDependency("ADv"):getNextUpgradeableItem(props.ShopItemUpgrade)
	return { nextItem or props.ShopItemUpgrade.Items[#props.ShopItemUpgrade.Items], nextItem == nil }
end

return {
	["BlacksmithShopItem"] = BlacksmithShopItem,
}
