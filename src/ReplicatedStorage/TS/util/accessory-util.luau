-- accessory-util

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local RigUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "rig-util").RigUtil
local ArmourType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").ArmourType

type Layer = "Head" | "Body" | "Legs" | "Back"
type Override = "Cape" | "Armour"
type ArmourType = "Helmet" | "Chestplate" | "Leggings"
type StoredAccessory = {
	Accessory: Accessory,
	AccessoryLayers: { [number]: Layer },
}
type AccessoryData = {
	HiddenLayers: { [Layer]: { [Override]: boolean } },
	StoredAccessories: { [StoredAccessory]: boolean },
}

local AccessoryLayer = {
	["Head"] = "Head",
	["Body"] = "Body",
	["Legs"] = "Legs",
	["Back"] = "Back",
}
local AccessoryOverride = {
	["Cape"] = "Cape",
	["Armour"] = "Armour",
}
local layerAccessoryTypes: { [Layer]: { [Enum.AccessoryType]: boolean } } = {
	[AccessoryLayer.Head] = {
		[Enum.AccessoryType.Hat] = true,
		[Enum.AccessoryType.Hair] = true,
	},
	[AccessoryLayer.Body] = {
		[Enum.AccessoryType.Front] = true,
		[Enum.AccessoryType.Jacket] = true,
		[Enum.AccessoryType.Shirt] = true,
		[Enum.AccessoryType.Sweater] = true,
		[Enum.AccessoryType.TShirt] = true,
	},
	[AccessoryLayer.Legs] = {
		[Enum.AccessoryType.Pants] = true,
		[Enum.AccessoryType.LeftShoe] = true,
		[Enum.AccessoryType.RightShoe] = true,
		[Enum.AccessoryType.DressSkirt] = true,
		[Enum.AccessoryType.Shorts] = true,
	},
	[AccessoryLayer.Back] = {
		[Enum.AccessoryType.Waist] = true,
		[Enum.AccessoryType.Back] = true,
	},
}
local armourTypeLayers: { [ArmourType]: Layer } = {
	[ArmourType.Helmet] = AccessoryLayer.Head,
	[ArmourType.Chestplate] = AccessoryLayer.Body,
	[ArmourType.Leggings] = AccessoryLayer.Legs,
}
local accessoryDataCache: { [Model]: AccessoryData } = {}
local AccessoryUtil: {
	hideLayer: (character: Model, override: Override, ...any) -> (),
	showLayer: (character: Model, override: Override, ...any) -> (),
	handleCharacter: (character: Model, isInitializing: boolean) -> (),
	getCharacterAccessoryData: (character: Model) -> AccessoryData,
	updateCharacterTransparency: (character: Model, armourType: ArmourType, isVisible: boolean) -> (),
} =
	{}
local getCharacterAccessoryData: (character: Model) -> AccessoryData
local handleCharacter: (character: Model, isInitializing: boolean) -> ()

function AccessoryUtil.hideLayer(character: Model, override: Override, ...: Layer)
	local layers = { ... }
	if not character then
		return nil
	end
	local data = getCharacterAccessoryData(character)
	for _, layer in layers do
		data.HiddenLayers[layer][override] = true
	end
	handleCharacter(character, false)
end
function AccessoryUtil.showLayer(character: Model, override: Override, ...: Layer)
	local layers = { ... }
	if not character then
		return nil
	end
	local data = getCharacterAccessoryData(character)
	for _, layer in layers do
		data.HiddenLayers[layer][override] = nil
	end
	handleCharacter(character, false)
end
handleCharacter = function(character: Model, isInitializing: boolean)
	local player = Players:GetPlayerFromCharacter(character)
	if not isInitializing and (player and not player:HasAppearanceLoaded()) then
		return nil
	end
	local data = getCharacterAccessoryData(character)
	if isInitializing then
		table.clear(data.StoredAccessories)
	end
	for storedAccessory in data.StoredAccessories do
		local isHidden = false
		for _, layer in storedAccessory.AccessoryLayers do
			local hiddenCount = 0
			for _ in data.HiddenLayers[layer] do
				hiddenCount = hiddenCount + 1
			end
			if hiddenCount > 0 then
				isHidden = true
				break
			end
		end
		if not isHidden then
			storedAccessory.Accessory.Parent = character
			data.StoredAccessories[storedAccessory] = nil
		end
	end
	local accessoryIndex = 0
	local accessories: { [number]: Accessory } = {}
	for index, child in character:GetChildren() do
		local _ = index - 1
		if child:IsA("Accessory") == true then
			accessoryIndex = accessoryIndex + 1
			accessories[accessoryIndex] = child
		end
	end
	for _, accessory in accessories do
		local layers: { [number]: Layer } = {}
		for layer, accessoryTypes in layerAccessoryTypes do
			if accessoryTypes[accessory.AccessoryType] ~= nil then
				table.insert(layers, layer)
			end
		end
		for _, layer in layers do
			local hiddenCount = 0
			for _ in data.HiddenLayers[layer] do
				hiddenCount = hiddenCount + 1
			end
			if hiddenCount > 0 then
				local storedAccessory = {
					["Accessory"] = accessory:Clone(),
					["AccessoryLayers"] = layers,
				}
				data.StoredAccessories[storedAccessory] = true
				RigUtil.unsecureWelds(accessory)
				accessory.Parent = nil
				break
			end
		end
	end
end
AccessoryUtil.handleCharacter = handleCharacter
getCharacterAccessoryData = function(character: Model): AccessoryData
	local cachedData = accessoryDataCache[character]
	if cachedData then
		return cachedData
	end
	local data: AccessoryData = {
		["HiddenLayers"] = {},
		["StoredAccessories"] = {},
	}
	for _, layer in ObjectUtils.values(AccessoryLayer) do
		data.HiddenLayers[layer] = {}
	end
	accessoryDataCache[character] = data
	local destroyConnection: RBXScriptConnection
	destroyConnection = character.Destroying:Connect(function()
		print(("AccessoryUtil CHARACTER DESTROYING %*"):format(character))
		destroyConnection:Disconnect()
	end)
	return data
end
AccessoryUtil.getCharacterAccessoryData = getCharacterAccessoryData
function AccessoryUtil.updateCharacterTransparency(character: Model, armourType: ArmourType, isVisible: boolean)
	if isVisible then
		local override = AccessoryOverride.Armour
		AccessoryUtil.showLayer(character, override, armourTypeLayers[armourType])
	else
		local override = AccessoryOverride.Armour
		AccessoryUtil.hideLayer(character, override, armourTypeLayers[armourType])
	end
	if not character then
		return nil
	end
	local lowerTorso = armourType == ArmourType.Chestplate and character:FindFirstChild("LowerTorso")
	if lowerTorso then
		lowerTorso.Transparency = isVisible and 0 or 1
	end
end
return {
	["AccessoryLayer"] = AccessoryLayer,
	["AccessoryOverride"] = AccessoryOverride,
	["AccessoryUtil"] = AccessoryUtil,
}
