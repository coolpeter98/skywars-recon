-- ProjectileUtil

local Services =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"services"
	)
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
return {
	["drawProjectileTrajectory"] = function(
		startPosition: Vector3,
		endPosition: Vector3,
		midPosition: Vector3
	): { Instance }
		local visuals: { Instance } = {}
		if RunService:IsStudio() then
			local endMarkerPart: Part = Instance.new("Part")
			endMarkerPart.Size = Vector3.new(1, 1, 1)
			endMarkerPart.Position = endPosition
			endMarkerPart.Anchored = true
			endMarkerPart.Color = Color3.new(1, 0, 0)
			endMarkerPart.Parent = Workspace
			local midMarkerPart: Part = Instance.new("Part")
			midMarkerPart.Size = Vector3.new(1, 1, 1)
			midMarkerPart.Position = midPosition
			midMarkerPart.Anchored = true
			midMarkerPart.CanCollide = false
			midMarkerPart.Color = Color3.new(0, 0, 1)
			midMarkerPart.Parent = Workspace
			table.insert(visuals, endMarkerPart)
			table.insert(visuals, midMarkerPart)
		end
		local beamRotation: CFrame = CFrame.Angles(0, 1.5707963267948966, 0)
		local doubleMidPosition: Vector3 = midPosition * 2
		local halfStartPosition: Vector3 = startPosition / 2
		local halfEndPosition: Vector3 = endPosition / 2
		local controlPoint: Vector3 = doubleMidPosition - halfStartPosition - halfEndPosition
		local startAttachment: Attachment = Instance.new("Attachment")
		startAttachment.CFrame = CFrame.new(startPosition, controlPoint) * beamRotation
		startAttachment.Parent = game.Workspace.Terrain
		local endAttachment: Attachment = Instance.new("Attachment")
		endAttachment.CFrame = CFrame.new(endPosition) * beamRotation
		endAttachment.Parent = game.Workspace.Terrain
		local beam: Beam = Instance.new("Beam")
		beam.FaceCamera = false
		beam.Segments = 200
		beam.Width0 = 0.5
		beam.Attachment0 = startAttachment
		beam.Attachment1 = endAttachment
		beam.CurveSize0 = (controlPoint - startPosition).Magnitude * 1.13
		beam.CurveSize1 = 0
		beam.Parent = game.Workspace.Terrain
		table.insert(visuals, startAttachment)
		table.insert(visuals, endAttachment)
		table.insert(visuals, beam)
		return visuals
	end,
}
