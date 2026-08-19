-- ToolUtil

return {
	["ToolUtil"] = {
		["weldTool"] = function(character: Model, tool: Tool, isLeftHand: boolean)
			local hand = character:FindFirstChild(isLeftHand and "LeftHand" or "RightHand")
			if not (hand and hand:IsA("BasePart")) then
				return nil
			end
			local grip = hand:FindFirstChild(isLeftHand and "LeftGripAttachment" or "RightGripAttachment")
			if not (grip and grip:IsA("Attachment")) then
				return nil
			end
			local motor = Instance.new("Motor6D")
			motor.C0 = grip.CFrame
			motor.C1 = tool.Grip
			motor.Part0 = hand
			motor.Part1 = tool.Handle
			motor.Parent = tool.Handle
			for _, descendant in tool:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Massless = true
					descendant.CanCollide = false
					if descendant ~= tool.Handle then
						local weld = Instance.new("Weld")
						weld.C0 = tool.Handle.CFrame:ToObjectSpace(descendant.CFrame)
						weld.Part0 = tool.Handle
						weld.Part1 = descendant
						weld.Parent = descendant
					end
				end
			end
			tool.Parent = character
		end,
		["createToolModel"] = function(tool: Tool, rotation: Vector3?)
			local model = Instance.new("Model")
			for _, child in tool:GetChildren() do
				child.Parent = model
			end
			local handle = model:FindFirstChild("Handle")
			if handle then
				model.PrimaryPart = handle
				local cf
				if rotation then
					cf = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
				else
					cf = CFrame.new()
				end
				model:SetPrimaryPartCFrame(cf)
			end
			return model
		end,
	},
}
