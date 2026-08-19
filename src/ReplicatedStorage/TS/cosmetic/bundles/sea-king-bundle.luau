-- SeaKingBundle

local CosmeticId: { [string]: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local SeaKingBundle = {
	["BundleId"] = "SeaKing",
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
			["Name"] = "Sea King Armour",
			["Rarity"] = "Mythical",
			["PackageType"] = "Armour",
			["Description"] = "Embody the regal might of the mythical Sea King with this armor, conquering the seas and the battlefield",
			["Id"] = CosmeticId.PackageSeaKing,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Sea King Helmet",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.HelmetSeaKing,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Sea King Chestplate",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.ChestplateSeaKing,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Sea King Leggings",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.LeggingsSeaKing,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Trident",
		["Rarity"] = "Mythical",
		["Description"] = "A mythical weapon associated with the seas, wield the mighty Trident and command the depths with unrivaled authority",
		["Id"] = CosmeticId.SwordSeaKing,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Sea King Bow",
		["Rarity"] = "Mythical",
		["Description"] = "Draw power from the ocean depths with this mythical bow, unleashing the fury of the sea in every shot",
		["Id"] = CosmeticId.BowSeaKing,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Sea King Cage",
		["Rarity"] = "Mythical",
		["Description"] = "Exude your prowess as a Sea King at the match start",
		["Id"] = CosmeticId.CageSeaKing,
	},
}
return {
	["SeaKingBundle"] = SeaKingBundle,
}
