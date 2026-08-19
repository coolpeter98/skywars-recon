-- CosmeticBows

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ItemGroup: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
return {
	["CosmeticBows"] = {
		{
			["Id"] = nil,
			["Name"] = "Bone Bow",
			["Description"] = "Send shivers down the spines of your enemies with this bone rattling bow!",
			["Rarity"] = "Common",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowBone,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Gold Bow",
			["Description"] = "Battle in luxury with this magnificent golden bow!",
			["Rarity"] = "Epic",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowGold,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Tactical Bow",
			["Rarity"] = "Legendary",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Description"] = "Engage in precise and strategic long-range combat with this epic bow, designed for calculated strikes and deadly accuracy",
			["Id"] = CosmeticId.BowTactical,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Glass Bow",
			["Rarity"] = "Rare",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Description"] = "A rare and delicate bow crafted from translucent glass, combining fragility and deadly accuracy in your archery skills",
			["Id"] = CosmeticId.BowGlass,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Royal Bow",
			["Rarity"] = "Common",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Description"] = "A simple yet elegant bow fit for nobility, perfect for unleashing precise shots on the battlefield",
			["Id"] = CosmeticId.BowRoyal,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Purple Tactical Bow",
			["Rarity"] = "Rare",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowPurpleTactical,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Gem Bow",
			["Rarity"] = "Common",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowGem,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Steampunk Bow",
			["Rarity"] = "Rare",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowSteampunk,
			["ItemGroup"] = ItemGroup.Bow,
		},
		{
			["Id"] = nil,
			["Name"] = "Phoenix Bow",
			["Rarity"] = "Epic",
			["Type"] = "Skin",
			["ItemGroup"] = nil,
			["Id"] = CosmeticId.BowPhoenix,
			["ItemGroup"] = ItemGroup.Bow,
		},
	},
}
