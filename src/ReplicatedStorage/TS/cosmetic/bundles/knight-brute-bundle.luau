-- KnightBruteBundle

local CosmeticId: { [string]: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local KnightBruteBundle = {
	["BundleId"] = "KnightBrute",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Packages"] = {},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Knight Brute Helmet",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.HelmetKnightBrute,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Knight Brute Chestplate",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.ChestplateKnightBrute,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Knight Brute Leggings",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.LeggingsKnightBrute,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Light Sword",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.SwordLight,
	},
}
return {
	["KnightBruteBundle"] = KnightBruteBundle,
}
