--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Color = require(ReplicatedStorage.TS.color).Color
local EggCharacters = require(ReplicatedStorage.TS["egg-character"]["egg-character"]).EggCharacters
local GameModes = require(ReplicatedStorage.TS.game["game-mode"]).GameModes
local EggWarsMap = require(script.Parent.EggWarsMap)
local TeamAllocator = require(script.Parent.TeamAllocator)

export type ModeSession = {
	Settings: {
		GameMode: string,
		MapName: string,
		AllowTeamSelection: boolean,
		MinimumPlayers: number?,
	},
	TeamAssignments: { [string]: string },
}

-- All runtime/custom-game surfaces are implemented. Exposure remains off to
-- match the original client/server product, where Egg Wars was queue-only.
local CUSTOM_GAMES_ENABLED = false
local GAME_MODE = "EggWarsQuads"
local TEAM_IDS = { "Red", "Lime", "Cyan", "Yellow" }
local MAPS = {
	ConstructionEgg = true,
	PhoenixEgg = true,
	TundraEgg = true,
}

local EggWarsMode = {}

EggWarsMode.Id = "EggWars"

local function getDefinition(gameMode: string)
	local definition = GameModes[gameMode]
	return if definition ~= nil and definition.GameType == "EggWars" then definition else nil
end

local function countPlayers(players: { [string]: boolean }): number
	local count = 0
	for _ in players do
		count += 1
	end
	return count
end

function EggWarsMode.supportsGameMode(gameMode: string): boolean
	return gameMode == GAME_MODE and getDefinition(gameMode) ~= nil
end

function EggWarsMode.supportsCustomGameMode(gameMode: string): boolean
	return CUSTOM_GAMES_ENABLED and EggWarsMode.supportsGameMode(gameMode)
end

function EggWarsMode.supportsQueueGameMode(gameMode: string): boolean
	return EggWarsMode.supportsGameMode(gameMode)
end

function EggWarsMode.getQueueableGameModes(): { string }
	return { GAME_MODE }
end

function EggWarsMode.getDefaultGameMode(): string
	return GAME_MODE
end

function EggWarsMode.getMapAssetFolder(): string
	return "EggWars"
end

function EggWarsMode.getStarterInventory(_: string): ({ { Type: string, Quantity: number } }, string?)
	return {
		{ Type = "BronzeSword", Quantity = 1 },
		{ Type = "BronzePickaxe", Quantity = 1 },
		{ Type = "BronzeHelmet", Quantity = 1 },
		{ Type = "BronzeChestplate", Quantity = 1 },
		{ Type = "BronzeLeggings", Quantity = 1 },
	},
		"BronzeSword"
end

function EggWarsMode.isMapNameValid(mapName: string): boolean
	return mapName == "" or MAPS[mapName] == true
end

function EggWarsMode.getMaximumPlayers(gameMode: string): number
	local definition = getDefinition(gameMode)
	return if definition ~= nil then definition.TeamSize * definition.MaxTeams else 0
end

function EggWarsMode.getTeamIds(gameMode: string): { string }
	return if EggWarsMode.supportsGameMode(gameMode) then table.clone(TEAM_IDS) else {}
end

function EggWarsMode.buildTeams(gameMode: string, assignments: { [string]: string }): { any }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local teams = {}
	local teamsById = {}
	for index, teamId in TEAM_IDS do
		local eggCharacter = EggCharacters[teamId]
		local team = {
			Id = teamId,
			Name = teamId,
			-- Egg Wars uses the softer character palette shown by its recovered UI,
			-- not the saturated generic team colors used by SkyWars.
			Color = if eggCharacter ~= nil and eggCharacter.Color ~= nil
				then eggCharacter.Color
				else Color.Team[teamId],
			Players = {} :: { [string]: boolean },
			MaxPlayers = definition.TeamSize,
			GroupIndex = index,
			CanRespawn = true,
		}
		teams[index] = team
		teamsById[teamId] = team
	end
	for userId, teamId in assignments do
		local team = teamsById[teamId]
		if team ~= nil and countPlayers(team.Players) < team.MaxPlayers then
			team.Players[userId] = true
		end
	end
	return teams
