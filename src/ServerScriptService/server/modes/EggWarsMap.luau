--!strict

-- Converts authored Egg Wars WorldData markers into the runtime arena. The
-- maps ship empty SpawnLocations/Generators/Shops/Chests folders; the original
-- server populated them at the cage transition, which is when populate() runs.

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local EggCharacterUtil = require(ReplicatedStorage.TS["egg-character"]["egg-character-util"]).EggCharacterUtil
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local RobloxAnimation = require(ReplicatedStorage.TS.asset.roblox["roblox-animation"]).RobloxAnimation
local ShopPrefabs = require(ReplicatedStorage.TS.game.shop["game-shop-prefab"]).ShopPrefabs

export type GeneratorData = {
	Id: string,
	Model: Model,
	Tier: number,
	TeamId: string?,
}

export type ArenaData = {
	EggsByTeam: { [string]: Model },
	EggPositions: { [string]: Vector3 },
	Generators: { GeneratorData },
}

local TEAM_BY_DIRECTION = {
	PositiveX = "Cyan",
	NegativeX = "Yellow",
	PositiveZ = "Lime",
	NegativeZ = "Red",
}

-- This is the numbering in populated_map_example_PhoenixGate.rbxl.
local SPAWN_LOCATION_TEAM_ORDER = { "Cyan", "Yellow", "Lime", "Red" }
local TEAM_IDS = { "Red", "Lime", "Cyan", "Yellow" }
local DROPPER_NAMES = { "TierOne", "TierTwo", "TierThree", "TierFour" }
local CAGE_HEIGHT = 30
local GENERATOR_ROOT_HEIGHT = 4.5
local SHIM_CENTER_HEIGHT = 1.5
local HALF_TURN = CFrame.Angles(0, math.pi, 0)
local GENERATED_EGGS_ATTRIBUTE = "EggWarsGenerated"
local GENERATED_SHIM_ATTRIBUTE = "EggWarsShim"

local EggWarsMap = {}

local function getFolder(parent: Instance, name: string): Folder?
	local child = parent:FindFirstChild(name)
	return if child ~= nil and child:IsA("Folder") then child else nil
end

local function getWorldData(map: Model): Folder?
	return getFolder(map, "WorldData")
end

local function collectCFrames(folder: Folder?): { CFrameValue }
	local values = {}
	if folder == nil then
		return values
	end
	for _, child in folder:GetChildren() do
		if child:IsA("CFrameValue") then
			table.insert(values, child)
		end
	end
	return values
end

local function selectExtreme(
	values: { CFrameValue },
	score: (position: Vector3) -> number,
	used: { [CFrameValue]: boolean }
): CFrameValue?
	local selected: CFrameValue? = nil
	local selectedScore = -math.huge
	for _, value in values do
		local candidateScore = score(value.Value.Position)
		if not used[value] and candidateScore > selectedScore then
			selected = value
			selectedScore = candidateScore
		end
	end
	if selected ~= nil then
		used[selected] = true
	end
	return selected
end

-- Child insertion order differs between maps; spatial assignment reproduces
-- the populated Phoenix Gate mapping and stays stable for the other maps.
local function readCardinalCFrames(folder: Folder?): { [string]: CFrame }?
	local values = collectCFrames(folder)
	if #values ~= 4 then
		return nil
	end
	local used: { [CFrameValue]: boolean } = {}
	local positiveX = selectExtreme(values, function(position)
		return position.X
	end, used)
	local negativeX = selectExtreme(values, function(position)
		return -position.X
	end, used)
	local positiveZ = selectExtreme(values, function(position)
		return position.Z
	end, used)
	local negativeZ = selectExtreme(values, function(position)
		return -position.Z
	end, used)
	if positiveX == nil or negativeX == nil or positiveZ == nil or negativeZ == nil then
		return nil
	end
	return {
		[TEAM_BY_DIRECTION.PositiveX] = positiveX.Value,
		[TEAM_BY_DIRECTION.NegativeX] = negativeX.Value,
		[TEAM_BY_DIRECTION.PositiveZ] = positiveZ.Value,
		[TEAM_BY_DIRECTION.NegativeZ] = negativeZ.Value,
	}
