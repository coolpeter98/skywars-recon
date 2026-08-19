-- BlacksmithShopGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local BlacksmithUpgrades = RuntimeLib.import(script, script.Parent, "blacksmith-upgrades").BlacksmithUpgrades
local BlacksmithItems = RuntimeLib.import(script, script.Parent, "blacksmith-items").BlacksmithItems
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local useState = React.useState
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type BlacksmithShopGuiProps = {
	AnchorPoint: UDim2?,
	Position: UDim2?,
}

return {
	["BlacksmithShopGui"] = function(props: BlacksmithShopGuiProps)
		local inventoryStore = useGlobalStore("Inventory")
		local gameCurrencyStore = useGlobalStore("GameCurrency")
		local selectedItem, setSelectedItem = useState(nil)
		local canPurchaseItem = useCallback(function(item)
			local currencyQuantity = gameCurrencyStore.Quantities[item.CurrencyType]
			local limit = item.Limit
			local effectiveLimit = limit == nil and (1 / 0) or limit
			local canPurchase
			if item.Price <= currencyQuantity then
				canPurchase = not Flamework.resolveDependency("qOA"):hasItem(item.ItemType, effectiveLimit, inventoryStore)
			else
				canPurchase = false
			end
			return canPurchase
		end, { inventoryStore, gameCurrencyStore })
		return React.createElement(Grid, {
			["key"] = "BlacksmithShop",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1240, 640)
		}, React.createElement(BlacksmithUpgrades, {
			["Position"] = UDim2.fromOffset(0, 0),
			["PlayerCurrencyData"] = gameCurrencyStore,
			["CanPurchaseItem"] = canPurchaseItem,
			["SetSelectedItem"] = setSelectedItem,
			["SelectedItem"] = selectedItem
		}), React.createElement(BlacksmithItems, {
			["Position"] = UDim2.fromOffset(440, 0),
			["CanPurchaseItem"] = canPurchaseItem,
			["SetSelectedItem"] = setSelectedItem
		}))
	end
}
