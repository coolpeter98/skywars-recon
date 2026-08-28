--!strict

-- Bridge maps ship authored geometry plus empty runtime folders. This converts
-- WorldData (GameSpawn/Portal/BuildBounds/Spawn) into the runtime objects, as
-- observed in the populated Castle client snapshot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local Color = require(ReplicatedStorage.TS.color).Color

export type ArenaData = {
	IndicatorPositions: { [string]: Vector3 },
	PortalsByTeam: { [string]: BasePart },
}

export type BuildConstraint = {
	Type: "BoundingBox",
	Minimum: Vector3,
	Maximum: Vector3,
	Whitelist: boolean,
}

local TEAM_IDS = { "Red", "Blue" }
local TEAM_COLORS = {
	Red = Color.Red,
	Blue = Color.LightBlue,
}
local CAGE_HEIGHT = 30
local PORTAL_SIZE = Vector3.new(21, 9, 21)
local PORTAL_CENTER_OFFSET = Vector3.new(0, -PORTAL_SIZE.Y / 2, 0)
local INDICATOR_HEIGHT = 15

local BridgeMap = {}

local function getFolder(parent: Instance, name: string): Folder?
	local child = parent:FindFirstChild(name)
	return if child ~= nil and child:IsA("Folder") then child else nil
end

local function getWorldData(map: Model): Folder?
	return getFolder(map, "WorldData")
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

local function readTeamCFrames(folder: Folder?): { [string]: CFrame }?
	if folder == nil then
		return nil
	end
	local cframes = {}
	for _, teamId in TEAM_IDS do
		local value = folder:FindFirstChild(teamId)
		if value == nil or not value:IsA("CFrameValue") then
			return nil
		end
		cframes[teamId] = value.Value
	end
	return cframes
end

local function collectCFrames(folder: Folder?): { CFrame }
	local cframes = {}
	if folder == nil then
		return cframes
	end
	for _, child in folder:GetChildren() do
		if child:IsA("CFrameValue") then
			table.insert(cframes, child.Value)
		end
	end
	return cframes
end

local function getNearestTeam(position: Vector3, teamCFrames: { [string]: CFrame }): string?
	local selectedTeam: string? = nil
	local selectedDistance = math.huge
	for teamId, teamCFrame in teamCFrames do
		local distance = (position - teamCFrame.Position).Magnitude
		if distance < selectedDistance then
			selectedTeam = teamId
			selectedDistance = distance
		end
	end
	return selectedTeam
end

function BridgeMap.getSpawnPositions(map: Model): { [string]: CFrame }?
	local worldData = getWorldData(map)
	local gameSpawns = worldData and readTeamCFrames(getFolder(worldData, "GameSpawn")) or nil
	if gameSpawns == nil then
		return nil
	end
	local spawnPositions = {}
	for teamId, spawnCFrame in gameSpawns do
		spawnPositions[teamId] = spawnCFrame + Vector3.new(0, CAGE_HEIGHT, 0)
	end
	return spawnPositions
end

function BridgeMap.getBuildConstraints(map: Model): { BuildConstraint }?
	local worldData = getWorldData(map)
	local bounds = collectCFrames(worldData and getFolder(worldData, "BuildBounds") or nil)
	if #bounds ~= 2 then
		return nil
	end
	local first = bounds[1].Position
	local second = bounds[2].Position
	return {
		{
			Type = "BoundingBox",
			Minimum = Vector3.new(
				math.min(first.X, second.X),
				math.min(first.Y, second.Y),
				math.min(first.Z, second.Z)
			),
			Maximum = Vector3.new(
				math.max(first.X, second.X),
				math.max(first.Y, second.Y),
				math.max(first.Z, second.Z)
			),
			Whitelist = true,
		},
	}
end

local function createSpawnLocation(name: string, cframe: CFrame, parent: Instance): SpawnLocation
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Size = Vector3.new(0.001, 0.001, 0.001)
	spawn.CFrame = cframe
	spawn.Transparency = 1
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanQuery = false
	spawn.CanTouch = false
	spawn.Enabled = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = parent
	return spawn
end

local function populateSpawnLocations(map: Model, spawnPositions: { [string]: CFrame }): boolean
	local folder = getFolder(map, "SpawnLocations")
	if folder == nil then
		return false
	end
	clearFolder(folder)
	for index, teamId in TEAM_IDS do
		createSpawnLocation(tostring(index), spawnPositions[teamId], folder)
	end
	return true
end

local function populateWorldSpawn(map: Model, worldData: Folder): boolean
	local spawnValue = worldData:FindFirstChild("Spawn")
	if spawnValue == nil or not spawnValue:IsA("CFrameValue") then
		return false
	end
	for _, child in map:GetChildren() do
		if child:IsA("SpawnLocation") and child.Name == "SpawnLocation" then
			child:Destroy()
		end
	end
	createSpawnLocation("SpawnLocation", spawnValue.Value, map)
	return true
end

local function populatePortals(
	map: Model,
	worldData: Folder,
	gameSpawns: { [string]: CFrame }
): ({ [string]: BasePart }?, { [string]: CFrame }?)
	local folder = getFolder(map, "Portals")
	local portalMarkers = collectCFrames(getFolder(worldData, "Portal"))
	if folder == nil or #portalMarkers ~= #TEAM_IDS then
		return nil, nil
	end
	clearFolder(folder)
	local portalsByTeam = {}
	local indicatorPositions = {}
	for _, portalMarker in portalMarkers do
		local teamId = getNearestTeam(portalMarker.Position, gameSpawns)
		if teamId == nil or portalsByTeam[teamId] ~= nil then
			return nil, nil
		end
		local portal = Instance.new("Part")
		portal.Name = "Portal"
		portal.Size = PORTAL_SIZE
		portal.CFrame = portalMarker * CFrame.new(PORTAL_CENTER_OFFSET)
		portal.Color = TEAM_COLORS[teamId]
		portal.Material = Enum.Material.Neon
		portal.Anchored = true
		portal.CanCollide = false
		portal:SetAttribute(Attribute.TeamId, teamId)
		portal.Parent = folder
		portalsByTeam[teamId] = portal
		indicatorPositions[teamId] = portal.Position + Vector3.new(0, INDICATOR_HEIGHT, 0)
	end
	return portalsByTeam, indicatorPositions
end

function BridgeMap.populate(map: Model): ArenaData?
	local worldData = getWorldData(map)
	local gameSpawns = worldData and readTeamCFrames(getFolder(worldData, "GameSpawn")) or nil
	local spawnPositions = BridgeMap.getSpawnPositions(map)
	local buildConstraints = BridgeMap.getBuildConstraints(map)
	if worldData == nil or gameSpawns == nil or spawnPositions == nil or buildConstraints == nil then
		warn(("[BridgeMap] map %s has incomplete Bridge WorldData"):format(map.Name))
		return nil
	end
	if not populateSpawnLocations(map, spawnPositions) or not populateWorldSpawn(map, worldData) then
		warn(("[BridgeMap] map %s has incomplete Bridge runtime folders"):format(map.Name))
		return nil
	end
	local portalsByTeam, indicatorPositions = populatePortals(map, worldData, gameSpawns)
	if portalsByTeam == nil or indicatorPositions == nil then
		warn(("[BridgeMap] map %s has invalid goal markers"):format(map.Name))
		return nil
	end
	return {
		IndicatorPositions = indicatorPositions,
		PortalsByTeam = portalsByTeam,
	}
end

return BridgeMap
