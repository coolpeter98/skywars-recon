-- CapeUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId: { [string]: string } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local RigUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "rig-util").RigUtil
return {
	["CapeUtil"] = {
		["spawnCape"] = function(character: Model, capeLevel: string): Model
			local cape = ReplicatedStorage.Cosmetic.Cape:FindFirstChild(capeLevel):Clone()
			local upperTorso: BasePart = character:FindFirstChild("UpperTorso")
			local primaryPart: BasePart = cape.PrimaryPart
			local heightOffset = (capeLevel == CosmeticId.CapeLevelTen or capeLevel == CosmeticId.CapeLevelTwenty) and 0.75 or (capeLevel == CosmeticId.CapeLevelThirty and 0.5 or (capeLevel == CosmeticId.CapeLevelForty and 0.5 or (capeLevel == CosmeticId.CapeLevelFifty and 0.42 or 0)))
			local offsetVector = Vector3.new(0, heightOffset, 0)
			local shoulderOffset = primaryPart.Position - cape:FindFirstChild("CapeShoulder").Position
			local offsetX = shoulderOffset.X
			local offsetY = shoulderOffset.Y
			local offsetZ = -shoulderOffset.Z
			local weldOffset = Vector3.new(offsetX, offsetY, offsetZ) + offsetVector
			primaryPart.CanCollide = false
			primaryPart.Massless = true
			local capeWeld: Weld = Instance.new("Weld")
			capeWeld.Name = "CapeWeld"
			capeWeld.Part0 = upperTorso
			capeWeld.Part1 = primaryPart
			capeWeld.C0 = CFrame.new(weldOffset)
			capeWeld.C1 = CFrame.new()
			capeWeld.Parent = primaryPart
			local capeShoulder: BasePart = cape:FindFirstChild("CapeShoulder")
			capeShoulder.CanCollide = false
			capeShoulder.Massless = true
			local capeShoulderWeld: Weld = Instance.new("Weld")
			capeShoulderWeld.Name = "CapeShoulderWeld"
			capeShoulderWeld.Part0 = upperTorso
			capeShoulderWeld.Part1 = capeShoulder
			capeShoulderWeld.C0 = CFrame.new(offsetVector) * CFrame.Angles(0, 3.141592653589793, 0)
			capeShoulderWeld.C1 = CFrame.new()
			capeShoulderWeld.Parent = cape
			capeWeld.Parent = primaryPart
			cape.Parent = character
			local destroyConnection = nil
			destroyConnection = upperTorso.Destroying:Connect(function()
				destroyConnection:Disconnect()
				cape:Destroy()
			end)
			cape.Destroying:Connect(function()
				RigUtil.unsecureWelds(cape)
			end)
			return cape
		end,
		["calculateCapeRotation"] = function(currentRotation: number, verticalVelocity: number, forwardVelocity: number, deltaTime: number): number
			local frameCount = deltaTime / 0.016666666666666666
			local targetRotation
			if math.abs(verticalVelocity) < 1 then
				if forwardVelocity > 6 then
					targetRotation = currentRotation + 2 * frameCount
					if targetRotation > 45 then
						targetRotation = targetRotation - 3 * frameCount
					end
				else
					if currentRotation > 45 then
						currentRotation = currentRotation - frameCount
					end
					if currentRotation > 30 then
						currentRotation = currentRotation - frameCount
					end
					targetRotation = currentRotation - frameCount
				end
			elseif verticalVelocity < 0 then
				targetRotation = currentRotation + 5 * frameCount
			else
				targetRotation = currentRotation - 5 * frameCount
			end
			local clampedRotation = math.min(targetRotation, 150)
			return math.max(clampedRotation, 10)
		end,
		["setCapeRotation"] = function(capePart: BasePart, weld: Weld, attachmentOffset: CFrame, rotation: number)
			local halfHeight = -capePart.Size.Y / 2
			local positionOffset = Vector3.new(0, halfHeight, 0)
			local capeParent = capePart.Parent
			if capeParent ~= nil then
				capeParent = capeParent.Name
			end
			if capeParent == "CapeLevelFifty" then
				local levelFiftyOffset = -(capePart.Size.Y - 1.2) / 2
				positionOffset = Vector3.new(0, levelFiftyOffset, 0)
			end
			local offsetCFrame = CFrame.new(positionOffset)
			local inverseOffsetCFrame = CFrame.new() - positionOffset
			local cframeAngles = CFrame.Angles
			local negativeRotation = -rotation
			weld.C0 = attachmentOffset * (inverseOffsetCFrame * cframeAngles(math.rad(negativeRotation), 3.141592653589793, 0) * offsetCFrame)
		end
	}
}
