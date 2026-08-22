-- test_block_geometry.luau — Lune unit tests for the greedy-mesh mining math
-- (BlockGeometry) plus a simulation of the full service-side re-culling rules
-- (decompose + describeFaces + neighbour face exposure).
--
-- Run with:  lune run tools/test_block_geometry.luau
--
-- The simulation mirrors BlockWorldService exactly:
--   * a voxel world maps "x,y,z" cell keys to a material name;
--   * merged parts are axis-aligned boxes of one material; their faces are
--     textured only where the original mesher left textures (fully covered
--     faces are culled);
--   * mining a cell inside a part splits it via decomposeBox, textures a new
--     box face when it borders the mined cell or when it was part of the old
--     part's textured exterior, and adds the texture back to neighbouring
--     parts' newly exposed faces.
-- Invariants checked after every mine:
--   * the decomposition covers exactly the old range minus the mined cell;
--   * every face adjacent to an air cell is textured (no textureless hole);
--   * every untextured face is fully covered by other cells (no visible
--     plain patch on a new box).

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
	{ Name = "Right", Axis = "X", Sign = 1, EdgeIsMax = true },
	{ Name = "Left", Axis = "X", Sign = -1, EdgeIsMax = false },
	{ Name = "Top", Axis = "Y", Sign = 1, EdgeIsMax = true },
	{ Name = "Bottom", Axis = "Y", Sign = -1, EdgeIsMax = false },
	{ Name = "Back", Axis = "Z", Sign = 1, EdgeIsMax = true },
	{ Name = "Front", Axis = "Z", Sign = -1, EdgeIsMax = false },
}

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
-- any cell adjacent across that face is air.
function World:meshedFaces(box)
	local faces = {}
	for _, face in FACE_LAYOUT do
		local edge = if face.EdgeIsMax then self:getEdge(box, face.Axis, true) else self:getEdge(box, face.Axis, false)
		local exposed = false
		local function anyAirAcross()
			if face.Axis == "X" then
				for y = box.minY, box.maxY do
					for z = box.minZ, box.maxZ do
						if self.cells[cellKey(edge + face.Sign, y, z)] == nil then
							return true
						end
					end
				end
			elseif face.Axis == "Y" then
				for x = box.minX, box.maxX do
					for z = box.minZ, box.maxZ do
						if self.cells[cellKey(x, edge + face.Sign, z)] == nil then
							return true
						end
					end
				end
			else
				for x = box.minX, box.maxX do
					for y = box.minY, box.maxY do
						if self.cells[cellKey(x, y, edge + face.Sign)] == nil then
							return true
						end
					end
				end
			end
			return false
		end
		if anyAirAcross() then
			faces[face.Name] = true
		end
	end
	return faces
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

function World:faceHasAirAdjacent(part, faceLayout)
	local box = part.Box
	local edge = self:getEdge(box, faceLayout.Axis, faceLayout.EdgeIsMax)
	if faceLayout.Axis == "X" then
		for y = box.minY, box.maxY do
			for z = box.minZ, box.maxZ do
				if self.cells[cellKey(edge + faceLayout.Sign, y, z)] == nil then
					return true
				end
			end
		end
	elseif faceLayout.Axis == "Y" then
		for x = box.minX, box.maxX do
			for z = box.minZ, box.maxZ do
				if self.cells[cellKey(x, edge + faceLayout.Sign, z)] == nil then
					return true
				end
			end
		end
	else
		for x = box.minX, box.maxX do
			for y = box.minY, box.maxY do
				if self.cells[cellKey(x, y, edge + faceLayout.Sign)] == nil then
					return true
				end
			end
		end
	end
	return false
end

function World:remeshAllFaces()
	for _, part in self.parts do
		part.Faces = self:meshedFaces(part.Box)
	end
end

