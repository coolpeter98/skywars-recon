--!strict
-- BlockWorldService — server-authoritative voxel world for block breaking.
--
-- The recovered maps (e.g. Airport) are greedy-meshed: runs of same-material
-- block cells are merged into a single axis-aligned Part whose exposed faces
-- carry tiled textures (StudsPerTile = 3, offset 0, one id per
-- material + face across the whole map) and whose hidden faces are
-- texture-culled. This service reconstructs the voxel grid from those parts
-- and re-meshes locally when cells are removed:
--
--   * every block cell is indexed (cell index = world position / 3) to its
--     owning part, item type, and break time;
--   * removals (pickaxe breaks remove one cell; explosions remove a whole
--     sphere) are BATCHED: every part that lost a cell is rebuilt exactly
--     once, and all affected parts are destroyed before any replacement
--     geometry is created, so the replication burst never shows old and new
--     geometry overlapping (the cause of carve flicker);
--   * replacement faces follow the recovered map's own culling rules: a
--     face is textured when any part of it borders air (or a removed cell)
--     and the material ships a texture for that orientation — full-face
--     overdraw on covered patches is the map's style (the shipped Airport
--     has 723 such partially-covered textured faces); cells inside the
--     removed region's bounding box become individual 3x3x3 parts whose 1x1
--     faces cull exactly, and the part's remainder outside the box rebuilds
--     as up to six slabs;
--   * faces of neighbouring parts that a removed cell used to hide get
--     their texture back.
--
-- Player-placed blocks register here too, so mining them goes through the
-- same path. Break progress is accumulated from the client's repeated
-- HitBlock events (fired once per heartbeat while the mouse is held on a
-- block) and replicated back through BlockBreakProgress (crack overlay),
-- BlockBreakStatusCleared, and BlockRemoved. When a block breaks, the mined
-- item is granted to the miner's inventory (explosions grant nothing).
-- Egg Wars is the mode exception: its authored arena cells are immutable to
-- both paths, while player-placed defence blocks remain breakable.

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
-- face that faces the mined cell (a neighbour at +Z shows its -Z face,
-- which Roblox calls Front).
local NEIGHBOUR_FACES = {
	{ Offset = Vector3.new(1, 0, 0), Face = "Left" },
	{ Offset = Vector3.new(-1, 0, 0), Face = "Right" },
	{ Offset = Vector3.new(0, 1, 0), Face = "Bottom" },
	{ Offset = Vector3.new(0, -1, 0), Face = "Top" },
	{ Offset = Vector3.new(0, 0, 1), Face = "Front" },
	{ Offset = Vector3.new(0, 0, -1), Face = "Back" },
}

local NORMAL_IDS: { [string]: Enum.NormalId } = {
	Right = Enum.NormalId.Right,
	Left = Enum.NormalId.Left,
	Top = Enum.NormalId.Top,
	Bottom = Enum.NormalId.Bottom,
	Back = Enum.NormalId.Back,
	Front = Enum.NormalId.Front,
}

-- A part's own faces by world direction (Roblox NormalId convention).
local PART_FACES = {
	{ Face = "Right", Axis = "X", EdgeIsMax = true },
	{ Face = "Left", Axis = "X", EdgeIsMax = false },
	{ Face = "Top", Axis = "Y", EdgeIsMax = true },
	{ Face = "Bottom", Axis = "Y", EdgeIsMax = false },
	{ Face = "Back", Axis = "Z", EdgeIsMax = true },
	{ Face = "Front", Axis = "Z", EdgeIsMax = false },
}

local function getBoxEdge(box: BlockGeometry.BoxRange, axis: string, isMax: boolean): number
	if axis == "X" then
		return if isMax then box.maxX else box.minX
	elseif axis == "Y" then
		return if isMax then box.maxY else box.minY
	else
		return if isMax then box.maxZ else box.minZ
	end
end

-- Visits every cell adjacent across the given box face.
local function iterateAcrossCells(
	box: BlockGeometry.BoxRange,
	axis: string,
	edgeCell: number,
	sign: number,
	visit: (cell: Vector3) -> ()
)
	if axis == "X" then
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				visit(Vector3.new(edgeCell + sign, y, z))
			end
		end
	elseif axis == "Y" then
		for x = box.minX, box.maxX do
			for z = box.minZ, box.maxZ do
				visit(Vector3.new(x, edgeCell + sign, z))
			end
		end
	else
		for x = box.minX, box.maxX do
			for y = box.minY, box.maxY do
				visit(Vector3.new(x, y, edgeCell + sign))
			end
		end
	end
end

local function isWithinRange(cell: Vector3, rangeMin: Vector3, rangeMax: Vector3): boolean
	return cell.X >= rangeMin.X
		and cell.X <= rangeMax.X
		and cell.Y >= rangeMin.Y
		and cell.Y <= rangeMax.Y
		and cell.Z >= rangeMin.Z
		and cell.Z <= rangeMax.Z
end

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

