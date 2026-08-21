--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Validation = require(script.Parent.Parent.Validation)
local Items = require(ReplicatedStorage.TS.item.item).Items

local BLOCK_SIZE = 3
local MAXIMUM_PLACE_DISTANCE = 18

local WorldHandlers = {}
WorldHandlers.__index = WorldHandlers

function WorldHandlers.new(context)
	return setmetatable({ context = context }, WorldHandlers)
end

function WorldHandlers.equipItem(self, player: Player, itemType: string)
	self.context.inventoryService:equipArmour(player, itemType)
end

function WorldHandlers.equipArmour(self, player: Player, itemType: string)
	self.context.inventoryService:unequipArmour(player, itemType)
end

function WorldHandlers.heldItemChanged(self, player: Player, itemType: string?)
	self.context.inventoryService:setHeldItem(player, itemType)
end

function WorldHandlers.useHeldItem(self, player: Player)
	self.context.inventoryService:dropHeldItem(player)
end

function WorldHandlers.itemPickup(self, player: Player, itemType: string, quantity: number, predictionId: string)
	self.context.inventoryService:registerPrediction(player, itemType, quantity, predictionId)
end

local function resolveBlockDefinition(player: Player, itemType: string)
	local itemDefinition = Items[itemType]
	if itemDefinition and itemDefinition.Rewrite then
		local teamId = player:GetAttribute("TeamId")
		local teamName = if type(teamId) == "string" and teamId ~= "" then teamId else "White"
		itemDefinition = Items[string.gsub(itemDefinition.Rewrite.Type, "{TeamId}", teamName)]
	end
	return itemDefinition
end

local function hasBlockAtPosition(blockContainer: Instance, position: Vector3): boolean
	for _, child in blockContainer:GetDescendants() do
		if child:IsA("BasePart") and (child.Position - position).Magnitude < 0.1 then
			return true
		end
	end
	return false
end

local function hasAdjacentBlock(blockContainer: Instance, position: Vector3): boolean
	for _, offset in
		{
			Vector3.new(BLOCK_SIZE, 0, 0),
			Vector3.new(-BLOCK_SIZE, 0, 0),
			Vector3.new(0, BLOCK_SIZE, 0),
			Vector3.new(0, -BLOCK_SIZE, 0),
			Vector3.new(0, 0, BLOCK_SIZE),
			Vector3.new(0, 0, -BLOCK_SIZE),
		}
	do
		for _, part in Workspace:GetPartBoundsInBox(CFrame.new(position + offset), Vector3.new(2.9, 2.9, 2.9)) do
			if part:IsDescendantOf(blockContainer) then
				return true
			end
		end
	end
	return false
end

local function intersectsCharacter(position: Vector3): boolean
	for _, part in Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(2.9, 2.9, 2.9)) do
		local character = part:FindFirstAncestorOfClass("Model")
		if character and Players:GetPlayerFromCharacter(character) ~= nil then
			if part.Name == "Head" or (part.Name == "UpperTorso" and part.Position.Y < position.Y) then
				return true
			end
		end
	end
	return false
end

local function roundVector(vector: Vector3): Vector3
	return Vector3.new(math.round(vector.X), math.round(vector.Y), math.round(vector.Z))
end

