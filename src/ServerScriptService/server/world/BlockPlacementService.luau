--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local BlockConstants = require(ReplicatedStorage.TS.block["block-constants"]).BlockConstants
local Items = require(ReplicatedStorage.TS.item.item).Items

type BlockDefinition = {
	CollectionTag: string?,
	Ref: BasePart?,
	Rotation: boolean?,
}

type ItemDefinition = {
	Block: BlockDefinition?,
	Name: string,
	Rewrite: { Type: string }?,
}

type InventoryPrediction = {
	createdAt: number,
	itemType: string,
	quantity: number,
}

local BLOCK_DIMENSION: Vector3 = BlockConstants.BLOCK_DIMENSION
local BLOCK_SIZE: number = BlockConstants.BLOCK_SIZE
local MAXIMUM_PLACE_DISTANCE: number = BlockConstants.MAXIMUM_PLACE_RANGE * BLOCK_SIZE
local PREDICTION_WAIT_TIMEOUT = 0.5
local POSITION_TOLERANCE = 0.01
local ROTATION_INCREMENT = 90
local PLACED_BLOCK_TAG = "block:placed"

local ADJACENT_OFFSETS = {
	Vector3.new(-BLOCK_SIZE, 0, -BLOCK_SIZE),
	Vector3.new(-BLOCK_SIZE, 0, 0),
	Vector3.new(-BLOCK_SIZE, 0, BLOCK_SIZE),
	Vector3.new(0, 0, -BLOCK_SIZE),
	Vector3.new(0, 0, BLOCK_SIZE),
	Vector3.new(BLOCK_SIZE, 0, -BLOCK_SIZE),
	Vector3.new(BLOCK_SIZE, 0, 0),
	Vector3.new(BLOCK_SIZE, 0, BLOCK_SIZE),
	Vector3.new(0, -BLOCK_SIZE, 0),
	Vector3.new(0, BLOCK_SIZE, 0),
}

local BlockPlacementService = {}
BlockPlacementService.__index = BlockPlacementService

local function validateBlockCatalog()
	for _, blockTemplate in ReplicatedStorage.Blocks:GetChildren() do
		assert(blockTemplate:IsA("BasePart"), ("Block asset %s must be a BasePart"):format(blockTemplate.Name))
		assert(
			blockTemplate.Size == BLOCK_DIMENSION,
			("Block asset %s must use the %s block dimensions"):format(blockTemplate.Name, tostring(BLOCK_DIMENSION))
		)
		local itemDefinition: ItemDefinition? = Items[blockTemplate.Name]
		assert(itemDefinition ~= nil, ("Block asset %s has no item definition"):format(blockTemplate.Name))
		assert(itemDefinition.Block ~= nil, ("Item %s is not marked as a block"):format(blockTemplate.Name))
		assert(
			itemDefinition.Block.Ref == blockTemplate,
			("Item %s does not reference its canonical block asset"):format(blockTemplate.Name)
		)
	end
	for itemType, itemDefinition: ItemDefinition in Items do
		if itemDefinition.Rewrite ~= nil and string.find(itemDefinition.Rewrite.Type, "{TeamId}", 1, true) ~= nil then
			local defaultBlockType = string.gsub(itemDefinition.Rewrite.Type, "{TeamId}", "White")
			local defaultDefinition: ItemDefinition? = Items[defaultBlockType]
			assert(
				defaultDefinition ~= nil and defaultDefinition.Block ~= nil,
				("Rewritten block item %s has no default block target"):format(itemType)
			)
		end
	end
end

local function getBlockContainer(): Instance
	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer == nil then
		blockContainer = Instance.new("Folder")
		blockContainer.Name = "BlockContainer"
		blockContainer.Parent = Workspace
	end
	return blockContainer
end

local function isGridAligned(position: Vector3): boolean
	local scaledPosition = position / BLOCK_SIZE
	local nearestGridPosition =
		Vector3.new(math.round(scaledPosition.X), math.round(scaledPosition.Y), math.round(scaledPosition.Z))
	return (scaledPosition - nearestGridPosition).Magnitude < POSITION_TOLERANCE
end

local function normalizeRotation(rotation: number): number?
	if rotation % ROTATION_INCREMENT ~= 0 or math.abs(rotation) > 360 then
		return nil
	end
	return rotation % 360
end

local function resolveBlockItem(player: Player, placedItemType: string): (ItemDefinition?, string?)
	local itemDefinition: ItemDefinition? = Items[placedItemType]
	if itemDefinition == nil then
		return nil, nil
	end
	local resolvedItemType = placedItemType
	if itemDefinition.Rewrite ~= nil then
		local teamId = player:GetAttribute(Attribute.TeamId)
		local teamName = if type(teamId) == "string" and teamId ~= "" then teamId else "White"
		resolvedItemType = string.gsub(itemDefinition.Rewrite.Type, "{TeamId}", teamName)
		itemDefinition = Items[resolvedItemType]
	end
	if
		itemDefinition == nil
		or itemDefinition.Block == nil
		or itemDefinition.Block.Ref == nil
		or not itemDefinition.Block.Ref:IsA("BasePart")
	then
		return nil, nil
	end
	return itemDefinition, resolvedItemType
end

