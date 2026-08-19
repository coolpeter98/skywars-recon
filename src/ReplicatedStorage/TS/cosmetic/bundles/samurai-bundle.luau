-- SamuraiBundle

type BundleItem = {
	Id: string?,
	Name: string?,
	Rarity: string?,
	LegacyAttachments: boolean?,
}

type BundlePackage = {
	Id: string?,
	PackageType: string?,
	Rarity: string?,
}

type SamuraiBundle = {
	BundleId: string,
	Packages: { BundlePackage },
	Helmet: BundleItem?,
	Chestplate: BundleItem?,
	Leggings: BundleItem?,
	Sword: BundleItem?,
	Cage: BundleItem?,
}

local CosmeticId: { [string]: string } = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local SamuraiBundle: SamuraiBundle = {
	["BundleId"] = "Samurai",
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
			["Rarity"] = "Rare",
			["Id"] = CosmeticId.PackageSamurai
		}
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Samurai Helmet",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetSamurai
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Samurai Chestplate",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateSamurai
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Samurai Leggings",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsSamurai
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Katana",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordKatana
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Samurai Cage",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.CageSamurai
	}
}
return {
	["SamuraiBundle"] = SamuraiBundle
}
