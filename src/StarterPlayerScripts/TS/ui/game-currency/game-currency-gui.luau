-- GameCurrencyGui

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
local Currencies =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-currency").Currencies
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local GameCurrencyItem =
	RuntimeLib.import(script, script.Parent.Parent, "blacksmith-shop", "game-currency-item").GameCurrencyItem
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

local function GameCurrencyGui(props)
	local currencyStore = useGlobalStore("GameCurrency")
	local currencies = ObjectUtils.values(Currencies)
	local items = table.create(#currencies)

	local function renderCurrencyItem(currency)
		local quantity = currencyStore.Quantities[currency.Type]
		local resolvedQuantity = quantity == nil and 0 or quantity
		return React.createElement(GameCurrencyItem, {
			["key"] = nil,
			["Size"] = nil,
			["CurrencyType"] = nil,
			["Quantity"] = nil,
			["TextSize"] = 18,
			["BackgroundTransparency"] = 0.6,
			["LayoutOrder"] = nil,
			["key"] = currency.Type,
			["Size"] = UDim2.fromOffset(60, 60),
			["CurrencyType"] = currency.Type,
			["Quantity"] = resolvedQuantity,
			["LayoutOrder"] = currency.Tier,
		})
	end

	for i, currency in currencies do
		items[i] = renderCurrencyItem(currency, i - 1, currencies)
	end

	return React.createElement(Grid, {
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["AutomaticSize"] = Enum.AutomaticSize.XY,
	}, items, React.createElement(List))
end

return {
	["GameCurrencyGui"] = GameCurrencyGui,
}