end

function EggWarsMode.buildSettings(record: ModeSession): { [string]: any }
	local definition = getDefinition(record.Settings.GameMode)
	assert(definition ~= nil, "Egg Wars settings require EggWarsQuads")
	return {
		MapName = record.Settings.MapName,
		MapSettings = { Size = "Small" },
		TeamSize = definition.TeamSize,
		MinPlayers = record.Settings.MinimumPlayers or 0,
		MaxPlayers = definition.TeamSize * definition.MaxTeams,
		Teams = EggWarsMode.buildTeams(record.Settings.GameMode, record.TeamAssignments),
		RespawnBehaviour = { Type = "Team", Delay = definition.RespawnBehaviour.Delay },
	}
end

function EggWarsMode.buildGameTeams(record: ModeSession): { [string]: any }
	local gameTeams = {}
	for _, team in EggWarsMode.buildTeams(record.Settings.GameMode, record.TeamAssignments) do
		gameTeams[team.Id] = {
			Id = team.Id,
			Name = team.Name,
			Color = team.Color,
			CanRespawn = true,
			AliveCount = countPlayers(team.Players),
		}
	end
	return gameTeams
end

function EggWarsMode.assignBalancedTeams(
	gameMode: string,
	userIds: { number },
	assignments: { [string]: string }
): { [string]: string }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local validTeams: { [string]: boolean } = {}
	local counts: { [string]: number } = {}
	for _, teamId in TEAM_IDS do
		validTeams[teamId] = true
		counts[teamId] = 0
	end
	local result: { [string]: string } = {}
	local pending = {}
	for _, userId in userIds do
		local userIdKey = tostring(userId)
		local teamId = assignments[userIdKey]
		if teamId ~= nil and validTeams[teamId] and counts[teamId] < definition.TeamSize then
			result[userIdKey] = teamId
			counts[teamId] += 1
		else
			table.insert(pending, userId)
		end
	end
	for _, userId in pending do
		local selectedTeam: string? = nil
		for _, teamId in TEAM_IDS do
			if
				counts[teamId] < definition.TeamSize
				and (selectedTeam == nil or counts[teamId] < counts[selectedTeam])
			then
				selectedTeam = teamId
			end
		end
		if selectedTeam ~= nil then
			result[tostring(userId)] = selectedTeam
			counts[selectedTeam] += 1
		end
	end
	return result
end

function EggWarsMode.assignQueuedTeams(gameMode: string, parties: { { number } }): { [string]: string }?
	local definition = getDefinition(gameMode)
	if definition == nil then
		return nil
	end
	return TeamAllocator.assignParties(parties, TEAM_IDS, definition.TeamSize)
end

function EggWarsMode.sanitizeTeamAssignments(
	gameMode: string,
	userIds: { number },
	assignments: { [string]: string }
): { [string]: string }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local validTeams: { [string]: boolean } = {}
	local counts: { [string]: number } = {}
	for _, teamId in TEAM_IDS do
		validTeams[teamId] = true
		counts[teamId] = 0
	end
	local result: { [string]: string } = {}
	for _, userId in userIds do
		local userIdKey = tostring(userId)
		local teamId = assignments[userIdKey]
		if teamId ~= nil and validTeams[teamId] and counts[teamId] < definition.TeamSize then
			result[userIdKey] = teamId
			counts[teamId] += 1
		end
	end
	return result
end

function EggWarsMode.getMapConfigFolder(gameMode: string): string
	assert(EggWarsMode.supportsGameMode(gameMode), "Unsupported Egg Wars game mode")
	return "Squads"
end

function EggWarsMode.getImportedSpawnPositions(map: Model): { [string]: CFrame }?
	return EggWarsMap.getSpawnPositions(map)
end

return EggWarsMode