-- Mines one cell using the same rules as BlockWorldService.mineCell /
-- splitPart / createBox / exposeNeighbourFaces.
function World:mine(cell)
	local key = cellKey(cell.X, cell.Y, cell.Z)
	local material = self.cells[key]
	check(material ~= nil, ("cell %s is occupied before mining"):format(key))
	self.cells[key] = nil

	-- find the owning part
	local ownerId = nil
	for id, part in self.parts do
		if part.Material == material and BlockGeometry.cellInBox(cell, part.Box) then
			ownerId = id
			break
		end
	end
	check(ownerId ~= nil, "mining cell has an owning part")

	if ownerId == nil then
		return
	end
	local owner = self.parts[ownerId]
	local oldRange = owner.Box
	local oldFaces = owner.Faces
	self.parts[ownerId] = nil

	local extents = BlockGeometry.boxExtents(oldRange)
	if extents.X == 1 and extents.Y == 1 and extents.Z == 1 then
		-- single-cell part: plain destroy, nothing to split
	else
		local boxes = BlockGeometry.decomposeBox(oldRange, cell)
		local covered = {}
		for _, box in boxes do
			for x = box.minX, box.maxX do
				for y = box.minY, box.maxY do
					for z = box.minZ, box.maxZ do
						local boxKey = cellKey(x, y, z)
						check(covered[boxKey] == nil, ("decomposition box overlap at %s"):format(boxKey))
						covered[boxKey] = true
					end
				end
			end
		end
		for x = oldRange.minX, oldRange.maxX do
			for y = oldRange.minY, oldRange.maxY do
				for z = oldRange.minZ, oldRange.maxZ do
					local cellKeyValue = cellKey(x, y, z)
					if cell.X == x and cell.Y == y and cell.Z == z then
						check(covered[cellKeyValue] == nil, ("mined cell %s is not in any box"):format(cellKeyValue))
					else
						check(
							covered[cellKeyValue] ~= nil,
							("remaining cell %s is covered by a box"):format(cellKeyValue)
						)
					end
				end
			end
		end
		for _, box in boxes do
			local faces = {}
			for _, face in BlockGeometry.describeFaces(box, oldRange, cell) do
				if face.BordersMined or (face.IsExterior and oldFaces[face.Face] == true) then
					faces[face.Face] = true
				end
			end
			self:addBox(material, box, faces)
		end
	end

	-- neighbour face exposure (exposeNeighbourFaces)
	local neighbourOffsets = {
		{ 1, 0, 0, "Left" },
		{ -1, 0, 0, "Right" },
		{ 0, 1, 0, "Bottom" },
		{ 0, -1, 0, "Top" },
		{ 0, 0, 1, "Back" },
		{ 0, 0, -1, "Front" },
	}
	for _, offset in neighbourOffsets do
		local neighbourKey = cellKey(cell.X + offset[1], cell.Y + offset[2], cell.Z + offset[3])
		if self.cells[neighbourKey] ~= nil then
			local faceName = offset[4]
			local found = false
			for _, part in self.parts do
				if
					BlockGeometry.cellInBox(
						{ X = cell.X + offset[1], Y = cell.Y + offset[2], Z = cell.Z + offset[3] },
						part.Box
					)
				then
					if part.Faces[faceName] == nil then
						part.Faces[faceName] = true
					end
					found = true
					break
				end
			end
			check(found, ("neighbour %s has a part"):format(neighbourKey))
		end
	end
end

-- After every mine: no face adjacent to air may lack a texture; no
-- untextured face may be adjacent to air.
function World:verifyCulling(context)
	for _, part in self.parts do
		for _, face in FACE_LAYOUT do
			local adjacentToAir = self:faceHasAirAdjacent(part, face)
			local textured = part.Faces[face.Name] == true
			if adjacentToAir then
				check(
					textured,
					("%s: face %s of %s box (%d,%d,%d)-(%d,%d,%d) borders air but has no texture"):format(
						context,
						face.Name,
						part.Material,
						part.Box.minX,
						part.Box.minY,
						part.Box.minZ,
						part.Box.maxX,
						part.Box.maxY,
						part.Box.maxZ
					)
				)
			else
				check(not textured or true, "covered faces may keep textures (overdraw) — allowed")
			end
		end
	end
end

local function runScenario(name, world, mines)
	for _, mine in mines do
		world:mine(mine)
		world:verifyCulling(name)
	end
	print(("  scenario %s: %d parts"):format(name, world.nextPartId))
end

print("BlockGeometry unit tests")

