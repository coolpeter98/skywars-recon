--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Color = require(ReplicatedStorage.TS.color).Color
local GameModes = require(ReplicatedStorage.TS.game["game-mode"]).GameModes
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

local TEAM_NAMES = {
	"LightBlue",
	"Red",
	"Lime",
	"Yellow",
	"Blue",
	"Cyan",
	"Orange",
	"Purple",
	"Pink",
	"Magenta",
	"White",
	"Brown",
}

local SKY_WARS_MAPS = {
	HomeTree = true,
	Construction = true,
	WildWest = true,
	Sakura = true,
	Acropolis = true,
	Farmland = true,
	Aztec = true,
	Colosseum = true,
	Savannah = true,
	Airport = true,
	Prison = true,
	Bank = true,
	ThemePark = true,
	Tundra = true,
	Ruins = true,
	Cargo = true,
	Suburbia = true,
	GrandPrix = true,
	Ash = true,
	Cove = true,
	Fungiland = true,
	Atlantis = true,
	Sphinx = true,
	PhoenixGate = true,
	Mines = true,
	Neon = true,
}

local QUEUEABLE_GAME_MODES = {
	"SkyWarsSolo",
	"SkyWarsDuos",
	"SkyWarsTrios",
	"SkyWarsQuads",
	"SkyWarsOctos",
}

local SkyWarsMode = {}

SkyWarsMode.Id = "SkyWars"

local function getDefinition(gameMode: string)
	local definition = GameModes[gameMode]
	if definition == nil or definition.GameType ~= "SkyWars" then
		return nil
	end
	return definition
end

local function countPlayers(players: { [string]: boolean }): number
	local count = 0
	for _ in players do
		count += 1
	end
	return count
end

function SkyWarsMode.supportsGameMode(gameMode: string): boolean
	return getDefinition(gameMode) ~= nil
end

function SkyWarsMode.supportsCustomGameMode(gameMode: string): boolean
	return SkyWarsMode.supportsGameMode(gameMode)
end

function SkyWarsMode.supportsQueueGameMode(gameMode: string): boolean
	return table.find(QUEUEABLE_GAME_MODES, gameMode) ~= nil
end

function SkyWarsMode.getQueueableGameModes(): { string }
	return table.clone(QUEUEABLE_GAME_MODES)
end

function SkyWarsMode.getDefaultGameMode(): string
	return "SkyWarsSolo"
end

function SkyWarsMode.getMapAssetFolder(): string
	return "SkyWars"
end

function SkyWarsMode.getStarterInventory(_: string): ({ { Type: string, Quantity: number } }, string?)
	return {
		{ Type = "BronzeSword", Quantity = 1 },
		{ Type = "TeamConcrete", Quantity = 32 },
	}, "BronzeSword"
end

function SkyWarsMode.isMapNameValid(mapName: string): boolean
	return mapName == "" or SKY_WARS_MAPS[mapName] == true
end

function SkyWarsMode.getMaximumPlayers(gameMode: string): number
	local definition = getDefinition(gameMode)
	return if definition then definition.TeamSize * definition.MaxTeams else 0
end

function SkyWarsMode.getTeamIds(gameMode: string): { string }
	local definition = getDefinition(gameMode)
	local teamIds = {}
	if definition == nil then
		return teamIds
	end
	for index = 1, definition.MaxTeams do
		teamIds[index] = TEAM_NAMES[index]
	end
	return teamIds
end

function SkyWarsMode.buildTeams(gameMode: string, assignments: { [string]: string }): { any }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local teams = {}
	local teamsById = {}
	for index, teamId in SkyWarsMode.getTeamIds(gameMode) do
		local team = {
			Id = teamId,
			Name = teamId,
			Color = Color.Team[teamId],
			Players = {} :: { [string]: boolean },
			MaxPlayers = definition.TeamSize,
			GroupIndex = index,
			CanRespawn = false,
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

function SkyWarsMode.buildSettings(record: ModeSession): { [string]: any }
	local definition = getDefinition(record.Settings.GameMode)
	assert(definition ~= nil, "SkyWars settings require a SkyWars game mode")
	local mapSettings = table.clone(definition.MapSettings or { Size = "Small" })
	setmetatable(mapSettings, nil)
	if mapSettings.ExcludedRegions ~= nil then
		mapSettings.ExcludedRegions = table.clone(mapSettings.ExcludedRegions)
	end
	return {
		MapName = record.Settings.MapName,
		MapSettings = mapSettings,
		TeamSize = definition.TeamSize,
		MinPlayers = record.Settings.MinimumPlayers or 0,
		MaxPlayers = definition.TeamSize * definition.MaxTeams,
		Teams = SkyWarsMode.buildTeams(record.Settings.GameMode, record.TeamAssignments),
		RespawnBehaviour = { Type = "Never" },
	}
end

function SkyWarsMode.buildGameTeams(record: ModeSession): { [string]: any }
	local gameTeams = {}
	for _, team in SkyWarsMode.buildTeams(record.Settings.GameMode, record.TeamAssignments) do
		gameTeams[team.Id] = {
			Id = team.Id,
			Name = team.Name,
			Color = team.Color,
			CanRespawn = false,
			AliveCount = countPlayers(team.Players),
		}
	end
	return gameTeams
end

function SkyWarsMode.assignBalancedTeams(
	gameMode: string,
	userIds: { number },
	assignments: { [string]: string }
): { [string]: string }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local teamIds = SkyWarsMode.getTeamIds(gameMode)
	local validTeams: { [string]: boolean } = {}
	local counts: { [string]: number } = {}
	for _, teamId in teamIds do
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
		for _, teamId in teamIds do
			if
				counts[teamId] < definition.TeamSize and (selectedTeam == nil or counts[teamId] < counts[selectedTeam])
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

function SkyWarsMode.assignQueuedTeams(gameMode: string, parties: { { number } }): { [string]: string }?
	local definition = getDefinition(gameMode)
	if definition == nil then
		return nil
	end
	return TeamAllocator.assignParties(parties, SkyWarsMode.getTeamIds(gameMode), definition.TeamSize)
end

function SkyWarsMode.sanitizeTeamAssignments(
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
	for _, teamId in SkyWarsMode.getTeamIds(gameMode) do
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

function SkyWarsMode.getMapConfigFolder(gameMode: string): string
	assert(SkyWarsMode.supportsGameMode(gameMode), "Unsupported SkyWars game mode")
	return gameMode
end

return SkyWarsMode
