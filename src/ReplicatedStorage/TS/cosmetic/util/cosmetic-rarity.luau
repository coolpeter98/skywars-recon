-- CosmeticRarity

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound

type CosmeticRarity = {
	Id: string,
	Rarity: number,
	Color: Color3,
	Sound: string,
}

local cosmeticRarities: { [string]: CosmeticRarity } = {}
for _, rarity: CosmeticRarity in
	{
		{
			["Id"] = "Common",
			["Color"] = nil,
			["Rarity"] = 1,
			["Sound"] = nil,
			["Color"] = Color.Rarity.Grey,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_01,
		},
		{
			["Id"] = "Uncommon",
			["Color"] = nil,
			["Rarity"] = 2,
			["Sound"] = nil,
			["Color"] = Color.Green,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_02,
		},
		{
			["Id"] = "Rare",
			["Color"] = nil,
			["Rarity"] = 3,
			["Sound"] = nil,
			["Color"] = Color.Rarity.Blue,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_03,
		},
		{
			["Id"] = "Epic",
			["Color"] = nil,
			["Rarity"] = 4,
			["Sound"] = nil,
			["Color"] = Color.Rarity.Purple,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_04,
		},
		{
			["Id"] = "Legendary",
			["Color"] = nil,
			["Rarity"] = 5,
			["Sound"] = nil,
			["Color"] = Color.Rarity.Gold,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_05,
		},
		{
			["Id"] = "Mythical",
			["Color"] = nil,
			["Rarity"] = 6,
			["Sound"] = nil,
			["Color"] = Color.Rarity.Red,
			["Sound"] = RobloxSound.Crate.CRATE_OPENED_LOOP_06,
		},
	}
do
	cosmeticRarities[rarity.Id] = rarity
end
return {
	["CosmeticRarities"] = cosmeticRarities,
}
