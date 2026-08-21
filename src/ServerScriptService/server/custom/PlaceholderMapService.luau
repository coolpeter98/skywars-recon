--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ModeRegistry = require(script.Parent.modes.ModeRegistry)

export type LoadedMap = {
	Model: Model,
	SpawnPositions: { [string]: CFrame },
	SpectatorCFrame: CFrame,
	VoidY: number,
}

local MAP_ORIGIN = Vector3.new(0, 300, 0)
local ACTIVE_MAP_NAME = "ActiveGameMap"

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

local function createChest(name: string, position: Vector3, parent: Instance, centerChest: boolean): Model
	local chest = Instance.new("Model")
	chest.Name = name
	local body = createPart(
		"Body",
		Vector3.new(4, 3, 3),
		CFrame.new(position),
		if centerChest then Color3.fromRGB(238, 185, 62) else Color3.fromRGB(139, 91, 54),
		chest
	)
	local lid = createPart(
		"Lid",
		Vector3.new(4.2, 1, 3.2),
		CFrame.new(position + Vector3.new(0, 2, 0)),
		if centerChest then Color3.fromRGB(255, 220, 92) else Color3.fromRGB(174, 118, 68),
		chest
	)
	body.CanCollide = true
	lid.CanCollide = true
	local animationController = Instance.new("AnimationController")
	animationController.Name = "AnimationController"
	animationController.Parent = chest
	chest.PrimaryPart = body
	local contents
	if centerChest then
		contents = {
			["0"] = { Slot = 0, Type = "IronSword", Quantity = 1 },
			["1"] = { Slot = 1, Type = "Bow", Quantity = 1 },
			["2"] = { Slot = 2, Type = "Arrow", Quantity = 12 },
			["3"] = { Slot = 3, Type = "GoldChestplate", Quantity = 1 },
		}
	else
		contents = {
			["0"] = { Slot = 0, Type = "BronzeSword", Quantity = 1 },
			["1"] = { Slot = 1, Type = "Planks", Quantity = 24 },
			["2"] = { Slot = 2, Type = "BronzeChestplate", Quantity = 1 },
		}
	end
	chest:SetAttribute("Inventory", HttpService:JSONEncode(contents))
	CollectionService:AddTag(chest, "block:chest")
	chest.Parent = parent
	return chest
end

local function snap(value: number): number
	return math.round(value / 3) * 3
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

	local centerIsland = Instance.new("Model")
	centerIsland.Name = "CenterIsland"
	centerIsland.Parent = template
	createPart("Platform", config.CenterSize, CFrame.new(MAP_ORIGIN), Color3.fromRGB(111, 135, 86), centerIsland)
	for index = 1, 4 do
		local angle = (index - 1) * math.pi / 2
		createChest(
			("CenterChest%d"):format(index),
			MAP_ORIGIN + Vector3.new(math.cos(angle) * 12, 4.5, math.sin(angle) * 12),
			centerIsland,
			true
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
		createPart("Platform", config.IslandSize, CFrame.new(islandPosition), Color3.fromRGB(101, 125, 76), island)
		local spawn = createPart(
			"Spawn",
			Vector3.new(6, 1, 6),
			CFrame.lookAt(islandPosition + Vector3.new(0, 5, 0), MAP_ORIGIN + Vector3.new(0, 5, 0)),
			Color3.fromRGB(255, 255, 255),
			island
		)
		spawn.Transparency = 1
		spawn.CanCollide = false
		for chestIndex = 1, config.ChestsPerIsland do
			local lateralOffset = (chestIndex - (config.ChestsPerIsland + 1) / 2) * 6
			local towardCenter = (MAP_ORIGIN - islandPosition).Unit
			local lateral = Vector3.new(-towardCenter.Z, 0, towardCenter.X)
			createChest(
				("Chest%d"):format(chestIndex),
				islandPosition + lateral * lateralOffset + Vector3.new(0, 4.5, 0),
				island,
				false
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
	if template and template:IsA("Model") then
		return template
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
	local staleMap = blockContainer and blockContainer:FindFirstChild(ACTIVE_MAP_NAME)
	if staleMap ~= nil then
		staleMap:Destroy()
	end
end

return PlaceholderMapService
