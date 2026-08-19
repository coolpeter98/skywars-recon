-- RomanBundle

type BundleItem = {
	Id: string,
	Rarity: string,
}

type BundlePackage = {
	Id: string,
	Rarity: string,
	PackageType: string,
}

type RomanBundle = {
	BundleId: string,
	Packages: { BundlePackage },
	Helmet: BundleItem,
	Chestplate: BundleItem,
	Leggings: BundleItem,
	Sword: BundleItem,
	Bow: BundleItem,
	Cage: BundleItem,
}

local CosmeticId = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local RomanBundle: RomanBundle = {
	["BundleId"] = "Roman",
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
			["Id"] = CosmeticId.PackageRoman
		},
		{
			["Id"] = nil,
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponRoman
		}
	},
	["Helmet"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetRoman
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateRoman
	},
	["Leggings"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsRoman
	},
	["Sword"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordRoman
	},
	["Bow"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.BowRoman
	},
	["Cage"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.CageRoman
	}
}
return {
	["RomanBundle"] = RomanBundle
}
