-- CosmeticCapes

local CosmeticId: { [string]: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId

type CosmeticCape = {
	Id: string,
	Name: string,
	Rarity: string,
	Type: string,
}

return {
	CosmeticCapes = {
		{
			Name = "Level 10 Cape",
			Rarity = "Uncommon",
			Type = "Cape",
			Id = CosmeticId.CapeLevelTen,
		},
		{
			Name = "Level 20 Cape",
			Rarity = "Rare",
			Type = "Cape",
			Id = CosmeticId.CapeLevelTwenty,
		},
		{
			Name = "Level 30 Cape",
			Rarity = "Epic",
			Type = "Cape",
			Id = CosmeticId.CapeLevelThirty,
		},
		{
			Name = "Level 40 Cape",
			Rarity = "Legendary",
			Type = "Cape",
			Id = CosmeticId.CapeLevelForty,
		},
		{
			Name = "Level 50 Cape",
			Rarity = "Mythical",
			Type = "Cape",
			Id = CosmeticId.CapeLevelFifty,
		},
	},
}
