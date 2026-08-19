-- VurrenBundle

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
	Description: string?,
	Image: unknown?,
	Packages: { BundleItem }?,
	Helmet: BundleItem?,
	Chestplate: BundleItem?,
	Leggings: BundleItem?,
	Sword: BundleItem?,
	Bow: BundleItem?,
	Cage: BundleItem?,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local VurrenBundle: Bundle = {
	["BundleId"] = "Vurren",
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
			["Name"] = "Vurren Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageVurren,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Vurren Helmet",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetVurren,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Vurren Chestplate",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateVurren,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Vurren Leggings",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsVurren,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Dragon Blade",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordDragonBlade,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Vurren Bow",
		["Rarity"] = "Epic",
		["ViewportOptions"] = nil,
		["Id"] = CosmeticId.BowVurren,
		["ViewportOptions"] = {
			["Rotate"] = Vector3.new(0, 0, 0),
		},
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Vurren Cage",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.CageVurren,
	},
}

return {
	["VurrenBundle"] = VurrenBundle,
}
