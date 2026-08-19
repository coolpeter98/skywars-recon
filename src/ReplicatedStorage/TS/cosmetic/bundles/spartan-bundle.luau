-- SpartanBundle

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local SpartanBundle = {
	["BundleId"] = "Spartan",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Cage"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["PackageType"] = "Armour",
			["Description"] = "Become a spartan warrior with this cosmetic armour set!",
			["Rarity"] = "Rare",
			["Id"] = CosmeticId.PackageSpartan,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Spartan Helmet",
		["Rarity"] = "Rare",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetSpartan,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Spartan Chestplate",
		["Rarity"] = "Rare",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateSpartan,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Spartan Leggings",
		["Rarity"] = "Rare",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsSpartan,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Spartan's Sword",
		["Description"] = "Unleash your inner warrior and battle your way to victory with this sleek spartan sword!",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.SwordSpartan,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Marble Peak",
		["Description"] = "A podium made of fine marble...",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.CageSpartan,
	},
}
return {
	["SpartanBundle"] = SpartanBundle,
}