local function containsBlock(blockContainer: Instance, position: Vector3): boolean
	for _, part in Workspace:GetPartBoundsInBox(CFrame.new(position), BLOCK_DIMENSION * 0.99) do
		if part:IsDescendantOf(blockContainer) then
			return true
		end
	end
	return false
end

local function hasAdjacentBlock(blockContainer: Instance, position: Vector3): boolean
	for _, offset in ADJACENT_OFFSETS do
		for _, part in Workspace:GetPartBoundsInBox(CFrame.new(position + offset), BLOCK_DIMENSION * 0.99) do
			if part:IsDescendantOf(blockContainer) then
				return true
			end
		end
	end
	return false
end

local function getPlayerRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root ~= nil and root:IsA("BasePart") then root else nil
end

local function createBlock(
	player: Player,
	placedItemType: string,
	resolvedItemType: string,
	itemDefinition: ItemDefinition,
	position: Vector3,
	rotation: number
): BasePart
	local blockDefinition = itemDefinition.Block :: BlockDefinition
	local block = (blockDefinition.Ref :: BasePart):Clone()
	block.Position = position
	block.Anchored = true
	if blockDefinition.Rotation == true then
		block.Orientation = Vector3.new(0, rotation, 0)
	end
	block:SetAttribute(Attribute.PlacedByUserId, player.UserId)
	block:SetAttribute(Attribute.PlacedItemType, placedItemType)
	block:SetAttribute(Attribute.ResolvedBlockType, resolvedItemType)
	CollectionService:AddTag(block, PLACED_BLOCK_TAG)
	if blockDefinition.CollectionTag ~= nil then
		CollectionService:AddTag(block, blockDefinition.CollectionTag)
	end
	return block
end

function BlockPlacementService.new(context)
	return setmetatable({
		context = context,
		reservedPositions = {} :: { [Vector3]: boolean },
	}, BlockPlacementService)
end

function BlockPlacementService.getPrediction(self, player: Player, predictionId: string): InventoryPrediction?
	local session = self.context.playerSessions:require(player)
	local deadline = os.clock() + PREDICTION_WAIT_TIMEOUT
	while session.pendingInventoryPredictions[predictionId] == nil and os.clock() < deadline do
		task.wait()
	end
	return session.pendingInventoryPredictions[predictionId]
end

function BlockPlacementService.reject(self, player: Player, predictionId: string): boolean
	self.context.inventoryService:rejectPrediction(player, predictionId)
	return false
end

function BlockPlacementService.isPlacementAllowedForServer(self, player: Player, position: Vector3): boolean
	local runtimeContext = self.context.runtimeContext:get()
	if runtimeContext.Role == "Private" then
		return self.context.roundService:isBlockPlacementAllowed(player, position)
	end
	return runtimeContext.Role == "Game"
end

function BlockPlacementService.placeBlock(
	self,
	player: Player,
	position: Vector3,
	rotation: number,
	predictionId: string
): boolean
	print("sigeon")
	local prediction = self:getPrediction(player, predictionId)
	if prediction == nil then
		return false
	end
	local root = getPlayerRoot(player)
	local normalizedRotation = normalizeRotation(rotation)
	local itemDefinition, resolvedItemType = resolveBlockItem(player, prediction.itemType)
		print(root == nil,
		 player:GetAttribute(Attribute.Spectating) == true,
		 not self:isPlacementAllowedForServer(player, position),
		 (root.Position - position).Magnitude >= MAXIMUM_PLACE_DISTANCE,
		 not isGridAligned(position),
		 normalizedRotation == nil,
		 itemDefinition == nil,
		 resolvedItemType == nil)
	if
		root == nil
		or player:GetAttribute(Attribute.Spectating) == true
		or not self:isPlacementAllowedForServer(player, position)
		or (root.Position - position).Magnitude >= MAXIMUM_PLACE_DISTANCE
		or not isGridAligned(position)
		or normalizedRotation == nil
		or itemDefinition == nil
		or resolvedItemType == nil
	then
		return self:reject(player, predictionId)
	end

	if self.reservedPositions[position] then
		return self:reject(player, predictionId)
	end
	self.reservedPositions[position] = true
	local success, placementResult = pcall(function(): boolean
		local blockContainer = getBlockContainer()
		-- Character geometry is intentionally ignored. Pillaring and clutch
		-- placement put the predicted cell through the placing player's body,
		-- and other players must not make an otherwise valid cell fail.
		if containsBlock(blockContainer, position) or not hasAdjacentBlock(blockContainer, position) then
			return self:reject(player, predictionId)
		end

		local block =
			createBlock(player, prediction.itemType, resolvedItemType, itemDefinition, position, normalizedRotation)
		local committed = self.context.inventoryService:commitPrediction(player, predictionId)
		if committed then
			block.Parent = blockContainer
		else
			block:Destroy()
		end
		if committed and self.context.blockWorldService ~= nil then
			-- Keep the voxel world in sync so placed blocks can be mined and
			-- hide neighbouring map faces exactly like map blocks do.
			self.context.blockWorldService:registerPart(block, resolvedItemType)
		end
		return committed
	end)
	self.reservedPositions[position] = nil
	if not success then
		error(placementResult, 0)
	end
	return placementResult
end

validateBlockCatalog()

return BlockPlacementService
