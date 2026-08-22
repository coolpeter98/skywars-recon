--!strict

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

local MAP_ORIGIN = Vector3.new(0, 300, 0)
local ACTIVE_MAP_NAME = "ActiveGameMap"
local BLOCK_SIZE = 3
local BUILD_HORIZONTAL_PADDING = 36
local BUILD_DEPTH_BELOW_MAP = 60
local BUILD_HEIGHT_ABOVE_MAP = 90
local PLATFORM_BLOCK_NAME = "StoneBricks"
local PLACED_BLOCK_TAG = "block:placed"
local TEMPLATE_VERSION = 4
local CHEST_ASSET_NAMES = { "ChestTierOne", "ChestTierTwo", "ChestTierThree", "ChestTierFour" }
-- The placeholder chests sat with their base 1.5 studs below their position;
-- real chest models are placed with the same base height so they sit on the
-- platform instead of floating or sinking.
local CHEST_BASE_OFFSET_FROM_POSITION = 1.5

local PlaceholderMapService = {}
PlaceholderMapService.__index = PlaceholderMapService

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

-- Clones a real recovered chest model (ReplicatedStorage/Misc) and positions
-- it so its bounding-box base sits 1.5 studs below `position` — the same base
-- height the old placeholder chests used. The model ships with its own
-- AnimationController/Animator rig, which the server drives when the chest is
-- opened. Returns nil if the asset is missing.
local function createChest(name: string, position: Vector3, parent: Instance, tier: number): Model?
	local misc = ReplicatedStorage:FindFirstChild("Misc")
	local assetName = CHEST_ASSET_NAMES[tier] or "Chest"
	local asset = misc and misc:FindFirstChild(assetName) or nil
	if asset == nil or not asset:IsA("Model") then
		warn(("[PlaceholderMapService] missing chest asset %s"):format(assetName))
		return nil
	end
	local chest = asset:Clone()
	chest.Name = name

	-- Place the bounding-box bottom at position.Y - CHEST_BASE_OFFSET_FROM_POSITION,
	-- horizontally centered on position (chests are axis-aligned here).
	local boundingCFrame, boundingSize = chest:GetBoundingBox()
	local boundingOffset = boundingCFrame.Position - chest:GetPivot().Position
	local bottomY = position.Y - CHEST_BASE_OFFSET_FROM_POSITION
	chest:PivotTo(
		CFrame.new(
			position.X - boundingOffset.X,
			bottomY + boundingSize.Y / 2 - boundingOffset.Y,
			position.Z - boundingOffset.Z
		)
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

	local contents = ChestLoot.getContents(tier)
	chest:SetAttribute("Inventory", HttpService:JSONEncode(contents))
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
				MAP_ORIGIN.Y - BUILD_DEPTH_BELOW_MAP,
				boundsCenter.Z - halfSize.Z - BUILD_HORIZONTAL_PADDING
			),
			Maximum = Vector3.new(
				boundsCenter.X + halfSize.X + BUILD_HORIZONTAL_PADDING,
				MAP_ORIGIN.Y + BUILD_HEIGHT_ABOVE_MAP,
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
			MAP_ORIGIN + Vector3.new(math.cos(angle) * 12, 4.5, math.sin(angle) * 12),
			centerIsland,
			3 + (index - 1) % 2
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
				islandPosition + lateral * lateralOffset + Vector3.new(0, 4.5, 0),
				island,
				math.min(chestIndex, 2)
			)
		end
	end
	template.Parent = destination
	return template
end

function PlaceholderMapService.new()
	return setmetatable({
		activeMap = nil :: Model?,
	}, PlaceholderMapService)
end

function PlaceholderMapService.ensureTemplate(self, gameMode: string): Model
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

function PlaceholderMapService.load(self, gameMode: string, selectedMapName: string): LoadedMap
	self:unload()
	local template = self:ensureTemplate(gameMode)
	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer == nil then
		blockContainer = Instance.new("Folder")
		blockContainer.Name = "BlockContainer"
		blockContainer.Parent = Workspace
	end
	local activeMap = template:Clone()
	activeMap.Name = ACTIVE_MAP_NAME
	activeMap:SetAttribute("SelectedMapName", selectedMapName)
	activeMap.Parent = blockContainer
	for _, descendant in activeMap:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute("Inventory") ~= nil then
			CollectionService:AddTag(descendant, "block:chest")
		end
	end
	self.activeMap = activeMap

	local spawnPositions = {}
	local teamIslands = activeMap:FindFirstChild("TeamIslands")
	if teamIslands then
		for _, island in teamIslands:GetChildren() do
			local spawn = island:FindFirstChild("Spawn")
			if spawn and spawn:IsA("BasePart") then
				spawnPositions[island.Name] = spawn.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end
	return {
		BuildConstraints = getBuildConstraints(activeMap),
		Model = activeMap,
		SpawnPositions = spawnPositions,
		SpectatorCFrame = CFrame.lookAt(MAP_ORIGIN + Vector3.new(0, 12, 18), MAP_ORIGIN),
		VoidY = MAP_ORIGIN.Y - 75,
	}
end

function PlaceholderMapService.unload(self)
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

return PlaceholderMapService
