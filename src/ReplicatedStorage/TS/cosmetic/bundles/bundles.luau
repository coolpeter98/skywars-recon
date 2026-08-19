-- bundles

type Bundle = {
	BundleId: string,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local SamuraiBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"samurai-bundle"
).SamuraiBundle
local SpartanBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"spartan-bundle"
).SpartanBundle
local VikingBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"viking-bundle"
).VikingBundle
local DeltaBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"delta-bundle"
).DeltaBundle
local AzazelBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"azazel-bundle"
).AzazelBundle
local VurrenBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"vurren-bundle"
).VurrenBundle
local DwarvenBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"dwarven-bundle"
).DwarvenBundle
local EgyptianBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"egyptian-bundle"
).EgyptianBundle
local JuggernautBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"juggernaut-bundle"
).JuggernautBundle
local ShogunBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"shogun-bundle"
).ShogunBundle
local SpacemanBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"spaceman-bundle"
).SpacemanBundle
local SeaKingBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"sea-king-bundle"
).SeaKingBundle
local CrusaderBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"crusader-bundle"
).CrusaderBundle
local RomanBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"roman-bundle"
).RomanBundle
local ArabianKnightBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"arabian-knight-bundle"
).ArabianKnightBundle
local NinjaBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"ninja-bundle"
).NinjaBundle
local KnightBruteBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"knight-brute-bundle"
).KnightBruteBundle
local PirateBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"pirate-bundle"
).PirateBundle
local PlasmaTitanBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"plasma-titan-bundle"
).PlasmaTitanBundle
local NordicWarriorBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"nordic-warrior-bundle"
).NordicWarriorBundle
local DeathKnightBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"death-knight-bundle"
).DeathKnightBundle
local MayanWarriorBundle = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"mayan-warrior-bundle"
).MayanWarriorBundle

local bundles: { [string]: Bundle } = {}
for _, bundle in
	{
		SamuraiBundle,
		SpartanBundle,
		VikingBundle,
		DeltaBundle,
		AzazelBundle,
		VurrenBundle,
		DwarvenBundle,
		EgyptianBundle,
		JuggernautBundle,
		ShogunBundle,
		SpacemanBundle,
		SeaKingBundle,
		CrusaderBundle,
		RomanBundle,
		ArabianKnightBundle,
		NinjaBundle,
		KnightBruteBundle,
		PirateBundle,
		PlasmaTitanBundle,
		NordicWarriorBundle,
		MayanWarriorBundle,
		DeathKnightBundle,
	}
do
	if bundle then
		bundles[bundle.BundleId] = bundle
	end
end
return {
	["Bundles"] = bundles,
}
