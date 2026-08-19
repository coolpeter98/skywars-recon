-- RegionalPricingUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RegionPricing = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"regional-pricing",
	"regional-pricing"
).RegionPricing
local GameProducts =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").GameProducts

local RegionalPricingUtil  = nil

RegionalPricingUtil = {
	getGameProduct = function(productId: string, pricingRegions: { [string]: number }): any
		local gameProduct = GameProducts[productId]
		local region = RegionalPricingUtil.getPricingRegion(pricingRegions)
		local discountPercentage
		if region == "" or not region then
			discountPercentage = nil
		else
			discountPercentage = RegionalPricingUtil.getDiscountPercentage(region)
		end
		local product
		if discountPercentage == 0 or (discountPercentage ~= discountPercentage or not discountPercentage) then
			product = nil
		else
			product = gameProduct.RegionalPricing
			if product ~= nil then
				product = product[discountPercentage]
			end
		end
		return product or gameProduct
	end,
	getDiscountPercentage = function(region: string): number
		local discount = RegionPricing[region]
		if discount ~= nil then
			discount = discount.DiscountPercentage
		end
		return discount == nil and 1 or discount
	end,
	getPricingRegion = function(pricingRegions: { [string]: number }): string?
		local highestRegion = nil
		local highestValue = 0
		for region, value in pricingRegions do
			if highestRegion == nil or value >= highestValue then
				highestValue = value
				highestRegion = region
			end
		end
		return highestRegion
	end,
}
return {
	["RegionalPricingUtil"] = RegionalPricingUtil,
}
