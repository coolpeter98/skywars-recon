-- FeaturedCosmetics

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics

local function getProductId(cosmeticId: string): string?
	local rarity: string = Cosmetics[cosmeticId].Rarity
	local isCommon: boolean = rarity == "Common"
	if isCommon or rarity == "Uncommon" then
		return ProductId.FEATURED_COSMETIC_TIER_1
	end
	local isRareOrCommon: boolean = rarity == "Rare" and true or isCommon
	if isRareOrCommon or rarity == "Epic" then
		return ProductId.FEATURED_COSMETIC_TIER_2
	end
	if rarity == "Legendary" and true or isRareOrCommon or rarity == "Mythical" then
		return ProductId.FEATURED_COSMETIC_TIER_3
	end
end

local featuredCosmetics: { [string]: string? } = {}
local featuredCosmeticsByProductId: { [string]: { string } } = {}
for _, cosmeticId in
	{
		CosmeticId.SwordCommon,
		CosmeticId.SwordCutlass,
		CosmeticId.SwordRapier,
		CosmeticId.SwordWrench,
		CosmeticId.SwordSpartan,
		CosmeticId.SwordKnightBlade,
		CosmeticId.SwordVikingAxe,
		CosmeticId.SwordWarAxe,
		CosmeticId.SwordDoubleAxe,
		CosmeticId.SwordRonin,
		CosmeticId.SwordNatureAxe,
		CosmeticId.SwordRing,
		CosmeticId.SwordPan,
		CosmeticId.SwordEgyptian,
		CosmeticId.SwordRazor,
		CosmeticId.SwordJuggernaut,
		CosmeticId.SwordNature,
		CosmeticId.SwordShogun,
		CosmeticId.SwordSeaKing,
	}
do
	local productId = getProductId(cosmeticId)
	featuredCosmetics[cosmeticId] = productId
	if featuredCosmeticsByProductId[productId] == nil then
		featuredCosmeticsByProductId[productId] = {}
	end
	local productCosmetics = featuredCosmeticsByProductId[productId]
	table.insert(productCosmetics, cosmeticId)
end
return {
	["FeaturedCosmetics"] = featuredCosmetics,
	["FeaturedCosmeticsByProductId"] = featuredCosmeticsByProductId,
}
