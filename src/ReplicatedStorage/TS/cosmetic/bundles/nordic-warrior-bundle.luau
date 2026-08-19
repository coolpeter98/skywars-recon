-- NordicWarriorBundle

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
	Pickaxe: BundleItem?,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxAnimation: { [string]: string } = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local CosmeticId: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

local NordicWarriorBundle: Bundle = {
	["BundleId"] = "NordicWarrior",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Bow"] = nil,
	["Pickaxe"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Nordic Warrior Armour",
			["Rarity"] = "Epic",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageNordicWarrior,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Nordic Warrior Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetNordicWarrior,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Nordic Warrior Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateNordicWarrior,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Nordic Warrior Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsNordicWarrior,
	},
}

local sword: BundleItem = {
	["Id"] = nil,
	["Name"] = "Nordic Warrior Axe",
	["Rarity"] = "Epic",
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordSculptedAxe,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.LONG_AXE_IDLE,
		["Sprint"] = RobloxAnimation.LONG_AXE_RUN,
		["Melee"] = { RobloxAnimation.LONG_AXE_SLASH },
	},
}

NordicWarriorBundle.Sword = sword
NordicWarriorBundle.Bow = {
	["Id"] = nil,
	["Name"] = "Nordic Warrior Bow",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.BowSpear,
}
NordicWarriorBundle.Pickaxe = {
	["Id"] = nil,
	["Name"] = "Nordic Warrior Pickaxe",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.PickaxeMystic,
}

return {
	["NordicWarriorBundle"] = NordicWarriorBundle,
}
