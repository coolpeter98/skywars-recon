-- ShogunBundle

type BundleItem = {
	Id: string?,
	Name: string,
	Rarity: string,
	Description: string?,
	PackageType: string?,
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

local CosmeticId: { [string]: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ShogunBundle: Bundle = {
	["BundleId"] = "Shogun",
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
			["Name"] = "Shogun Armour",
			["Rarity"] = "Legendary",
			["PackageType"] = "Armour",
			["Description"] = "Embrace the might of the legendary Shogun with this armor, radiating authority and invincibility",
			["Id"] = CosmeticId.PackageShogun,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Shogun Helmet",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.HelmetShogun,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Shogun Chestplate",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.ChestplateShogun,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Shogun Leggings",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.LeggingsShogun,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Naginata",
		["Rarity"] = "Legendary",
		["Description"] = "Master the legendary polearm, the Naginata, showcasing your unparalleled skill and finesse in combat",
		["Id"] = CosmeticId.SwordShogun,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Namson Bow",
		["Rarity"] = "Legendary",
		["Description"] = "The legendary Namson Bow, forged by a renowned archer, exuding unparalleled power and precision",
		["Id"] = CosmeticId.BowShogun,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Shogun Cage",
		["Rarity"] = "Legendary",
		["Description"] = "A legendary cage inspired by the grandeur of a Shogun castle",
		["Id"] = CosmeticId.CageShogun,
	},
}

return {
	["ShogunBundle"] = ShogunBundle,
}
