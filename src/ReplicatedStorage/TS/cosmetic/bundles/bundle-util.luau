-- BundleUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PrimedCosmeticType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PrimedCosmeticType
local Bundles = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

type BundlePart = {
	Id: string,
}

export type BundleUtil = {
	Helmet: BundlePart?,
	Chestplate: BundlePart?,
	Leggings: BundlePart?,
	Sword: BundlePart?,
	Bow: BundlePart?,
	Pickaxe: BundlePart?,
	Cage: BundlePart?,
	getBundleCosmetics: (self: BundleUtil, cosmeticType: string?) -> { string },
	getBundlePrimedCosmeticId: (bundleId: string, primedType: PrimedCosmeticType) -> string?,
	getPackageCosmeticId: (self: BundleUtil, bundleId: string, packageType: string) -> string?,
}

local BundleUtil = {
	["getBundleCosmetics"] = function(self: BundleUtil, cosmeticType: string?)
		if cosmeticType == nil then
			cosmeticType = nil
		end
		if cosmeticType == "Armour" then
			local helmetId = self.Helmet
			if helmetId ~= nil then
				helmetId = helmetId.Id
			end
			local chestplateId = self.Chestplate
			if chestplateId ~= nil then
				chestplateId = chestplateId.Id
			end
			local leggingsId = self.Leggings
			if leggingsId ~= nil then
				leggingsId = leggingsId.Id
			end
			return ArrayUtil.filterDefined({ helmetId, chestplateId, leggingsId })
		end
		if cosmeticType == "Weapons" then
			local swordId = self.Sword
			if swordId ~= nil then
				swordId = swordId.Id
			end
			local bowId = self.Bow
			if bowId ~= nil then
				bowId = bowId.Id
			end
			return ArrayUtil.filterDefined({ swordId, bowId })
		end
		if cosmeticType == nil then
			local helmetId = self.Helmet
			if helmetId ~= nil then
				helmetId = helmetId.Id
			end
			local chestplateId = self.Chestplate
			if chestplateId ~= nil then
				chestplateId = chestplateId.Id
			end
			local leggingsId = self.Leggings
			if leggingsId ~= nil then
				leggingsId = leggingsId.Id
			end
			local swordId = self.Sword
			if swordId ~= nil then
				swordId = swordId.Id
			end
			local bowId = self.Bow
			if bowId ~= nil then
				bowId = bowId.Id
			end
			local pickaxeId = self.Pickaxe
			if pickaxeId ~= nil then
				pickaxeId = pickaxeId.Id
			end
			local cageId = self.Cage
			if cageId ~= nil then
				cageId = cageId.Id
			end
			return ArrayUtil.filterDefined({
				helmetId,
				chestplateId,
				leggingsId,
				swordId,
				bowId,
				pickaxeId,
				cageId
			})
		end
	end
}
local getPackageCosmeticId = nil
function BundleUtil.getBundlePrimedCosmeticId(bundleId: string, primedType: PrimedCosmeticType)
	local bundle = Bundles[bundleId]
	if primedType == PrimedCosmeticType.Cage then
		local cageId = bundle.Cage
		if cageId ~= nil then
			cageId = cageId.Id
		end
		return cageId
	end
	if primedType == PrimedCosmeticType.Armour then
		return getPackageCosmeticId(bundleId, "Armour")
	end
	if primedType == PrimedCosmeticType.Weapons then
		return getPackageCosmeticId(bundleId, "Weapons")
	end
end
getPackageCosmeticId = function(bundleId: string, packageType: string)
	local matchingPackage = nil
	for index, package in Bundles[bundleId].Packages do
		local _ = index - 1
		if package.PackageType == packageType == true then
			matchingPackage = package
			break
		end
	end
	if matchingPackage ~= nil then
		matchingPackage = matchingPackage.Id
	end
	return matchingPackage
end
BundleUtil.getPackageCosmeticId = getPackageCosmeticId
return {
	["BundleUtil"] = BundleUtil
}
