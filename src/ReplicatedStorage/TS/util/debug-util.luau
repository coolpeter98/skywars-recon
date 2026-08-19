-- DebugUtil

local Workspace: Workspace = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
return {
	["DebugUtil"] = {
		["createDebugPart"] = function(cframe: CFrame, color: Color3): Part
			local part: Part = Instance.new("Part")
			part.Name = "DebugPart"
			part.CFrame = cframe
			part.Size = Vector3.new(1, 1, 1)
			part.Color = color
			part.Anchored = true
			part.CanCollide = false
			part.Parent = Workspace
			return part
		end
	}
}
