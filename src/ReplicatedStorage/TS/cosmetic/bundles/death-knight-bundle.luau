-- DeathKnightBundle

local CosmeticId = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local DeathKnightBundle = {
	["BundleId"] = "DeathKnight",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Pickaxe"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Death Knight Armour",
			["Rarity"] = "Mythical",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageDeathKnight,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Death Knight Helmet",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.HelmetDeathKnight,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Death Knight Chestplate",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.ChestplateDeathKnight,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Death Knight Leggings",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.LeggingsDeathKnight,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Death Knight Axe",
		["Rarity"] = "Mythical",
		["ItemAnimation"] = nil,
		["Id"] = CosmeticId.SwordSkullAxe,
		["ItemAnimation"] = {},
	},
	["Pickaxe"] = {
		["Id"] = nil,
		["Name"] = "Death Knight Pickaxe",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.PickaxeSkull,
	},
}
return {
	["DeathKnightBundle"] = DeathKnightBundle,
}