end

function EggWarsMap.getSpawnPositions(map: Model): { [string]: CFrame }?
	local worldData = getWorldData(map)
	local gameSpawns = worldData and readCardinalCFrames(getFolder(worldData, "GameSpawn")) or nil
	if gameSpawns == nil then
		return nil
	end
	local spawnPositions = {}
	for teamId, spawnCFrame in gameSpawns do
		spawnPositions[teamId] = spawnCFrame + Vector3.new(0, CAGE_HEIGHT, 0)
	end
	return spawnPositions
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

local function playLoopedAnimation(model: Model, animationId: string?)
	if animationId == nil or animationId == "" then
		return
	end
	local animationController = model:FindFirstChildWhichIsA("AnimationController", true)
	if animationController == nil then
		return
	end
	local animator = animationController:FindFirstChildOfClass("Animator")
	if animator == nil then
		animator = Instance.new("Animator")
		animator.Parent = animationController
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()
	if success and track ~= nil then
		track.Looped = true
		track:Play()
	end
end

local function createSpawnLocations(folder: Folder, spawnPositions: { [string]: CFrame })
	clearFolder(folder)
	for index, teamId in SPAWN_LOCATION_TEAM_ORDER do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = tostring(index)
		spawn.Size = Vector3.new(0.001, 0.001, 0.001)
		spawn.CFrame = spawnPositions[teamId]
		spawn.Transparency = 1
		spawn.Anchored = true
		spawn.CanCollide = false
		spawn.CanQuery = false
		spawn.CanTouch = false
		spawn.Enabled = true
		spawn.Neutral = true
		spawn.Parent = folder
	end
end

local function removeOldExternalArtifacts(blockContainer: Instance)
	local eggs = Workspace:FindFirstChild("Eggs")
	if eggs ~= nil and eggs:GetAttribute(GENERATED_EGGS_ATTRIBUTE) == true then
		eggs:Destroy()
	end
	for _, child in blockContainer:GetChildren() do
		if child:GetAttribute(GENERATED_SHIM_ATTRIBUTE) == true then
			child:Destroy()
		end
	end
end

local function createEggsAndShims(eggCFrames: { [string]: CFrame }, blockContainer: Instance): { [string]: Model }?
	removeOldExternalArtifacts(blockContainer)
	local eggsFolder = Instance.new("Folder")
	eggsFolder.Name = "Eggs"
	eggsFolder:SetAttribute(GENERATED_EGGS_ATTRIBUTE, true)
	eggsFolder.Parent = Workspace

	local shimTemplate = ReplicatedStorage:FindFirstChild("Blocks")
	shimTemplate = shimTemplate and shimTemplate:FindFirstChild("ShimBlock") or nil
	if shimTemplate == nil or not shimTemplate:IsA("BasePart") then
		warn("[EggWarsMap] ReplicatedStorage.Blocks.ShimBlock is missing")
		eggsFolder:Destroy()
		return nil
	end

	local eggsByTeam = {}
	for _, teamId in TEAM_IDS do
		local eggCFrame = eggCFrames[teamId]
		local egg = EggCharacterUtil.createEggModel(teamId)
		if egg == nil or eggCFrame == nil then
			warn(("[EggWarsMap] could not create the %s egg"):format(teamId))
			eggsFolder:Destroy()
			return nil
		end
		egg.Name = "Egg"
		egg:SetAttribute(Attribute.TeamId, teamId)
		egg:SetAttribute(Attribute.EggId, teamId)
		egg:SetAttribute(Attribute.Health, HealthConstants.EGG_DEFAULT_HEALTH)
		egg:PivotTo(eggCFrame * HALF_TURN)
		egg.Parent = eggsFolder
		CollectionService:AddTag(egg, "egg")
		CollectionService:AddTag(egg, "entity")
		playLoopedAnimation(egg, RobloxAnimation.EGG_IDLE_PRIMARY)
		eggsByTeam[teamId] = egg

		local shim = shimTemplate:Clone()
		shim.Name = "ShimBlock"
		shim.CFrame = CFrame.new(eggCFrame.Position + Vector3.new(0, SHIM_CENTER_HEIGHT, 0))
		shim.Anchored = true
		shim:SetAttribute(GENERATED_SHIM_ATTRIBUTE, true)
		shim.Parent = blockContainer
		-- MeleeController shrinks tagged shims while raycasting so the egg stays
		-- targetable from the sides, then restores their size.
		CollectionService:AddTag(shim, "shim")
	end
	return eggsByTeam
