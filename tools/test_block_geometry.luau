-- test_block_geometry.luau — Lune unit tests for the greedy-mesh re-meshing
-- math (BlockGeometry) plus a simulation of the full service-side removal
-- rules (batched removeBlocks: bounding-box singles + slabs, neighbour face
-- exposure).
--
-- Run with:  lune run tools/test_block_geometry.luau
--
-- The simulation mirrors the batched BlockWorldService design exactly:
--   * a voxel world maps "x,y,z" cell keys to a material name;
--   * merged parts are axis-aligned boxes of one material with face textures;
--   * removeBlocks batches every removed cell: each part that lost a cell is
--     rebuilt ONCE — individual blocks inside the removed region's bounding
--     box and up to six slabs outside it;
--   * a face is textured when any across-cell is air or removed AND the
--     material ships a texture for that orientation (overdraw is allowed,
--     matching the recovered map's own style); neighbours of removed cells
--     get their missing face texture back.
-- Invariants checked after every operation:
--   * the voxel state is exactly the initial state minus the removed cells;
--   * parts tile the world (no gaps, no overlaps);
--   * every textured face has at least one exposed across-cell (no
--     fully-covered textured faces);
--   * no face with an exposed across-cell lacks a texture unless the
--     material has no texture for that face orientation (plain-face
--     materials like Grass sides).

local BlockGeometry = require("../src/ServerScriptService/server/world/BlockGeometry")

local failures = 0
local checks = 0

local function check(condition, message)
	checks += 1
	if not condition then
		failures += 1
		print(("FAIL: %s"):format(message))
	end
end

local function cellKey(x, y, z)
	return ("%d,%d,%d"):format(x, y, z)
end

local FACE_LAYOUT = {
	{ Name = "Right", Axis = "X", EdgeIsMax = true },
	{ Name = "Left", Axis = "X", EdgeIsMax = false },
	{ Name = "Top", Axis = "Y", EdgeIsMax = true },
	{ Name = "Bottom", Axis = "Y", EdgeIsMax = false },
	{ Name = "Back", Axis = "Z", EdgeIsMax = true },
	{ Name = "Front", Axis = "Z", EdgeIsMax = false },
}

-- Materials that only ship a texture for the given faces (Grass ships only
-- Top); all other materials have all six faces.
local PARTIAL_MATERIALS = {
	GrassLike = { Top = true },
}

local function hasFaceTexture(material, faceName)
	local partial = PARTIAL_MATERIALS[material]
	if partial ~= nil then
		return partial[faceName] == true
	end
	return true
end

local World = {}
World.__index = World

function World.new()
	return setmetatable({
		cells = {}, -- key -> material
		parts = {}, -- partId -> { Material, Box, Faces }
		nextPartId = 0,
	}, World)
end

function World:addBox(material, box, faces)
	local id = self.nextPartId
	self.nextPartId += 1
	for x = box.minX, box.maxX do
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				self.cells[cellKey(x, y, z)] = material
			end
		end
	end
	self.parts[id] = { Material = material, Box = box, Faces = faces or {} }
	return id
end

-- Initial meshing rule (mirrors the map generator): a face is textured when
-- any across-cell is air and the material has that face texture.
function World:meshedFaces(material, box)
	local faces = {}
	for _, face in FACE_LAYOUT do
		if hasFaceTexture(material, face.Name) then
			local edge = self:getEdge(box, face.Axis, face.EdgeIsMax)
			local sign = if face.EdgeIsMax then 1 else -1
			local anyAir = false
			self:iterateAcross(box, face.Axis, edge, sign, function(across)
				if self.cells[cellKey(across.X, across.Y, across.Z)] == nil then
					anyAir = true
				end
			end)
			if anyAir then
				faces[face.Name] = true
			end
		end
	end
	return faces
end

function World:remeshAllFaces()
	for _, part in self.parts do
		part.Faces = self:meshedFaces(part.Material, part.Box)
	end
end

function World:getEdge(box, axis, isMax)
	if axis == "X" then
		return if isMax then box.maxX else box.minX
	elseif axis == "Y" then
		return if isMax then box.maxY else box.minY
	else
		return if isMax then box.maxZ else box.minZ
	end
end

function World:iterateAcross(box, axis, edge, sign, visit)
	if axis == "X" then
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				visit({ X = edge + sign, Y = y, Z = z })
			end
		end
	elseif axis == "Y" then
		for x = box.minX, box.maxX do
			for z = box.minZ, box.maxZ do
				visit({ X = x, Y = edge + sign, Z = z })
			end
		end
	else
		for x = box.minX, box.maxX do
			for y = box.minY, box.maxY do
				visit({ X = x, Y = y, Z = edge + sign })
			end
		end
	end
end

function World:faceHasAirAdjacent(part, faceLayout)
	local box = part.Box
	local edge = self:getEdge(box, faceLayout.Axis, faceLayout.EdgeIsMax)
	local sign = if faceLayout.EdgeIsMax then 1 else -1
	local anyAir = false
	self:iterateAcross(box, faceLayout.Axis, edge, sign, function(across)
		if self.cells[cellKey(across.X, across.Y, across.Z)] == nil then
			anyAir = true
		end
	end)
	return anyAir
end

-- Removes a batch of cells using the same rules as the batched BlockWorldService:
-- group by part, rebuild each affected part once (bounding-box singles +
-- slabs), then re-expose neighbour faces.
function World:removeBlocks(removedCells)
	local removedKeys = {}
	local affectedList = {}
	local affectedIndexByPart = {}
	for _, cell in removedCells do
		local key = cellKey(cell.X, cell.Y, cell.Z)
		local material = self.cells[key]
		if material ~= nil and removedKeys[key] == nil then
			removedKeys[key] = cell
			-- find the owning part
			local ownerId = nil
			for id, part in self.parts do
				if part.Material == material and BlockGeometry.cellInBox(cell, part.Box) then
					ownerId = id
					break
				end
			end
			check(ownerId ~= nil, ("removed cell %s has an owning part"):format(key))
			if ownerId ~= nil then
				local index = affectedIndexByPart[ownerId]
				if index == nil then
					index = #affectedList + 1
					affectedIndexByPart[ownerId] = index
					affectedList[index] = { PartId = ownerId, Removed = {} }
				end
				table.insert(affectedList[index].Removed, cell)
			end
		end
	end
	if #affectedList == 0 then
		return 0
	end

	for _, affected in affectedList do
		self:remeshPart(affected.PartId, affected.Removed, removedKeys)
	end

	local removedCount = 0
	for key, cell in removedKeys do
		removedCount += 1
		self:exposeNeighbourFaces(cell, key)
	end
	return removedCount
end

function World:remeshPart(partId, removed, removedKeys)
	local old = self.parts[partId]
	if old == nil then
		return
	end
	self.parts[partId] = nil
	local box = old.Box
	local material = old.Material

	-- clear the part's cells
	for x = box.minX, box.maxX do
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				self.cells[cellKey(x, y, z)] = nil
			end
		end
	end

	-- bounding box of removed cells, clipped to the part
	local boxMin = { X = math.huge, Y = math.huge, Z = math.huge }
	local boxMax = { X = -math.huge, Y = -math.huge, Z = -math.huge }
	for _, cell in removed do
		boxMin.X = math.min(boxMin.X, cell.X)
		boxMin.Y = math.min(boxMin.Y, cell.Y)
		boxMin.Z = math.min(boxMin.Z, cell.Z)
		boxMax.X = math.max(boxMax.X, cell.X)
		boxMax.Y = math.max(boxMax.Y, cell.Y)
		boxMax.Z = math.max(boxMax.Z, cell.Z)
	end
	boxMin.X = math.max(boxMin.X, box.minX)
	boxMin.Y = math.max(boxMin.Y, box.minY)
	boxMin.Z = math.max(boxMin.Z, box.minZ)
	boxMax.X = math.min(boxMax.X, box.maxX)
	boxMax.Y = math.min(boxMax.Y, box.maxY)
	boxMax.Z = math.min(boxMax.Z, box.maxZ)

	local range = {
		minX = box.minX,
		maxX = box.maxX,
		minY = box.minY,
		maxY = box.maxY,
		minZ = box.minZ,
		maxZ = box.maxZ,
	}

	for x = boxMin.X, boxMax.X do
		for y = boxMin.Y, boxMax.Y do
			for z = boxMin.Z, boxMax.Z do
				if removedKeys[cellKey(x, y, z)] == nil then
					local newBox = { minX = x, maxX = x, minY = y, maxY = y, minZ = z, maxZ = z }
					self:addBox(material, newBox, self:replacementFaces(material, newBox, removedKeys, range))
				end
			end
		end
	end

	for _, slab in BlockGeometry.decomposeBoxMinusBox(range, boxMin, boxMax) do
		self:addBox(material, slab, self:replacementFaces(material, slab, removedKeys, range))
	end
end

function World:replacementFaces(material, newBox, removedKeys, partRange)
	local faces = {}
	for _, face in FACE_LAYOUT do
		if hasFaceTexture(material, face.Name) then
			local edge = self:getEdge(newBox, face.Axis, face.EdgeIsMax)
			local sign = if face.EdgeIsMax then 1 else -1
			local anyExposed = false
			self:iterateAcross(newBox, face.Axis, edge, sign, function(across)
				local acrossKey = cellKey(across.X, across.Y, across.Z)
				local occupied = removedKeys[acrossKey] == nil
					and (BlockGeometry.cellInBox(across, partRange) or self.cells[acrossKey] ~= nil)
				if not occupied then
					anyExposed = true
				end
			end)
			if anyExposed then
				faces[face.Name] = true
			end
		end
	end
	return faces
end

function World:exposeNeighbourFaces(removedCell, removedKey)
	local offsets = {
		{ 1, 0, 0, "Left" },
		{ -1, 0, 0, "Right" },
		{ 0, 1, 0, "Bottom" },
		{ 0, -1, 0, "Top" },
		{ 0, 0, 1, "Front" },
		{ 0, 0, -1, "Back" },
	}
	for _, offset in offsets do
		local neighbourKey = cellKey(removedCell.X + offset[1], removedCell.Y + offset[2], removedCell.Z + offset[3])
		if self.cells[neighbourKey] ~= nil then
			local faceName = offset[4]
			local neighbourCell = {
				X = removedCell.X + offset[1],
				Y = removedCell.Y + offset[2],
				Z = removedCell.Z + offset[3],
			}
			local found = false
			for _, part in self.parts do
				if BlockGeometry.cellInBox(neighbourCell, part.Box) then
					found = true
					if part.Faces[faceName] == nil and hasFaceTexture(part.Material, faceName) then
						part.Faces[faceName] = true
					end
					break
				end
			end
			check(found, ("neighbour %s of removed cell %s has a part"):format(neighbourKey, removedKey))
		end
	end
end

-- Invariants after every removal: exact voxel state (checked against the
-- expected material map), tiling, and registry-aware culling.
function World:verify(context, expectedCells)
	-- 1. voxel state matches the oracle.
	local expectedCount = 0
	for key in expectedCells do
		expectedCount += 1
		check(self.cells[key] ~= nil, ("%s: cell %s missing"):format(context, key))
	end
	local actualCount = 0
	for key, material in self.cells do
		actualCount += 1
		check(expectedCells[key] == material, ("%s: cell %s holds %s"):format(context, key, tostring(material)))
	end
	check(
		actualCount == expectedCount,
		("%s: voxel count %d vs expected %d"):format(context, actualCount, expectedCount)
	)

	-- 2. parts tile the world without overlap.
	local seen = {}
	local partCellCount = 0
	for _, part in self.parts do
		for x = part.Box.minX, part.Box.maxX do
			for y = part.Box.minY, part.Box.maxY do
				for z = part.Box.minZ, part.Box.maxZ do
					local key = cellKey(x, y, z)
					check(seen[key] == nil, ("%s: cell %s is covered by two parts"):format(context, key))
					seen[key] = true
					check(self.cells[key] == part.Material, ("%s: part cell %s material mismatch"):format(context, key))
					partCellCount += 1
				end
			end
		end
	end
	check(
		partCellCount == actualCount,
		("%s: part cell count %d vs voxel count %d"):format(context, partCellCount, actualCount)
	)

	-- 3. culling: textured faces have an exposed across-cell; untextured
	-- faces have no exposed across-cell unless the material lacks the face.
	for _, part in self.parts do
		for _, face in FACE_LAYOUT do
			local textured = part.Faces[face.Name] == true
			local anyAir = self:faceHasAirAdjacent(part, face)
			local materialHas = hasFaceTexture(part.Material, face.Name)
			if textured then
				check(
					anyAir,
					("%s: textured face %s of %s has no exposed across-cell"):format(context, face.Name, part.Material)
				)
			elseif anyAir then
				check(
					not materialHas,
					("%s: exposed face %s of %s lacks its texture"):format(context, face.Name, part.Material)
				)
			end
		end
	end
end

local function snapshotCells(world)
	local snapshot = {}
	for key, material in world.cells do
		snapshot[key] = material
	end
	return snapshot
end

local function buildExpected(initialCells, removedList)
	local expected = {}
	for key, material in initialCells do
		expected[key] = material
	end
	for _, cell in removedList do
		expected[cellKey(cell.X, cell.Y, cell.Z)] = nil
	end
	return expected
end

local function runMines(name, world, mines, initialCells)
	local removedSoFar = {}
	for _, mine in mines do
		table.insert(removedSoFar, mine)
		world:removeBlocks({ mine })
		world:verify(name, buildExpected(initialCells, removedSoFar))
	end
	print(("  scenario %s: %d parts"):format(name, world.nextPartId))
end

print("BlockGeometry unit tests")

-- 1. box-minus-box slab decomposition covers exactly the range minus the
-- inner box and never overlaps.
do
	local range = { minX = 0, maxX = 4, minY = 0, maxY = 4, minZ = 0, maxZ = 4 }
	local innerMin = { X = 2, Y = 1, Z = 1 }
	local innerMax = { X = 3, Y = 3, Z = 3 }
	local covered = {}
	for _, slab in BlockGeometry.decomposeBoxMinusBox(range, innerMin, innerMax) do
		for x = slab.minX, slab.maxX do
			for y = slab.minY, slab.maxY do
				for z = slab.minZ, slab.maxZ do
					local key = cellKey(x, y, z)
					check(covered[key] == nil, ("slab overlap at %s"):format(key))
					covered[key] = true
				end
			end
		end
	end
	for x = range.minX, range.maxX do
		for y = range.minY, range.maxY do
			for z = range.minZ, range.maxZ do
				local inner = x >= innerMin.X
					and x <= innerMax.X
					and y >= innerMin.Y
					and y <= innerMax.Y
					and z >= innerMin.Z
					and z <= innerMax.Z
				check((covered[cellKey(x, y, z)] ~= nil) == not inner, ("cell %d,%d,%d slab coverage"):format(x, y, z))
			end
		end
	end
end

-- 2. single-cell inner box: the classic box-minus-cell decomposition.
do
	local range = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	local slabs = BlockGeometry.decomposeBoxMinusBox(range, { X = 1, Y = 1, Z = 1 }, { X = 1, Y = 1, Z = 1 })
	check(#slabs == 6, "box minus interior cell yields six slabs")
	local cellCount = 0
	for _, slab in slabs do
		for x = slab.minX, slab.maxX do
			for y = slab.minY, slab.maxY do
				for z = slab.minZ, slab.maxZ do
					cellCount += 1
				end
			end
		end
	end
	check(cellCount == 26, "slabs cover exactly 26 cells")
end

print("Mining simulation tests (batched removal)")

-- 3. Interior pickaxe mine of a lone 3x3x3 merged part.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces("Stone", box))
	local initial = snapshotCells(world)
	runMines("interior-mine", world, { { X = 1, Y = 1, Z = 1 } }, initial)
	check(world.nextPartId == 7, "3x3x3 interior mine produces 6 replacement slabs")
end

-- 4. Corner mine of a lone box.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces("Stone", box))
	local initial = snapshotCells(world)
	runMines("corner-mine", world, { { X = 0, Y = 0, Z = 0 } }, initial)
