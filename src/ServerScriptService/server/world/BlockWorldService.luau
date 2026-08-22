--!strict
-- BlockWorldService — server-authoritative voxel world for block breaking.
--
-- The recovered maps (e.g. Airport) are greedy-meshed: runs of same-material
-- block cells are merged into a single axis-aligned Part whose exposed faces
-- carry tiled textures (StudsPerTile = 3, offset 0, one id per
-- material + face across the whole map) and whose hidden faces are
-- texture-culled. This service reconstructs the voxel grid from those parts
-- and re-meshes locally when a cell is mined:
--
--   * every block cell is indexed (cell index = world position / 3) to its
--     owning part, item type, and break time;
--   * mining a single-cell part destroys it outright;
--   * mining a cell inside a merged part replaces the part with up to six
--     axis-aligned boxes (the standard box-minus-cell decomposition, see
--     BlockGeometry) and re-culls their faces: a face is textured when it
--     borders the mined cell or when it belongs to the old part's textured
--     exterior;
--   * faces of neighbouring parts that the mined cell used to hide get
--     their texture back (the original map only textures exposed faces).
--
-- Player-placed blocks register here too, so mining them goes through the
-- same path. Break progress is accumulated from the client's repeated
-- HitBlock events (fired once per heartbeat while the mouse is held on a
-- block) and replicated back through BlockBreakProgress (crack overlay),
-- BlockBreakStatusCleared, and BlockRemoved. When a block breaks, the mined
-- item is granted to the miner's inventory.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local BlockConstants = require(ReplicatedStorage.TS.block["block-constants"]).BlockConstants
local BlockGeometry = require(script.Parent.BlockGeometry)
local Items = require(ReplicatedStorage.TS.item.item).Items

type ItemDefinition = {
	Name: string,
	Block: { BreakTime: number? }?,
	Pickaxe: { TimeMultiplier: number }?,
}

type VoxelEntry = {
	part: BasePart,
	itemType: string,
	breakTime: number,
}

type BreakState = {
	position: Vector3,
	accumulated: number,
	lastHit: number,
}

local TYPED_ITEMS = Items :: { [string]: ItemDefinition }

local BLOCK_SIZE: number = BlockConstants.BLOCK_SIZE
local BLOCK_DIMENSION: Vector3 = BlockConstants.BLOCK_DIMENSION
-- The client gives up on a target after this long without a hit; used to
-- sweep stale crack overlays server-side.
local BREAK_HIT_EXPIRE: number = BlockConstants.BLOCK_HIT_EXPIRE
-- Network jitter can inflate the delta between two HitBlock events; clamp it
-- so a lag spike cannot fast-forward a break.
local BREAK_HIT_MAX_GAP = 0.25
-- The client's break raycast reaches 35 studs from the camera; this bound
-- from the character root covers that plus third-person camera slack.
local BREAK_MAX_RANGE = 48
local GRID_TOLERANCE = 0.01
local SWEEP_INTERVAL_FRAMES = 30

-- Neighbour offsets (in cells) and the NormalId name of the neighbour's
-- face that faces the mined cell.
local NEIGHBOUR_FACES = {
	{ Offset = Vector3.new(1, 0, 0), Face = "Left" },
	{ Offset = Vector3.new(-1, 0, 0), Face = "Right" },
	{ Offset = Vector3.new(0, 1, 0), Face = "Bottom" },
	{ Offset = Vector3.new(0, -1, 0), Face = "Top" },
	{ Offset = Vector3.new(0, 0, 1), Face = "Back" },
	{ Offset = Vector3.new(0, 0, -1), Face = "Front" },
}

local NORMAL_IDS: { [string]: Enum.NormalId } = {
	Right = Enum.NormalId.Right,
	Left = Enum.NormalId.Left,
	Top = Enum.NormalId.Top,
	Bottom = Enum.NormalId.Bottom,
	Back = Enum.NormalId.Back,
	Front = Enum.NormalId.Front,
}

local BlockWorldService = {}
BlockWorldService.__index = BlockWorldService

local function toCellVector(position: Vector3): Vector3
	return Vector3.new(position.X / BLOCK_SIZE, position.Y / BLOCK_SIZE, position.Z / BLOCK_SIZE)
end