-- Egg Wars preserves the authored arena exactly. Blocks placed during the
-- round carry PlacedByUserId and remain normal, breakable defence blocks.
function BlockWorldService.isImmutableMapEntry(self, entry: VoxelEntry): boolean
	local eggWarsService = self.context.eggWarsService
	return eggWarsService ~= nil
		and eggWarsService:protectsMapGeometry()
		and entry.part:GetAttribute(Attribute.PlacedByUserId) == nil
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
-- placement would be allowed (active rounds: inside the arena constraints
-- while alive; public game servers: anywhere).
function BlockWorldService.isInteractionAllowed(self, player: Player, position: Vector3): boolean
	local runtimeContext = self.context.runtimeContext:get()
	if runtimeContext.Role == "Private" then
		return self.context.roundService:isBlockPlacementAllowed(player, position)
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
	if self:isImmutableMapEntry(entry) then
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

-- Carves a spherical explosion out of the voxel world: every block whose
-- cell center lies within `radiusStuds` of `position` is removed in ONE
-- batched pass (no items are granted — the blast destroys, it does not
-- gather). Returns the number of blocks destroyed.
function BlockWorldService.mineExplosion(self, position: Vector3, radiusStuds: number): number
	if radiusStuds <= 0 or radiusStuds ~= radiusStuds or radiusStuds == math.huge then
		return 0
	end
	local scaledCenter = position / BLOCK_SIZE
	local radiusCells = radiusStuds / BLOCK_SIZE
	local removedPositions: { Vector3 } = {}
	local minX = math.floor(scaledCenter.X - radiusCells)
	local maxX = math.ceil(scaledCenter.X + radiusCells)
	local minY = math.floor(scaledCenter.Y - radiusCells)
	local maxY = math.ceil(scaledCenter.Y + radiusCells)
	local minZ = math.floor(scaledCenter.Z - radiusCells)
	local maxZ = math.ceil(scaledCenter.Z + radiusCells)
	for x = minX, maxX do
		for y = minY, maxY do
			for z = minZ, maxZ do
				local cellCenter = Vector3.new(x * BLOCK_SIZE, y * BLOCK_SIZE, z * BLOCK_SIZE)
				if (cellCenter - position).Magnitude <= radiusStuds then
					table.insert(removedPositions, cellCenter)
				end
			end
		end
	end
	return self:removeBlocks(removedPositions)
end

-- Removes the block at `position` (a block-cell center). The affected part
-- is rebuilt in one pass (see removeBlocks). Returns the mined item type.
function BlockWorldService.mineCell(self, position: Vector3): string?
	local entry = self.cells[keyForPosition(position)]
	if entry == nil or entry.part.Parent == nil then
		return nil
	end
	local itemType = entry.itemType
	if self:removeBlocks({ position }) == 0 then
		return nil
	end
	return itemType
end

