-- WizardShopGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local WizardShopItems = RuntimeLib.import(script, script.Parent, "wizard-shop-items").WizardShopItems
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type WizardShopGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["WizardShopGui"] = function(props: WizardShopGuiProps)
		local gameCurrency = useGlobalStore("GameCurrency")
		local teamUpgrades = useGlobalStore("TeamUpgrades")
		local canPurchaseItem = useCallback(function(itemId, quantity)
			return quantity <= gameCurrency.Quantities[itemId]
		end, { gameCurrency })
		return React.createElement(
			Window,
			{
				["key"] = "WizardShop",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleText"] = "TEAM UPGRADES",
				["TitleImage"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(1130, 502),
				["TitleImage"] = RobloxImage.Icon.SHOPPING_CART,
			},
			React.createElement(WizardShopItems, {
				["Position"] = UDim2.fromOffset(30, 62),
				["CanPurchaseItem"] = canPurchaseItem,
				["TeamUpgrades"] = teamUpgrades,
			})
		)
	end,
}
