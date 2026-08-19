-- DwarvenBundle

local RuntimeLib: { import: (script: Instance, parent: Instance, ...string) -> any } =
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
local DwarvenBundle = {
	["BundleId"] = "Dwarven",
	["Description"] = "Gear up and embrace the might of the mountains. Stand strong and showcase your warrior spirit!",
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
	).RobloxImage.GameProduct.DWARVEN_RENDER_16_9,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Dwarven Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageDwarven,
		},
		{
			["Id"] = nil,
			["Name"] = "Dwarven Weapons",
			["Rarity"] = "Epic",
			["PackageType"] = "Weapons",
			["Id"] = CosmeticId.PackageWeaponDwarven,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Dwarven Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetDwarven,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Dwarven Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateDwarven,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Dwarven Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsDwarven,
	},
}
local DwarvenSword = {
	["Id"] = nil,
	["Name"] = "Dwarven Long Hammer",
	["Rarity"] = "Epic",
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordDwarven,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.LONG_AXE_IDLE,
		["Sprint"] = RobloxAnimation.LONG_AXE_RUN,
		["Melee"] = { RobloxAnimation.LONG_AXE_SLASH },
	},
}
DwarvenBundle.Sword = DwarvenSword
DwarvenBundle.Bow = {
	["Id"] = nil,
	["Name"] = "Dwarven Bow",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.BowDwarven,
}
local DwarvenCage = {
	["Id"] = nil,
	["Name"] = "Dwarven Statue",
	["Rarity"] = "Epic",
	["Id"] = CosmeticId.CageDwarven,
	["Display"] = {
		["CageOffset"] = CFrame.new(0, -0.5, 1.5),
		["CharacterOffset"] = CFrame.new(6, 0, -7.5) * CFrame.Angles(0, 0.39269908169872414, 0),
	},
}
DwarvenBundle.Cage = DwarvenCage
return {
	["DwarvenBundle"] = DwarvenBundle,
}
