-- VikingBundle

local CosmeticId: {
	PackageViking: string,
	HelmetViking: string,
	ChestplateViking: string,
	LeggingsViking: string,
	SwordVikingAxe: string,
	CageViking: string,
} =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"cosmetic",
		"cosmetic-id"
	).CosmeticId
local VikingBundle = {
	["BundleId"] = "Viking",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Cage"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Description"] = "Become a viking warrior with this cosmetic armour set!",
			["Rarity"] = "Legendary",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageViking,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Viking Helmet",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetViking,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Viking Chestplate",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateViking,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Viking Leggings",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsViking,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Viking Axe",
		["Description"] = "Demolish your opponents with this sharp and dependable axe!",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.SwordVikingAxe,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "The Viking Spirit",
		["Description"] = "Sail through the sky and prepare to defeat your enemies in your very own Viking Ship!",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.CageViking,
	},
}
return {
	["VikingBundle"] = VikingBundle,
}
