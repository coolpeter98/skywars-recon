-- MayanWarriorBundle

type BundleItem = {
	Id: string?,
	Name: string,
	Rarity: string,
	PackageType: string?,
	LegacyAttachments: boolean?,
	ItemAnimation: unknown?,
	ViewportOptions: unknown?,
}

type Bundle = {
	BundleId: string,
	Packages: { BundleItem }?,
	Helmet: BundleItem?,
	Chestplate: BundleItem?,
	Leggings: BundleItem?,
	Sword: BundleItem?,
	Bow: BundleItem?,
	Cage: BundleItem?,
}

local CosmeticId = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local MayanWarriorBundle: Bundle = {
	["BundleId"] = "MayanWarrior",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Mayan Warrior Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageMayanWarrior,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Mayan Warrior Helmet",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.HelmetMayanWarrior,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Mayan Warrior Chestplate",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.ChestplateMayanWarrior,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Mayan Warrior Leggings",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.LeggingsMayanWarrior,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Mayan Warrior Spear",
		["Rarity"] = "Rare",
		["Id"] = CosmeticId.SwordMayanSpear,
	},
}

return {
	["MayanWarriorBundle"] = MayanWarriorBundle,
}