end

-- 5. Sequential mines.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces("Stone", box))
	local initial = snapshotCells(world)
	local mines = {
		{ X = 0, Y = 0, Z = 0 },
		{ X = 1, Y = 0, Z = 0 },
		{ X = 2, Y = 2, Z = 2 },
		{ X = 1, Y = 1, Z = 1 },
	}
	local removedSoFar = {}
	for _, mine in mines do
		table.insert(removedSoFar, mine)
		world:removeBlocks({ mine })
		world:verify("sequential-mines", buildExpected(initial, removedSoFar))
	end
	print(("  scenario sequential-mines: %d parts"):format(world.nextPartId))
end

-- 6. Two merged parts of different materials sharing a face: mining the
-- boundary cell of one re-textures the other part's hidden face.
do
	local world = World.new()
	local partA = { minX = 0, maxX = 1, minY = 0, maxY = 1, minZ = 0, maxZ = 1 }
	local partB = { minX = 2, maxX = 3, minY = 0, maxY = 1, minZ = 0, maxZ = 1 }
	world:addBox("Stone", partA, {})
	world:addBox("Dirt", partB, {})
	world:remeshAllFaces()
	local initial = snapshotCells(world)
	local sharedFaceCulled = true
	for _, part in world.parts do
		if part.Material == "Stone" and part.Faces["Right"] ~= nil then
			sharedFaceCulled = false
		end
		if part.Material == "Dirt" and part.Faces["Left"] ~= nil then
			sharedFaceCulled = false
		end
	end
	check(sharedFaceCulled, "faces between two adjacent merged parts are culled")
	runMines("two-material-boundary", world, { { X = 1, Y = 0, Z = 1 } }, initial)
	local dirtLeftTextured = false
	for _, part in world.parts do
		if part.Material == "Dirt" and part.Faces["Left"] == true then
			dirtLeftTextured = true
		end
	end
	check(dirtLeftTextured, "neighbour part face hidden by the mined cell is re-textured")
