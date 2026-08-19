-- PlasmaTitanBundle

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
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
type BundleData = {
	BundleId: string,
	Image: any,
	Packages: { { Id: string, Rarity: string, PackageType: string } },
	Helmet: { Id: string, Rarity: string },
	Chestplate: { Id: string, Rarity: string },
	Leggings: { Id: string, Rarity: string },
	Sword: {
		Id: string,
		Name: string,
		Rarity: string,
		DualWield: boolean,
		ItemAnimation: { Idle: any, Melee: { any } },
	},
	Bow: {
		Id: string,
		Rarity: string,
		ItemAnimation: { Idle: any, Tool: any },
		ProjectileAnimation: {
			DrawAnimation: any,
			FireAnimation: any,
			DrawAnimationTool: any,
			FireAnimationTool: any,
		},
		ProjectileRef: Instance,
	},
	Cage: {
		Id: string,
		Rarity: string,
		Display: { CageOffset: CFrame, CageScale: number, CharacterOffset: CFrame },
	},
}

local PlasmaTitanBundle: BundleData = {
	["BundleId"] = "PlasmaTitan",
	["Image"] = nil,
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Bow"] = nil,
	["Image"] = RobloxImage.GameProduct.PLASMA_TITAN_RENDER_16_9,
	["Packages"] = {
		{
			["Id"] = nil,
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackagePlasmaTitan,
		},
		{
			["Id"] = nil,
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponPlasmaTitan,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetPlasmaTitan,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplatePlasmaTitan,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsPlasmaTitan,
	},
}
local sword = {
	["Id"] = nil,
	["Name"] = "Plasma Titan Blades",
	["Rarity"] = "Epic",
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordPlasmaTitan,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.PLASMA_BLADES_IDLE,
		["Melee"] = { RobloxAnimation.SPACEMAN_DUAL_SLASH },
	},
}
PlasmaTitanBundle.Sword = sword
local bow = {
	["Id"] = nil,
	["Rarity"] = "Epic",
	["ItemAnimation"] = nil,
	["ProjectileAnimation"] = nil,
	["ProjectileRef"] = nil,
	["Id"] = CosmeticId.BowPlasmaTitan,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.POWER_BOW_IDLE,
		["Tool"] = RobloxAnimation.POWER_BOW_TOOL_IDLE,
	},
	["ProjectileAnimation"] = {
		["DrawAnimation"] = RobloxAnimation.POWER_BOW_CHARACTER_DRAW,
		["FireAnimation"] = RobloxAnimation.POWER_BOW_CHARACTER_FIRE,
		["DrawAnimationTool"] = RobloxAnimation.POWER_BOW_TOOL_DRAW,
		["FireAnimationTool"] = RobloxAnimation.POWER_BOW_TOOL_FIRE,
	},
	["ProjectileRef"] = ReplicatedStorage.Projectiles.PlasmaArrow,
}
PlasmaTitanBundle.Bow = bow
local cage = {
	["Id"] = nil,
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.CagePlasmaTitan,
	["Display"] = {
		["CageOffset"] = CFrame.new(1.5, 0, 1.5) * CFrame.Angles(0, -1.1780972450961724, 0),
		["CageScale"] = 1.5,
		["CharacterOffset"] = CFrame.new(-1.5, 0, -7.5),
	},
}
PlasmaTitanBundle.Cage = cage
return {
	["PlasmaTitanBundle"] = PlasmaTitanBundle,
}
