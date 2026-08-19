-- SeasonUtil

export type SeasonPassReward = {
	Premium: boolean,
	Tier: number,
}

export type SeasonUtil = {
	LEGACY_EXPERIENCE_PER_TIER: number,
	SKIP_PRICES_ROBUX: { number },
	SKIP_TIER_IDS: { number },
	ROBUX_PER_TIER: number,
	BASE_EXP_PER_LEVEL: number,
	INCREMENT_MULTIPLIER_PER_LEVEL: number,
	EXP_INCREMENT_LIMIT: number,
	MAX_LEVEL: number,
	getSkipPrice: (tier: number) -> number?,
	getTier: (experience: number) -> number,
	getMaxTier: () -> number,
	getProgress: (experience: number) -> number,
	getProgressDecimal: (experience: number) -> number,
	getRequiredExperience: (level: number, currentExperience: number) -> number,
	getExperience: (level: number) -> number,
	promptSkipTiers: (tiers: number, player: Player?) -> (),
	getFeatureList: (tier: number, purchased: boolean) -> string,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local MarketplaceService: MarketplaceService = Services.MarketplaceService
local Players: Players = Services.Players
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local SeasonPassRewards: { SeasonPassReward } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").SeasonPassRewards
local SeasonUtil: SeasonUtil = {
	["LEGACY_EXPERIENCE_PER_TIER"] = 500,
}
local SKIP_PRICES_ROBUX: { number } = {
	99,
	189,
	279,
	369,
	449,
	529,
	609,
	689,
	769,
	849,
	929,
	999,
	1079,
	1159,
	1239,
	1309,
	1389,
	1469,
	1549,
	1619,
	1699,
	1779,
	1859,
	1939,
	2019,
	2089,
	2169,
	2249,
	2329,
	2409,
	2489,
	2569,
	2649,
	2729,
	2809,
	2889,
	2969,
	3049,
	3129,
	3209,
	3289,
	3369,
	3449,
	3529,
	3609,
	3679,
	3759,
	3839,
	3919,
	3999,
	4079,
	4159,
	4239,
	4319,
	4399,
	4479,
	4559,
	4639,
	4719,
	4799,
	4879,
	4959,
	5039,
	5119,
	5199,
	5279,
	5359,
	5439,
	5519,
	5599,
	5679,
	5759,
	5839,
	5919,
	5999,
	6079,
	6159,
	6239,
	6319,
	6399,
	6479,
	6559,
	6639,
	6719,
	6799,
	6879,
}
SeasonUtil.SKIP_PRICES_ROBUX = SKIP_PRICES_ROBUX
local SKIP_TIER_IDS: { number } = PlaceUtil.isProduction()
		and {
			3280482702,
			3280482709,
			3280482715,
			3280482724,
			3280482732,
			3280482735,
			3280482738,
			3280482741,
			3280482750,
			3280482759,
			3280482762,
			3280482768,
			3280482772,
			3280482780,
			3280482786,
			3280482790,
			3280482798,
			3280482806,
			3280482814,
			3280482824,
			3280482827,
			3280482833,
			3280482843,
			3280482846,
			3280482847,
			3280482851,
			3280482856,
			3280482859,
			3280482861,
			3280482865,
			3280482869,
			3280482879,
			3280482886,
			3280482892,
			3280482898,
			3280482904,
			3280482912,
			3280482918,
			3280482926,
			3280482935,
			3280482940,
			3280482942,
			3280482948,
			3280482954,
			3280482960,
			3280482970,
			3280482978,
			3280482987,
			3280482990,
			3280482997,
			3280483001,
			3280483008,
			3280483017,
			3280483021,
			3280483024,
			3280483034,
			3280483042,
			3280483050,
			3280483052,
			3280483058,
			3280483062,
			3280483074,
			3280483078,
			3280483083,
			3280483086,
			3280483087,
			3280483091,
			3280483096,
			3280483102,
			3280483108,
			3280483112,
			3280483120,
			3280483128,
			3280483132,
			3280483136,
			3280483142,
			3280483152,
			3280483155,
			3280483160,
			3280483164,
			3280483172,
			3280483179,
			3280483183,
			3280483191,
			3280483195,
			3280483204,
		}
	or {
		1303509929,
		1303509934,
		1303509939,
		1303509946,
		1303509951,
		1303509966,
		1303509970,
		1303509973,
		1303509976,
		1303509983,
		1303509992,
		1303509995,
		1303509999,
		1303510005,
		1303510009,
		1303510019,
		1303510243,
		1303510251,
		1303510255,
		1303510261,
		1303510271,
		1303510274,
		1303510280,
		1303510287,
		1303510298,
		1303510304,
		1303510305,
		1303510309,
		1303510316,
		1303510326,
		1303510331,
		1303510333,
		1303510526,
		1303510534,
		1303510538,
		1303510542,
		1303510545,
		1303510552,
		1303510557,
		1303510564,
		1303510573,
		1303510578,
		1303510582,
		1303510585,
		1303510590,
		1303510595,
		1303510606,
		1303510616,
		1303510841,
		1303510848,
	}
SeasonUtil.SKIP_TIER_IDS = SKIP_TIER_IDS
SeasonUtil.ROBUX_PER_TIER = 100
SeasonUtil.BASE_EXP_PER_LEVEL = 2800
SeasonUtil.INCREMENT_MULTIPLIER_PER_LEVEL = 1.05
SeasonUtil.EXP_INCREMENT_LIMIT = 7000
SeasonUtil.MAX_LEVEL = 86
local EXPERIENCE_PER_LEVEL: { number } = {}
local EXPERIENCE_THRESHOLDS: { number } = {}
function SeasonUtil.getSkipPrice(tier: number): number?
	return SKIP_PRICES_ROBUX[tier]
end
function SeasonUtil.getTier(experience: number): number
	local tier = 0
	for i = 0, #EXPERIENCE_THRESHOLDS - 1 do
		if EXPERIENCE_THRESHOLDS[i + 1] > experience then
			break
		end
		tier = i
	end
	return tier
end
function SeasonUtil.getMaxTier(): number
	local maxTier = 0
	for _ in SeasonPassRewards do
		maxTier = maxTier + 1
	end
	return maxTier
end
local getExperience: (level: number) -> number
function SeasonUtil.getProgress(experience: number): number
	local tier = 0
	for i = 0, #EXPERIENCE_THRESHOLDS - 1 do
		if EXPERIENCE_THRESHOLDS[i + 1] > experience then
			break
		end
		tier = i
	end
	return experience - getExperience(tier)
end
function SeasonUtil.getProgressDecimal(experience: number): number
	local tier = 0
	for i = 0, #EXPERIENCE_THRESHOLDS - 1 do
		if EXPERIENCE_THRESHOLDS[i + 1] > experience then
			break
		end
		tier = i
	end
	local tierExperience = getExperience(tier + 1) - getExperience(tier)
	return (experience - getExperience(tier)) / tierExperience
end
function SeasonUtil.getRequiredExperience(level: number, currentExperience: number): number
	return SeasonUtil.getExperience(level) - currentExperience
end
getExperience = function(level: number): number
	if level < 0 then
		return 0
	end
	local thresholds = EXPERIENCE_THRESHOLDS
	local maxIndex = #EXPERIENCE_THRESHOLDS - 1
	return thresholds[math.min(level, maxIndex) + 1]
end
SeasonUtil.getExperience = getExperience
function SeasonUtil.promptSkipTiers(tiers: number, player: Player?): ()
	if player == nil then
		player = Players.LocalPlayer
	end
	local index = tiers - 1
	if #SKIP_TIER_IDS < tiers or tiers < 0 then
		return nil
	end
	MarketplaceService:PromptProductPurchase(player, SKIP_TIER_IDS[index + 1])
end
function SeasonUtil.getFeatureList(tier: number, purchased: boolean): string
	if purchased then
		return "Thanks for purchasing and supporting the game! :)"
	end
	local unlockedCount = 0
	local remainingCount = 0
	local features = {}
	for _, reward in SeasonPassRewards do
		if reward.Premium then
			if reward.Tier <= tier then
				unlockedCount = unlockedCount + 1
			else
				remainingCount = remainingCount + 1
			end
		end
	end
	table.insert(features, "<font face='Gotham' color='#36E270'><b>50%</b></font> faster season progress!")
	if unlockedCount > 0 then
		local unlockMessage = ("Unlock <font face='Gotham' color='#36E270'><b>%*</b></font> premium rewards instantly!"):format(
			unlockedCount
		)
		table.insert(features, unlockMessage)
		local earnAnotherMessage = ("Earn another <font face='Gotham' color='#36E270'><b>%*</b></font> premium rewards!"):format(
			remainingCount
		)
		table.insert(features, earnAnotherMessage)
	else
		local earnMessage = ("Earn <font face='Gotham' color='#36E270'><b>%*</b></font> premium rewards!"):format(
			remainingCount
		)
		table.insert(features, earnMessage)
	end
	local formattedFeatures = table.create(#features)
	for index, feature in features do
		local _ = index - 1
		formattedFeatures[index] = ("- %*"):format(feature)
	end
	return ("%*"):format((table.concat(formattedFeatures, "\n")))
end
EXPERIENCE_PER_LEVEL[1] = 2800
EXPERIENCE_THRESHOLDS[1] = 0
for level = 1, 85 do
	local increment = EXPERIENCE_PER_LEVEL[level] * 1.05
	local cappedIncrement = math.min(increment, 7000)
	local cumulativeExperience = EXPERIENCE_THRESHOLDS[level] + cappedIncrement
	local nextLevel = level + 1
	local roundedUnits = cumulativeExperience / 250
	EXPERIENCE_THRESHOLDS[nextLevel] = math.round(roundedUnits) * 250
	EXPERIENCE_PER_LEVEL[level + 1] = cappedIncrement
end
return {
	["SeasonUtil"] = SeasonUtil,
}
