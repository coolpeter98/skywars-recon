-- VectorUtil

return {
	["VectorDiff"] = function(first: BasePart?, second: BasePart?): Vector3?
		if first and second then
			return second.Position - first.Position
		else
			return nil
		end
	end,
	["Distance"] = function(player: Player, target: Model | BasePart): number?
		local characterPart = player.Character
		if characterPart ~= nil then
			characterPart = characterPart.PrimaryPart
		end
		if target:IsA("Model") then
			target = target.PrimaryPart
		end
		local diff
		if characterPart and target then
			diff = target.Position - characterPart.Position
		else
			diff = nil
		end
		if diff ~= nil then
			diff = diff.Magnitude
		end
		return diff
	end,
	["VectorUtil"] = {
		["NORTH"] = Vector3.new(0, 0, -1),
		["EAST"] = Vector3.new(1, 0, 0),
		["SOUTH"] = Vector3.new(0, 0, 1),
		["WEST"] = Vector3.new(-1, 0, 0),
		["UP"] = Vector3.new(0, 1, 0),
		["DOWN"] = Vector3.new(0, -1, 0),
		["SINGLE_NORMALS"] = { Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1) },
		["NORMALS"] = {
			Vector3.new(0, 0, -1),
			Vector3.new(1, 0, 0),
			Vector3.new(0, 0, 1),
			Vector3.new(-1, 0, 0),
			Vector3.new(0, 1, 0),
			Vector3.new(0, -1, 0),
		},
		["modVector"] = function(vector: Vector3, modulus: number): Vector3
			local x = vector.X % modulus
			local y = vector.Y % modulus
			local z = vector.Z % modulus
			return Vector3.new(x, y, z)
		end,
		["roundVector"] = function(vector: Vector3): Vector3
			local x = vector.X
			local roundedX = math.round(x)
			local y = vector.Y
			local roundedY = math.round(y)
			local z = vector.Z
			local roundedZ = math.round(z)
			return Vector3.new(roundedX, roundedY, roundedZ)
		end,
		["floorVector"] = function(vector: Vector3): Vector3
			local x = vector.X
			local flooredX = math.floor(x)
			local y = vector.Y
			local flooredY = math.floor(y)
			local z = vector.Z
			local flooredZ = math.floor(z)
			return Vector3.new(flooredX, flooredY, flooredZ)
		end,
		["ceilVector"] = function(vector: Vector3): Vector3
			local x = vector.X
			local ceiledX = math.ceil(x)
			local y = vector.Y
			local ceiledY = math.ceil(y)
			local z = vector.Z
			local ceiledZ = math.ceil(z)
			return Vector3.new(ceiledX, ceiledY, ceiledZ)
		end,
		["absVector"] = function(vector: Vector3): Vector3
			local x = vector.X
			local absX = math.abs(x)
			local y = vector.Y
			local absY = math.abs(y)
			local z = vector.Z
			local absZ = math.abs(z)
			return Vector3.new(absX, absY, absZ)
		end,
		["sum"] = function(vector: Vector3): number
			return vector.X + vector.Y + vector.Z
		end,
		["min"] = function(first: Vector3, second: Vector3): Vector3
			local firstX = first.X
			local secondX = second.X
			local minX = math.min(firstX, secondX)
			local firstY = first.Y
			local secondY = second.Y
			local minY = math.min(firstY, secondY)
			local firstZ = first.Z
			local secondZ = second.Z
			local minZ = math.min(firstZ, secondZ)
			return Vector3.new(minX, minY, minZ)
		end,
		["max"] = function(first: Vector3, second: Vector3): Vector3
			local firstX = first.X
			local secondX = second.X
			local maxX = math.max(firstX, secondX)
			local firstY = first.Y
			local secondY = second.Y
			local maxY = math.max(firstY, secondY)
			local firstZ = first.Z
			local secondZ = second.Z
			local maxZ = math.max(firstZ, secondZ)
			return Vector3.new(maxX, maxY, maxZ)
		end,
		["isInAABB"] = function(point: Vector3, aabbMin: Vector3, aabbMax: Vector3): boolean
			local result
			if
				point.X >= aabbMin.X
				and (
					point.X <= aabbMax.X and (point.Y >= aabbMin.Y and (point.Y <= aabbMax.Y and point.Z >= aabbMin.Z))
				)
			then
				result = point.Z <= aabbMax.Z
			else
				result = false
			end
			return result
		end,
		["isInAABB2"] = function(point: Vector3, aabbMin: Vector3, aabbMax: Vector3): boolean
			local result
			if point.X >= aabbMin.X and (point.X <= aabbMax.X and point.Y >= aabbMin.Y) then
				result = point.Y <= aabbMax.Y
			else
				result = false
			end
			return result
		end,
		["distance"] = function(first: Vector3, second: Vector3): number
			return (second - first).Magnitude
		end,
	},
}
