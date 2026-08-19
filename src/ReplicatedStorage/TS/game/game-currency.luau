-- Game currency definitions and tier lookup

local CurrencyType = {
	["TierOne"] = "TierOne",
	["TierTwo"] = "TierTwo",
	["TierThree"] = "TierThree",
	["TierFour"] = "TierFour",
}

export type Currency = {
	Type: string,
	Tier: number,
	ItemType: string,
	GeneratorShare: boolean?,
}

local Currencies: { [string]: Currency } = {}
for _, currencyData in
	{
		{
			["Tier"] = 1,
			["ItemType"] = "BronzeCoin",
			["GeneratorShare"] = true,
			["Type"] = CurrencyType.TierOne,
		},
		{
			["Tier"] = 2,
			["ItemType"] = "IronCoin",
			["Type"] = CurrencyType.TierTwo,
		},
		{
			["Tier"] = 3,
			["ItemType"] = "GoldCoin",
			["Type"] = CurrencyType.TierThree,
		},
		{
			["Tier"] = 4,
			["ItemType"] = "Shard",
			["Type"] = CurrencyType.TierFour,
		},
	}
do
	Currencies[currencyData.Type] = currencyData
end

return {
	["getCurrencyByTier"] = function(tier: number): string?
		for currencyType, currency in Currencies do
			if currency.Tier == tier then
				return currencyType
			end
		end
		return nil
	end,
	["CurrencyType"] = CurrencyType,
	["Currencies"] = Currencies,
}
