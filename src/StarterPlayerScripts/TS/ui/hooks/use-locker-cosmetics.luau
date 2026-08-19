-- useLockerCosmetics

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticTypes = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-type"
).CosmeticTypes
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local CosmeticsModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics")
local Cosmetics = CosmeticsModule.Cosmetics
local CosmeticsByType = CosmeticsModule.CosmeticsByType
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local useState = React.useState

type Cosmetic = {
	Id: string,
	Name: string,
	Description: string?,
	Type: string,
	ItemGroup: string?,
	Rarity: string,
	Group: string,
}

type Profile = {
	Cosmetics: {
		Owned: { [string]: boolean },
		Active: { [string]: string },
		ActiveSkinsGroup: { [string]: string },
	},
}

type UseLockerCosmeticsReturn = {
	Cosmetics: { Cosmetic },
	DisplayNameFilter: string,
	CosmeticTypeFilter: string,
	CosmeticTypeFilterChangedTime: number,
	SetDisplayNameFilter: (filter: string) -> (),
	SetCosmeticTypeFilter: (filter: string) -> (),
	IsOwned: (cosmetic: Cosmetic) -> boolean,
	IsActive: (cosmetic: Cosmetic) -> boolean,
}

local SORT_PRIORITY = {
	[ItemGroup.Sword] = 1,
	[ItemGroup.Bow] = 2,
	[ItemGroup.Helmet] = 3,
	[ItemGroup.Chestplate] = 4,
	[ItemGroup.Leggings] = 5,
	["Cage"] = 6,
	["KillEffect"] = 7,
	["Cape"] = 7,
	["Title"] = 7,
	["ArrowTrailEffect"] = 7,
}