end

-- 7. Materials with missing face textures (Grass ships only Top): exposed
-- sides stay plain without failing the culling invariant.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("GrassLike", box, world:meshedFaces("GrassLike", box))
	local initial = snapshotCells(world)
	runMines("grass-mine", world, { { X = 1, Y = 1, Z = 1 } }, initial)
	for _, part in world.parts do
		check(part.Faces["Left"] == nil, "GrassLike sides stay plain")
	end
end

print("Explosion carve tests (batched)")

-- 8. Sphere, not cube: solid 9x9x9 exploded at its center cell with radius
-- 3 blocks.
do
	local world = World.new()
	local box = { minX = -4, maxX = 4, minY = -4, maxY = 4, minZ = -4, maxZ = 4 }
	world:addBox("Stone", box, world:meshedFaces("Stone", box))
	local initial = snapshotCells(world)
	local sphereCells = {}
	local center = { X = 0, Y = 0, Z = 0 }
	local radius = 3
	for x = -4, 4 do
		for y = -4, 4 do
			for z = -4, 4 do
				local dx, dy, dz = x - center.X, y - center.Y, z - center.Z
				if dx * dx + dy * dy + dz * dz <= radius * radius then
					table.insert(sphereCells, { X = x, Y = y, Z = z })
				end
			end
		end
	end
	local destroyed = world:removeBlocks(sphereCells)
	world:verify("explosion-center", buildExpected(initial, sphereCells))
	check(destroyed == 123, ("center explosion destroyed 123 blocks, got %d"):format(destroyed))
	check(world.cells[cellKey(3, 0, 0)] == nil, "sphere reaches the face centers (3,0,0)")
	check(world.cells[cellKey(0, 3, 0)] == nil, "sphere reaches (0,3,0)")
	check(world.cells[cellKey(0, 0, -3)] == nil, "sphere reaches (0,0,-3)")
	check(world.cells[cellKey(3, 3, 3)] ~= nil, "sphere does not reach the corner (3,3,3)")
	check(world.cells[cellKey(4, 0, 0)] ~= nil, "sphere does not reach (4,0,0)")
