--!strict
-- Tracks per-round combat stats and awards XP at round end (public rounds
-- only — every hook checks the session Kind; custom rounds award nothing).
-- Awards update the runtime profile + per-queue stats, replicate GameStats
-- (client end screen) and Profile, refresh nametag attributes, and queue a
-- Drop save.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExperienceRules = require(script.Parent.ExperienceRules)
local GameModes = require(ReplicatedStorage.TS.game["game-mode"]).GameModes
local CurrentSeason = require(ReplicatedStorage.TS.season["season-pass"]).CurrentSeason

-- How long a player's damage on the victim stays eligible for an assist.
local ASSIST_WINDOW_SECONDS = 10

export type RoundStats = {
	Kills: number,
	Assists: number,
	Deaths: number,
	DamageDealt: number,
	DamageTaken: number,
}

local function emptyRoundStats(): RoundStats
	return {
		Kills = 0,
		Assists = 0,
		Deaths = 0,
		DamageDealt = 0,
		DamageTaken = 0,
	}
end

local function toNumber(value: any, fallback: number): number
	return if type(value) == "number" then value else fallback
end

local ExperienceService = {}
ExperienceService.__index = ExperienceService

function ExperienceService.new(context)
	return setmetatable({
		context = context,
		roundStats = {} :: { [Player]: RoundStats },
		damageHistory = {} :: { [Player]: { [Player]: number } },
		participation = {} :: { [Player]: number },
	}, ExperienceService)
end

-- Custom rounds must never grant XP or stats.
function ExperienceService.isPublicRound(self: ExperienceService): boolean
	local roundService = self.context.roundService
	local session = roundService ~= nil and roundService.session or nil
	return session ~= nil and session.Kind == "Public"
end

function ExperienceService.getStats(self: ExperienceService, player: Player): RoundStats
	local stats = self.roundStats[player]
	if stats == nil then
		stats = emptyRoundStats()
		self.roundStats[player] = stats
	end
	return stats
end

function ExperienceService.clearRound(self: ExperienceService)
	table.clear(self.roundStats)
	table.clear(self.damageHistory)
	table.clear(self.participation)
end

function ExperienceService.onRoundStarted(self: ExperienceService)
	self:clearRound()
end

function ExperienceService.onPlayerSpawned(self: ExperienceService, player: Player)
	if not self:isPublicRound() then
		return
	end
	-- Keep the earliest participation time: respawns and Bridge point resets
	-- re-spawn without resetting the clock.
	if self.participation[player] == nil then
		self.participation[player] = os.clock()
	end
end

-- Assists: any validated damaging hit refreshes the attacker's eligibility.
function ExperienceService.onDamage(self: ExperienceService, attacker: Player?, target: Player, damage: number)
	if not self:isPublicRound() or damage <= 0 then
		return
	end
	local targetStats = self:getStats(target)
	targetStats.DamageTaken += damage
	if attacker ~= nil and attacker ~= target and attacker.Parent == Players then
		self:getStats(attacker).DamageDealt += damage
		local history = self.damageHistory[target]
		if history == nil then
			history = {}
			self.damageHistory[target] = history
		end
		history[attacker] = os.clock()
	end
end

-- Credits the killer plus anyone who damaged the victim within the assist
-- window. Respawn-mode eliminations count too — still combat outcomes.
function ExperienceService.onElimination(self: ExperienceService, player: Player, killer: Player?)
	if not self:isPublicRound() then
		return
	end
	self:getStats(player).Deaths += 1
	if killer ~= nil and killer ~= player and killer.Parent == Players then
		self:getStats(killer).Kills += 1
	end
	local history = self.damageHistory[player]
	if history ~= nil then
		local cutoff = os.clock() - ASSIST_WINDOW_SECONDS
		for attacker, lastHit in history do
			if lastHit >= cutoff and attacker ~= killer and attacker.Parent == Players then
				self:getStats(attacker).Assists += 1
			end
		end
		self.damageHistory[player] = nil
	end
end

-- Production queue id backing a game mode (keys per-queue profile stats).
function ExperienceService.getQueueId(self: ExperienceService, gameMode: string): string?
	local definition = GameModes[gameMode]
	if definition == nil then
		return nil
	end
	local queue = definition.Queue
	if type(queue) ~= "table" then
		return nil
	end
	local queueId = queue.Production
	return if type(queueId) == "string" then queueId else nil
