-- CosmeticPackages

type BundleDefinition = {
	BundleId: string,
	Cage: { [string]: any }?,
	Packages: { { PackageType: string, [string]: any } }?,
	[string]: any,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Bundles: { [string]: BundleDefinition } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local ItemGroup: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local StringUtil: { formatDisplayName: (bundleId: string) -> string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local ObjectUtils: { values: <T>(obj: { [string]: T }) -> { T } } = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local BundleUtil: { getBundleCosmetics: (bundle: BundleDefinition, packageType: string) -> { any } } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundle-util").BundleUtil

local bundleList: { BundleDefinition } = ObjectUtils.values(Bundles)
local cosmeticPackages: { any } = {}

local function createBundleCosmetics(bundle: BundleDefinition): { any }
	local displayName = StringUtil.formatDisplayName(bundle.BundleId)
	local cosmetics: { any } = {}
	for _, itemGroup in ObjectUtils.values(ItemGroup) do
		local itemGroupData = bundle[itemGroup]
		if itemGroupData ~= nil then
			local cosmetic = {
				["Name"] = nil,
				["Type"] = "Skin",
				["Group"] = nil,
				["ItemGroup"] = nil,
				["Name"] = ("%* %*"):format(displayName, itemGroup),
				["Group"] = bundle.BundleId,
				["ItemGroup"] = itemGroup,
			}
			for key, value in itemGroupData do
				cosmetic[key] = value
			end
			table.insert(cosmetics, cosmetic)
		end
	end
	if bundle.Cage then
		local cageCosmetic = {
			["Name"] = nil,
			["Type"] = "Cage",
			["Group"] = nil,
			["Name"] = ("%* Cage"):format(displayName),
			["Group"] = bundle.BundleId,
		}
		for key, value in bundle.Cage do
			cageCosmetic[key] = value
		end
		table.insert(cosmetics, cageCosmetic)
	end
	for _, package in bundle.Packages do
		local packageCosmetic = {
			["Name"] = nil,
			["Group"] = nil,
			["Type"] = "Package",
			["Cosmetics"] = nil,
			["Name"] = ("%* %*"):format(displayName, package.PackageType),
			["Group"] = bundle.BundleId,
			["Cosmetics"] = BundleUtil.getBundleCosmetics(bundle, package.PackageType),
		}
		for key, value in package do
			packageCosmetic[key] = value
		end
		table.insert(cosmetics, packageCosmetic)
	end
	return cosmetics
end

for index = 1, #bundleList do
	local bundle = bundleList[index]
	local _ = index - 1
	for _, cosmetic in createBundleCosmetics(bundle) do
		table.insert(cosmeticPackages, cosmetic)
	end
end

return {
	["CosmeticPackages"] = cosmeticPackages,
}
