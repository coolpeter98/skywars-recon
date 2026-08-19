-- PirateBundle

local CosmeticId = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

export type BundlePiece = {
	Id: string,
	Name: string,
	Rarity: string,
}

export type CosmeticBundle = {
	BundleId: string,
	Packages: { any },
	Helmet: BundlePiece?,
	Chestplate: BundlePiece?,
	Leggings: BundlePiece?,
	Sword: BundlePiece?,
}

local PirateBundle: CosmeticBundle = {
	["BundleId"] = "Pirate",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Packages"] = {},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Pirate Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetPirate
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Pirate Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplatePirate
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Pirate Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsPirate
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Pirate\'s Cutlass",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.SwordPirateCutlass
	}
}

return {
	["PirateBundle"] = PirateBundle
}