local function cellKey(cell: BlockGeometry.Cell): string
	return ("%d,%d,%d"):format(math.round(cell.X), math.round(cell.Y), math.round(cell.Z))
end

local function keyForPosition(position: Vector3): string
	return cellKey(toCellVector(position))
end

local function isOnGrid(position: Vector3): boolean
	local scaled = position / BLOCK_SIZE
	return (scaled - Vector3.new(math.round(scaled.X), math.round(scaled.Y), math.round(scaled.Z))).Magnitude
		< GRID_TOLERANCE
end

local function isAxisAligned(part: BasePart): boolean
	local orientation = part.Orientation
	return math.abs(orientation.X % 360) < GRID_TOLERANCE
		and math.abs(orientation.Y % 360) < GRID_TOLERANCE
		and math.abs(orientation.Z % 360) < GRID_TOLERANCE
end

local function getBreakTime(itemType: string): number
	local itemDefinition = TYPED_ITEMS[itemType]
	local breakTime = if itemDefinition and itemDefinition.Block then itemDefinition.Block.BreakTime else nil
	if breakTime ~= nil and breakTime > 0 then
		return breakTime
	end
	return 0.5
end

-- Returns the cell range (inclusive, in cell coordinates) covered by an
-- axis-aligned part whose size is a multiple of the block size, or nil when
-- the part is not cell-aligned.
local function getCellRange(part: BasePart): (Vector3?, Vector3?)
	local halfSize = part.Size / 2
	local corner = part.Position - halfSize
	local minCell = toCellVector(corner + BLOCK_DIMENSION / 2)
	if not isOnGrid(minCell * BLOCK_SIZE) then
		return nil, nil
	end
	local extents = toCellVector(part.Size)
	local minX, minY, minZ = math.round(minCell.X), math.round(minCell.Y), math.round(minCell.Z)
	return Vector3.new(minX, minY, minZ),
		Vector3.new(
			minX + math.round(extents.X) - 1,
			minY + math.round(extents.Y) - 1,
			minZ + math.round(extents.Z) - 1
		)
end

function BlockWorldService.new(context)
	return setmetatable({
		context = context,
		cells = {} :: { [string]: VoxelEntry },
		faceTextures = {} :: { [string]: { [string]: string } },
		breakStates = setmetatable({}, { __mode = "k" }) :: { [Player]: BreakState },
		heartbeat = nil :: RBXScriptConnection?,
		sweepCounter = 0,
	}, BlockWorldService)
end

function BlockWorldService.start(self)
	if self.heartbeat ~= nil then
		return
	end
	self.heartbeat = RunService.Heartbeat:Connect(function()
		self.sweepCounter += 1
		if self.sweepCounter % SWEEP_INTERVAL_FRAMES ~= 0 then
			return
		end
		local now = os.clock()
		for player, state in self.breakStates do
			if now - state.lastHit > BREAK_HIT_EXPIRE then
				self.breakStates[player] = nil
				if player.Parent == Players then
					self.context.outbound:fire("BlockBreakStatusCleared", player, state.position)
				end
			end
		end
	end)
end

function BlockWorldService.stop(self)
	if self.heartbeat ~= nil then
		self.heartbeat:Disconnect()
		self.heartbeat = nil
	end
end

-- Rebuilds the voxel index from a freshly loaded arena model. Clears any
-- previous index, texture registry, and active break sessions (the previous
-- arena no longer exists).
function BlockWorldService.rebuild(self, mapModel: Instance)
	self:clear()
	for _, descendant in mapModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			self:registerPart(descendant)
		end
	end
end

function BlockWorldService.clear(self)
	table.clear(self.cells)
	table.clear(self.faceTextures)
	for player, state in self.breakStates do
		self.breakStates[player] = nil
		if player.Parent == Players then
			self.context.outbound:fire("BlockBreakStatusCleared", player, state.position)
		end
	end
end

