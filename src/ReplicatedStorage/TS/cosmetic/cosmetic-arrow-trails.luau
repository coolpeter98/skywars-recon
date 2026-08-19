-- CosmeticArrowTrails

type CosmeticId = {
	ArrowTrailWhite: string,
	ArrowTrailRainbow: string,
	ArrowTrailSpiral: string,
	ArrowTrailFire: string,
	ArrowTrailIce: string,
	ArrowTrailLightning: string,
	ArrowTrailVoid: string,
	ArrowTrailGold: string,
	ArrowTrailCapybara: string,
	ArrowTrailEmerald: string,
	ArrowTrailFirework: string,
	ArrowTrailCloud: string,
	ArrowTrailEgg: string,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

local CosmeticId: CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
return {
	["CosmeticArrowTrails"] = {
		{
			["Id"] = nil,
			["Name"] = "White Arrow",
			["Rarity"] = "Common",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailWhite,
		},
		{
			["Id"] = nil,
			["Name"] = "Rainbow Arrow",
			["Description"] = "Follow this arrow to a pot of gold!",
			["Rarity"] = "Epic",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailRainbow,
		},
		{
			["Id"] = nil,
			["Name"] = "Spiral Arrow",
			["Description"] = "This arrow is making me dizzy...",
			["Rarity"] = "Uncommon",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailSpiral,
		},
		{
			["Id"] = nil,
			["Name"] = "Fire Arrow",
			["Description"] = "This arrow is hot!",
			["Rarity"] = "Rare",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailFire,
		},
		{
			["Id"] = nil,
			["Name"] = "Ice Arrow",
			["Description"] = "Unleash icy magic upon your enemies with epic arrows, freezing them in their tracks with a chilling touch",
			["Rarity"] = "Epic",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailIce,
		},
		{
			["Id"] = nil,
			["Name"] = "Lightning Arrow",
			["Description"] = "Arrows crackling with electrifying power, striking down your enemies with the unstoppable force of lightning",
			["Rarity"] = "Legendary",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailLightning,
		},
		{
			["Id"] = nil,
			["Name"] = "Void Arrow",
			["Description"] = "Arrows infused with the power of the void, striking fear into the hearts of your foes with their otherworldly energy",
			["Rarity"] = "Rare",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailVoid,
		},
		{
			["Id"] = nil,
			["Name"] = "Gold Arrow",
			["Description"] = "Arrows crafted from shimmering gold material, radiating opulence and precision in every shot",
			["Rarity"] = "Uncommon",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailGold,
		},
		{
			["Id"] = nil,
			["Name"] = "Capybara Arrow",
			["Description"] = "Quirky arrows adorned with adorable capybara designs, bringing a touch of cuteness to your archery skills",
			["Rarity"] = "Common",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailCapybara,
		},
		{
			["Id"] = nil,
			["Name"] = "Emerald Arrow",
			["Rarity"] = "Common",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailEmerald,
		},
		{
			["Id"] = nil,
			["Name"] = "Firework Arrow",
			["Rarity"] = "Rare",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailFirework,
		},
		{
			["Id"] = nil,
			["Name"] = "Cloud Arrow",
			["Rarity"] = "Epic",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailCloud,
		},
		{
			["Id"] = nil,
			["Name"] = "Egg Arrow",
			["Rarity"] = "Legendary",
			["Type"] = "ArrowTrailEffect",
			["Id"] = CosmeticId.ArrowTrailEgg,
		},
	},
}
