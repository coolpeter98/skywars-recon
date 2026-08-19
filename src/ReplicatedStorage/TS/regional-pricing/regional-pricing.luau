-- RegionalPricing

type RegionalPricingEntry = {
	CountryCode: string,
	DiscountPercentage: number,
}

local RegionalPricing: { [string]: RegionalPricingEntry } = {}
for _, regionalPricingEntry: RegionalPricingEntry in {
	{
		["CountryCode"] = "BR",
		["DiscountPercentage"] = 0.5
	},
	{
		["CountryCode"] = "PH",
		["DiscountPercentage"] = 0.3
	},
	{
		["CountryCode"] = "VN",
		["DiscountPercentage"] = 0.5
	},
	{
		["CountryCode"] = "MX",
		["DiscountPercentage"] = 0.5
	},
	{
		["CountryCode"] = "RU",
		["DiscountPercentage"] = 0.5
	},
	{
		["CountryCode"] = "PE",
		["DiscountPercentage"] = 0.5
	}
} do
	RegionalPricing[regionalPricingEntry.CountryCode] = regionalPricingEntry
end
return {
	["RegionPricing"] = RegionalPricing
}