-- Records one block part (map geometry or a player-placed block). Parts that
-- are not full block cells (thin slabs, decor, chest meshes, misaligned
-- geometry) are skipped for indexing but still contribute their face
-- textures to the shared per-material texture registry when they are named
-- after a block item.
function BlockWorldService.registerPart(self, part: BasePart, forcedItemType: string?)
	local itemType = forcedItemType or part.Name
	local itemDefinition = TYPED_ITEMS[itemType]
	if itemDefinition == nil or itemDefinition.Block == nil then
		return
	end
	self:collectFaceTextures(part, itemType)

	local size = part.Size
	if
		math.abs(size.X % BLOCK_SIZE) > GRID_TOLERANCE
		or math.abs(size.Y % BLOCK_SIZE) > GRID_TOLERANCE
		or math.abs(size.Z % BLOCK_SIZE) > GRID_TOLERANCE
	then
		return
	end

	local entry: VoxelEntry = {
		part = part,
		itemType = itemType,
		breakTime = getBreakTime(itemType),
	}
	if size == BLOCK_DIMENSION then
		-- Single-cell parts may be rotated (e.g. launch pads); the client
		-- targets them by their center, which must sit on the grid.
		if not isOnGrid(part.Position) then
			return
		end
		self.cells[keyForPosition(part.Position)] = entry
		return
	end
	if not isAxisAligned(part) then
		return
	end
	local minCell, maxCell = getCellRange(part)
	if minCell == nil or maxCell == nil then
		return
	end
	for x = minCell.X, maxCell.X do
		for y = minCell.Y, maxCell.Y do
			for z = minCell.Z, maxCell.Z do
				self.cells[cellKey(Vector3.new(x, y, z))] = entry
			end
		end
	end
end

function BlockWorldService.collectFaceTextures(self, part: BasePart, itemType: string)
	local faceTable = self.faceTextures[itemType]
	if faceTable == nil then
		faceTable = {}
		self.faceTextures[itemType] = faceTable
	end
	for _, child in part:GetChildren() do
		if child:IsA("Texture") and child.Face ~= nil and child.Texture ~= "" then
			local faceName = child.Face.Name
			if faceTable[faceName] == nil then
				faceTable[faceName] = child.Texture
			end
		end
	end
end

-- Mirrors BlockPlacementService's role gate: breaking is allowed wherever
-- placement would be allowed (custom rounds: inside the arena constraints
-- while alive; public game servers: anywhere).
function BlockWorldService.isInteractionAllowed(self, player: Player, position: Vector3): boolean
	local runtimeContext = self.context.runtimeContext:get()
	if runtimeContext.Role == "Private" then
		return self.context.customGameService:isBlockPlacementAllowed(player, position)
	end
	return runtimeContext.Role == "Game"
end

function BlockWorldService.canBreak(self, player: Player, position: Vector3): boolean
	if player.Parent ~= Players then
		return false
	end
	if not isOnGrid(position) then
		return false
	end
	local entry = self.cells[keyForPosition(position)]
	if entry == nil or entry.part.Parent == nil then
		return false
	end
	if player:GetAttribute(Attribute.Alive) ~= true or player:GetAttribute(Attribute.Spectating) == true then
		return false
	end
	if not self:isInteractionAllowed(player, position) then
		return false
	end
	local session = self.context.playerSessions:get(player)
	local heldItemType = if session then session.heldItemType else nil
	local heldDefinition = if type(heldItemType) == "string" then TYPED_ITEMS[heldItemType] else nil
	if heldDefinition == nil or heldDefinition.Pickaxe == nil then
		return false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	return (root.Position - position).Magnitude <= BREAK_MAX_RANGE
end

function BlockWorldService.getRequiredBreakTime(self, player: Player, position: Vector3): number
	local entry = self.cells[keyForPosition(position)]
	local breakTime = if entry then entry.breakTime else 0.5
	local session = self.context.playerSessions:get(player)
	local heldItemType = if session then session.heldItemType else nil
	local heldDefinition = if type(heldItemType) == "string" then TYPED_ITEMS[heldItemType] else nil
	local multiplier = 1
	if heldDefinition ~= nil and heldDefinition.Pickaxe ~= nil and heldDefinition.Pickaxe.TimeMultiplier ~= nil then
		multiplier = heldDefinition.Pickaxe.TimeMultiplier
	end
	return breakTime * multiplier
end

