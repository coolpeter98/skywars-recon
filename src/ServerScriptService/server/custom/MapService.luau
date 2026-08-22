--!strict
-- MapService — builds and owns the active arena for custom-game rounds.
--
-- Primary path: imported maps. A map is a Model under
-- ServerStorage.Maps.SkyWars.<MapName> (the original game's convention, read
-- by ReplicatedStorage.TS.game.map["map-info"]) with this layout:
--
--	<MapName> (Model)
--	├── WorldData (Folder)
--	│	├── Spawn (CFrameValue)          — the map's own anchor point; the map
--	│	│                                  is placed so this lands at MAP_ORIGIN
--	│	├── Chest (Folder) > Tier (Folder)
--	│	│	├── 1..4 (Folder)             — one folder per chest tier
--	│	│	│	└── <n> (CFrameValue)      — chest position (+ yaw rotation); the
--	│	│	                                CFrameValue's name equals its tier
--	│	├── GameSpawn (Folder)           — per-direction island spots (unused)
--	│	└── ContestSpawn (Folder)        — per-direction contest spots (unused)
--	├── SpawnLocations (Folder)          — SpawnLocation parts named 1..12
--	├── SpawnLocation                    — mirrors WorldData.Spawn (anchor)
--	├── Chests (Folder)                  — generator-placed chest templates
--	│                                      (no animation rig; discarded)
--	└── Default / N / N E / N P / ...    — island geometry models
--
-- SpawnLocations are numbered 1..12 and map 1:1 onto the twelve SkyWars teams
-- (Solo uses all twelve); modes with fewer teams spread their spawns evenly
-- around the map. Chests are spawned fresh from the recovered
-- ReplicatedStorage/Misc/ChestTierOne..Four prefabs (they carry the
-- AnimationController/Animator rig the client's chest component requires)
-- at each CFrameValue, with the tier's loot rolled from ChestLoot.
--
-- Fallback path: when the selected map has no imported model (or no map is
-- selected, i.e. "random"), the per-mode placeholder template is generated
-- (one island per team plus a center island with loot chests) exactly as
-- before imported maps were supported.
--
-- Either way the arena is cloned into Workspace.BlockContainer as
-- "ActiveGameMap", a sibling of player-placed blocks (the client's block
-- raycast whitelists exactly Workspace.BlockContainer).

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ModeRegistry = require(script.Parent.modes.ModeRegistry)
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

-- The anchor point (WorldData.Spawn) of a map — and the center of a
-- placeholder template — is placed at this world position; the rest of the
-- map keeps its saved offsets.
local MAP_ORIGIN = Vector3.new(0, 300, 0)
-- The client's block grid places block centers on world multiples of 3, so
-- block bottoms land on Y ≡ 1.5 (mod 3). Real maps store their build
-- surfaces (chest floors, island decks) at local Y ≡ 1.5 (mod 3); anchoring
-- the map's Spawn point at MAP_ORIGIN would land those surfaces at ≡ 0
-- (mod 3), exactly 1.5 studs off the grid, so maps are shifted down 1.5.
local MAP_GRID_Y_OFFSET = Vector3.new(0, -1.5, 0)
local ACTIVE_MAP_NAME = "ActiveGameMap"
local BLOCK_SIZE = 3
local BUILD_HORIZONTAL_PADDING = 36
local BUILD_MIN_Y_PADDING = 12
local BUILD_MAX_Y_PADDING = 90
local VOID_BELOW_MAP = 60
local SPECTATOR_HEIGHT = 100
local PLATFORM_BLOCK_NAME = "StoneBricks"
local PLACED_BLOCK_TAG = "block:placed"
local TEMPLATE_VERSION = 4
local CHEST_ASSET_NAMES = { "ChestTierOne", "ChestTierTwo", "ChestTierThree", "ChestTierFour" }
-- The placeholder chests sat with their base 1.5 studs below their position;
-- real chest models are placed with the same base height so they sit on the
-- platform instead of floating or sinking.
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

-- Clones a recovered chest prefab (ReplicatedStorage/Misc) and places it so
-- its bounding-box base sits `baseOffset` studs below the given CFrame and its
-- box center lands on the CFrame's X/Z. Placeholder chests pass 1.5 (their
-- historical base height); real-map chests pass 0 so the base rests exactly on
-- the floor the generator's CFrameValue marks. The prefab ships with its own
-- AnimationController/Animator rig, which the server drives when the chest is
-- opened. Returns nil if the asset is missing.
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

	-- Place the bounding-box bottom at cframe.Position.Y - baseOffset,
	-- horizontally centered on the CFrame (chests are yaw-rotated only, so
	-- the axis-aligned bounding box is exact).
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
	assert(adapter ~= nil, "No custom-game adapter for " .. gameMode)
	local mapRoot = ServerStorage:WaitForChild("Maps"):WaitForChild("SkyWars")
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
	}, MapService)
