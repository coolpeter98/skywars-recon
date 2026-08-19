-- ArabianKnightBundle

local CosmeticId: { [string]: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ArabianKnightBundle = {
	["BundleId"] = "ArabianKnight",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Bow"] = nil,
	["Cage"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageArabianKnight,
		},
		{
			["Id"] = nil,
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponArabianKnight,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetArabianKnight,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateArabianKnight,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsArabianKnight,
	},
	["Sword"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordArabianKnight,
	},
	["Bow"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.BowArabianKnight,
	},
	["Cage"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.CageArabianKnight,
	},
}
return {
	["ArabianKnightBundle"] = ArabianKnightBundle,
}
