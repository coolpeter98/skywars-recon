-- JuggernautBundle

type BundleItem = {
	Id: string?,
	Name: string,
	Rarity: string,
	Description: string?,
	PackageType: string?,
}

type JuggernautBundle = {
	BundleId: string,
	Packages: { BundleItem }?,
	Helmet: BundleItem?,
	Chestplate: BundleItem?,
	Leggings: BundleItem?,
	Sword: BundleItem?,
	Bow: BundleItem?,
	Cage: BundleItem?,
}

local CosmeticId: {
	PackageJuggernaut: string,
	HelmetJuggernaut: string,
	ChestplateJuggernaut: string,
	LeggingsJuggernaut: string,
	SwordJuggernaut: string,
	BowJuggernaut: string,
	CageJuggernaut: string,
} =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"cosmetic",
		"cosmetic-id"
	).CosmeticId
local JuggernautBundle: JuggernautBundle = {
	["BundleId"] = "Juggernaut",
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
			["Name"] = "Juggernaut Armour",
			["Rarity"] = "Epic",
			["PackageType"] = "Armour",
			["Description"] = "Arm yourself with epic armor, exuding power and invincibility, turning you into an unstoppable force to be reckoned with",
			["Id"] = CosmeticId.PackageJuggernaut,
		},
	},
	["Helmet"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Helmet",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.HelmetJuggernaut,
	},
	["Chestplate"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Chestplate",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.ChestplateJuggernaut,
	},
	["Leggings"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Leggings",
		["Rarity"] = "Epic",
		["Id"] = CosmeticId.LeggingsJuggernaut,
	},
	["Sword"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Sword",
		["Rarity"] = "Epic",
		["Description"] = "Embrace unstoppable might with this epic sword, empowering you to crush your enemies with unrelenting force",
		["Id"] = CosmeticId.SwordJuggernaut,
	},
	["Bow"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Bow",
		["Rarity"] = "Epic",
		["Description"] = " Fire devastating arrows with immense force using this epic bow, establishing your dominance on the battlefield",
		["Id"] = CosmeticId.BowJuggernaut,
	},
	["Cage"] = {
		["Id"] = nil,
		["Name"] = "Juggernaut Cage",
		["Rarity"] = "Epic",
		["Description"] = "Begin your match in the cage of a Juggernaut, exuding strength!",
		["Id"] = CosmeticId.CageJuggernaut,
	},
}
return {
	["JuggernautBundle"] = JuggernautBundle,
}