end

local function getNearestTeam(position: Vector3, eggCFrames: { [string]: CFrame }): string?
	local nearestTeam: string? = nil
	local nearestDistance = math.huge
	for teamId, eggCFrame in eggCFrames do
		local distance = (position - eggCFrame.Position).Magnitude
		if distance < nearestDistance then
			nearestTeam = teamId
			nearestDistance = distance
		end
	end
	return nearestTeam
end

local function createGenerators(
	worldData: Folder,
	destination: Folder,
	eggCFrames: { [string]: CFrame }
): { GeneratorData }?
	clearFolder(destination)
	local generatorMarkers = getFolder(worldData, "Generator")
	local droppers = ReplicatedStorage:FindFirstChild("Prefab")
	droppers = droppers and droppers:FindFirstChild("Droppers") or nil
	if generatorMarkers == nil or droppers == nil then
		warn("[EggWarsMap] generator markers or dropper prefabs are missing")
		return nil
	end

	local generators = {}
	for _, tierFolder in generatorMarkers:GetChildren() do
		local tier = tonumber(tierFolder.Name)
		local dropperName = if tier ~= nil then DROPPER_NAMES[tier] else nil
		local template = if dropperName ~= nil then droppers:FindFirstChild(dropperName) else nil
		if tier ~= nil and tierFolder:IsA("Folder") and template ~= nil and template:IsA("Model") then
			for _, marker in tierFolder:GetChildren() do
				if marker:IsA("CFrameValue") then
					local generator = template:Clone()
					-- The populated snapshot makes every generator part non-solid; the
					-- invisible RootPart must not leave a collision box mid-machine.
					for _, descendant in generator:GetDescendants() do
						if descendant:IsA("BasePart") then
							descendant.CanCollide = false
							descendant.CanQuery = false
						end
					end
					local id = HttpService:GenerateGUID(false)
					local teamId = if tier == 1 then getNearestTeam(marker.Value.Position, eggCFrames) else nil
					generator.Name = dropperName :: string
					generator:SetAttribute("GeneratorId", id)
					generator:SetAttribute("GeneratorTier", tier)
					if teamId ~= nil then
						generator:SetAttribute(Attribute.TeamId, teamId)
					end
					local targetCFrame = marker.Value * CFrame.new(0, GENERATOR_ROOT_HEIGHT, 0) * HALF_TURN
					if generator.PrimaryPart ~= nil then
						generator:SetPrimaryPartCFrame(targetCFrame)
					else
						generator:PivotTo(targetCFrame)
					end
					generator.Parent = destination
					CollectionService:AddTag(generator, "generator")
					playLoopedAnimation(generator, RobloxAnimation.DROPPER_IDLE)
					table.insert(generators, {
						Id = id,
						Model = generator,
						Tier = tier,
						TeamId = teamId,
					})
				end
			end
		end
	end
	return generators
end

