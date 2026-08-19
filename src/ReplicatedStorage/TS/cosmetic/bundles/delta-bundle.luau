-- DeltaBundle

local CosmeticId = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local DeltaBundle = {
	["BundleId"] = "Delta",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Cage"] = nil,
	["Packages"] = {
		{
			["Id"] = nil,
			["Name"] = "Delta Armour",
			["Description"] = "Transform into a futuristic warrior with this cosmetic armour set and become a champion of the cosmos!",
			["Rarity"] = "Mythical",
			["PackageType"] = "Armour",
			["Id"] = CosmeticId.PackageRonin
		}
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Delta Helmet",
		["Rarity"] = "Mythical",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.HelmetDelta
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Delta Chestplate",
		["Rarity"] = "Mythical",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.ChestplateDelta
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Delta Leggings",
		["Rarity"] = "Mythical",
		["LegacyAttachments"] = true,
		["Id"] = CosmeticId.LeggingsDelta
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Delta\'s Saber",
		["Description"] = "Use Delta\'s Saber to slash your way to victory!",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.SwordRonin
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Delta\'s Trawler",
		["Description"] = "Hover above the skies and prepare for battle in this intergalactic spacecraft!",
		["Rarity"] = "Mythical",
		["Id"] = CosmeticId.CageRonin
	}
}
return {
	["DeltaBundle"] = DeltaBundle
}
