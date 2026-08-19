-- PrimedCosmetics

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local PrimedCosmeticType = GameProduct.PrimedCosmeticType
local ProductId = GameProduct.ProductId
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local BundleUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"bundle-util"
).BundleUtil
local FeaturedCosmetics = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"shop",
	"featured-cosmetics"
).FeaturedCosmetics

local function addBundle(bundleName: string, exclude: boolean?): { { string } }
	if exclude == nil then
		exclude = false
	end
	if exclude then
		return {}
	end
	local cageId: string? = BundleUtil.getBundlePrimedCosmeticId(bundleName, PrimedCosmeticType.Cage)
	local armourId: string? = BundleUtil.getBundlePrimedCosmeticId(bundleName, PrimedCosmeticType.Armour)
	local weaponsId: string? = BundleUtil.getBundlePrimedCosmeticId(bundleName, PrimedCosmeticType.Weapons)
	return ArrayUtil.filterDefined({
		cageId and { cageId, ProductId.CAGE_SINGLE } or cageId,
		armourId and { armourId, ProductId.ARMOUR_SINGLE } or armourId,
		weaponsId and { weaponsId, ProductId.WEAPONS_SINGLE } or weaponsId,
	})
end

local primedCosmeticProducts: { { string } } = {}
local appendIndex = #primedCosmeticProducts
local spacemanProducts = addBundle("Spaceman")
local spacemanCount = #spacemanProducts
table.move(spacemanProducts, 1, spacemanCount, appendIndex + 1, primedCosmeticProducts)
local appendIndex = appendIndex + spacemanCount
local dwarvenProducts = addBundle("Dwarven")
local dwarvenCount = #dwarvenProducts
table.move(dwarvenProducts, 1, dwarvenCount, appendIndex + 1, primedCosmeticProducts)
local appendIndex = appendIndex + dwarvenCount
local crusaderProducts = addBundle("Crusader")
local crusaderCount = #crusaderProducts
table.move(crusaderProducts, 1, crusaderCount, appendIndex + 1, primedCosmeticProducts)
local appendIndex = appendIndex + crusaderCount
local romanProducts = addBundle("Roman")
local romanCount = #romanProducts
table.move(romanProducts, 1, romanCount, appendIndex + 1, primedCosmeticProducts)
local appendIndex = appendIndex + romanCount
local arabianKnightProducts = addBundle("ArabianKnight")
local arabianKnightCount = #arabianKnightProducts
table.move(arabianKnightProducts, 1, arabianKnightCount, appendIndex + 1, primedCosmeticProducts)
local appendIndex = appendIndex + arabianKnightCount
local plasmaTitanProducts = addBundle("PlasmaTitan")
table.move(plasmaTitanProducts, 1, #plasmaTitanProducts, appendIndex + 1, primedCosmeticProducts)

local primedCosmetics: { [string]: string } = {}
for _, primedProduct in ArrayUtil.filterDefined(primedCosmeticProducts) do
	primedCosmetics[primedProduct[1]] = primedProduct[2]
end
for cosmeticId, productId in FeaturedCosmetics do
	primedCosmetics[cosmeticId] = productId
end
return {
	["PrimedCosmetics"] = primedCosmetics,
}