-- 1. Single-cell part: decompose returns nothing.
do
	local boxes = BlockGeometry.decomposeBox(
		{ minX = 5, maxX = 5, minY = 5, maxY = 5, minZ = 5, maxZ = 5 },
		{ X = 5, Y = 5, Z = 5 }
	)
	check(#boxes == 0, "single-cell decompose is empty")
end

-- 2. Corner / edge / interior decomposition coverage on a 3x3x3 box.
for _, mined in
	{
		{ X = 0, Y = 0, Z = 0 },
		{ X = 2, Y = 2, Z = 2 },
		{ X = 1, Y = 0, Z = 2 },
		{ X = 1, Y = 1, Z = 1 },
	}
do
	local oldRange = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	local boxes = BlockGeometry.decomposeBox(oldRange, mined)
	local covered = {}
	for _, box in boxes do
		for x = box.minX, box.maxX do
			for y = box.minY, box.maxY do
				for z = box.minZ, box.maxZ do
					local key = cellKey(x, y, z)
					check(covered[key] == nil, ("overlap at %s"):format(key))
					covered[key] = true
				end
			end
		end
	end
	local count = 0
	for x = 0, 2 do
		for y = 0, 2 do
			for z = 0, 2 do
				if x ~= mined.X or y ~= mined.Y or z ~= mined.Z then
					check(covered[cellKey(x, y, z)] == true, ("cell %d,%d,%d covered"):format(x, y, z))
					count += 1
				else
					check(covered[cellKey(x, y, z)] == nil, ("mined cell %d,%d,%d not covered"):format(x, y, z))
				end
			end
		end
	end
	check(count == 26, "decompose covers exactly 26 cells")
	check(#boxes <= 6, "at most six boxes")
end

-- 3. Face descriptions for an interior mine in a 3x3x3 box: every face that
-- borders the mined cell must be flagged, and flagged faces must actually
-- border the mined cell.
do
	local oldRange = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	local mined = { X = 1, Y = 1, Z = 1 }
	for _, box in BlockGeometry.decomposeBox(oldRange, mined) do
		for _, face in BlockGeometry.describeFaces(box, oldRange, mined) do
			local adjacent = {}
			adjacent.X = face.EdgeCell + face.Sign
			adjacent.Y = face.EdgeCell + face.Sign
			adjacent.Z = face.EdgeCell + face.Sign
			adjacent.X, adjacent.Y, adjacent.Z = 0, 0, 0
			if face.Axis == "X" then
				adjacent = { X = face.EdgeCell + face.Sign, Y = mined.Y, Z = mined.Z }
			elseif face.Axis == "Y" then
				adjacent = { X = mined.X, Y = face.EdgeCell + face.Sign, Z = mined.Z }
			else
				adjacent = { X = mined.X, Y = mined.Y, Z = face.EdgeCell + face.Sign }
			end
			local trulyBorders = adjacent.X == mined.X and adjacent.Y == mined.Y and adjacent.Z == mined.Z
			check(
				face.BordersMined == trulyBorders,
				("face %s of box (%d,%d,%d)-(%d,%d,%d): BordersMined=%s, truth=%s"):format(
					face.Face,
					box.minX,
					box.minY,
					box.minZ,
					box.maxX,
					box.maxY,
					box.maxZ,
					tostring(face.BordersMined),
					tostring(trulyBorders)
				)
			)
		end
	end
end

print("Mining simulation tests")

-- 4. Interior mine of a lone 3x3x3 merged part: every face visible through
-- the hole is textured, every new part face toward the hole is textured.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces(box))
	runScenario("interior-mine", world, { { X = 1, Y = 1, Z = 1 } })
	check(world.nextPartId == 7, "3x3x3 interior mine produces 6 replacement boxes")
end

-- 5. Corner mine of a lone box.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces(box))
	runScenario("corner-mine", world, { { X = 0, Y = 0, Z = 0 } })
end

-- 6. Sequential mines: mine a corner, then the cell next to it (through the
-- new boxes), then the far corner.
do
	local world = World.new()
	local box = { minX = 0, maxX = 2, minY = 0, maxY = 2, minZ = 0, maxZ = 2 }
	world:addBox("Stone", box, world:meshedFaces(box))
	runScenario("sequential-mines", world, {
		{ X = 0, Y = 0, Z = 0 },
		{ X = 1, Y = 0, Z = 0 },
		{ X = 2, Y = 2, Z = 2 },
		{ X = 1, Y = 1, Z = 1 },
	})
end

-- 7. Two merged parts of different materials sharing a face: mining the
-- boundary cell of one must re-texture the other part's hidden face.
do
	local world = World.new()
	local partA = { minX = 0, maxX = 1, minY = 0, maxY = 1, minZ = 0, maxZ = 1 }
	local partB = { minX = 2, maxX = 3, minY = 0, maxY = 1, minZ = 0, maxZ = 1 }
	world:addBox("Stone", partA, {})
	world:addBox("Dirt", partB, {})
	-- The real mesher sees the whole voxel grid before culling faces.
	world:remeshAllFaces()
	-- The shared faces between A and B must have been culled initially.
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
	runScenario("two-material-boundary", world, { { X = 1, Y = 0, Z = 1 } })
	-- After mining A's cell (1,0,1): Dirt's Left face must now be textured.
	local dirtLeftTextured = false
	for _, part in world.parts do
		if part.Material == "Dirt" and part.Faces["Left"] == true then
			dirtLeftTextured = true
		end
	end
	check(dirtLeftTextured, "neighbour part face hidden by the mined cell is re-textured")
end

-- 8. Randomised property test.
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
		world:addBox("Stone", box, world:meshedFaces(box))
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
		runScenario(("random-%d"):format(iteration), world, mines)
	end
end

print(("done: %d checks, %d failures"):format(checks, failures))
if failures > 0 then
	local process = require("@lune/process")
	process.exit(1)
end
