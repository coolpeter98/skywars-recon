-- data-profile

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local QueueId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "matchmaking", "queue-id").QueueId
local CurrentSeason =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeason
local PartyInvitePrivacy = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"player-settings",
	"player-settings"
).PartyInvitePrivacy

local PerformanceTestGroup: { Unset: string, Cutback: string, Normal: string } = {
	["Unset"] = "Unset",
	["Cutback"] = "Cutback",
	["Normal"] = "Normal",
}

local StatsTemplate: { [string]: number } = {
	["Wins"] = 0,
	["WinStreak"] = 0,
	["Losses"] = 0,
	["Kills"] = 0,
	["Deaths"] = 0,
	["DamageDealt"] = 0,
	["DamageTaken"] = 0,
}

local SharedDataProfileTemplate: { [string]: any } = {
	["WasTeleporting"] = false,
	["SeasonLevelTimeSum"] = 0,
	["SessionTimeSum"] = 0,
	["Coins"] = 0,
	["LastJoinedTime"] = 0,
	["LastPlayedTime"] = 0,
	["LastSessionTime"] = 0,
	["TeleportEngageTime"] = 0,
	["PreviousJoinedTime"] = 0,
}

local StatsByQueue: { [string]: typeof(StatsTemplate) } = table.clone(StatsTemplate)
setmetatable(StatsByQueue, nil)
StatsByQueue[QueueId.Solo] = StatsTemplate
StatsByQueue[QueueId.Duos] = StatsTemplate
StatsByQueue[QueueId.Trios] = StatsTemplate
StatsByQueue[QueueId.Quads] = StatsTemplate
StatsByQueue[QueueId.Private] = StatsTemplate
StatsByQueue[QueueId.DuelsSolo] = StatsTemplate
StatsByQueue[QueueId.DuelsDuos] = StatsTemplate
StatsByQueue[QueueId.TestingSolo] = StatsTemplate
StatsByQueue[QueueId.TestingDuos] = StatsTemplate
StatsByQueue[QueueId.TestingTrios] = StatsTemplate
StatsByQueue[QueueId.TestingQuads] = StatsTemplate
StatsByQueue[QueueId.TestingPrivate] = StatsTemplate
StatsByQueue[QueueId.TestingDuelsSolo] = StatsTemplate
StatsByQueue[QueueId.TestingDuelsDuos] = StatsTemplate
StatsByQueue[QueueId.EggWarsQuads] = StatsTemplate
StatsByQueue[QueueId.TestingEggWarsQuads] = StatsTemplate
SharedDataProfileTemplate.Stats = StatsByQueue
SharedDataProfileTemplate.Party = {
	["PartyId"] = "",
	["PartyOwnerId"] = 0,
}
SharedDataProfileTemplate.DiscordVerification = {
	["VerificationCode"] = "",
	["Verified"] = false,
}
SharedDataProfileTemplate.OwnedPasses = {}
SharedDataProfileTemplate.OwnedProducts = {}
SharedDataProfileTemplate.Cosmetics = {
	["Owned"] = {},
	["Active"] = {},
	["ActiveSkins"] = {},
	["ActiveSkinsGroup"] = {},
}
SharedDataProfileTemplate.Ranks = {}
SharedDataProfileTemplate.Experience = 0
SharedDataProfileTemplate.FirstPerson = false
SharedDataProfileTemplate.InitialSession = true
SharedDataProfileTemplate.InitialSessionTime = 0
SharedDataProfileTemplate.LoginStreak = {
	["Streak"] = 0,
	["LastLoginTime"] = 0,
	["TimezoneOffset"] = 0,
	["TimezoneOffsetLastUpdatedTime"] = 0,
	["StreakHistory"] = nil,
	["StreakHistory"] = {},
}

local AchievementsTemplate: { [string]: any } = {
	["SummerScavengerHunt"] = {
		["Completed"] = false,
		["Progress"] = nil,
		["Progress"] = {},
	},
}
SharedDataProfileTemplate.Achievements = AchievementsTemplate
SharedDataProfileTemplate.MigratedCosmeticsPatch = false
SharedDataProfileTemplate.MigratedCosmeticsThree = false
SharedDataProfileTemplate.MigratedCosmeticsTwo = false
SharedDataProfileTemplate.MigratedCosmetics = false
SharedDataProfileTemplate.MigratedExperience = false
SharedDataProfileTemplate.MigratedHunt = false
SharedDataProfileTemplate.MigratedSeasonId = false
SharedDataProfileTemplate.MigratedProducts = false
SharedDataProfileTemplate.MigratedSettings = false
SharedDataProfileTemplate.MigratedSeasonExperience = false
SharedDataProfileTemplate.MigratedStore = false
SharedDataProfileTemplate.Missions = {}
SharedDataProfileTemplate.Settings = {
	["MusicMuted"] = true,
	["MusicVolume"] = 0,
	["SfxVolume"] = 100,
	["PartyInvitePrivacy"] = nil,
	["AutoQueue"] = true,
	["FieldOfView"] = 70,
	["PartyInvitePrivacy"] = PartyInvitePrivacy.Public,
}

local SeasonTemplate: { [string]: any } = {
	["OwnedPasses"] = {},
}
local SeasonData = {
	[CurrentSeason] = {
		["Experience"] = 0,
		["CurrentTierId"] = 1,
		["AwardedTiers"] = nil,
		["AwardedTiers"] = {},
	},
}
SeasonTemplate.SeasonData = SeasonData
SharedDataProfileTemplate.Season = SeasonTemplate
SharedDataProfileTemplate.ProcessedReceipts = {}
SharedDataProfileTemplate.PerformanceTestGroup = PerformanceTestGroup.Normal
SharedDataProfileTemplate.PrimedCosmeticPurchase = nil
SharedDataProfileTemplate.OwedCosmeticPurchases = {}
SharedDataProfileTemplate.Gems = 0
SharedDataProfileTemplate.CountryHistory = {}
SharedDataProfileTemplate.CountryHistoryLastUpdated = 0
SharedDataProfileTemplate.UpdateLog = {}

local ServerDataProfileTemplate: { [string]: any } = table.clone(SharedDataProfileTemplate)
setmetatable(ServerDataProfileTemplate, nil)

return {
	["PerformanceTestGroup"] = PerformanceTestGroup,
	["SharedDataProfileTemplate"] = SharedDataProfileTemplate,
	["ServerDataProfileTemplate"] = ServerDataProfileTemplate,
}
