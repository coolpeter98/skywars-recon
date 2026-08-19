-- GameProduct

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Season = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").Season
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local ProductConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "product-constants").ProductConstants
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage

export type RegionalPricing = {
	Percentage: number,
	DeveloperProductId: number?,
}

export type GameProduct = {
	ProductId: number,
	GamepassId: number?,
	DeveloperProductId: number?,
	DisplayName: string,
	PriceInRobux: number?,
	PriceInGems: number?,
	OneTimePurchase: boolean,
	Bundle: { any }?,
	BundleId: string?,
	SeasonPass: any?,
	SeasonPassExperience: number?,
	PrimedCosmeticType: string?,
	RegionalPricing: { RegionalPricing }?,
	Gambling: boolean?,
	Crate: { Id: string, Quantity: number }?,
	GemsReward: number?,
	Image: string?,
	Description: string?,
}

local ProductId: { [string]: string } = {
	["EARLY_SUPPORTER"] = "EARLY_SUPPORTER",
	["SAMURAI"] = "SAMURAI",
	["SEASON_ONE_PASS"] = "SEASON_ONE_PASS",
	["SEASON_TWO_PASS"] = "SEASON_TWO_PASS",
	["SEASON_TWO_PASS_BUNDLE"] = "SEASON_TWO_PASS_BUNDLE",
	["SEASON_THREE_PASS"] = "SEASON_THREE_PASS",
	["SEASON_THREE_PASS_BUNDLE"] = "SEASON_THREE_PASS_BUNDLE",
	["AZAZEL"] = "AZAZEL",
	["VURREN"] = "VURREN",
	["SPACEMAN"] = "SPACEMAN",
	["DWARVEN"] = "DWARVEN",
	["CRUSADER"] = "CRUSADER",
	["ROMAN"] = "ROMAN",
	["ARABIAN_KNIGHT"] = "ARABIAN_KNIGHT",
	["PLASMA_TITAN_BUNDLE"] = "PLASMA_TITAN_BUNDLE",
	["CAGE_SINGLE"] = "CAGE_SINGLE",
	["ARMOUR_SINGLE"] = "ARMOUR_SINGLE",
	["WEAPONS_SINGLE"] = "WEAPONS_SINGLE",
	["FEATURED_COSMETIC_TIER_1"] = "FEATURED_COSMETIC_TIER_1",
	["FEATURED_COSMETIC_TIER_2"] = "FEATURED_COSMETIC_TIER_2",
	["FEATURED_COSMETIC_TIER_3"] = "FEATURED_COSMETIC_TIER_3",
	["KNIGHT_BRUTE_CRATE_1"] = "KNIGHT_BRUTE_CRATE_1",
	["KNIGHT_BRUTE_CRATE_3"] = "KNIGHT_BRUTE_CRATE_3",
	["KNIGHT_BRUTE_CRATE_5"] = "KNIGHT_BRUTE_CRATE_5",
	["KNIGHT_BRUTE_CRATE_10"] = "KNIGHT_BRUTE_CRATE_10",
	["NINJA_CRATE_1"] = "NINJA_CRATE_1",
	["NINJA_CRATE_3"] = "NINJA_CRATE_3",
	["NINJA_CRATE_5"] = "NINJA_CRATE_5",
	["NINJA_CRATE_10"] = "NINJA_CRATE_10",
	["GEMS_TIER_1"] = "GEMS_TIER_1",
	["GEMS_TIER_2"] = "GEMS_TIER_2",
	["GEMS_TIER_3"] = "GEMS_TIER_3",
	["GEMS_TIER_4"] = "GEMS_TIER_4",
	["GEMS_TIER_5"] = "GEMS_TIER_5",
	["GEMS_TIER_6"] = "GEMS_TIER_6"
}
local GamepassNames: { [number]: string } = {}
local Gamepass = setmetatable({}, {
	["__index"] = GamepassNames
})
Gamepass.EARLY_SUPPORTER = 28638054
GamepassNames[28638054] = "EARLY_SUPPORTER"
Gamepass.SAMURAI = 58170859
GamepassNames[58170859] = "SAMURAI"
Gamepass.SEASON_ONE_PASS = 77847060
GamepassNames[77847060] = "SEASON_ONE_PASS"
Gamepass.SEASON_TWO_PASS = 189184592
GamepassNames[189184592] = "SEASON_TWO_PASS"
Gamepass.SEASON_TWO_PASS_BUNDLE = 189196836
GamepassNames[189196836] = "SEASON_TWO_PASS_BUNDLE"
Gamepass.SEASON_THREE_PASS = 1197397827
GamepassNames[1197397827] = "SEASON_THREE_PASS"
Gamepass.SEASON_THREE_PASS_BUNDLE = 1198781862
GamepassNames[1198781862] = "SEASON_THREE_PASS_BUNDLE"
Gamepass.AZAZEL = 87047560
GamepassNames[87047560] = "AZAZEL"
Gamepass.VURREN = 89210528
GamepassNames[89210528] = "VURREN"
Gamepass.DWARVEN = 159760772
GamepassNames[159760772] = "DWARVEN"
Gamepass.SPACEMAN = 159760851
GamepassNames[159760851] = "SPACEMAN"
Gamepass.CRUSADER = 199223190
GamepassNames[199223190] = "CRUSADER"
Gamepass.ROMAN = 199223092
GamepassNames[199223092] = "ROMAN"
Gamepass.ARABIAN_KNIGHT = 199223322
GamepassNames[199223322] = "ARABIAN_KNIGHT"
Gamepass.PLASMA_TITAN_BUNDLE = 1089204958
GamepassNames[1089204958] = "PLASMA_TITAN_BUNDLE"
local DeveloperProductNames: { [number]: string } = {}
local DeveloperProduct = setmetatable({}, {
	["__index"] = DeveloperProductNames
})
DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_30 = 1885608303
DeveloperProductNames[1885608303] = "SEASON_TWO_PASS_DISCOUNT_30"
DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_50 = 1884753612
DeveloperProductNames[1884753612] = "SEASON_TWO_PASS_DISCOUNT_50"
DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_70 = 1884754397
DeveloperProductNames[1884754397] = "SEASON_TWO_PASS_DISCOUNT_70"
DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_30 = 1885608577
DeveloperProductNames[1885608577] = "SEASON_TWO_PASS_BUNDLE_DISCOUNT_30"
DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_50 = 1884755591
DeveloperProductNames[1884755591] = "SEASON_TWO_PASS_BUNDLE_DISCOUNT_50"
DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_70 = 1884755726
DeveloperProductNames[1884755726] = "SEASON_TWO_PASS_BUNDLE_DISCOUNT_70"
DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_30 = 3279388079
DeveloperProductNames[3279388079] = "SEASON_THREE_PASS_DISCOUNT_30"
DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_50 = 3279388321
DeveloperProductNames[3279388321] = "SEASON_THREE_PASS_DISCOUNT_50"
DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_70 = 3279388565
DeveloperProductNames[3279388565] = "SEASON_THREE_PASS_DISCOUNT_70"
DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_30 = 3279387330
DeveloperProductNames[3279387330] = "SEASON_THREE_PASS_BUNDLE_DISCOUNT_30"
DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_50 = 3279387574
DeveloperProductNames[3279387574] = "SEASON_THREE_PASS_BUNDLE_DISCOUNT_50"
DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_70 = 3279387863
DeveloperProductNames[3279387863] = "SEASON_THREE_PASS_BUNDLE_DISCOUNT_70"
DeveloperProduct.SPACEMAN_DISCOUNT_30 = 1885608796
DeveloperProductNames[1885608796] = "SPACEMAN_DISCOUNT_30"
DeveloperProduct.SPACEMAN_DISCOUNT_50 = 1884768330
DeveloperProductNames[1884768330] = "SPACEMAN_DISCOUNT_50"
DeveloperProduct.SPACEMAN_DISCOUNT_70 = 1884768633
DeveloperProductNames[1884768633] = "SPACEMAN_DISCOUNT_70"
DeveloperProduct.DWARVEN_DISCOUNT_30 = 1885608998
DeveloperProductNames[1885608998] = "DWARVEN_DISCOUNT_30"
DeveloperProduct.DWARVEN_DISCOUNT_50 = 1884771451
DeveloperProductNames[1884771451] = "DWARVEN_DISCOUNT_50"
DeveloperProduct.DWARVEN_DISCOUNT_70 = 1884771616
DeveloperProductNames[1884771616] = "DWARVEN_DISCOUNT_70"
DeveloperProduct.CRUSADER_DISCOUNT_30 = 1885609226
DeveloperProductNames[1885609226] = "CRUSADER_DISCOUNT_30"
DeveloperProduct.CRUSADER_DISCOUNT_50 = 1884772557
DeveloperProductNames[1884772557] = "CRUSADER_DISCOUNT_50"
DeveloperProduct.CRUSADER_DISCOUNT_70 = 1884772901
DeveloperProductNames[1884772901] = "CRUSADER_DISCOUNT_70"
DeveloperProduct.PLASMA_TITAN_DISCOUNT_30 = 3232954296
DeveloperProductNames[3232954296] = "PLASMA_TITAN_DISCOUNT_30"
DeveloperProduct.PLASMA_TITAN_DISCOUNT_50 = 3232954828
DeveloperProductNames[3232954828] = "PLASMA_TITAN_DISCOUNT_50"
DeveloperProduct.PLASMA_TITAN_DISCOUNT_70 = 3232955849
DeveloperProductNames[3232955849] = "PLASMA_TITAN_DISCOUNT_70"
DeveloperProduct.CAGE_SINGLE = 1518265736
DeveloperProductNames[1518265736] = "CAGE_SINGLE"
DeveloperProduct.CAGE_SINGLE_DISCOUNT_30 = 1885610278
DeveloperProductNames[1885610278] = "CAGE_SINGLE_DISCOUNT_30"
DeveloperProduct.CAGE_SINGLE_DISCOUNT_50 = 1884774542
DeveloperProductNames[1884774542] = "CAGE_SINGLE_DISCOUNT_50"
DeveloperProduct.CAGE_SINGLE_DISCOUNT_70 = 1884774769
DeveloperProductNames[1884774769] = "CAGE_SINGLE_DISCOUNT_70"
DeveloperProduct.ARMOUR_SINGLE = 1518266118
DeveloperProductNames[1518266118] = "ARMOUR_SINGLE"
DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_30 = 1885610469
DeveloperProductNames[1885610469] = "ARMOUR_SINGLE_DISCOUNT_30"
DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_50 = 1884775172
DeveloperProductNames[1884775172] = "ARMOUR_SINGLE_DISCOUNT_50"
DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_70 = 1884775322
DeveloperProductNames[1884775322] = "ARMOUR_SINGLE_DISCOUNT_70"
DeveloperProduct.WEAPONS_SINGLE = 1518266557
DeveloperProductNames[1518266557] = "WEAPONS_SINGLE"
DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_30 = 1885610712
DeveloperProductNames[1885610712] = "WEAPONS_SINGLE_DISCOUNT_30"
DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_50 = 1884776054
DeveloperProductNames[1884776054] = "WEAPONS_SINGLE_DISCOUNT_50"
DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_70 = 1884776175
DeveloperProductNames[1884776175] = "WEAPONS_SINGLE_DISCOUNT_70"
DeveloperProduct.FEATURED_COSMETIC_TIER_1 = 3286509470
DeveloperProductNames[3286509470] = "FEATURED_COSMETIC_TIER_1"
DeveloperProduct.FEATURED_COSMETIC_TIER_2 = 3286509628
DeveloperProductNames[3286509628] = "FEATURED_COSMETIC_TIER_2"
DeveloperProduct.FEATURED_COSMETIC_TIER_3 = 3286509664
DeveloperProductNames[3286509664] = "FEATURED_COSMETIC_TIER_3"
DeveloperProduct.GEMS_TIER_1 = 1868554850
DeveloperProductNames[1868554850] = "GEMS_TIER_1"
DeveloperProduct.GEMS_TIER_1_DISCOUNT_30 = 1885603618
DeveloperProductNames[1885603618] = "GEMS_TIER_1_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_1_DISCOUNT_50 = 1884776869
DeveloperProductNames[1884776869] = "GEMS_TIER_1_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_1_DISCOUNT_70 = 1884777061
DeveloperProductNames[1884777061] = "GEMS_TIER_1_DISCOUNT_70"
DeveloperProduct.GEMS_TIER_2 = 1868555240
DeveloperProductNames[1868555240] = "GEMS_TIER_2"
DeveloperProduct.GEMS_TIER_2_DISCOUNT_30 = 1885604063
DeveloperProductNames[1885604063] = "GEMS_TIER_2_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_2_DISCOUNT_50 = 1884777394
DeveloperProductNames[1884777394] = "GEMS_TIER_2_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_2_DISCOUNT_70 = 1884777615
DeveloperProductNames[1884777615] = "GEMS_TIER_2_DISCOUNT_70"
DeveloperProduct.GEMS_TIER_3 = 1868555452
DeveloperProductNames[1868555452] = "GEMS_TIER_3"
DeveloperProduct.GEMS_TIER_3_DISCOUNT_30 = 1885604509
DeveloperProductNames[1885604509] = "GEMS_TIER_3_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_3_DISCOUNT_50 = 1884777935
DeveloperProductNames[1884777935] = "GEMS_TIER_3_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_3_DISCOUNT_70 = 1884778134
DeveloperProductNames[1884778134] = "GEMS_TIER_3_DISCOUNT_70"
DeveloperProduct.GEMS_TIER_4 = 1868556599
DeveloperProductNames[1868556599] = "GEMS_TIER_4"
DeveloperProduct.GEMS_TIER_4_DISCOUNT_30 = 1885604764
DeveloperProductNames[1885604764] = "GEMS_TIER_4_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_4_DISCOUNT_50 = 1884778438
DeveloperProductNames[1884778438] = "GEMS_TIER_4_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_4_DISCOUNT_70 = 1884778713
DeveloperProductNames[1884778713] = "GEMS_TIER_4_DISCOUNT_70"
DeveloperProduct.GEMS_TIER_5 = 3248916333
DeveloperProductNames[3248916333] = "GEMS_TIER_5"
DeveloperProduct.GEMS_TIER_5_DISCOUNT_30 = 3248916679
DeveloperProductNames[3248916679] = "GEMS_TIER_5_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_5_DISCOUNT_50 = 3248916953
DeveloperProductNames[3248916953] = "GEMS_TIER_5_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_5_DISCOUNT_70 = 3248917166
DeveloperProductNames[3248917166] = "GEMS_TIER_5_DISCOUNT_70"
DeveloperProduct.GEMS_TIER_6 = 3248917463
DeveloperProductNames[3248917463] = "GEMS_TIER_6"
DeveloperProduct.GEMS_TIER_6_DISCOUNT_30 = 3248917690
DeveloperProductNames[3248917690] = "GEMS_TIER_6_DISCOUNT_30"
DeveloperProduct.GEMS_TIER_6_DISCOUNT_50 = 3248917813
DeveloperProductNames[3248917813] = "GEMS_TIER_6_DISCOUNT_50"
DeveloperProduct.GEMS_TIER_6_DISCOUNT_70 = 3248917954
DeveloperProductNames[3248917954] = "GEMS_TIER_6_DISCOUNT_70"
DeveloperProduct.KNIGHT_BRUTE_CRATE_1 = 1868557085
DeveloperProductNames[1868557085] = "KNIGHT_BRUTE_CRATE_1"
DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_30 = 1885600866
DeveloperProductNames[1885600866] = "KNIGHT_BRUTE_CRATE_1_DISCOUNT_30"
DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_50 = 1884780131
DeveloperProductNames[1884780131] = "KNIGHT_BRUTE_CRATE_1_DISCOUNT_50"
DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_70 = 1884780305
DeveloperProductNames[1884780305] = "KNIGHT_BRUTE_CRATE_1_DISCOUNT_70"
DeveloperProduct.KNIGHT_BRUTE_CRATE_3 = 1877759477
DeveloperProductNames[1877759477] = "KNIGHT_BRUTE_CRATE_3"
DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_30 = 1885601195
DeveloperProductNames[1885601195] = "KNIGHT_BRUTE_CRATE_3_DISCOUNT_30"
DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_50 = 1884780565
DeveloperProductNames[1884780565] = "KNIGHT_BRUTE_CRATE_3_DISCOUNT_50"
DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_70 = 1884780770
DeveloperProductNames[1884780770] = "KNIGHT_BRUTE_CRATE_3_DISCOUNT_70"
DeveloperProduct.KNIGHT_BRUTE_CRATE_5 = 1868558188
DeveloperProductNames[1868558188] = "KNIGHT_BRUTE_CRATE_5"
DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_30 = 1885601506
DeveloperProductNames[1885601506] = "KNIGHT_BRUTE_CRATE_5_DISCOUNT_30"
DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_50 = 1884781034
DeveloperProductNames[1884781034] = "KNIGHT_BRUTE_CRATE_5_DISCOUNT_50"
DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_70 = 1884781250
DeveloperProductNames[1884781250] = "KNIGHT_BRUTE_CRATE_5_DISCOUNT_70"
DeveloperProduct.KNIGHT_BRUTE_CRATE_10 = 1868558287
DeveloperProductNames[1868558287] = "KNIGHT_BRUTE_CRATE_10"
DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_30 = 1885601997
DeveloperProductNames[1885601997] = "KNIGHT_BRUTE_CRATE_10_DISCOUNT_30"
DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_50 = 1884781438
DeveloperProductNames[1884781438] = "KNIGHT_BRUTE_CRATE_10_DISCOUNT_50"
DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_70 = 1884781650
DeveloperProductNames[1884781650] = "KNIGHT_BRUTE_CRATE_10_DISCOUNT_70"
DeveloperProduct.NINJA_CRATE_1 = 2678593981
DeveloperProductNames[2678593981] = "NINJA_CRATE_1"
DeveloperProduct.NINJA_CRATE_1_DISCOUNT_30 = 2678594249
DeveloperProductNames[2678594249] = "NINJA_CRATE_1_DISCOUNT_30"
DeveloperProduct.NINJA_CRATE_1_DISCOUNT_50 = 2678594740
DeveloperProductNames[2678594740] = "NINJA_CRATE_1_DISCOUNT_50"
DeveloperProduct.NINJA_CRATE_1_DISCOUNT_70 = 2678594842
DeveloperProductNames[2678594842] = "NINJA_CRATE_1_DISCOUNT_70"
DeveloperProduct.NINJA_CRATE_3 = 2678594993
DeveloperProductNames[2678594993] = "NINJA_CRATE_3"
DeveloperProduct.NINJA_CRATE_3_DISCOUNT_30 = 2678595060
DeveloperProductNames[2678595060] = "NINJA_CRATE_3_DISCOUNT_30"
DeveloperProduct.NINJA_CRATE_3_DISCOUNT_50 = 2678595159
DeveloperProductNames[2678595159] = "NINJA_CRATE_3_DISCOUNT_50"
DeveloperProduct.NINJA_CRATE_3_DISCOUNT_70 = 2678595241
DeveloperProductNames[2678595241] = "NINJA_CRATE_3_DISCOUNT_70"
DeveloperProduct.NINJA_CRATE_5 = 2678595696
DeveloperProductNames[2678595696] = "NINJA_CRATE_5"
DeveloperProduct.NINJA_CRATE_5_DISCOUNT_30 = 2678595756
DeveloperProductNames[2678595756] = "NINJA_CRATE_5_DISCOUNT_30"
DeveloperProduct.NINJA_CRATE_5_DISCOUNT_50 = 2678595792
DeveloperProductNames[2678595792] = "NINJA_CRATE_5_DISCOUNT_50"
DeveloperProduct.NINJA_CRATE_5_DISCOUNT_70 = 2678595876
DeveloperProductNames[2678595876] = "NINJA_CRATE_5_DISCOUNT_70"
DeveloperProduct.NINJA_CRATE_10 = 2678595942
DeveloperProductNames[2678595942] = "NINJA_CRATE_10"
DeveloperProduct.NINJA_CRATE_10_DISCOUNT_30 = 2678595990
DeveloperProductNames[2678595990] = "NINJA_CRATE_10_DISCOUNT_30"
DeveloperProduct.NINJA_CRATE_10_DISCOUNT_50 = 2678596043
DeveloperProductNames[2678596043] = "NINJA_CRATE_10_DISCOUNT_50"
DeveloperProduct.NINJA_CRATE_10_DISCOUNT_70 = 2678596080
DeveloperProductNames[2678596080] = "NINJA_CRATE_10_DISCOUNT_70"
local PrimedCosmeticType: { [string]: string } = {
	["Cage"] = "Cage",
	["Armour"] = "Armour",
	["Weapons"] = "Weapons",
	["FeaturedCosmetic"] = "FeaturedCosmetic"
}
local Products: { GameProduct } = {}
local EarlySupporterProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Early Supporter",
	["PriceInRobux"] = -1,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["ProductId"] = ProductId.EARLY_SUPPORTER,
	["GamepassId"] = Gamepass.EARLY_SUPPORTER,
	["Bundle"] = { CosmeticId.CageUfo, CosmeticId.SwordSupporter }
}
local SeasonOnePassProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Season 1 Pass",
	["PriceInRobux"] = -1,
	["OneTimePurchase"] = true,
	["SeasonPass"] = nil,
	["ProductId"] = ProductId.SEASON_ONE_PASS,
	["GamepassId"] = Gamepass.SEASON_ONE_PASS,
	["SeasonPass"] = Season.ONE
}
local SamuraiBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Samurai Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Samurai",
	["ProductId"] = ProductId.SAMURAI,
	["GamepassId"] = Gamepass.SAMURAI,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = { CosmeticId.CageSamurai, CosmeticId.PackageSamurai, CosmeticId.SwordKatana }
}
local AzazelBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Azazel Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Azazel",
	["ProductId"] = ProductId.AZAZEL,
	["GamepassId"] = Gamepass.AZAZEL,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.CageAzazel,
		CosmeticId.PackageAzazel,
		CosmeticId.SwordLongAxe,
		CosmeticId.BowAzazel
	}
}
local VurrenBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Vurren Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Vurren",
	["ProductId"] = ProductId.VURREN,
	["GamepassId"] = Gamepass.VURREN,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.CageVurren,
		CosmeticId.PackageVurren,
		CosmeticId.SwordDragonBlade,
		CosmeticId.BowVurren
	}
}
local SpacemanBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Spaceman Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Spaceman",
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.SPACEMAN,
	["GamepassId"] = Gamepass.SPACEMAN,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackageSpaceman,
		CosmeticId.CageSpaceman,
		CosmeticId.SwordSpaceman,
		CosmeticId.BowSpaceman
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SPACEMAN_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SPACEMAN_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SPACEMAN_DISCOUNT_70
		}
	}
}
local DwarvenBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Dwarven Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Dwarven",
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.DWARVEN,
	["GamepassId"] = Gamepass.DWARVEN,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackageDwarven,
		CosmeticId.CageDwarven,
		CosmeticId.SwordDwarven,
		CosmeticId.BowDwarven
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.DWARVEN_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.DWARVEN_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.DWARVEN_DISCOUNT_70
		}
	}
}
local SeasonTwoPassProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Season 2 Pass",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["SeasonPass"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.SEASON_TWO_PASS,
	["GamepassId"] = Gamepass.SEASON_TWO_PASS,
	["PriceInRobux"] = ProductConstants.DEFAULT_SEASON_PASS_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_SEASON_PASS_PRICE_GEMS,
	["SeasonPass"] = Season.THREE,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_DISCOUNT_70
		}
	}
}
local SeasonTwoPassBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Season 2 Pass Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["SeasonPass"] = nil,
	["SeasonPassExperience"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.SEASON_TWO_PASS_BUNDLE,
	["GamepassId"] = Gamepass.SEASON_TWO_PASS_BUNDLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_SEASON_PASS_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_SEASON_PASS_BUNDLE_PRICE_GEMS,
	["SeasonPass"] = Season.THREE,
	["SeasonPassExperience"] = SeasonUtil.getExperience(15),
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_TWO_PASS_BUNDLE_DISCOUNT_70
		}
	}
}
local SeasonThreePassProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Season 3 Pass",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["SeasonPass"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.SEASON_THREE_PASS,
	["GamepassId"] = Gamepass.SEASON_THREE_PASS,
	["PriceInRobux"] = ProductConstants.DEFAULT_SEASON_PASS_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_SEASON_PASS_PRICE_GEMS,
	["SeasonPass"] = Season.THREE_2,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_DISCOUNT_70
		}
	}
}
local SeasonThreePassBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Season 3 Pass Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["SeasonPass"] = nil,
	["SeasonPassExperience"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.SEASON_THREE_PASS_BUNDLE,
	["GamepassId"] = Gamepass.SEASON_THREE_PASS_BUNDLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_SEASON_PASS_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_SEASON_PASS_BUNDLE_PRICE_GEMS,
	["SeasonPass"] = Season.THREE_2,
	["SeasonPassExperience"] = SeasonUtil.getExperience(15),
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.SEASON_THREE_PASS_BUNDLE_DISCOUNT_70
		}
	}
}
local CrusaderBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Crusader Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Crusader",
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.CRUSADER,
	["GamepassId"] = Gamepass.CRUSADER,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackageCrusader,
		CosmeticId.CageCrusader,
		CosmeticId.SwordCrusader,
		CosmeticId.BowCrusader
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CRUSADER_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CRUSADER_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CRUSADER_DISCOUNT_70
		}
	}
}
local RomanBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Roman Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "Roman",
	["ProductId"] = ProductId.ROMAN,
	["GamepassId"] = Gamepass.ROMAN,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackageRoman,
		CosmeticId.CageRoman,
		CosmeticId.SwordRoman,
		CosmeticId.BowRoman
	}
}
local ArabianKnightBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Arabian Knight Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "ArabianKnight",
	["ProductId"] = ProductId.ARABIAN_KNIGHT,
	["GamepassId"] = Gamepass.ARABIAN_KNIGHT,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackageArabianKnight,
		CosmeticId.CageArabianKnight,
		CosmeticId.SwordArabianKnight,
		CosmeticId.BowArabianKnight
	}
}
local PlasmaTitanBundleProduct = {
	["ProductId"] = nil,
	["GamepassId"] = nil,
	["DisplayName"] = "Plasma Titan Bundle",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = true,
	["Bundle"] = nil,
	["BundleId"] = "PlasmaTitan",
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.PLASMA_TITAN_BUNDLE,
	["GamepassId"] = Gamepass.PLASMA_TITAN_BUNDLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_BUNDLE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_BUNDLE_PRICE_GEMS,
	["Bundle"] = {
		CosmeticId.PackagePlasmaTitan,
		CosmeticId.CagePlasmaTitan,
		CosmeticId.SwordPlasmaTitan,
		CosmeticId.BowPlasmaTitan
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.PLASMA_TITAN_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.PLASMA_TITAN_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.PLASMA_TITAN_DISCOUNT_70
		}
	}
}
local CageSingleProduct = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "1 Cage",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.CAGE_SINGLE,
	["DeveloperProductId"] = DeveloperProduct.CAGE_SINGLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_CAGE_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CAGE_PRICE_GEMS,
	["PrimedCosmeticType"] = PrimedCosmeticType.Cage,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CAGE_SINGLE_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CAGE_SINGLE_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.CAGE_SINGLE_DISCOUNT_70
		}
	}
}
__set_list(Products, 1, {EarlySupporterProduct, SeasonOnePassProduct, SamuraiBundleProduct, AzazelBundleProduct, VurrenBundleProduct, SpacemanBundleProduct, DwarvenBundleProduct, SeasonTwoPassProduct, SeasonTwoPassBundleProduct, SeasonThreePassProduct, SeasonThreePassBundleProduct, CrusaderBundleProduct, RomanBundleProduct, ArabianKnightBundleProduct, PlasmaTitanBundleProduct, CageSingleProduct})
local ArmourSingleProduct = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "1 Armour Set",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.ARMOUR_SINGLE,
	["DeveloperProductId"] = DeveloperProduct.ARMOUR_SINGLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_ARMOUR_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_ARMOUR_PRICE_GEMS,
	["PrimedCosmeticType"] = PrimedCosmeticType.Armour,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.ARMOUR_SINGLE_DISCOUNT_70
		}
	}
}
local WeaponsSingleProduct = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "1 Weapon Set",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.WEAPONS_SINGLE,
	["DeveloperProductId"] = DeveloperProduct.WEAPONS_SINGLE,
	["PriceInRobux"] = ProductConstants.DEFAULT_WEAPON_PRICE_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_WEAPON_PRICE_GEMS,
	["PrimedCosmeticType"] = PrimedCosmeticType.Weapons,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.WEAPONS_SINGLE_DISCOUNT_70
		}
	}
}
local FeaturedCosmeticTier1Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Daily Cosmetic Tier 1",
	["PriceInRobux"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["ProductId"] = ProductId.FEATURED_COSMETIC_TIER_1,
	["DeveloperProductId"] = DeveloperProduct.FEATURED_COSMETIC_TIER_1,
	["PriceInRobux"] = ProductConstants.FEATURED_COSMETIC_TIER_1_PRICE_ROBUX,
	["PrimedCosmeticType"] = PrimedCosmeticType.FeaturedCosmetic
}
local FeaturedCosmeticTier2Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Daily Cosmetic Tier 2",
	["PriceInRobux"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["ProductId"] = ProductId.FEATURED_COSMETIC_TIER_2,
	["DeveloperProductId"] = DeveloperProduct.FEATURED_COSMETIC_TIER_2,
	["PriceInRobux"] = ProductConstants.FEATURED_COSMETIC_TIER_2_PRICE_ROBUX,
	["PrimedCosmeticType"] = PrimedCosmeticType.FeaturedCosmetic
}
local FeaturedCosmeticTier3Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Daily Cosmetic Tier 3",
	["PriceInRobux"] = nil,
	["OneTimePurchase"] = false,
	["PrimedCosmeticType"] = nil,
	["ProductId"] = ProductId.FEATURED_COSMETIC_TIER_3,
	["DeveloperProductId"] = DeveloperProduct.FEATURED_COSMETIC_TIER_3,
	["PriceInRobux"] = ProductConstants.FEATURED_COSMETIC_TIER_3_PRICE_ROBUX,
	["PrimedCosmeticType"] = PrimedCosmeticType.FeaturedCosmetic
}
local KnightBruteCrate1Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Knight Brute Crate x1",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.KNIGHT_BRUTE_CRATE_1,
	["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_1,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_1_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_1_GEMS,
	["Crate"] = {
		["Id"] = "KnightBruteCrate",
		["Quantity"] = 1
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_1_DISCOUNT_70
		}
	}
}
local KnightBruteCrate3Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Knight Brute Crate x3",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.KNIGHT_BRUTE_CRATE_3,
	["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_3,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_3_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_3_GEMS,
	["Crate"] = {
		["Id"] = "KnightBruteCrate",
		["Quantity"] = 3
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_3_DISCOUNT_70
		}
	}
}
local KnightBruteCrate5Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Knight Brute Crate x5",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.KNIGHT_BRUTE_CRATE_5,
	["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_5,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_5_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_5_GEMS,
	["Crate"] = {
		["Id"] = "KnightBruteCrate",
		["Quantity"] = 5
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_5_DISCOUNT_70
		}
	}
}
local KnightBruteCrate10Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Knight Brute Crate x10",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.KNIGHT_BRUTE_CRATE_10,
	["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_10,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_10_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_10_GEMS,
	["Crate"] = {
		["Id"] = "KnightBruteCrate",
		["Quantity"] = 10
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.KNIGHT_BRUTE_CRATE_10_DISCOUNT_70
		}
	}
}
local NinjaCrate1Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Ninja Crate x1",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.NINJA_CRATE_1,
	["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_1,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_1_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_1_GEMS,
	["Crate"] = {
		["Id"] = "NinjaCrate",
		["Quantity"] = 1
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_1_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_1_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_1_DISCOUNT_70
		}
	}
}
local NinjaCrate3Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Ninja Crate x3",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.NINJA_CRATE_3,
	["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_3,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_3_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_3_GEMS,
	["Crate"] = {
		["Id"] = "NinjaCrate",
		["Quantity"] = 3
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_3_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_3_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_3_DISCOUNT_70
		}
	}
}
local NinjaCrate5Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Ninja Crate x5",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.NINJA_CRATE_5,
	["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_5,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_5_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_5_GEMS,
	["Crate"] = {
		["Id"] = "NinjaCrate",
		["Quantity"] = 5
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_5_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_5_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_5_DISCOUNT_70
		}
	}
}
local NinjaCrate10Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Ninja Crate x10",
	["PriceInRobux"] = nil,
	["PriceInGems"] = nil,
	["OneTimePurchase"] = false,
	["Gambling"] = true,
	["Crate"] = nil,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.NINJA_CRATE_10,
	["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_10,
	["PriceInRobux"] = ProductConstants.DEFAULT_CRATE_PRICE_10_ROBUX,
	["PriceInGems"] = ProductConstants.DEFAULT_CRATE_PRICE_10_GEMS,
	["Crate"] = {
		["Id"] = "NinjaCrate",
		["Quantity"] = 10
	},
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_10_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_10_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.NINJA_CRATE_10_DISCOUNT_70
		}
	}
}
local GemsTier1Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Pile of Gems",
	["Description"] = "A pile of magical gems!",
	["Image"] = nil,
	["PriceInRobux"] = 149,
	["OneTimePurchase"] = false,
	["GemsReward"] = 1500,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_1,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_1,
	["Image"] = RobloxImage.Gem.TIER_1,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_1_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_1_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_1_DISCOUNT_70
		}
	}
}
local GemsTier2Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Bag of Gems",
	["Description"] = "An enticing bag filled with gems!",
	["Image"] = nil,
	["PriceInRobux"] = 199,
	["OneTimePurchase"] = false,
	["GemsReward"] = 2200,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_2,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_2,
	["Image"] = RobloxImage.Gem.TIER_2,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_2_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_2_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_2_DISCOUNT_70
		}
	}
}
local GemsTier3Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Sack of Gems",
	["Description"] = "A bountiful sack overflowing with gems!",
	["Image"] = nil,
	["PriceInRobux"] = 399,
	["OneTimePurchase"] = false,
	["GemsReward"] = 4700,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_3,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_3,
	["Image"] = RobloxImage.Gem.TIER_3,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_3_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_3_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_3_DISCOUNT_70
		}
	}
}
__set_list(Products, 17, {ArmourSingleProduct, WeaponsSingleProduct, FeaturedCosmeticTier1Product, FeaturedCosmeticTier2Product, FeaturedCosmeticTier3Product, KnightBruteCrate1Product, KnightBruteCrate3Product, KnightBruteCrate5Product, KnightBruteCrate10Product, NinjaCrate1Product, NinjaCrate3Product, NinjaCrate5Product, NinjaCrate10Product, GemsTier1Product, GemsTier2Product, GemsTier3Product})
local GemsTier4Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Chest of Gems",
	["Description"] = "An enormous chest packed with gems!",
	["Image"] = nil,
	["PriceInRobux"] = 799,
	["OneTimePurchase"] = false,
	["GemsReward"] = 10000,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_4,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_4,
	["Image"] = RobloxImage.Gem.TIER_4,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_4_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_4_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_4_DISCOUNT_70
		}
	}
}
local GemsTier5Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Barrel of Gems",
	["Description"] = "A massive barrel brimming with shimmering gems!",
	["Image"] = nil,
	["PriceInRobux"] = 1599,
	["OneTimePurchase"] = false,
	["GemsReward"] = 22000,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_5,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_5,
	["Image"] = RobloxImage.Gem.TIER_5,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_5_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_5_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_5_DISCOUNT_70
		}
	}
}
local GemsTier6Product = {
	["ProductId"] = nil,
	["DeveloperProductId"] = nil,
	["DisplayName"] = "Vault of Gems",
	["Description"] = "An immense vault overflowing with untold riches of dazzling gems!",
	["Image"] = nil,
	["PriceInRobux"] = 4499,
	["OneTimePurchase"] = false,
	["GemsReward"] = 65000,
	["RegionalPricing"] = nil,
	["ProductId"] = ProductId.GEMS_TIER_6,
	["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_6,
	["Image"] = RobloxImage.Gem.TIER_6,
	["RegionalPricing"] = {
		{
			["Percentage"] = 0.3,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_6_DISCOUNT_30
		},
		{
			["Percentage"] = 0.5,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_6_DISCOUNT_50
		},
		{
			["Percentage"] = 0.7,
			["DeveloperProductId"] = nil,
			["DeveloperProductId"] = DeveloperProduct.GEMS_TIER_6_DISCOUNT_70
		}
	}
}
__set_list(Products, 33, {GemsTier4Product, GemsTier5Product, GemsTier6Product})
local CurrentSeasonProductId = ProductId.SEASON_THREE_PASS
local CurrentSeasonBundleProductId = ProductId.SEASON_THREE_PASS_BUNDLE
local CurrentSeasonGamepass = Gamepass.SEASON_THREE_PASS
local CurrentSeasonGamepassBundle = Gamepass.SEASON_THREE_PASS_BUNDLE
local function createGameProduct(product: GameProduct): GameProduct
	local regionalPricing = product.RegionalPricing or {}
	local newProduct = table.clone(product)
	setmetatable(newProduct, nil)
	local function createDiscountedVariant(variants: { [number]: GameProduct }, priceTier: RegionalPricing): { [number]: GameProduct }
		local percentage = priceTier.Percentage
		local discountedProduct = table.clone(product)
		setmetatable(discountedProduct, nil)
		discountedProduct.GamepassId = nil
		discountedProduct.DeveloperProductId = priceTier.DeveloperProductId
		local discountedPrice = product.PriceInRobux * priceTier.Percentage
		discountedProduct.PriceInRobux = math.floor(discountedPrice)
		discountedProduct.RegionalPricing = {}
		variants[percentage] = discountedProduct
		return variants
	end
	local discountedProducts = {}
	for index = 1, #regionalPricing do
		discountedProducts = createDiscountedVariant(discountedProducts, regionalPricing[index], index - 1, regionalPricing)
	end
	newProduct.RegionalPricing = discountedProducts
	return newProduct
end
local GameProducts: { [number]: GameProduct } = {}
local Gamepasses: { [number]: GameProduct } = {}
local DeveloperProducts: { [number]: GameProduct } = {}
local PrimedCosmeticProducts: { [string]: string } = {}
local PurchaseType: { [string]: string } = {
	["Robux"] = "Robux",
	["Gems"] = "Gems"
}
for _, product in Products do
	local gameProduct = createGameProduct(product)
	GameProducts[gameProduct.ProductId] = gameProduct
	if gameProduct.GamepassId then
		Gamepasses[gameProduct.GamepassId] = gameProduct
	end
	if gameProduct.DeveloperProductId then
		DeveloperProducts[gameProduct.DeveloperProductId] = gameProduct
	end
	for _, discountedVariant in gameProduct.RegionalPricing do
		if discountedVariant.DeveloperProductId ~= nil then
			DeveloperProducts[discountedVariant.DeveloperProductId] = discountedVariant
		end
	end
	if gameProduct.PrimedCosmeticType then
		PrimedCosmeticProducts[gameProduct.PrimedCosmeticType] = gameProduct.ProductId
	end
end
return {
	["ProductId"] = ProductId,
	["Gamepass"] = Gamepass,
	["DeveloperProduct"] = DeveloperProduct,
	["PurchaseType"] = PurchaseType,
	["PrimedCosmeticType"] = PrimedCosmeticType,
	["CurrentSeasonProductId"] = CurrentSeasonProductId,
	["CurrentSeasonBundleProductId"] = CurrentSeasonBundleProductId,
	["CurrentSeasonGamepass"] = CurrentSeasonGamepass,
	["CurrentSeasonGamepassBundle"] = CurrentSeasonGamepassBundle,
	["GameProducts"] = GameProducts,
	["Gamepasses"] = Gamepasses,
	["DeveloperProducts"] = DeveloperProducts,
	["PrimedCosmeticProducts"] = PrimedCosmeticProducts
}