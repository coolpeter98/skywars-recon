-- SeasonPass

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")

type SeasonPassReward = {
	Type: string,
	Quantity: number?,
	CosmeticId: string?,
	Premium: boolean,
	Tier: number?
}

local Season: { [string]: string } = {
	["ONE"] = "ONE",
	["TWO"] = "TWO",
	["THREE"] = "THREE",
	["THREE_2"] = "THREE_2"
}
local CurrentSeason: string = Season.THREE_2
local tierIndex = 0
local SeasonPassRewards: { [number]: SeasonPassReward } = {}
for _, rewardData: SeasonPassReward in {
	{
		["Type"] = "Gems",
		["Quantity"] = 150,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.SwordConstructionHammer
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.BowGem
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.ArrowTrailEmerald
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.PickaxeRocketDrill
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.KillEffectSlimeCube
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 150,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordWavyDagger
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.PickaxeBreach
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleSharkBoy
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 200,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.LeggingsSharkSuit
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.ChestplateSharkSuit
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.HelmetSharkSuit
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 200,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.BowSteampunk
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.ArrowTrailFirework
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleScavenger
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.PickaxeMech
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.KillEffectTornado
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 200,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.HelmetColaHat
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.SwordRazorBaton
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 250,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleMayanWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordMayanSpear
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 250,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.LeggingsMayanWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.ChestplateMayanWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.HelmetMayanWarrior
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 250,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.PickaxeBooster
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.BowPhoenix
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleShapeshifter
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 250,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.ArrowTrailCloud
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordForestBlade
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 250,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.KillEffectUfo
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleNordicWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordSculptedAxe
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.BowSpear
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.PickaxeMystic
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.LeggingsNordicWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.ChestplateNordicWarrior
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.HelmetNordicWarrior
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.SwordMace
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.TitleAssassin
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.ArrowTrailEgg
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.PickaxeElectro
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.HelmetGasMask
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.KillEffectGateOfBabylon
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleDeathKnight
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordSkullAxe
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.PickaxeSkull
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 300,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.LeggingsDeathKnight
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.ChestplateDeathKnight
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.HelmetDeathKnight
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 500,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 550,
		["Premium"] = false
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 600,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 650,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordRoyalBlade
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 750,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 800,
		["Premium"] = false
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 850,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 900,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.PickaxeLight
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1000,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1050,
		["Premium"] = false
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1100,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1150,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = true,
		["CosmeticId"] = CosmeticId.SwordBruteSawblade
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1250,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1300,
		["Premium"] = false
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1350,
		["Premium"] = true
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 1400,
		["Premium"] = false
	},
	{
		["Type"] = "Cosmetic",
		["CosmeticId"] = nil,
		["Premium"] = false,
		["CosmeticId"] = CosmeticId.TitleCompletionistSeasonThree
	},
	{
		["Type"] = "Gems",
		["Quantity"] = 10000,
		["Premium"] = true
	}
} do
	local reward: SeasonPassReward = table.clone(rewardData)
	setmetatable(reward, nil)
	reward.Tier = tierIndex
	SeasonPassRewards[tierIndex] = reward
	tierIndex = tierIndex + 1
end
local SortedSeasonPassRewards: { SeasonPassReward } = ObjectUtils.values(SeasonPassRewards)
table.sort(SortedSeasonPassRewards, function(left: SeasonPassReward, right: SeasonPassReward)
	return left.Tier < right.Tier
end)
return {
	["Season"] = nil,
	["CurrentSeason"] = nil,
	["CurrentSeasonNumber"] = 3,
	["SeasonPassRewards"] = nil,
	["SortedSeasonPassRewards"] = nil,
	["Season"] = Season,
	["CurrentSeason"] = CurrentSeason,
	["SeasonPassRewards"] = SeasonPassRewards,
	["SortedSeasonPassRewards"] = SortedSeasonPassRewards
}
