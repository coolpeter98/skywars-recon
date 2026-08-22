--!strict
-- BlockGeometry — pure voxel math for mining/exploding greedy-meshed block
-- geometry. No Roblox dependencies, so the whole module can be unit-tested
-- under Lune.
--
-- The recovered maps store runs of same-material block cells as one
-- axis-aligned Part (greedy meshing); only the exposed faces carry textures
-- (face culling), and faces whose material lacks a texture for that
-- orientation stay plain (measured: the original Airport map has 723
-- partially-covered textured faces — full-face overdraw is the map's own
-- visual style).
--
-- Cell coordinates are plain tables { X: number, Y: number, Z: number }
-- (Roblox Vector3 values satisfy the same shape, so callers may pass either).

export type Cell = { X: number, Y: number, Z: number }

export type BoxRange = {
	minX: number,
	maxX: number,
	minY: number,
	maxY: number,
	minZ: number,
	maxZ: number,
}

export type BlockGeometry = {
	decomposeBoxMinusBox: (range: BoxRange, innerMin: Cell, innerMax: Cell) -> { BoxRange },
	boxCenter: (box: BoxRange) -> Cell,
	boxExtents: (box: BoxRange) -> Cell,
	cellInBox: (cell: Cell, box: BoxRange) -> boolean,
}

local BlockGeometry: BlockGeometry = {}

-- Decomposes `range` minus the inner box [innerMin..innerMax] into up to six
-- axis-aligned boxes (the standard box-minus-box slab decomposition). The
-- inner box must lie within the range; a single-cell inner box gives the
-- classic box-minus-cell decomposition.
function BlockGeometry.decomposeBoxMinusBox(range: BoxRange, innerMin: Cell, innerMax: Cell): { BoxRange }
	local boxes: { BoxRange } = {}
	if innerMin.X - 1 >= range.minX then
		table.insert(boxes, {
			minX = range.minX,
			maxX = innerMin.X - 1,
			minY = range.minY,
			maxY = range.maxY,
			minZ = range.minZ,
			maxZ = range.maxZ,
		})
	end
	if innerMax.X + 1 <= range.maxX then
		table.insert(boxes, {
			minX = innerMax.X + 1,
			maxX = range.maxX,
			minY = range.minY,
			maxY = range.maxY,
			minZ = range.minZ,
			maxZ = range.maxZ,
		})
	end
	if innerMin.Y - 1 >= range.minY then
		table.insert(boxes, {
			minX = innerMin.X,
			maxX = innerMax.X,
			minY = range.minY,
			maxY = innerMin.Y - 1,
			minZ = range.minZ,
			maxZ = range.maxZ,
		})
	end
	if innerMax.Y + 1 <= range.maxY then
		table.insert(boxes, {
			minX = innerMin.X,
			maxX = innerMax.X,
			minY = innerMax.Y + 1,
			maxY = range.maxY,
			minZ = range.minZ,
			maxZ = range.maxZ,
		})
	end
	if innerMin.Z - 1 >= range.minZ then
		table.insert(boxes, {
			minX = innerMin.X,
			maxX = innerMax.X,
			minY = innerMin.Y,
			maxY = innerMax.Y,
			minZ = range.minZ,
			maxZ = innerMin.Z - 1,
		})
	end
	if innerMax.Z + 1 <= range.maxZ then
		table.insert(boxes, {
			minX = innerMin.X,
			maxX = innerMax.X,
			minY = innerMin.Y,
			maxY = innerMax.Y,
			minZ = innerMax.Z + 1,
			maxZ = range.maxZ,
		})
	end
	return boxes
end

function BlockGeometry.boxCenter(box: BoxRange): Cell
	return {
		X = (box.minX + box.maxX) / 2,
		Y = (box.minY + box.maxY) / 2,
		Z = (box.minZ + box.maxZ) / 2,
	}
end

function BlockGeometry.boxExtents(box: BoxRange): Cell
	return {
		X = box.maxX - box.minX + 1,
		Y = box.maxY - box.minY + 1,
		Z = box.maxZ - box.minZ + 1,
	}
end

function BlockGeometry.cellInBox(cell: Cell, box: BoxRange): boolean
	return cell.X >= box.minX
		and cell.X <= box.maxX
		and cell.Y >= box.minY
		and cell.Y <= box.maxY
		and cell.Z >= box.minZ
		and cell.Z <= box.maxZ
end

return BlockGeometry
