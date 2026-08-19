-- ItemUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PowerUps = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "power-up", "power-ups").PowerUps
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage

return {
	["ItemUtil"] = {
		["createToolFromPowerUp"] = function(powerUpId: string)
			local tool = ReplicatedStorage.Items:FindFirstChild("PowerUp"):Clone()
			tool:FindFirstChild("Handle").Color = PowerUps[powerUpId].Color
			return tool
		end,
		["createToolFromBasePart"] = function(basePart: BasePart)
			local tool: Tool = Instance.new("Tool")
			local toolName: string = basePart.Name
			basePart.Name = "Handle"
			basePart.Anchored = false
			basePart.CanCollide = false
			basePart.Size = Vector3.new(1, 1, 1)
			for _, child in basePart:GetChildren() do
				if child:IsA("Texture") then
					child.StudsPerTileU = 1
					child.StudsPerTileV = 1
				end
			end
			basePart.Parent = tool
			tool.Name = toolName
			return tool
		end,
		["createToolFromAccessory"] = function(accessory: Accessory)
			local tool: Tool = Instance.new("Tool")
			local toolName: string = accessory.Name
			if #accessory:GetChildren() > 1 then
				local model: Model = Instance.new("Model")
				for _, child in accessory:GetChildren() do
					if child:IsA("BasePart") then
						child:Clone().Parent = model
					end
				end
				local cframe: CFrame, size: Vector3 = model:GetBoundingBox()
				local handle: Part = Instance.new("Part")
				handle.Name = "Handle"
				handle.Size = size
				handle.Position = cframe.Position
				handle.Transparency = 1
				handle.Parent = tool
				for _, child in accessory:GetChildren() do
					if child:IsA("BasePart") then
						child.Parent = handle
						local weld: WeldConstraint = Instance.new("WeldConstraint")
						weld.Part0 = handle
						weld.Part1 = child
						weld.Parent = child
					end
				end
			else
				accessory:FindFirstChild("Handle").Parent = tool
			end
			tool.Name = toolName
			return tool
		end
	}
}
