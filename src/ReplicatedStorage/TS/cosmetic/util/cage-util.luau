-- CageUtil

local ReplicatedStorage: ReplicatedStorage = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage

return {
	["CageUtil"] = {
		["createCage"] = function(cageName: string, cageCframe: CFrame): Model
			local cage: Model = ReplicatedStorage.Cosmetic.Cage:FindFirstChild(cageName):Clone()
			for _, descendant: Instance in cage:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = true
				end
			end
			cage.PrimaryPart = cage:FindFirstChild("SpawnArea")
			cage:SetPrimaryPartCFrame(cageCframe * CFrame.Angles(0, 3.141592653589793, 0))
			return cage
		end
	}
}