end

-- 9. Explosion centered on a cell boundary.
do
	local world = World.new()
	local box = { minX = -3, maxX = 4, minY = -3, maxY = 4, minZ = -3, maxZ = 4 }
	world:addBox("Stone", box, world:meshedFaces("Stone", box))
	local initial = snapshotCells(world)
	local boundaryCenter = { X = 1.5, Y = 1.5, Z = 1.5 }
	local sphereCells = {}
	for x = -3, 4 do
		for y = -3, 4 do
			for z = -3, 4 do
				local dx, dy, dz = x - boundaryCenter.X, y - boundaryCenter.Y, z - boundaryCenter.Z
				if dx * dx + dy * dy + dz * dz <= 9 then
					table.insert(sphereCells, { X = x, Y = y, Z = z })
				end
			end
		end
	end
	local destroyed = world:removeBlocks(sphereCells)
	world:verify("explosion-boundary", buildExpected(initial, sphereCells))
	check(destroyed == #sphereCells, "boundary explosion destroys the oracle cell count")
end

-- 10. Explosion across two merged materials.
do
	local world = World.new()
	local partA = { minX = -4, maxX = 1, minY = -4, maxY = 4, minZ = -4, maxZ = 4 }
	local partB = { minX = 2, maxX = 4, minY = -4, maxY = 4, minZ = -4, maxZ = 4 }
	world:addBox("Stone", partA, {})
	world:addBox("Dirt", partB, {})
	world:remeshAllFaces()
	local initial = snapshotCells(world)
	local center = { X = 1.5, Y = 0, Z = 0 }
	local sphereCells = {}
	for x = -4, 4 do
		for y = -4, 4 do
			for z = -4, 4 do
				local dx, dy, dz = x - center.X, y - center.Y, z - center.Z
				if dx * dx + dy * dy + dz * dz <= 9 then
					table.insert(sphereCells, { X = x, Y = y, Z = z })
				end
			end
		end
	end
	local destroyed = world:removeBlocks(sphereCells)
	world:verify("explosion-two-materials", buildExpected(initial, sphereCells))
	check(destroyed > 0, "two-material explosion destroys blocks")
	check(world.cells[cellKey(1, 0, 0)] == nil, "Stone side of the boundary is carved")
	check(world.cells[cellKey(2, 0, 0)] == nil, "Dirt side of the boundary is carved")
	check(world.cells[cellKey(-4, 0, 0)] ~= nil, "far Stone corner survives")
	check(world.cells[cellKey(4, 3, 0)] ~= nil, "far Dirt corner survives")
end

-- 11. Randomized mining property tests.
do
	local seed = 12345
	local function random(min, max)
		seed = (seed * 1103515245 + 12345) % 2147483648
		return min + seed % (max - min + 1)
	end
	for iteration = 1, 40 do
		local world = World.new()
		local sx, sy, sz = random(1, 4), random(1, 4), random(1, 4)
		local box = { minX = 0, maxX = sx - 1, minY = 0, maxY = sy - 1, minZ = 0, maxZ = sz - 1 }
		world:addBox("Stone", box, world:meshedFaces("Stone", box))
		local initial = snapshotCells(world)
		local mines = {}
		local minedKeys = {}
		local targetMines = math.min(3, sx * sy * sz)
		while #mines < targetMines do
			local cell = { X = random(0, sx - 1), Y = random(0, sy - 1), Z = random(0, sz - 1) }
			local key = cellKey(cell.X, cell.Y, cell.Z)
			if minedKeys[key] == nil then
				minedKeys[key] = true
				table.insert(mines, cell)
			end
		end
		local removedSoFar = {}
		for _, mine in mines do
			table.insert(removedSoFar, mine)
			world:removeBlocks({ mine })
			world:verify(("random-%d"):format(iteration), buildExpected(initial, removedSoFar))
		end
	end
end

-- 12. Randomized explosion property tests.
do
	local seed = 987654321
	local function random(min, max)
		seed = (seed * 1103515245 + 12345) % 2147483648
		return min + seed % (max - min + 1)
	end
	for iteration = 1, 25 do
		local world = World.new()
		local sx, sy, sz = random(2, 6), random(2, 6), random(2, 6)
		local box = { minX = 0, maxX = sx - 1, minY = 0, maxY = sy - 1, minZ = 0, maxZ = sz - 1 }
		world:addBox("Stone", box, world:meshedFaces("Stone", box))
		local initial = snapshotCells(world)
		local center = {
			X = random(0, (sx - 1) * 2) / 2,
			Y = random(0, (sy - 1) * 2) / 2,
			Z = random(0, (sz - 1) * 2) / 2,
		}
		local radiusBlocks = random(1, 3)
		local sphereCells = {}
		for x = 0, sx - 1 do
			for y = 0, sy - 1 do
				for z = 0, sz - 1 do
					local dx, dy, dz = x - center.X, y - center.Y, z - center.Z
					if dx * dx + dy * dy + dz * dz <= radiusBlocks * radiusBlocks then
						table.insert(sphereCells, { X = x, Y = y, Z = z })
					end
				end
			end
		end
		local destroyed = world:removeBlocks(sphereCells)
		check(destroyed == #sphereCells, ("random explosion %d destroys the oracle cell count"):format(iteration))
		world:verify(("explosion-random-%d"):format(iteration), buildExpected(initial, sphereCells))
	end
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
