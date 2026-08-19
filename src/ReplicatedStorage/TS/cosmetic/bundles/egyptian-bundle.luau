-- EgyptianBundle

local CosmeticId = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local EgyptianBundle = {
	["BundleId"] = "Egyptian",
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
			["Name"] = "Egyptian Armour",
			["Rarity"] = "Rare",
			["PackageType"] = "Armour",
			["Description"] = "Equip yourself with this rare armor inspired by the splendor of ancient Egypt, providing protection and an aura of regal might",
			["Id"] = CosmeticId.PackageEgyptian,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Egyptian Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetEgyptian,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Egyptian Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateEgyptian,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Egyptian Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsEgyptian,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Khopesh",
		["Rarity"] = "Rare",
		["Description"] = "Embrace the legacy of ancient Egypt with this rare curved sword, honoring the warriors of the past in your battles of the present",
		["Id"] = CosmeticId.SwordEgyptian,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Egyptian Bow",
		["Rarity"] = "Rare",
		["Description"] = "A bow adorned with intricate Egyptian motifs, channeling the power of the pharaohs and delivering precise shots to your enemies",
		["Id"] = CosmeticId.BowEgyptian,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Egyptian Carriage Cage",
		["Rarity"] = "Rare",
		["Description"] = "An impressive cage designed as a majestic Egyptian carriage",
		["Id"] = CosmeticId.CageEgyptian,
	},
}
return {
	["EgyptianBundle"] = EgyptianBundle,
}
