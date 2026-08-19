-- BlacksmithUpgrades

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
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Currencies =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-currency").Currencies
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local GameShop = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop")
local ShopItemType = GameShop.ShopItemType
local Shops = GameShop.Shops
local ShopType = GameShop.ShopType
local BlacksmithShopItem = RuntimeLib.import(script, script.Parent, "blacksmith-shop-item").BlacksmithShopItem
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local GameCurrencyItem = RuntimeLib.import(script, script.Parent, "game-currency-item").GameCurrencyItem
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local CharacterViewport =
	RuntimeLib.import(script, script.Parent.Parent, "viewport", "character-viewport").CharacterViewport
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local ItemViewport = RuntimeLib.import(script, script.Parent.Parent, "viewport", "item-viewport").ItemViewport
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type Props = {
	SelectedItem: any?,
	PlayerCurrencyData: {
		Quantities: { [string]: number },
	},
	CanPurchaseItem: (...any) -> ...any,
	SetSelectedItem: (...any) -> ...any,
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["BlacksmithUpgrades"] = function(props: Props)
		local players = usePlayers()
		local blacksmithShop = Shops[ShopType.Blacksmith]
		local teamColor
		if RunService:IsRunning() then
			teamColor = Flamework.resolveDependency("x5"):getPlayerTeam()
		else
			teamColor = nil
		end
		if props.SelectedItem then
			local _ = props.SelectedItem.ShopItemType == ShopItemType.Items
		end
		local currencies = ObjectUtils.values(Currencies)
		local currencyElements = table.create(#currencies)
		local function createCurrencyItem(currency)
			local quantity = props.PlayerCurrencyData.Quantities[currency.Type]
			return React.createElement(GameCurrencyItem, {
				["Size"] = nil,
				["TextSize"] = 18,
				["CurrencyType"] = nil,
				["Quantity"] = nil,
				["ZIndex"] = 5,
				["LayoutOrder"] = nil,
				["Size"] = UDim2.fromOffset(40, 40),
				["CurrencyType"] = currency.Type,
				["Quantity"] = quantity,
				["LayoutOrder"] = currency.Tier,
			})
		end
		for index, currency in currencies do
			currencyElements[index] = createCurrencyItem(currency, index - 1, currencies)
		end
		local currencyRow = React.createElement(
			Grid,
			{
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["Position"] = UDim2.fromOffset(0, 62),
				["Size"] = UDim2.fromOffset(420, 52),
			},
			currencyElements,
			React.createElement(List, {
				["Padding"] = UDim.new(0, 65),
			})
		)
		local characterViewport
		if RunService:IsRunning() then
			characterViewport = React.createElement(CharacterViewport, {
				["FieldOfView"] = 30,
				["Visible"] = true,
			})
		else
			characterViewport = nil
		end
		local itemViewport
		if RunService:IsRunning() then
			local itemViewportProps = {}
			local itemType = props.SelectedItem
			if itemType ~= nil then
				itemType = itemType.ItemType
			end
			itemViewportProps.ItemType = itemType
			itemViewportProps.Visible = false
			itemViewport = React.createElement(ItemViewport, itemViewportProps)
		else
			itemViewport = nil
		end
		local playerNameText = React.createElement(Text, {
			["key"] = "PlayerName",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 36,
			["Bold"] = true,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 290),
			["Text"] = players.LocalPlayer.DisplayName,
		})
		local cosmeticGradientProps = {
			["key"] = "CosmeticGradient",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.fromScale(0, 1),
			["Size"] = UDim2.fromScale(1, 0.3),
		}
		if teamColor ~= nil then
			teamColor = teamColor.Color
		end
		if teamColor == nil then
			teamColor = Color.White
		end
		cosmeticGradientProps.BackgroundColor3 = teamColor
		cosmeticGradientProps.BackgroundTransparency = 0
		local viewportGrid = React.createElement(
			Grid,
			{
				["key"] = "Viewport",
				["Position"] = nil,
				["Size"] = nil,
				["Position"] = UDim2.fromOffset(0, 114),
				["Size"] = UDim2.fromOffset(420, 350),
			},
			characterViewport,
			itemViewport,
			playerNameText,
			React.createElement(
				Grid,
				cosmeticGradientProps,
				React.createElement("uigradient", {
					["Rotation"] = 270,
					["Transparency"] = nil,
					["Transparency"] = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0, 0),
						NumberSequenceKeypoint.new(1, 1, 0),
					}),
				})
			),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local upgrades = ObjectUtils.values(blacksmithShop.ItemUpgrades)
		local upgradeElements = table.create(#upgrades)
		local function createUpgradeItem(upgrade, index)
			local createElement = React.createElement
			local blacksmithShopItem = BlacksmithShopItem
			local upgradeItemProps = {
				["ShopItemUpgrade"] = nil,
				["Upgradeable"] = true,
				["CanPurchaseItem"] = nil,
				["CornerRadius"] = nil,
				["SetSelectedItem"] = nil,
				["ShopItemUpgrade"] = upgrade,
				["CanPurchaseItem"] = props.CanPurchaseItem,
				["CornerRadius"] = {
					["Left"] = index == 0,
					["Right"] = index == #blacksmithShop.ItemUpgrades - 1,
				},
				["SetSelectedItem"] = props.SetSelectedItem,
			}
			return createElement(blacksmithShopItem, upgradeItemProps)
		end
		for index, upgrade in upgrades do
			upgradeElements[index] = createUpgradeItem(upgrade, index - 1, upgrades)
		end
		return React.createElement(
			Window,
			{
				["key"] = "Upgrades",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleImage"] = nil,
				["TitleText"] = "UPGRADES",
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(420, 640),
				["TitleImage"] = RobloxImage.Icon.ARROW,
			},
			currencyRow,
			viewportGrid,
			React.createElement(
				Grid,
				{
					["Position"] = UDim2.fromOffset(0, 464),
					["Size"] = UDim2.fromOffset(420, 176),
				},
				upgradeElements,
				React.createElement(List, {
					["Padding"] = UDim.new(0, 0),
				})
			)
		)
	end,
}
