-- CrusaderBundle

type BundleItem = {
	Id: string?,
	Name: string,
	Rarity: string,
	PackageType: string?,
	Display: { [string]: unknown }?,
}

type Bundle = {
	BundleId: string,
	Description: string?,
	Image: string?,
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
local CosmeticId: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local CrusaderBundle: Bundle = {
	["BundleId"] = "Crusader",
	["Description"] = "Embody the valour of a knight. Charge into battle with a noble and heroic appearance!",
	["Image"] = nil,
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Bow"] = nil,
	["Cage"] = nil,
	["Image"] = RuntimeLib.import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"asset",
		"roblox",
		"roblox-image"
	).RobloxImage.GameProduct.CRUSADER_RENDER_16_9,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Crusader Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageCrusader,
		},
		{
			["Id"] = nil,
			["Name"] = "Crusader Weapons",
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponCrusader,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Crusader Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetCrusader,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Crusader Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateCrusader,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Crusader Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsCrusader,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Crusader Sword",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordCrusader,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Crusader Bow",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.BowCrusader,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Crusader Cage",
		["Rarity"] = "Epic",
		["Display"] = nil,
		["Id"] = CosmeticId.CageCrusader,
		["Display"] = {},
	},
}

return {
	["CrusaderBundle"] = CrusaderBundle,
}
