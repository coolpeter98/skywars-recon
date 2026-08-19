-- BuildConstraint

local VectorUtil: {
	isInAABB: (position: Vector3, minimum: Vector3, maximum: Vector3) -> boolean,
} = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil

type BuildConstraintType = "BoundingBox" | "Radius" | "World"

local BuildConstraintType = {
	BoundingBox = "BoundingBox",
	Radius = "Radius",
	World = "World",
}

type BuildConstraint = {
	Type: BuildConstraintType,
	Origin: Vector3?,
	Minimum: Vector3?,
	Maximum: Vector3?,
	Distance: number?,
}

return {
	["BuildConstraintType"] = BuildConstraintType,
	["BuildConstraint"] = {
		["isInBuildConstraint"] = function(position: Vector3, constraint: BuildConstraint): boolean
			if constraint.Type == BuildConstraintType.BoundingBox then
				return VectorUtil.isInAABB(position, constraint.Minimum, constraint.Maximum)
			elseif constraint.Type == BuildConstraintType.Radius then
				return (constraint.Origin - position).Magnitude < constraint.Distance
			else
				return false
			end
		end,
	},
}
