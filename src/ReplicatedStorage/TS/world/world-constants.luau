-- WorldConstants

local WorldConstants: { WORLD_ACCELERATION: Vector3 } = {}
local GRAVITY_ACCELERATION: number = -require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace.Gravity * 0.4
WorldConstants.WORLD_ACCELERATION = Vector3.new(0, GRAVITY_ACCELERATION, 0)
return {
	["WorldConstants"] = WorldConstants
}
