-- Cosmetics

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticKillEffects = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"cosmetic-kill-effects"
).CosmeticKillEffects
local CosmeticArmour =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-armour").CosmeticArmour
local CosmeticArrowTrails = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"cosmetic-arrow-trails"
).CosmeticArrowTrails
local CosmeticBows =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-bows").CosmeticBows
local CosmeticCages =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-cages").CosmeticCages
local CosmeticCapes =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-capes").CosmeticCapes
local CosmeticPackages = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"cosmetic-packages"
).CosmeticPackages
local CosmeticPickaxes = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"cosmetic-pickaxes"
).CosmeticPickaxes
local CosmeticSwords =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-swords").CosmeticSwords
local CosmeticTitles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-titles").CosmeticTitles
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticMisc =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-misc").CosmeticMisc
local SeasonPassRewards =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").SeasonPassRewards

type Cosmetic = {
	Id: string,
	Name: string,
	Rarity: string,
	Type: string,
}

local migratedCosmetics: { string } = {
	CosmeticId.SwordSupporter,
	CosmeticId.SwordKatana,
	CosmeticId.HelmetSamurai,
	CosmeticId.ChestplateSamurai,
	CosmeticId.LeggingsSamurai,
}
local allCosmetics: { Cosmetic } = {
	{
		["Id"] = nil,
		["Name"] = "Podium Win Effect",
		["Rarity"] = "Epic",
		["Type"] = "WinEffect",
		["Id"] = CosmeticId.WinEffectPodium,
	},
}
local initialCount = #allCosmetics
local armourCount = #CosmeticArmour
table.move(CosmeticArmour, 1, armourCount, initialCount + 1, allCosmetics)
local countAfterArmour = initialCount + armourCount
local arrowTrailsCount = #CosmeticArrowTrails
table.move(CosmeticArrowTrails, 1, arrowTrailsCount, countAfterArmour + 1, allCosmetics)
local countAfterArrowTrails = countAfterArmour + arrowTrailsCount
local bowsCount = #CosmeticBows
table.move(CosmeticBows, 1, bowsCount, countAfterArrowTrails + 1, allCosmetics)
local countAfterBows = countAfterArrowTrails + bowsCount
local cagesCount = #CosmeticCages
table.move(CosmeticCages, 1, cagesCount, countAfterBows + 1, allCosmetics)
local countAfterCages = countAfterBows + cagesCount
local capesCount = #CosmeticCapes
table.move(CosmeticCapes, 1, capesCount, countAfterCages + 1, allCosmetics)
local countAfterCapes = countAfterCages + capesCount
local killEffectsCount = #CosmeticKillEffects
table.move(CosmeticKillEffects, 1, killEffectsCount, countAfterCapes + 1, allCosmetics)
local countAfterKillEffects = countAfterCapes + killEffectsCount
local miscCount = #CosmeticMisc
table.move(CosmeticMisc, 1, miscCount, countAfterKillEffects + 1, allCosmetics)
local countAfterMisc = countAfterKillEffects + miscCount
local packagesCount = #CosmeticPackages
table.move(CosmeticPackages, 1, packagesCount, countAfterMisc + 1, allCosmetics)
local countAfterPackages = countAfterMisc + packagesCount
local pickaxesCount = #CosmeticPickaxes
table.move(CosmeticPickaxes, 1, pickaxesCount, countAfterPackages + 1, allCosmetics)
local countAfterPickaxes = countAfterPackages + pickaxesCount
local swordsCount = #CosmeticSwords
table.move(CosmeticSwords, 1, swordsCount, countAfterPickaxes + 1, allCosmetics)
local countAfterSwords = countAfterPickaxes + swordsCount
table.move(CosmeticTitles, 1, #CosmeticTitles, countAfterSwords + 1, allCosmetics)

local cosmeticsById: { [string]: Cosmetic } = {}
local cosmeticsByType: { [string]: { Cosmetic } } = {}
for _, cosmetic: Cosmetic in allCosmetics do
	cosmeticsById[cosmetic.Id] = cosmetic
	if cosmeticsByType[cosmetic.Type] == nil then
		cosmeticsByType[cosmetic.Type] = {}
	end
	local cosmeticsOfType = cosmeticsByType[cosmetic.Type]
	table.insert(cosmeticsOfType, cosmetic)
end
for _, reward in SeasonPassRewards do
	if reward.Type == "Cosmetic" and cosmeticsById[reward.CosmeticId] == nil then
		print((("Missing CosmeticId %*"):format(reward.CosmeticId)))
	end
end
return {
	["MigratedCosmetics"] = migratedCosmetics,
	["Cosmetics"] = cosmeticsById,
	["CosmeticsByType"] = cosmeticsByType,
}