-- The client fires HitBlock once per heartbeat while the mouse is held on a
-- block. This accumulates break progress for the player's current target and
-- replicates the crack overlay via BlockBreakProgress; once the accumulated
-- time reaches the block's BreakTime scaled by the held pickaxe's
-- TimeMultiplier, the block is mined, the overlay is cleared, and the mined
-- item is granted to the miner.
function BlockWorldService.registerHit(self, player: Player, position: Vector3)
	local state = self.breakStates[player]
	if not self:canBreak(player, position) then
		if state ~= nil and state.position == position then
			self.breakStates[player] = nil
			self.context.outbound:fire("BlockBreakStatusCleared", player, position)
		end
		return
	end
	local now = os.clock()
	if state == nil or state.position ~= position then
		if state ~= nil then
			self.context.outbound:fire("BlockBreakStatusCleared", player, state.position)
		end
		state = { position = position, accumulated = 0, lastHit = now }
		self.breakStates[player] = state
		self.context.outbound:fire("BlockBreakProgress", player, position, 0)
		return
	end
	state.accumulated += math.min(now - state.lastHit, BREAK_HIT_MAX_GAP)
	state.lastHit = now
	local required = self:getRequiredBreakTime(player, position)
	local progress = math.min(1, state.accumulated / required)
	self.context.outbound:fire("BlockBreakProgress", player, position, progress)
	if state.accumulated >= required then
		self.breakStates[player] = nil
		local minedItemType = self:mineCell(position)
		self.context.outbound:fire("BlockBreakStatusCleared", player, position)
		self.context.outbound:fire("BlockRemoved", player, position)
		if minedItemType ~= nil then
			self.context.inventoryService:changeItem(player, minedItemType, 1)
		end
	end
end

-- Removes the block at `position` (a block-cell center). Single-cell parts
-- are destroyed outright; merged parts are split into up to six boxes around
-- the mined cell with their faces re-culled. Returns the mined item type.
function BlockWorldService.mineCell(self, position: Vector3): string?
	local key = keyForPosition(position)
	local entry = self.cells[key]
	if entry == nil then
		return nil
	end
	self.cells[key] = nil
	local part = entry.part
	if part.Parent == nil then
		return nil
	end
	local itemType = entry.itemType
	if part.Size == BLOCK_DIMENSION then
		part:Destroy()
	else
		self:splitPart(part, position)
	end
	self:exposeNeighbourFaces(position)
	return itemType
end

-- Replaces a merged part with up to six boxes around the mined cell, then
-- re-culls their faces. The replacement parts keep the old part's name,
-- material, color, transparency, surface, and physical flags, and live under
-- the same parent.
function BlockWorldService.splitPart(self, part: BasePart, minedPosition: Vector3)
	local minCell, maxCell = getCellRange(part)
	if minCell == nil or maxCell == nil then
		-- Unreachable for indexed multi-cell parts; degrade to a plain removal.
		part:Destroy()
		return
	end
	local minedCell = toCellVector(minedPosition)
	local oldRange: BlockGeometry.BoxRange = {
		minX = minCell.X,
		maxX = maxCell.X,
		minY = minCell.Y,
		maxY = maxCell.Y,
		minZ = minCell.Z,
		maxZ = maxCell.Z,
	}
	local oldTexturedFaces: { [string]: boolean } = {}
	for _, child in part:GetChildren() do
		if child:IsA("Texture") and child.Face ~= nil and child.Texture ~= "" then
			oldTexturedFaces[child.Face.Name] = true
		end
	end
	local itemType = part.Name
	local parent = part.Parent
	local material = part.Material
	local color = part.Color
	local transparency = part.Transparency
	local anchored = part.Anchored
	local canCollide = part.CanCollide
	local topSurface = part.TopSurface
	local bottomSurface = part.BottomSurface

	for _, box in BlockGeometry.decomposeBox(oldRange, minedCell) do
		self:createBox(
			itemType,
			box,
			oldRange,
			minedCell,
			oldTexturedFaces,
			parent,
			material,
			color,
			transparency,
			anchored,
			canCollide,
			topSurface,
			bottomSurface
		)
	end
	-- Drop the stale entries that still reference the destroyed part (the
	-- new boxes already re-indexed their cells above).
	for x = oldRange.minX, oldRange.maxX do
		for y = oldRange.minY, oldRange.maxY do
			for z = oldRange.minZ, oldRange.maxZ do
				local key = cellKey(Vector3.new(x, y, z))
				local entry = self.cells[key]
				if entry ~= nil and entry.part == part then
					self.cells[key] = nil
				end
			end
		end
	end
	part:Destroy()