local function getCosmetics(profile: Profile): { Cosmetic }
	local ownedCosmeticIds = ObjectUtils.keys(profile.Cosmetics.Owned)
	for _, cape in CosmeticsByType.Cape do
		if profile.Cosmetics.Owned[cape.Id] == nil then
			local capeId = cape.Id
			table.insert(ownedCosmeticIds, capeId)
		end
	end
	local count = 0
	local ownedCosmetics = {}
	for index, cosmeticId in ownedCosmeticIds do
		local _ = index - 1
		if Cosmetics[cosmeticId] ~= nil == true then
			count = count + 1
			ownedCosmetics[count] = cosmeticId
		end
	end
	local cosmetics = table.create(#ownedCosmetics)
	for index, cosmeticId in ownedCosmetics do
		local _ = index - 1
		cosmetics[index] = Cosmetics[cosmeticId]
	end
	return cosmetics
end

local function filterDisplayName(cosmetics: { Cosmetic }, displayNameFilter: string): { Cosmetic }
	if displayNameFilter == "" or not displayNameFilter then
		return cosmetics
	end
	local function matchesFilter(cosmetic: Cosmetic): boolean
		local nameLower = string.lower(cosmetic.Name)
		local filterLower = string.lower(displayNameFilter)
		local nameMatch = string.match(nameLower, filterLower)
		if nameMatch == 0 or nameMatch ~= nameMatch then
			nameMatch = false
		elseif nameMatch == "" then
			nameMatch = false
		end
		local matches = nameMatch and true or false
		if not matches then
			local description = cosmetic.Description
			if description ~= nil then
				local descriptionLower = string.lower(description)
				local filterLower = string.lower(displayNameFilter)
				description = string.match(descriptionLower, filterLower)
			end
			if description == 0 or description ~= description then
				description = false
			elseif description == "" then
				description = false
			end
			matches = description and true or false
		end
		return matches
	end
	local count = 0
	local result = {}
	for index, cosmetic in cosmetics do
		if matchesFilter(cosmetic, index - 1, cosmetics) == true then
			count = count + 1
			result[count] = cosmetic
		end
	end
	return result
end

local function filterCosmeticType(cosmetics: { Cosmetic }, cosmeticTypeFilter: string): { Cosmetic }
	if cosmeticTypeFilter == "ALL" then
		return cosmetics
	end
	local isCosmeticType = CosmeticTypes[cosmeticTypeFilter] ~= nil
	local count = 0
	local result = {}
	for index, cosmetic in cosmetics do
		local _ = index - 1
		local matches
		if isCosmeticType then
			matches = cosmetic.Type == cosmeticTypeFilter
		elseif cosmetic.Type == "Skin" then
			matches = cosmetic.ItemGroup == cosmeticTypeFilter
		else
			matches = false
		end
		if matches == true then
			count = count + 1
			result[count] = cosmetic
		end
	end
	return result
end

return {
	["useLockerCosmetics"] = function(profileData: { Profile: Profile }): UseLockerCosmeticsReturn
		local displayNameFilter, setDisplayNameFilter = useState("")
		local cosmeticTypeFilter, setCosmeticTypeFilter = useState("ALL")
		local cosmeticTypeFilterChangedTime = useRef(0)
		local cosmetics = filterDisplayName(
			filterCosmeticType(getCosmetics(profileData.Profile), cosmeticTypeFilter),
			displayNameFilter
		)
		local profile = profileData.Profile
		table.sort(cosmetics, function(cosmeticA: Cosmetic, cosmeticB: Cosmetic): boolean
			local aOwned = profile.Cosmetics.Owned[cosmeticA.Id] ~= nil
			local bOwned = profile.Cosmetics.Owned[cosmeticB.Id] ~= nil
			if aOwned and not bOwned then
				return true
			end
			if not aOwned and bOwned then
				return false
			end
			if CosmeticRarities[cosmeticA.Rarity].Rarity ~= CosmeticRarities[cosmeticB.Rarity].Rarity then
				return CosmeticRarities[cosmeticA.Rarity].Rarity > CosmeticRarities[cosmeticB.Rarity].Rarity
			end
			if cosmeticA.Group == cosmeticB.Group then
				local aSortKey
				if cosmeticA.Type == "Skin" then
					aSortKey = cosmeticA.ItemGroup
				else
					aSortKey = cosmeticA.Type
				end
				local aPriority = SORT_PRIORITY[aSortKey]
				local aPriorityValue = aPriority == nil and 0 or aPriority
				local bSortKey
				if cosmeticB.Type == "Skin" then
					bSortKey = cosmeticB.ItemGroup
				else
					bSortKey = cosmeticB.Type
				end
				local bPriority = SORT_PRIORITY[bSortKey]
				return aPriorityValue < (bPriority == nil and 0 or bPriority)
			end
			local aBundleIndex = -1
			for index, bundle in ObjectUtils.keys(Bundles) do
				local _ = index - 1
				if bundle == cosmeticA.Group == true then
					aBundleIndex = index - 1
					break
				end
			end
			local bBundleIndex = -1
			for index, bundle in ObjectUtils.keys(Bundles) do
				local _ = index - 1
				if bundle == cosmeticB.Group == true then
					bBundleIndex = index - 1
					break
				end
			end
			return bBundleIndex < aBundleIndex
		end)
		return {
			["Cosmetics"] = cosmetics,
			["DisplayNameFilter"] = displayNameFilter,
			["CosmeticTypeFilter"] = cosmeticTypeFilter,
			["CosmeticTypeFilterChangedTime"] = cosmeticTypeFilterChangedTime.current,
			["SetDisplayNameFilter"] = setDisplayNameFilter,
			["SetCosmeticTypeFilter"] = function(filter)
				cosmeticTypeFilterChangedTime.current = os.clock()
				setCosmeticTypeFilter(filter)
			end,
			["IsOwned"] = function(cosmetic: Cosmetic): boolean
				return profileData.Profile.Cosmetics.Owned[cosmetic.Id] ~= nil
			end,
			["IsActive"] = function(cosmetic: Cosmetic): boolean
				local profile = profileData.Profile
				local isActive
				if cosmetic.Type == "Skin" then
					isActive = profile.Cosmetics.ActiveSkinsGroup[cosmetic.ItemGroup] == cosmetic.Id
				else
					isActive = profile.Cosmetics.Active[cosmetic.Type] == cosmetic.Id
				end
				return isActive
			end,
		}
	end,
}
