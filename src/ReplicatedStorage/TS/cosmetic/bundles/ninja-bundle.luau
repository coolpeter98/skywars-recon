-- NinjaBundle

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId: { [string]: string } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local RobloxAnimation: { [string]: string } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local NinjaBundle = {
	["BundleId"] = "Ninja",
	["Packages"] = nil,
	["Helmet"] = nil,
	["Chestplate"] = nil,
	["Leggings"] = nil,
	["Sword"] = nil,
	["Packages"] = {},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Ninja Helmet",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.HelmetNinja
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Ninja Chestplate",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.ChestplateNinja
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Ninja Leggings",
		["Rarity"] = "Legendary",
		["Id"] = CosmeticId.LeggingsNinja
	}
}
local twinblade = {
	["Id"] = nil,
	["Name"] = "Twinblade",
	["Rarity"] = "Mythical",
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordTwinblade,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.TWINBLADE_IDLE,
		["Sprint"] = RobloxAnimation.TWINBLADE_SPRINT,
		["Melee"] = { RobloxAnimation.TWINBLADE_MELEE }
	}
}
NinjaBundle.Sword = twinblade
return {
	["NinjaBundle"] = NinjaBundle
}
