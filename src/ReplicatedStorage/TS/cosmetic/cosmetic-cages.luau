-- CosmeticCages

type CosmeticDefinition = {
	Id: string?,
	Name: string,
	Description: string?,
	Rarity: string,
	Type: string,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticCages: { CosmeticDefinition } = {
	{
		["Id"] = nil,
		["Name"] = "Glass Cage",
		["Rarity"] = "Rare",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageGlass,
	},
	{
		["Id"] = nil,
		["Name"] = "UFO Cage",
		["Rarity"] = "Mythical",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageUfo,
	},
	{
		["Id"] = nil,
		["Name"] = "Balloon Cage",
		["Rarity"] = "Uncommon",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageBalloon,
	},
	{
		["Id"] = nil,
		["Name"] = "Bird Cage",
		["Description"] = "Tweet tweet! Plan your victory in the skies with your feathered friends!",
		["Rarity"] = "Epic",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageBird,
	},
	{
		["Id"] = nil,
		["Name"] = "Magic Carpet",
		["Description"] = "Discover a whole new world on this magic carpet ride!",
		["Rarity"] = "Uncommon",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageCarpet,
	},
	{
		["Id"] = nil,
		["Name"] = "The Clouds",
		["Description"] = "Relax with your head in the clouds while you float above the starting islands!",
		["Rarity"] = "Common",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageClouds,
	},
	{
		["Id"] = nil,
		["Name"] = "Capybara Ascension",
		["Description"] = "Pull up to the SkyWars island with your capybara companions!",
		["Rarity"] = "Legendary",
		["Type"] = "Cage",
		["Id"] = CosmeticId.CageCapybara,
	},
	{
		["Id"] = nil,
		["Name"] = "Claw Machine Cage",
		["Rarity"] = "Epic",
		["Type"] = "Cage",
		["Description"] = "Begin your match in a playful fashion",
		["Id"] = CosmeticId.CageClawMachine,
	},
	{
		["Id"] = nil,
		["Name"] = "Cookie Jar Cage",
		["Rarity"] = "Uncommon",
		["Type"] = "Cage",
		["Description"] = "A whimsical cage shaped like a delightful cookie jar",
		["Id"] = CosmeticId.CageCookieJar,
	},
	{
		["Id"] = nil,
		["Name"] = "Mini Tank Cage",
		["Rarity"] = "Rare",
		["Type"] = "Cage",
		["Description"] = "Begin your match inside a compact and powerful tank-inspired cage",
		["Id"] = CosmeticId.CageMiniTank,
	},
	{
		["Id"] = nil,
		["Name"] = "Soup Pot Cage",
		["Rarity"] = "Uncommon",
		["Type"] = "Cage",
		["Description"] = "Start every match in a boiling cauldron of soup, adding a touch of culinary creativity to your match",
		["Id"] = CosmeticId.CageSoupPot,
	},
}

return {
	["CosmeticCages"] = CosmeticCages,
}