function WorldHandlers.placeBlock(self, player: Player, position: Vector3, rotation: number, predictionId: string)
	local session = self.context.playerSessions:require(player)
	local deadline = os.clock() + 0.5
	while session.pendingInventoryPredictions[predictionId] == nil and os.clock() < deadline do
		task.wait()
	end
	local prediction = session.pendingInventoryPredictions[predictionId]
	if prediction == nil then
		self.context.outbound:fire("BlockRemoved", player, position)
		return
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local itemDefinition = resolveBlockDefinition(player, prediction.itemType)
	local scaledPosition = position / BLOCK_SIZE
	local positionIsSnapped = (scaledPosition - roundVector(scaledPosition)).Magnitude < 0.01
	local validRotation = rotation % 90 == 0 and math.abs(rotation) <= 360
	if
		root == nil
		or not root:IsA("BasePart")
		or (root.Position - position).Magnitude >= MAXIMUM_PLACE_DISTANCE
		or not positionIsSnapped
		or not validRotation
		or itemDefinition == nil
		or itemDefinition.Block == nil
	then
		self.context.inventoryService:rejectPrediction(player, predictionId)
		self.context.outbound:fire("BlockRemoved", player, position)
		return
	end

	local blockContainer = Workspace:FindFirstChild("BlockContainer")
	if blockContainer == nil then
		blockContainer = Instance.new("Folder")
		blockContainer.Name = "BlockContainer"
		blockContainer.Parent = Workspace
	end
	if
		hasBlockAtPosition(blockContainer, position)
		or not hasAdjacentBlock(blockContainer, position)
		or intersectsCharacter(position)
	then
		self.context.inventoryService:rejectPrediction(player, predictionId)
		self.context.outbound:fire("BlockRemoved", player, position)
		return
	end

	local block = itemDefinition.Block.Ref:Clone()
	block.Position = position
	block.Anchored = true
	if itemDefinition.Block.Rotation then
		block.Orientation = Vector3.new(0, rotation, 0)
	end
	block:SetAttribute("Shooter", player.UserId)
	block.Parent = blockContainer
	local committed = self.context.inventoryService:commitPrediction(player, predictionId)
	if not committed then
		block:Destroy()
	end
	self.context.outbound:fire("BlockRemoved", player, position)
end
function WorldHandlers.hitBlock(self, player: Player, position: Vector3) end

function WorldHandlers.openChest(self, player: Player, chest: Model)
	self.context.inventoryService:openChest(player, chest)
end

function WorldHandlers.takeChestItem(self, player: Player, chest: Model, itemType: string, quantity: number)
	self.context.inventoryService:transferChestItem(player, chest, itemType, quantity)
end

function WorldHandlers.closeChest(self, player: Player, chest: Model)
	self.context.inventoryService:closeChest(player, chest)
end

function WorldHandlers.getRoutes(self)
	return {
		{
			Name = "EquipItem",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:equipItem(player, arguments[1])
			end,
		},
		{
			Name = "EquipArmour",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:equipArmour(player, arguments[1])
			end,
		},
		{
			Name = "HeldItemChanged",
			Validate = Validation.tuple({ Validation.optional(Validation.string) }, 0),
			Handle = function(player, arguments)
				self:heldItemChanged(player, arguments[1])
			end,
		},
		{
			Name = "UseHeldItem",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:useHeldItem(player)
			end,
		},
		{
			Name = "ItemPickup",
			Validate = Validation.tuple({ Validation.string, Validation.integer, Validation.string }),
			Handle = function(player, arguments)
				self:itemPickup(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "PlaceBlock",
			Validate = Validation.tuple({ Validation.finiteVector3, Validation.finiteNumber, Validation.string }),
			Handle = function(player, arguments)
				self:placeBlock(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "HitBlock",
			Validate = Validation.tuple({ Validation.finiteVector3 }),
			Handle = function(player, arguments)
				self:hitBlock(player, arguments[1])
			end,
		},
		{
			Name = "OpenChest",
			Validate = Validation.tuple({ Validation.instance("Model") }),
			Handle = function(player, arguments)
				self:openChest(player, arguments[1])
			end,
		},
		{
			Name = "TakeChestItem",
			Validate = Validation.tuple({
				Validation.instance("Model"),
				Validation.string,
				Validation.integer,
			}),
			Handle = function(player, arguments)
				self:takeChestItem(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "CloseChest",
			Validate = Validation.tuple({ Validation.instance("Model") }),
			Handle = function(player, arguments)
				self:closeChest(player, arguments[1])
			end,
		},
	}
end

return WorldHandlers
