--!strict
-- BlockGeometry — pure voxel math for mining into greedy-meshed block
-- geometry. No Roblox dependencies, so the whole module can be unit-tested
-- under Lune.
--
-- The recovered maps store runs of same-material block cells as one
-- axis-aligned Part (greedy meshing); only the exposed faces carry textures
-- (face culling). Mining one cell therefore means carving the cell out of
-- the merged box and re-deciding which of the remaining faces are visible.
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

export type FaceDescription = {
	Face: string, -- NormalId name ("Right", "Top", ...)
	Axis: "X" | "Y" | "Z",
	EdgeCell: number, -- cell index of the box edge the face sits on
	Sign: number, -- +1: faces the positive axis, -1: faces the negative axis
	IsExterior: boolean, -- the face lies on the old part's outer boundary
	BordersMined: boolean, -- the face is directly adjacent to the mined cell
}

export type BlockGeometry = {
	decomposeBox: (oldRange: BoxRange, mined: Cell) -> { BoxRange },
	boxCenter: (box: BoxRange) -> Cell,
	boxExtents: (box: BoxRange) -> Cell,
	cellInBox: (cell: Cell, box: BoxRange) -> boolean,
	describeFaces: (box: BoxRange, oldRange: BoxRange, mined: Cell) -> { FaceDescription },
}

local BlockGeometry: BlockGeometry = {}

-- The standard box-minus-one-cell decomposition: up to six axis-aligned
-- boxes that together cover exactly `oldRange` minus the mined cell.
function BlockGeometry.decomposeBox(oldRange: BoxRange, mined: Cell): { BoxRange }
	local boxes: { BoxRange } = {}
	local cx, cy, cz = mined.X, mined.Y, mined.Z
	if cx - 1 >= oldRange.minX then
		table.insert(boxes, {
			minX = oldRange.minX,
			maxX = cx - 1,
			minY = oldRange.minY,
			maxY = oldRange.maxY,
			minZ = oldRange.minZ,
			maxZ = oldRange.maxZ,
		})
	end
	if cx + 1 <= oldRange.maxX then
		table.insert(boxes, {
			minX = cx + 1,
			maxX = oldRange.maxX,
			minY = oldRange.minY,
			maxY = oldRange.maxY,
			minZ = oldRange.minZ,
			maxZ = oldRange.maxZ,
		})
	end
	if cy - 1 >= oldRange.minY then
		table.insert(boxes, {
			minX = cx,
			maxX = cx,
			minY = oldRange.minY,
			maxY = cy - 1,
			minZ = oldRange.minZ,
			maxZ = oldRange.maxZ,
		})
	end
	if cy + 1 <= oldRange.maxY then
		table.insert(boxes, {
			minX = cx,
			maxX = cx,
			minY = cy + 1,
			maxY = oldRange.maxY,
			minZ = oldRange.minZ,
			maxZ = oldRange.maxZ,
		})
	end
	if cz - 1 >= oldRange.minZ then
		table.insert(boxes, {
			minX = cx,
			maxX = cx,
			minY = cy,
			maxY = cy,
			minZ = oldRange.minZ,
			maxZ = cz - 1,
		})
	end
	if cz + 1 <= oldRange.maxZ then
		table.insert(boxes, {
			minX = cx,
			maxX = cx,
			minY = cy,
			maxY = cy,
			minZ = cz + 1,
			maxZ = oldRange.maxZ,
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

local FACE_LAYOUT: { { Face: string, Axis: "X" | "Y" | "Z", Sign: number, EdgeIsMax: boolean } } = {
	{ Face = "Right", Axis = "X", Sign = 1, EdgeIsMax = true },
	{ Face = "Left", Axis = "X", Sign = -1, EdgeIsMax = false },
	{ Face = "Top", Axis = "Y", Sign = 1, EdgeIsMax = true },
	{ Face = "Bottom", Axis = "Y", Sign = -1, EdgeIsMax = false },
	{ Face = "Back", Axis = "Z", Sign = 1, EdgeIsMax = true },
	{ Face = "Front", Axis = "Z", Sign = -1, EdgeIsMax = false },
}

local function getRangeEdge(range: BoxRange, axis: "X" | "Y" | "Z", isMax: boolean): number
	if axis == "X" then
		return if isMax then range.maxX else range.minX
	elseif axis == "Y" then
		return if isMax then range.maxY else range.minY
	else
		return if isMax then range.maxZ else range.minZ
	end
end

-- Describes the six faces of a replacement box for re-culling. The caller
-- textures a face when `BordersMined` is set (the face forms part of the new
-- hole) or when `IsExterior` is set and the old part had that face textured.
-- Fresh interior cuts — the planes where the old part was carved apart —
-- stay untextured, matching the map's original culling.
function BlockGeometry.describeFaces(box: BoxRange, oldRange: BoxRange, mined: Cell): { FaceDescription }
	local faces: { FaceDescription } = {}
	for _, layout in FACE_LAYOUT do
		local edgeCell = getRangeEdge(box, layout.Axis, layout.EdgeIsMax)
		local adjacentCell = edgeCell + layout.Sign
		local axisMatches = (layout.Axis == "X" and adjacentCell == mined.X)
			or (layout.Axis == "Y" and adjacentCell == mined.Y)
			or (layout.Axis == "Z" and adjacentCell == mined.Z)
		local tangentSpanContains = (
			layout.Axis == "X"
			and mined.Y >= box.minY
			and mined.Y <= box.maxY
			and mined.Z >= box.minZ
			and mined.Z <= box.maxZ
		)
			or (layout.Axis == "Y" and mined.X >= box.minX and mined.X <= box.maxX and mined.Z >= box.minZ and mined.Z <= box.maxZ)
			or (
				layout.Axis == "Z"
				and mined.X >= box.minX
				and mined.X <= box.maxX
				and mined.Y >= box.minY
				and mined.Y <= box.maxY
			)
		table.insert(faces, {
			Face = layout.Face,
			Axis = layout.Axis,
			EdgeCell = edgeCell,
			Sign = layout.Sign,
			IsExterior = getRangeEdge(oldRange, layout.Axis, layout.EdgeIsMax) == edgeCell,
			BordersMined = axisMatches and tangentSpanContains,
		})
	end
	return faces
end

return BlockGeometry