local function createPrefab(
	prefabData,
	baseCFrame: CFrame,
	name: string?,
	destination: Folder,
	groundAligned: boolean
): Model?
	local template = prefabData and prefabData.Prefab or nil
	if template == nil or not template:IsA("Model") then
		return nil
	end
	local model = template:Clone()
	if name ~= nil then
		model.Name = name
	end
	-- Rigged shop prefabs are unanchored in ReplicatedStorage and would fall
	-- out of the arena; every spawned shop-rig part is anchored (as in the
	-- populated Phoenix Gate save).
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end
	local targetCFrame = baseCFrame * (prefabData.Offset or CFrame.new())
	if groundAligned then
		-- Static scene models are authored around a ground plane, not a rig root;
		-- PivotTo at the marker buries them by ~4 and ~2 blocks respectively.
		local boundingCFrame, boundingSize = model:GetBoundingBox()
		local heightBelowPivot = model:GetPivot().Position.Y - (boundingCFrame.Position.Y - boundingSize.Y / 2)
		local position = targetCFrame.Position
		targetCFrame = CFrame.new(position.X, baseCFrame.Position.Y + heightBelowPivot, position.Z)
			* targetCFrame.Rotation
	end
	model:PivotTo(targetCFrame)
	model.Parent = destination
	playLoopedAnimation(model, prefabData.IdleAnimation)
	return model
end

local function createShops(worldData: Folder, destination: Folder): boolean
	clearFolder(destination)
	local shopMarkers = getFolder(worldData, "Shop")
	if shopMarkers == nil then
		warn("[EggWarsMap] WorldData.Shop is missing")
		return false
	end
	for shopType, prefabData in ShopPrefabs do
		local markers = getFolder(shopMarkers, shopType)
		if markers == nil then
			warn(("[EggWarsMap] WorldData.Shop.%s is missing"):format(shopType))
			return false
		end
		for _, marker in markers:GetChildren() do
			if marker:IsA("CFrameValue") then
				local baseCFrame = marker.Value * HALF_TURN
				for _, scenePrefab in prefabData.ScenePrefabs or {} do
					createPrefab(scenePrefab, baseCFrame, nil, destination, scenePrefab.Rigged ~= true)
				end
				local shop = createPrefab(prefabData.Prefab, baseCFrame, shopType, destination, false)
				if shop == nil then
					return false
				end
				CollectionService:AddTag(shop, "shop")
			end
		end
	end
	-- The recovered map has QuickShop markers, but the populated live snapshot
	-- creates nothing from them; preserve that behavior.
	return true
end

function EggWarsMap.populate(map: Model): ArenaData?
	local worldData = getWorldData(map)
	local blockContainer = map.Parent
	if worldData == nil or blockContainer == nil then
		return nil
	end
	local eggCFrames = readCardinalCFrames(getFolder(worldData, "SpawnEgg"))
	local spawnPositions = EggWarsMap.getSpawnPositions(map)
	local spawnLocations = getFolder(map, "SpawnLocations")
	local generatorsFolder = getFolder(map, "Generators")
	local shopsFolder = getFolder(map, "Shops")
	if
		eggCFrames == nil
		or spawnPositions == nil
		or spawnLocations == nil
		or generatorsFolder == nil
		or shopsFolder == nil
	then
		warn(("[EggWarsMap] map %s has incomplete Egg Wars runtime folders"):format(map.Name))
		return nil
	end

	createSpawnLocations(spawnLocations, spawnPositions)
	local eggsByTeam = createEggsAndShims(eggCFrames, blockContainer)
	local generators = createGenerators(worldData, generatorsFolder, eggCFrames)
	if eggsByTeam == nil or generators == nil or not createShops(worldData, shopsFolder) then
		removeOldExternalArtifacts(blockContainer)
		return nil
	end
	return {
		EggsByTeam = eggsByTeam,
		EggPositions = {
			Red = eggCFrames.Red.Position,
			Lime = eggCFrames.Lime.Position,
			Cyan = eggCFrames.Cyan.Position,
			Yellow = eggCFrames.Yellow.Position,
		},
		Generators = generators,
	}
end

function EggWarsMap.clearExternalArtifacts(blockContainer: Instance?)
	if blockContainer ~= nil then
		removeOldExternalArtifacts(blockContainer)
	end
end

return EggWarsMap
