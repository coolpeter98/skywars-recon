-- AzazelBundle

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

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local AzazelBundle: Bundle = {
	["BundleId"] = "Azazel",
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
			["Name"] = "Ballista Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageAzazel,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Ballista Helmet",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetAzazel,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Ballista Chestplate",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateAzazel,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Ballista Leggings",
		["Rarity"] = "Epic",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsAzazel,
	},
}

local sword: BundleItem = {
	["Id"] = nil,
	["Name"] = "Ballista Axe",
	["Rarity"] = "Epic",
	["ItemAnimation"] = nil,
	["ViewportOptions"] = nil,
	["Id"] = CosmeticId.SwordLongAxe,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.LONG_AXE_IDLE,
		["Sprint"] = RobloxAnimation.LONG_AXE_RUN,
		["Melee"] = { RobloxAnimation.LONG_AXE_SLASH },
	},
	["ViewportOptions"] = {
		["Zoom"] = -0.3,
		["Rotate"] = Vector3.new(0, -60, 0),
	},
}

AzazelBundle.Sword = sword
AzazelBundle.Bow = {
	["Id"] = nil,
	["Name"] = "Ballista Bow",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.BowAzazel,
}
AzazelBundle.Cage = {
	["Id"] = nil,
	["Name"] = "Ballista Cage",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.CageAzazel,
}

return {
	["AzazelBundle"] = AzazelBundle,
}
