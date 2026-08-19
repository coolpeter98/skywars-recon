-- AbTestType

export type AbTestType = number | "VerifyFollowJay" | "GemTiers" | "FeaturedCosmetics"

local AbTestTypeNames: { [number]: string } = {}
local AbTestType = setmetatable({}, {
	["__index"] = AbTestTypeNames,
})
AbTestType.AutoQueue = 0
AbTestTypeNames[0] = "AutoQueue"
AbTestType.Shop = 1
AbTestTypeNames[1] = "Shop"
AbTestType.VerifyFollowJay = "VerifyFollowJay"
AbTestType.GemTiers = "GemTiers"
AbTestType.FeaturedCosmetics = "FeaturedCosmetics"
return {
	["AbTestType"] = AbTestType,
}
