--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Color = require(ReplicatedStorage.TS.color).Color
local GameModes = require(ReplicatedStorage.TS.game["game-mode"]).GameModes
local BridgeMap = require(script.Parent.BridgeMap)
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

local GAME_MODES = { "DuelsSolo", "DuelsDuos" }
local TEAM_IDS = { "Red", "Blue" }
local TEAM_COLORS = {
	Red = Color.Red,
	Blue = Color.LightBlue,
}
local MAP_ASSET_NAMES = {
	Castle = "Castle",
	Ships = "Ships",
	PhoenixBridge = "Phoenix Bridge",
}
local STARTER_ARMOUR = { "IronHelmet", "IronChestplate", "IronLeggings" }

local BridgeMode = {}

BridgeMode.Id = "Bridge"

local function getDefinition(gameMode: string)
	local definition = GameModes[gameMode]
	return if definition ~= nil and definition.GameType == "Duels" then definition else nil
end

local function countPlayers(players: { [string]: boolean }): number
	local count = 0
	for _ in players do
		count += 1
	end
	return count
end

function BridgeMode.supportsGameMode(gameMode: string): boolean
	return table.find(GAME_MODES, gameMode) ~= nil and getDefinition(gameMode) ~= nil
end

function BridgeMode.supportsCustomGameMode(gameMode: string): boolean
	return BridgeMode.supportsGameMode(gameMode)
end

function BridgeMode.supportsQueueGameMode(gameMode: string): boolean
	return BridgeMode.supportsGameMode(gameMode)
end

function BridgeMode.getQueueableGameModes(): { string }
	return table.clone(GAME_MODES)
end

function BridgeMode.getDefaultGameMode(): string
	return "DuelsSolo"
end

function BridgeMode.getMapAssetFolder(): string
	return "Bridge"
end

function BridgeMode.getStarterInventory(_: string): ({ { Type: string, Quantity: number } }, string?)
	return {
		{ Type = "DiamondSword", Quantity = 1 },
		{ Type = "Bow", Quantity = 1 },
		{ Type = "DiamondPickaxe", Quantity = 1 },
		{ Type = "TeamConcrete", Quantity = 100 },
		{ Type = "IronHelmet", Quantity = 1 },
		{ Type = "IronChestplate", Quantity = 1 },
		{ Type = "IronLeggings", Quantity = 1 },
	},
		"DiamondSword"
end

function BridgeMode.getStarterArmour(_: string): { string }
	return table.clone(STARTER_ARMOUR)
end

function BridgeMode.isMapNameValid(mapName: string): boolean
	return mapName == "" or MAP_ASSET_NAMES[mapName] ~= nil
end

function BridgeMode.resolveMapAssetName(mapName: string): string
	return MAP_ASSET_NAMES[mapName] or mapName
end

function BridgeMode.getCatalogMapName(assetName: string): string
	for mapName, candidateAssetName in MAP_ASSET_NAMES do
		if candidateAssetName == assetName then
			return mapName
		end
	end
	return assetName
end

function BridgeMode.getMaximumPlayers(gameMode: string): number
	local definition = getDefinition(gameMode)
	return if definition ~= nil then definition.TeamSize * definition.MaxTeams else 0
end

function BridgeMode.getTeamIds(gameMode: string): { string }
	return if BridgeMode.supportsGameMode(gameMode) then table.clone(TEAM_IDS) else {}
end

function BridgeMode.buildTeams(gameMode: string, assignments: { [string]: string }): { any }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local teams = {}
	local teamsById = {}
	for index, teamId in TEAM_IDS do
		local team = {
			Id = teamId,
			Name = teamId,
			Color = TEAM_COLORS[teamId],
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

function BridgeMode.buildSettings(record: ModeSession): { [string]: any }
	local definition = getDefinition(record.Settings.GameMode)
	assert(definition ~= nil, "Bridge settings require a Duels game mode")
	return {
		MapName = record.Settings.MapName,
		MapSettings = { Size = "Small" },
		TeamSize = definition.TeamSize,
		MinPlayers = record.Settings.MinimumPlayers or 0,
		MaxPlayers = definition.TeamSize * definition.MaxTeams,
		Teams = BridgeMode.buildTeams(record.Settings.GameMode, record.TeamAssignments),
		RespawnBehaviour = { Type = "Always", Delay = 0 },
	}
end

function BridgeMode.buildGameTeams(record: ModeSession): { [string]: any }
	local gameTeams = {}
	for _, team in BridgeMode.buildTeams(record.Settings.GameMode, record.TeamAssignments) do
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

function BridgeMode.assignBalancedTeams(
	gameMode: string,
	userIds: { number },
	assignments: { [string]: string }
): { [string]: string }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local validTeams = { Red = true, Blue = true }
	local counts = { Red = 0, Blue = 0 }
	local result = {}
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

function BridgeMode.assignQueuedTeams(gameMode: string, parties: { { number } }): { [string]: string }?
	local definition = getDefinition(gameMode)
	if definition == nil then
		return nil
	end
	return TeamAllocator.assignParties(parties, TEAM_IDS, definition.TeamSize)
end

function BridgeMode.sanitizeTeamAssignments(
	gameMode: string,
	userIds: { number },
	assignments: { [string]: string }
): { [string]: string }
	local definition = getDefinition(gameMode)
	if definition == nil then
		return {}
	end
	local validTeams = { Red = true, Blue = true }
	local counts = { Red = 0, Blue = 0 }
	local result = {}
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

function BridgeMode.getMapConfigFolder(gameMode: string): string
	assert(BridgeMode.supportsGameMode(gameMode), "Unsupported Bridge game mode")
	return if gameMode == "DuelsSolo" then "Solo" else "Duo"
end

function BridgeMode.getImportedSpawnPositions(map: Model): { [string]: CFrame }?
	return BridgeMap.getSpawnPositions(map)
end

function BridgeMode.getImportedBuildConstraints(map: Model): { BridgeMap.BuildConstraint }?
	return BridgeMap.getBuildConstraints(map)
end

return BridgeMode
