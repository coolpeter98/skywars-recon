--!strict
-- MapService — builds and owns the active arena for any game round.
--
-- Primary path: imported maps at ServerStorage.Maps.<GameType>.<MapName>
-- (the original game's convention, read by ReplicatedStorage.TS.game.map["map-info"]).
-- SkyWars layout: WorldData (Spawn/Chest.Tier.1..4/GameSpawn CFrameValues),
-- SpawnLocations 1..12 mapping 1:1 onto the twelve SkyWars teams, and island
-- geometry models. Chests are spawned fresh from the ReplicatedStorage/Misc
-- ChestTierOne..Four prefabs, which carry the AnimationController rig the
-- client's chest component requires. Random picks from valid imported maps;
-- the placeholder is only a recovery path. Arenas clone to
-- Workspace.BlockContainer.Map (client block raycast whitelists exactly
-- Workspace.BlockContainer), catalog id in the SelectedMapName attribute.

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ModeRegistry = require(script.Parent.Parent.modes.ModeRegistry)
local ChestLoot = require(script.Parent.Parent.world.ChestLoot)

export type BuildConstraint = {
	Type: "BoundingBox",
	Minimum: Vector3,
	Maximum: Vector3,
	Whitelist: boolean,
}

export type LoadedMap = {
	BuildConstraints: { BuildConstraint },
	Model: Model,
	SpawnPositions: { [string]: CFrame },
	SpectatorCFrame: CFrame,
	VoidY: number,
}

-- Recovered maps are authored around world origin; keeping those coordinates
-- keeps arenas below the pre-game lobby (floor ~Y=134) and on the 3-stud grid.
-- Only the recovery placeholder uses this.
local MAP_ORIGIN = Vector3.zero
local BLOCK_SIZE = 3
local BUILD_HORIZONTAL_PADDING = 36
local BUILD_MIN_Y_PADDING = 12
local BUILD_MAX_Y_PADDING = 90
local VOID_BELOW_MAP = 60
local SPECTATOR_HEIGHT = 100
local PLATFORM_BLOCK_NAME = "StoneBricks"
local PLACED_BLOCK_TAG = "block:placed"
local TEMPLATE_VERSION = 5
local CHEST_ASSET_NAMES = { "ChestTierOne", "ChestTierTwo", "ChestTierThree", "ChestTierFour" }
local CHEST_BASE_OFFSET_FROM_POSITION = 1.5

local MapService = {}
MapService.__index = MapService

local function createPart(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- Places a cloned chest prefab so its bounding-box base sits `baseOffset`
-- studs below `cframe` (chests are yaw-only, so the AABB is exact).
local function createChest(name: string, cframe: CFrame, tier: number, parent: Instance, baseOffset: number): Model?
	local misc = ReplicatedStorage:FindFirstChild("Misc")
	local assetName = CHEST_ASSET_NAMES[tier] or "Chest"
	local asset = misc and misc:FindFirstChild(assetName) or nil
	if asset == nil or not asset:IsA("Model") then
		warn(("[MapService] missing chest asset %s"):format(assetName))
		return nil
	end
	local chest = asset:Clone()
	chest.Name = name

	local boundingCFrame, boundingSize = chest:GetBoundingBox()
	local boundingOffset = boundingCFrame.Position - chest:GetPivot().Position
	local bottomY = cframe.Position.Y - baseOffset
	chest:PivotTo(
		CFrame.new(
			cframe.Position.X - boundingOffset.X,
			bottomY + boundingSize.Y / 2 - boundingOffset.Y,
			cframe.Position.Z - boundingOffset.Z
		) * (cframe - cframe.Position)
	)

	if chest.PrimaryPart == nil then
		local largestPart: BasePart? = nil
		for _, descendant in chest:GetDescendants() do
			if
				descendant:IsA("BasePart")
				and (largestPart == nil or descendant.Size.Magnitude > largestPart.Size.Magnitude)
			then
				largestPart = descendant
			end
		end
		chest.PrimaryPart = largestPart
	end

	chest:SetAttribute("Inventory", HttpService:JSONEncode(ChestLoot.getContents(tier)))
	chest:SetAttribute("ChestTier", tier)
	CollectionService:AddTag(chest, "block:chest")
	chest.Parent = parent
	return chest
end

local function snap(value: number): number
	return math.round(value / BLOCK_SIZE) * BLOCK_SIZE
end

local function getGridAlignedPlatformSize(configuredSize: Vector3): Vector3
	local function getAxisSize(axisSize: number): number
		local cellCount = math.max(1, math.ceil(axisSize / BLOCK_SIZE))
		if cellCount % 2 == 0 then
			cellCount += 1
		end
		return cellCount * BLOCK_SIZE
	end
	return Vector3.new(getAxisSize(configuredSize.X), BLOCK_SIZE, getAxisSize(configuredSize.Z))
end

local function getBuildConstraints(activeMap: Model): { BuildConstraint }
	local boundsCFrame, boundsSize = activeMap:GetBoundingBox()
	local halfSize = boundsSize / 2
	local boundsCenter = boundsCFrame.Position
	return {
		{
			Type = "BoundingBox",
			Minimum = Vector3.new(
				boundsCenter.X - halfSize.X - BUILD_HORIZONTAL_PADDING,
				boundsCenter.Y - halfSize.Y - BUILD_MIN_Y_PADDING,
				boundsCenter.Z - halfSize.Z - BUILD_HORIZONTAL_PADDING
			),
			Maximum = Vector3.new(
				boundsCenter.X + halfSize.X + BUILD_HORIZONTAL_PADDING,
				boundsCenter.Y + halfSize.Y + BUILD_MAX_Y_PADDING,
				boundsCenter.Z + halfSize.Z + BUILD_HORIZONTAL_PADDING
			),
			Whitelist = true,
		},
	}
end

local function buildTemplate(gameMode: string, destination: Instance): Model
	local adapter = ModeRegistry.get(gameMode)
	assert(adapter ~= nil, "No mode adapter for " .. gameMode)
	local mapRoot = ServerStorage:WaitForChild("Maps"):WaitForChild(adapter.getMapAssetFolder())
	local configFolder = mapRoot:WaitForChild(adapter.getMapConfigFolder(gameMode))
	local config = require(configFolder:WaitForChild("MapConfig"))
	local teamIds = adapter.getTeamIds(gameMode)

	local template = Instance.new("Model")
	template.Name = "Template"
	template:SetAttribute("GameMode", gameMode)
	template:SetAttribute("Placeholder", true)
	template:SetAttribute("TemplateVersion", TEMPLATE_VERSION)

	local centerIsland = Instance.new("Model")
	centerIsland.Name = "CenterIsland"
	centerIsland.Parent = template
	createPart(
		PLATFORM_BLOCK_NAME,
		getGridAlignedPlatformSize(config.CenterSize),
		CFrame.new(MAP_ORIGIN),
		Color3.fromRGB(111, 135, 86),
		centerIsland
	)
	for index = 1, 4 do
		local angle = (index - 1) * math.pi / 2
		createChest(
			("CenterChest%d"):format(index),
			CFrame.new(MAP_ORIGIN + Vector3.new(math.cos(angle) * 12, 4.5, math.sin(angle) * 12)),
			3 + (index - 1) % 2,
			centerIsland,
			CHEST_BASE_OFFSET_FROM_POSITION
		)
	end

	local teamIslands = Instance.new("Folder")
	teamIslands.Name = "TeamIslands"
	teamIslands.Parent = template
	for index, teamId in teamIds do
		local angle = ((index - 1) / config.TeamCount) * math.pi * 2
		local islandPosition = MAP_ORIGIN
			+ Vector3.new(snap(math.cos(angle) * config.IslandRadius), 0, snap(math.sin(angle) * config.IslandRadius))
		local island = Instance.new("Model")
		island.Name = teamId
		island:SetAttribute("TeamId", teamId)
		island.Parent = teamIslands
		createPart(
			PLATFORM_BLOCK_NAME,
			getGridAlignedPlatformSize(config.IslandSize),
			CFrame.new(islandPosition),
			Color3.fromRGB(101, 125, 76),
			island
		)
		local spawn = createPart(
			"Spawn",
			Vector3.new(6, 1, 6),
			CFrame.lookAt(islandPosition + Vector3.new(0, 5, 0), MAP_ORIGIN + Vector3.new(0, 5, 0)),
			Color3.fromRGB(255, 255, 255),
			island
		)
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.CanQuery = false
		spawn.CanTouch = false
		for chestIndex = 1, config.ChestsPerIsland do
			local lateralOffset = (chestIndex - (config.ChestsPerIsland + 1) / 2) * 6
			local towardCenter = (MAP_ORIGIN - islandPosition).Unit
			local lateral = Vector3.new(-towardCenter.Z, 0, towardCenter.X)
			createChest(
				("Chest%d"):format(chestIndex),
				CFrame.new(islandPosition + lateral * lateralOffset + Vector3.new(0, 4.5, 0)),
				math.min(chestIndex, 2),
				island,
				CHEST_BASE_OFFSET_FROM_POSITION
			)
		end
	end
	template.Parent = destination
	return template
end

function MapService.new()
	return setmetatable({
		activeMap = nil :: Model?,
		random = Random.new(),
	}, MapService)
end

function MapService.ensureTemplate(self, gameMode: string): Model
	local adapter = ModeRegistry.get(gameMode)
	assert(adapter ~= nil, "Unsupported game mode")
	local mapFolder = ServerStorage.Maps:FindFirstChild(adapter.getMapAssetFolder())
	local modeFolder = mapFolder and mapFolder:FindFirstChild(adapter.getMapConfigFolder(gameMode))
	assert(modeFolder ~= nil, "Missing placeholder map folder for " .. gameMode)
	local template = modeFolder:FindFirstChild("Template")
	if template and template:IsA("Model") and template:GetAttribute("TemplateVersion") == TEMPLATE_VERSION then
		return template
	end
	if template ~= nil then
		template:Destroy()
	end
	return buildTemplate(gameMode, modeFolder)
end

-- Reads the map's anchor (WorldData.Spawn, falling back to the top-level
-- SpawnLocation part that mirrors it).
local function getAnchorPosition(mapAsset: Model): Vector3?
	local worldData = mapAsset:FindFirstChild("WorldData")
	if worldData ~= nil then
		local spawnValue = worldData:FindFirstChild("Spawn")
		if spawnValue ~= nil and spawnValue:IsA("CFrameValue") then
			return spawnValue.Value.Position
		end
	end
	for _, child in mapAsset:GetChildren() do
		if child:IsA("SpawnLocation") and child.Name == "SpawnLocation" then
			return child.CFrame.Position
		end
	end
	return nil
end

local function getImportedMapNames(gameMode: string): { string }
	local adapter = ModeRegistry.get(gameMode)
	if adapter == nil then
		return {}
	end
	local maps = ServerStorage:FindFirstChild("Maps")
	local modeMaps = maps and maps:FindFirstChild(adapter.getMapAssetFolder())
	local mapNames = {}
	if modeMaps == nil then
		return mapNames
	end
	for _, child in modeMaps:GetChildren() do
		local catalogName = if type(adapter.getCatalogMapName) == "function"
			then adapter.getCatalogMapName(child.Name)
			else child.Name
		if
			child:IsA("Model")
			and adapter.isMapNameValid(catalogName)
			and getAnchorPosition(child) ~= nil
			and child:FindFirstChild("SpawnLocations") ~= nil
		then
			table.insert(mapNames, catalogName)
		end
	end
	table.sort(mapNames)
	return mapNames
end

-- Tries to load an imported map into `blockContainer`; returns nil (or a
-- destroyed map) on failure so load() falls back to the placeholder arena.
function MapService.loadMap(self, gameMode: string, mapName: string, blockContainer: Instance): LoadedMap?
	local adapter = ModeRegistry.get(gameMode)
	if adapter == nil then
		return nil
	end
	local maps = ServerStorage:FindFirstChild("Maps")
	local modeMaps = maps and maps:FindFirstChild(adapter.getMapAssetFolder())
	local assetName = if type(adapter.resolveMapAssetName) == "function"
		then adapter.resolveMapAssetName(mapName)
		else mapName
	local mapAsset = modeMaps and modeMaps:FindFirstChild(assetName)
	if mapAsset == nil or not mapAsset:IsA("Model") then
		return nil
	end

	if getAnchorPosition(mapAsset) == nil then
		warn(("[MapService] map %q has no WorldData.Spawn anchor"):format(mapName))
		return nil
	end

	local map = mapAsset:Clone()
	-- The live server always exposes the active arena as Workspace.BlockContainer.Map.
	map.Name = "Map"
	map:SetAttribute("SelectedMapName", mapName)
	map:SetAttribute("Placeholder", false)

	-- Do not PivotTo a synthetic anchor: PivotTo consumes an absolute model
	-- pivot, not a transform, and most maps have a saved pivot at Y=1.5, which
	-- shifted them off the client's 3-stud grid.
	map.Parent = blockContainer

	-- Most modes read numbered SpawnLocations; WorldData-driven modes provide
	-- their own reader and populate their runtime folders later (at cage time).
	local teamIds = adapter.getTeamIds(gameMode)
	local spawnPositions: { [string]: CFrame } = {}
	local importedSpawnReader = adapter.getImportedSpawnPositions
	local usesDeferredWorldPopulation = type(importedSpawnReader) == "function"
	if usesDeferredWorldPopulation then
		local importedSpawnPositions = importedSpawnReader(map)
		if importedSpawnPositions == nil then
			warn(("[MapService] map %q has invalid WorldData game spawns"):format(mapName))
			map:Destroy()
			return nil
		end
		spawnPositions = importedSpawnPositions
	else
		local spawnLocationsFolder = map:FindFirstChild("SpawnLocations")
		if spawnLocationsFolder == nil or not spawnLocationsFolder:IsA("Folder") then
			warn(("[MapService] map %q has no SpawnLocations folder"):format(mapName))
			map:Destroy()
			return nil
		end
		local spawnsByIndex: { [number]: SpawnLocation } = {}
		local spawnCount = 0
		for _, spawnLocation in spawnLocationsFolder:GetChildren() do
			if spawnLocation:IsA("SpawnLocation") then
				local spawnIndex = tonumber(spawnLocation.Name)
				if spawnIndex ~= nil and spawnIndex >= 1 and spawnIndex % 1 == 0 then
					spawnsByIndex[spawnIndex] = spawnLocation
					spawnCount = math.max(spawnCount, spawnIndex)
				end
			end
		end
		if spawnCount < #teamIds then
			warn(
				("[MapService] map %q has %d spawns but mode %s needs %d teams"):format(
					mapName,
					spawnCount,
					gameMode,
					#teamIds
				)
			)
			map:Destroy()
			return nil
		end
		for ordinal, teamId in teamIds do
			local spawnIndex = math.floor(1 + ((ordinal - 1) * spawnCount) / #teamIds + 0.5)
			local spawnLocation = spawnsByIndex[spawnIndex]
			if spawnLocation == nil then
				warn(("[MapService] map %q is missing spawn location %d"):format(mapName, spawnIndex))
				map:Destroy()
				return nil
			end
			spawnPositions[teamId] = spawnLocation.CFrame
		end
		spawnLocationsFolder:Destroy()
	end

	-- Anchor SpawnLocation mirrors WorldData.Spawn; kill it so it never acts
	-- as a default Roblox spawn. Deferred modes keep it until population.
	if not usesDeferredWorldPopulation then
		for _, child in map:GetChildren() do
			if child:IsA("SpawnLocation") and child.Name == "SpawnLocation" then
				child:Destroy()
			end
		end
	end

	-- Discard the generator-placed chest templates: no animation rig (the
	-- client's chest component needs one) and baked ProximityPrompts. Fresh
	-- prefab chests are spawned at the WorldData.Chest.Tier CFrameValues below.
	local worldData = map:FindFirstChild("WorldData")
	if not usesDeferredWorldPopulation then
		local chestsFolder = map:FindFirstChild("Chests")
		if chestsFolder ~= nil then
			chestsFolder:Destroy()
		end
	end
	if worldData ~= nil and not usesDeferredWorldPopulation then
		local chestFolder = worldData:FindFirstChild("Chest")
		local tierFolder = chestFolder and chestFolder:FindFirstChild("Tier")
		if tierFolder ~= nil and tierFolder:IsA("Folder") then
			for _, tierGroup in tierFolder:GetChildren() do
				local tier = tonumber(tierGroup.Name)
				if tier ~= nil and ChestLoot.getContents(tier) ~= nil then
					local chestIndex = 0
					for _, cframeValue in tierGroup:GetChildren() do
						if cframeValue:IsA("CFrameValue") then
							chestIndex += 1
							-- The prefab's lock sits on its +Z side, opposite the map
							-- generator's convention, hence the 180° yaw.
							createChest(
								("Chest_T%d_%d"):format(tier, chestIndex),
								cframeValue.Value * CFrame.Angles(0, math.pi, 0),
								tier,
								map,
								0
							)
						end
					end
				end
			end
		end
	end

	local boundingCFrame = map:GetBoundingBox()
	local mapCenter = boundingCFrame.Position
	local importedBuildConstraintReader = adapter.getImportedBuildConstraints
	local constraints = if type(importedBuildConstraintReader) == "function"
		then importedBuildConstraintReader(map)
		else getBuildConstraints(map)
	if constraints == nil or #constraints == 0 then
		warn(("[MapService] map %q has invalid build constraints"):format(mapName))
		map:Destroy()
		return nil
	end
	return {
		BuildConstraints = constraints,
		Model = map,
		SpawnPositions = spawnPositions,
		SpectatorCFrame = CFrame.lookAt(mapCenter + Vector3.new(0, SPECTATOR_HEIGHT, 16), mapCenter),
		VoidY = constraints[1].Minimum.Y - VOID_BELOW_MAP,
	}
end

function MapService.load(self, gameMode: string, selectedMapName: string): LoadedMap
	self:unload()
	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer == nil then
		blockContainer = Instance.new("Model")
		blockContainer.Name = "BlockContainer"
		blockContainer.Parent = Workspace
	end
	local resolvedMapName = selectedMapName
	if resolvedMapName == "" then
		local importedMapNames = getImportedMapNames(gameMode)
		if #importedMapNames > 0 then
			resolvedMapName = importedMapNames[self.random:NextInteger(1, #importedMapNames)]
		end
	end
	if resolvedMapName ~= "" then
		local map = self:loadMap(gameMode, resolvedMapName, blockContainer)
		if map ~= nil then
			self.activeMap = map.Model
			return map
		end
		warn(("[MapService] map %q is not imported; using the placeholder arena"):format(resolvedMapName))
	elseif selectedMapName == "" then
		warn("[MapService] no valid imported maps are available for Random; using the placeholder arena")
	end
	local template = self:ensureTemplate(gameMode)
	local placeholderMap = template:Clone()
	placeholderMap.Name = "Placeholder"
	placeholderMap:SetAttribute("SelectedMapName", selectedMapName)
	placeholderMap.Parent = blockContainer
	for _, descendant in placeholderMap:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute("Inventory") ~= nil then
			CollectionService:AddTag(descendant, "block:chest")
			-- Cached template carries a stale loot roll; re-roll per round.
			local tier = descendant:GetAttribute("ChestTier")
			if type(tier) == "number" then
				descendant:SetAttribute("Inventory", HttpService:JSONEncode(ChestLoot.getContents(tier)))
			end
		end
	end
	self.activeMap = placeholderMap

	local spawnPositions = {}
	local teamIslands = placeholderMap:FindFirstChild("TeamIslands")
	if teamIslands then
		for _, island in teamIslands:GetChildren() do
			local spawn = island:FindFirstChild("Spawn")
			if spawn and spawn:IsA("BasePart") then
				spawnPositions[island.Name] = spawn.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end
	return {
		BuildConstraints = getBuildConstraints(placeholderMap),
		Model = placeholderMap,
		SpawnPositions = spawnPositions,
		SpectatorCFrame = CFrame.lookAt(MAP_ORIGIN + Vector3.new(0, 12, 18), MAP_ORIGIN),
		VoidY = MAP_ORIGIN.Y - 75,
	}
end

function MapService.unload(self)
	if self.activeMap ~= nil then
		self.activeMap:Destroy()
		self.activeMap = nil
	end
	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer ~= nil then
		for _, placedBlock in CollectionService:GetTagged(PLACED_BLOCK_TAG) do
			if placedBlock:IsDescendantOf(blockContainer) then
				placedBlock:Destroy()
			end
		end
		-- Safety net for arenas left over from interrupted rounds (only
		-- arenas carry SelectedMapName; placed blocks never do).
		for _, child in blockContainer:GetChildren() do
			if child:GetAttribute("SelectedMapName") ~= nil then
				child:Destroy()
			end
		end
	end
end

return MapService