-- Batched block removal (pickaxe breaks remove one cell; explosions remove
-- a whole sphere). Every part that lost a cell is rebuilt exactly ONCE, and
-- all affected parts are destroyed BEFORE any replacement geometry is
-- created — during replication the client never sees old and new geometry
-- overlapping (the source of the carve flicker).
--
-- Replacement geometry follows the recovered map's own culling rules: a
-- face is textured when any part of it borders air or a removed cell and
-- the material has a texture for that orientation (full-face overdraw on
-- covered patches is the map's style); faces between two blocks stay
-- untextured. Cells inside the removed region's bounding box become
-- individual 3x3x3 parts (their 1x1 faces cull exactly, so the crater
-- interior is overdraw-free); the part's remainder outside that box is
-- rebuilt as up to six slabs.
function BlockWorldService.removeBlocks(self, removedPositions: { Vector3 }): number
	local removedKeys = {} :: { [string]: Vector3 }
	local affectedList = {} :: { { itemType: string, part: BasePart, removed: { Vector3 } } }
	local affectedIndexByPart = {} :: { [BasePart]: number }
	for _, position in removedPositions do
		local key = keyForPosition(position)
		local entry = self.cells[key]
		if
			entry ~= nil
			and entry.part.Parent ~= nil
			and not self:isImmutableMapEntry(entry)
			and removedKeys[key] == nil
		then
			removedKeys[key] = position
			local affectedIndex = affectedIndexByPart[entry.part]
			if affectedIndex == nil then
				affectedIndex = #affectedList + 1
				affectedIndexByPart[entry.part] = affectedIndex
				affectedList[affectedIndex] = {
					itemType = entry.itemType,
					part = entry.part,
					removed = {},
				}
			end
			table.insert(affectedList[affectedIndex].removed, position)
		end
	end
	if #affectedList == 0 then
		return 0
	end

	for _, affected in affectedList do
		self:remeshPart(affected.part, affected.itemType, affected.removed, removedKeys)
	end

	-- Faces of neighbouring parts that the removed cells used to hide were
	-- texture-culled by the generator; re-add the missing ones (full-face,
	-- per-block tiling — the original map's own overdraw style).
	local removedCount = 0
	for key in removedKeys do
		removedCount += 1
		self:exposeNeighbourFaces(removedKeys[key])
	end
	return removedCount
end

-- Rebuilds one part that lost cells: captures its presentation, clears its
-- cells from the index, destroys it, then creates the final replacement
-- parts (individuals inside the removed bounding box + slabs outside it).
function BlockWorldService.remeshPart(
	self,
	part: BasePart,
	itemType: string,
	removed: { Vector3 },
	removedKeys: { [string]: Vector3 }
)
	local minCell, maxCell = getCellRange(part)
	if minCell == nil or maxCell == nil then
		part:Destroy()
		return
	end
	local parent = part.Parent
	local material = part.Material
	local color = part.Color
	local transparency = part.Transparency
	local anchored = part.Anchored
	local canCollide = part.CanCollide
	local topSurface = part.TopSurface
	local bottomSurface = part.BottomSurface

	local boxMin = Vector3.new(math.huge, math.huge, math.huge)
	local boxMax = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, position in removed do
		local cell = toCellVector(position)
		boxMin = Vector3.new(math.min(boxMin.X, cell.X), math.min(boxMin.Y, cell.Y), math.min(boxMin.Z, cell.Z))
		boxMax = Vector3.new(math.max(boxMax.X, cell.X), math.max(boxMax.Y, cell.Y), math.max(boxMax.Z, cell.Z))
	end
	boxMin = Vector3.new(math.max(boxMin.X, minCell.X), math.max(boxMin.Y, minCell.Y), math.max(boxMin.Z, minCell.Z))
	boxMax = Vector3.new(math.min(boxMax.X, maxCell.X), math.min(boxMax.Y, maxCell.Y), math.min(boxMax.Z, maxCell.Z))

	-- Clear this part's cells before any replacement is indexed.
	for x = minCell.X, maxCell.X do
		for y = minCell.Y, maxCell.Y do
			for z = minCell.Z, maxCell.Z do
				local key = cellKey(Vector3.new(x, y, z))
				local entry = self.cells[key]
				if entry ~= nil and entry.part == part then
					self.cells[key] = nil
				end
			end
		end
	end
	part:Destroy()

	for x = boxMin.X, boxMax.X do
		for y = boxMin.Y, boxMax.Y do
			for z = boxMin.Z, boxMax.Z do
				local cell = Vector3.new(x, y, z)
				if removedKeys[cellKey(cell)] == nil then
					self:createReplacementBox(
						itemType,
						{ minX = x, maxX = x, minY = y, maxY = y, minZ = z, maxZ = z },
						removedKeys,
						minCell,
						maxCell,
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
			end
		end
	end

	for _, slab in
		BlockGeometry.decomposeBoxMinusBox({
			minX = minCell.X,
			maxX = maxCell.X,
			minY = minCell.Y,
			maxY = maxCell.Y,
			minZ = minCell.Z,
			maxZ = maxCell.Z,
		}, boxMin, boxMax)
	do
		self:createReplacementBox(
			itemType,
			slab,
			removedKeys,
			minCell,
			maxCell,
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
end

-- Creates one replacement part (a single block or a slab), textures its
-- faces with the map's culling rule, and indexes its cells.
function BlockWorldService.createReplacementBox(
	self,
	itemType: string,
	box: BlockGeometry.BoxRange,
	removedKeys: { [string]: Vector3 },
	partMin: Vector3,
	partMax: Vector3,
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

	for _, face in PART_FACES do
		local edgeCell = if face.EdgeIsMax then getBoxEdge(box, face.Axis, true) else getBoxEdge(box, face.Axis, false)
		local sign = if face.EdgeIsMax then 1 else -1
		local anyExposed = false
		iterateAcrossCells(box, face.Axis, edgeCell, sign, function(across)
			local acrossKey = cellKey(across)
			local occupied = removedKeys[acrossKey] == nil
				and (isWithinRange(across, partMin, partMax) or self.cells[acrossKey] ~= nil)
			if not occupied then
				anyExposed = true
			end
		end)
		if anyExposed then
			self:addFaceTexture(boxPart, itemType, face.Face)
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

-- Adds a face texture to a part when the material has one for that face
-- (materials like Grass only ship a Top texture; their other faces stay
-- plain, exactly like the recovered map).
function BlockWorldService.addFaceTexture(self, part: BasePart, itemType: string, faceName: string)
	local faceTable = self.faceTextures[itemType]
	local textureId = if faceTable then faceTable[faceName] else nil
	if textureId == nil then
		return
	end
	local texture = Instance.new("Texture")
	texture.Face = NORMAL_IDS[faceName]
	texture.Texture = textureId
	texture.StudsPerTileU = BLOCK_SIZE
	texture.StudsPerTileV = BLOCK_SIZE
	texture.Parent = part
end

-- The removed cell used to hide the neighbouring part's face, so the map
-- generator texture-culled it. Re-add the texture when it is missing (the
-- full-face, per-block tiling overdraws covered patches exactly like the
-- original map's own partially-covered faces).
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
		if not hasTexture then
			self:addFaceTexture(part, entry.itemType, faceName)
		end
	end
end

return BlockWorldService