end

function MapService.ensureTemplate(self, gameMode: string): Model
	local adapter = ModeRegistry.get(gameMode)
	assert(adapter ~= nil, "Unsupported custom game mode")
	local modeFolder = ServerStorage.Maps.SkyWars:FindFirstChild(adapter.getMapConfigFolder(gameMode))
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

-- Reads the map's anchor position (WorldData.Spawn CFrameValue, falling back
-- to the top-level SpawnLocation part that mirrors it).
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

-- Tries to load an imported map into `blockContainer`. Returns nil when
-- no such map is imported (or the map is malformed) so load() can fall back
-- to the placeholder arena.
function MapService.loadMap(self, gameMode: string, mapName: string, blockContainer: Instance): LoadedMap?
	local adapter = ModeRegistry.get(gameMode)
	if adapter == nil then
		return nil
	end
	local maps = ServerStorage:FindFirstChild("Maps")
	local skyWarsMaps = maps and maps:FindFirstChild("SkyWars")
	local mapAsset = skyWarsMaps and skyWarsMaps:FindFirstChild(mapName)
	if mapAsset == nil or not mapAsset:IsA("Model") then
		return nil
	end

	local anchorPosition = getAnchorPosition(mapAsset)
	if anchorPosition == nil then
		warn(("[MapService] map %q has no WorldData.Spawn anchor"):format(mapName))
		return nil
	end

	local map = mapAsset:Clone()
	map.Name = ACTIVE_MAP_NAME
	map:SetAttribute("SelectedMapName", mapName)
	map:SetAttribute("Placeholder", false)

	-- Identity rotation: map geometry is axis-aligned in its saved space.
	local rootCFrame = CFrame.new(MAP_ORIGIN - anchorPosition + MAP_GRID_Y_OFFSET)
	map:PivotTo(rootCFrame)
	map.Parent = blockContainer

	-- Read team spawns from the numbered SpawnLocations (spawn index 1..N maps
	-- to team ordinal 1..N; fewer teams spread evenly around the map), then
	-- remove the parts so Roblox's default spawn logic cannot place characters
	-- on them mid-round.
	local teamIds = adapter.getTeamIds(gameMode)
	local spawnPositions: { [string]: CFrame } = {}
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
		spawnPositions[teamId] = rootCFrame * spawnLocation.CFrame
	end
	spawnLocationsFolder:Destroy()

	-- The top-level anchor SpawnLocation mirrors WorldData.Spawn; it must not
	-- act as a fallback spawn for unassigned characters.
	for _, child in map:GetChildren() do
		if child:IsA("SpawnLocation") and child.Name == "SpawnLocation" then
			child:Destroy()
		end
	end

	-- Discard the generator-placed chest templates: they carry no animation
	-- rig (the client's chest component requires one) and their baked
	-- ProximityPrompts would dead-end. Fresh prefab chests are spawned below
	-- at the WorldData.Chest.Tier CFrameValues instead.
	local chestsFolder = map:FindFirstChild("Chests")
	if chestsFolder ~= nil then
		chestsFolder:Destroy()
	end
	local worldData = map:FindFirstChild("WorldData")
	if worldData ~= nil then
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
							-- The prefab's lock sits on its +Z side, opposite the
							-- map generator's convention (the map's own chests
							-- face their lock along the CFrameValue's look
							-- vector), so yaw the prefab 180° after the value's
							-- rotation.
							createChest(
								("Chest_T%d_%d"):format(tier, chestIndex),
								rootCFrame * cframeValue.Value * CFrame.Angles(0, math.pi, 0),
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
	local constraints = getBuildConstraints(map)
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
	if selectedMapName ~= "" then
		local map = self:loadMap(gameMode, selectedMapName, blockContainer)
		if map ~= nil then
			self.activeMap = map.Model
			return map
		end
		warn(("[MapService] map %q is not imported; using the placeholder arena"):format(selectedMapName))
	end
	local template = self:ensureTemplate(gameMode)
	local placeholderMap = template:Clone()
	placeholderMap.Name = ACTIVE_MAP_NAME
	placeholderMap:SetAttribute("SelectedMapName", selectedMapName)
	placeholderMap.Parent = blockContainer
	for _, descendant in placeholderMap:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute("Inventory") ~= nil then
			CollectionService:AddTag(descendant, "block:chest")
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
	end
	local staleMap = blockContainer and blockContainer:FindFirstChild(ACTIVE_MAP_NAME)
	if staleMap ~= nil then
		staleMap:Destroy()
	end
end

return MapService
