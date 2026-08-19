-- SpacemanBundle

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
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation

local SpacemanBundle: Bundle = {
	["BundleId"] = "Spaceman",
	["Description"] = "Step into this interstellar space suit! Perfect for those looking for an out-of-this-world look.",
	["Image"] = nil,
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Bow"] = nil,
	["Image"] = RuntimeLib.import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"asset",
		"roblox",
		"roblox-image"
	).RobloxImage.GameProduct.SPACEMAN_RENDER_16_9,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Spaceman Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageSpaceman,
		},
		{
			["Id"] = nil,
			["Name"] = "Spaceman Weapons",
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponSpaceman,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Spaceman Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetSpaceman,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Spaceman Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateSpaceman,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Spaceman Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsSpaceman,
	},
}

local SpaceBlades: BundleItem = {
	["Id"] = nil,
	["Name"] = "Space Blades",
	["Rarity"] = "Epic",
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordSpaceman,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.SPACEMAN_DUAL_IDLE,
		["Melee"] = { RobloxAnimation.SPACEMAN_DUAL_SLASH },
	},
}
SpacemanBundle.Sword = SpaceBlades
SpacemanBundle.Bow = {
	["Id"] = nil,
	["Name"] = "Space Bow",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.BowSpaceman,
}

local SpaceExplorerCage: BundleItem = {
	["Id"] = nil,
	["Name"] = "Space Explorer",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.CageSpaceman,
	["Display"] = {
		["CageOffset"] = CFrame.new(1.5, 0, 1.5) * CFrame.Angles(0, 1.1780972450961724, 0),
		["CageScale"] = 0.7,
		["CharacterOffset"] = CFrame.new(0, 0, -7.5),
	},
}
SpacemanBundle.Cage = SpaceExplorerCage

return {
	["SpacemanBundle"] = SpacemanBundle,
}