end

function BlockWorldService.createBox(
	self,
	itemType: string,
	box: BlockGeometry.BoxRange,
	oldRange: BlockGeometry.BoxRange,
	minedCell: BlockGeometry.Cell,
	oldTexturedFaces: { [string]: boolean },
	parent: Instance?,
	material: Enum.Material,
	color: Color3,
	transparency: number,
	anchored: boolean,
	canCollide: boolean,
	topSurface: Enum.SurfaceType,
	bottomSurface: Enum.SurfaceType
)
	local extents = BlockGeometry.boxExtents(box)
	local center = BlockGeometry.boxCenter(box)
	local boxPart = Instance.new("Part")
	boxPart.Name = itemType
	boxPart.Size = Vector3.new(extents.X * BLOCK_SIZE, extents.Y * BLOCK_SIZE, extents.Z * BLOCK_SIZE)
	boxPart.Position = Vector3.new(center.X * BLOCK_SIZE, center.Y * BLOCK_SIZE, center.Z * BLOCK_SIZE)
	boxPart.Material = material
	boxPart.Color = color
	boxPart.Transparency = transparency
	boxPart.Anchored = anchored
	boxPart.CanCollide = canCollide
	boxPart.TopSurface = topSurface
	boxPart.BottomSurface = bottomSurface
	boxPart.Parent = parent

	local faceTable = self.faceTextures[itemType] or {}
	local fallbackTexture: string? = nil
	for _, textureId in faceTable do
		fallbackTexture = textureId
		break
	end
	for _, face in BlockGeometry.describeFaces(box, oldRange, minedCell) do
		if face.BordersMined or (face.IsExterior and oldTexturedFaces[face.Face] == true) then
			local textureId = faceTable[face.Face] or fallbackTexture
			if textureId ~= nil then
				local texture = Instance.new("Texture")
				texture.Face = NORMAL_IDS[face.Face]
				texture.Texture = textureId
				texture.StudsPerTileU = BLOCK_SIZE
				texture.StudsPerTileV = BLOCK_SIZE
				texture.Parent = boxPart
			end
		end
	end
	self:indexBoxCells(boxPart, itemType, box)
end

function BlockWorldService.indexBoxCells(self, boxPart: BasePart, itemType: string, box: BlockGeometry.BoxRange)
	local entry: VoxelEntry = {
		part = boxPart,
		itemType = itemType,
		breakTime = getBreakTime(itemType),
	}
	for x = box.minX, box.maxX do
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				self.cells[cellKey(Vector3.new(x, y, z))] = entry
			end
		end
	end
end

-- The mined cell used to hide the neighbouring parts' faces, so the map
-- generator texture-culled them. Re-add the texture for each neighbour that
-- lacks one. Tiling is per-block (StudsPerTile = 3, offset 0): merged faces
-- are cell-aligned, so the pattern stays on the global grid, and covered
-- patches stay hidden behind the surrounding blocks exactly like the
-- original map's full-face texturing.
function BlockWorldService.exposeNeighbourFaces(self, position: Vector3)
	local minedCell = toCellVector(position)
	for _, neighbour in NEIGHBOUR_FACES do
		local entry = self.cells[cellKey(minedCell + neighbour.Offset)]
		if entry == nil or entry.part.Parent == nil then
			continue
		end
		local part = entry.part
		local faceName = neighbour.Face
		local hasTexture = false
		for _, child in part:GetChildren() do
			if child:IsA("Texture") and child.Face ~= nil and child.Face.Name == faceName then
				hasTexture = true
				break
			end
		end
		if hasTexture then
			continue
		end
		local faceTable = self.faceTextures[entry.itemType] or {}
		local textureId = faceTable[faceName]
		if textureId == nil then
			for _, anyTexture in faceTable do
				textureId = anyTexture
				break
			end
		end
		if textureId == nil then
			continue
		end
		local texture = Instance.new("Texture")
		texture.Face = NORMAL_IDS[faceName]
		texture.Texture = textureId
		texture.StudsPerTileU = BLOCK_SIZE
		texture.StudsPerTileV = BLOCK_SIZE
		texture.Parent = part
	end
end

return BlockWorldService