end

function ExperienceService.awardPlayer(
	self: ExperienceService,
	player: Player,
	stats: RoundStats,
	position: number?,
	secondsPlayed: number,
	experience: ExperienceRules.ExperienceTable,
	gameMode: string
)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local profile = session.profile

	local matchExperience =
		ExperienceRules.computeMatchExperience(experience, stats.Kills, stats.Assists, position, secondsPlayed)
	local total = matchExperience.Total

	profile.Experience = toNumber(profile.Experience, 0) + total

	-- Season pass XP mirrors match XP (reconstructed; original rate lost).
	local season = profile.Season
	if type(season) == "table" and type(season.SeasonData) == "table" then
		local seasonEntry = season.SeasonData[CurrentSeason]
		if type(seasonEntry) == "table" then
			seasonEntry.Experience = toNumber(seasonEntry.Experience, 0) + total
		end
	end

	local didWin = position == 1
	local queueId = self:getQueueId(gameMode)
	if queueId ~= nil and type(profile.Stats) == "table" then
		local queueStats = profile.Stats[queueId]
		if type(queueStats) ~= "table" then
			queueStats = {}
			profile.Stats[queueId] = queueStats
		end
		queueStats.Wins = toNumber(queueStats.Wins, 0) + (if didWin then 1 else 0)
		queueStats.Losses = toNumber(queueStats.Losses, 0) + (if didWin then 0 else 1)
		queueStats.WinStreak = if didWin then toNumber(queueStats.WinStreak, 0) + 1 else 0
		queueStats.Kills = toNumber(queueStats.Kills, 0) + stats.Kills
		queueStats.Deaths = toNumber(queueStats.Deaths, 0) + stats.Deaths
		queueStats.DamageDealt = toNumber(queueStats.DamageDealt, 0) + stats.DamageDealt
		queueStats.DamageTaken = toNumber(queueStats.DamageTaken, 0) + stats.DamageTaken
	end

	-- GameStats drives the client end screen; Profile drives the level bar.
	self.context.outbound:setValue(player, "GameStats", {
		Wins = if didWin then 1 else 0,
		Kills = stats.Kills,
		DamageDealt = stats.DamageDealt,
		DamageTaken = stats.DamageTaken,
		ExperienceMap = matchExperience.Breakdown,
		ExperienceMultipliers = {},
		PodiumPosition = position,
		SeasonPassXp = total,
		ExperienceCustomNames = {},
	})
	self.context.outbound:sendProfile(player, profile)
	local nametagService = self.context.nametagService
	if nametagService ~= nil then
		nametagService:refreshAttributes(player)
	end
	local dataService = self.context.dataService
	if dataService ~= nil then
		dataService:save(player)
	end
end

-- `placements` mirrors the GameResult payload: index 1 is the winners array,
-- index 2 the eliminated players in reverse elimination order, so offset + 1
-- is each player's finish position.
function ExperienceService.onRoundEnded(self: ExperienceService, winners: { Player }, placements: { { Player } })
	if not self:isPublicRound() then
		self:clearRound()
		return
	end
	local session = self.context.roundService.session
	if session == nil then
		self:clearRound()
		return
	end
	local experience = ExperienceRules.resolveExperience(session.GameMode, GameModes)
	if experience == nil then
		warn(("[ExperienceService] No experience table for %s; awarding nothing."):format(session.GameMode))
		self:clearRound()
		return
	end

	local positions = {} :: { [Player]: number }
	for _, winner in winners do
		positions[winner] = 1
	end
	local eliminated = placements[2]
	if eliminated ~= nil then
		for index, player in eliminated do
			positions[player] = index + 1
		end
	end

	for _, player in Players:GetPlayers() do
		local stats = self.roundStats[player]
		local startedAt = self.participation[player]
		if stats ~= nil and startedAt ~= nil and player.Parent == Players then
			self:awardPlayer(player, stats, positions[player], os.clock() - startedAt, experience, session.GameMode)
		end
	end
	self:clearRound()
end

function ExperienceService.start(_: ExperienceService) end

function ExperienceService.stop(_: ExperienceService) end

return ExperienceService
