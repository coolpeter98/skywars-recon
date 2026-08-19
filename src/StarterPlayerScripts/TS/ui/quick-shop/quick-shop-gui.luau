-- QuickShopGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local RadialPromptGui = RuntimeLib.import(script, script.Parent.Parent, "components", "radial-prompt", "radial-prompt-gui").RadialPromptGui
local RadialPromptItem = RuntimeLib.import(script, script.Parent.Parent, "components", "radial-prompt", "radial-prompt-item").RadialPromptItem
local GameShop = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop")
local Shops = GameShop.Shops
local ShopType = GameShop.ShopType
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

local QuickShopItemTypeNames = {}
local QuickShopItemType = setmetatable({}, {
	["__index"] = QuickShopItemTypeNames,
})
QuickShopItemType.Standard = 0
QuickShopItemTypeNames[0] = "Standard"
QuickShopItemType.Upgrade = 1
QuickShopItemTypeNames[1] = "Upgrade"

return {
	["QuickShopGui"] = function(_)
		local currencyState = useGlobalStore("GameCurrency")
		local canPurchaseItem = useCallback(function(item)
			local quantity = currencyState.Quantities[item.CurrencyType]
			local limit = item.Limit
			local amount = limit == nil and (1 / 0) or limit
			local canPurchase
			if item.Price <= quantity then
				canPurchase = not Flamework.resolveDependency("qOA"):hasItem(item.ItemType, amount)
			else
				canPurchase = false
			end
			return canPurchase
		end, { currencyState })
		local quickShop = Shops[ShopType.QuickShop]
		local items = {}
		for _, item in quickShop.Items do
			local entry = {
				["Type"] = QuickShopItemType.Standard,
				["Value"] = item,
			}
			table.insert(items, entry)
		end
		for _, upgrade in quickShop.ItemUpgrades do
			local entry = {
				["Type"] = QuickShopItemType.Upgrade,
				["Value"] = upgrade,
			}
			table.insert(items, entry)
		end
		local props = {
			["Items"] = items,
			["Render"] = function(item, promptProps)
				if item.Type == QuickShopItemType.Standard then
					return React.createElement(RadialPromptItem, {
						["key"] = item.Value.ItemType,
						["AnchorPoint"] = promptProps.AnchorPoint,
						["Position"] = promptProps.Position,
						["ShopItem"] = item.Value,
						["CanPurchaseItem"] = canPurchaseItem,
					})
				end
				local nextUpgrade = Flamework.resolveDependency("ADv"):getNextUpgradeableItem(item.Value) or item.Value.Items[#item.Value.Items]
				return React.createElement(RadialPromptItem, {
					["key"] = nextUpgrade.ItemType,
					["AnchorPoint"] = promptProps.AnchorPoint,
					["Position"] = promptProps.Position,
					["ShopItem"] = nextUpgrade,
					["CanPurchaseItem"] = canPurchaseItem,
				})
			end,
			["OnSelect"] = function(item)
				if item.Type == QuickShopItemType.Standard then
					Flamework.resolveDependency("ADv"):purchaseItem(ShopType.QuickShop, item.Value.ItemIndex)
				else
					Flamework.resolveDependency("ADv"):purchaseItemUpgrade(ShopType.QuickShop, item.Value.ItemIndex)
				end
			end,
		}
		return React.createElement(RadialPromptGui, props)
	end,
}
