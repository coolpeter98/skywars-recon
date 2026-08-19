-- GameStore

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameState: { Pregame: string, Countdown: string, InGame: string, Ended: string } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local CurrencyType: { TierOne: string, TierTwo: string, TierThree: string, TierFour: string } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-currency").CurrencyType
local defaultGameStore = {
	["GameState"] = nil,
	["GameStateChangeTime"] = 0,
	["GameTeams"] = nil,
	["GameStats"] = nil,
	["GameCurrency"] = nil,
	["PowerUps"] = nil,
	["BuildConstraints"] = nil,
	["Players"] = nil,
	["TeamUpgrades"] = nil,
	["Zones"] = nil,
	["Cooldowns"] = nil,
	["GameState"] = GameState.Pregame,
	["GameTeams"] = {},
	["GameStats"] = {
		["Wins"] = 0,
		["Kills"] = 0,
		["DamageDealt"] = 0,
		["DamageTaken"] = 0,
		["ExperienceMap"] = nil,
		["ExperienceMultipliers"] = nil,
		["ExperienceCustomNames"] = nil,
		["SeasonPassXp"] = 0,
		["ExperienceMap"] = {},
		["ExperienceMultipliers"] = {},
		["ExperienceCustomNames"] = {}
	}
}
local defaultGameCurrency = {
	["Quantities"] = {
		[CurrencyType.TierOne] = 0,
		[CurrencyType.TierTwo] = 0,
		[CurrencyType.TierThree] = 0,
		[CurrencyType.TierFour] = 0
	}
}
defaultGameStore.GameCurrency = defaultGameCurrency
defaultGameStore.PowerUps = {}
defaultGameStore.BuildConstraints = {}
defaultGameStore.Players = {}
defaultGameStore.TeamUpgrades = {}
defaultGameStore.Zones = {}
defaultGameStore.Cooldowns = {}
return {
	["DefaultGameStore"] = defaultGameStore
}
