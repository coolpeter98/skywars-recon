-- RigUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local SkinsUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local RigUtil = {}
local equipAccessory = nil

function RigUtil.equipArmour(character: Model, itemId: string, skinId: string): Model?
	return equipAccessory(character, SkinsUtil.getArmour(itemId, skinId), skinId, SkinsUtil.isLegacyArmour(skinId))
end

equipAccessory = function(character: Model, accessory: Model, skinId: string, isLegacy: boolean): Model?
	if isLegacy == nil then
		isLegacy = false
	end
	local accessoryModel: Model = Instance.new("Model")
	accessoryModel.Name = accessory.Name
	accessoryModel:SetAttribute(Attribute.Armour, true)
	for _, child in accessory:GetChildren() do
		local cloned = child:Clone()
		cloned.Parent = accessoryModel
		cloned.CanCollide = false
		cloned.Massless = true
		accessoryModel.PrimaryPart = cloned
		local attachment = cloned:FindFirstChildOfClass("Attachment")
		local targetAttachment = nil
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("Attachment") then
				local parentName = descendant.Parent.Name
				local attachmentName = descendant.Name
				if (not isLegacy or parentName ~= "LowerTorso" and parentName ~= "HumanoidRootPart" and (attachmentName ~= "LeftShoulderRigAttachment" and attachmentName ~= "RightShoulderRigAttachment" or parentName ~= "UpperTorso") and ((attachmentName ~= "LeftKneeRigAttachment" and attachmentName ~= "RightKneeRigAttachment" or parentName ~= "LeftUpperLeg" and parentName ~= "RightUpperLeg") and ((attachmentName ~= "NeckRigAttachment" or parentName ~= "UpperTorso") and ((attachmentName ~= "LeftWristRigAttachment" or parentName ~= "LeftLowerArm") and ((attachmentName ~= "RightWristRigAttachment" or parentName ~= "RightLowerArm") and (not skinId or skinId ~= CosmeticId.ChestplateSpartan and skinId ~= CosmeticId.ChestplateAzazel or (attachmentName ~= "LeftElbowRigAttachment" or parentName ~= "LeftUpperArm") and (attachmentName ~= "RightElbowRigAttachment" or parentName ~= "RightUpperArm"))))))) and descendant.Name == attachment.Name then
					local shouldSetTarget = isLegacy
					if not isLegacy then
						local unriggedName = string.gsub(attachment.Name, "RigAttachment", "")
						local motor = descendant.Parent:FindFirstChildOfClass("Motor6D")
						if motor ~= nil then
							motor = motor.Name
						end
						shouldSetTarget = motor == unriggedName
					end
					if shouldSetTarget then
						if targetAttachment ~= nil then
							print("Attachment name collision: " .. descendant.Parent.Name)
						end
						targetAttachment = descendant
					end
				end
			end
		end
		if not targetAttachment then
			print("Failed to find target attachment: " .. attachment.Name)
			return nil
		end
		local mirroredPosition = attachment.CFrame.Position * Vector3.new(1, -1, 1)
		local rotation = attachment.CFrame - attachment.CFrame.Position
		cloned.CFrame = targetAttachment.WorldCFrame * (CFrame.new(mirroredPosition) * rotation)
		local targetPart = targetAttachment.Parent
		local weld: WeldConstraint = Instance.new("WeldConstraint")
		weld.Name = "AccessoryWeld"
		weld.Part0 = targetPart
		weld.Part1 = cloned
		weld.Parent = accessoryModel
	end
	accessoryModel.Parent = character
	return accessoryModel
end
RigUtil.equipAccessory = equipAccessory

function RigUtil.unsecureWelds(rig: Model)
	local weldCount = 0
	local welds = {}
	for i, descendant in rig:GetDescendants() do
		local _ = i - 1
		if (descendant:IsA("Weld") or descendant:IsA("WeldConstraint")) == true then
			weldCount = weldCount + 1
			welds[weldCount] = descendant
		end
	end
	for i, weld in welds do
		local _ = i - 1
		weld:SetAttribute(Attribute.RemovingWeld, true)
	end
end

function RigUtil.applyHumanoidDescriptionConfig(description: HumanoidDescription)
	description.Head = 0
	description.Torso = 0
	description.LeftArm = 0
	description.RightArm = 0
	description.LeftLeg = 0
	description.RightLeg = 0
	description.BodyTypeScale = 0.3
	description.DepthScale = 1
	description.HeadScale = 1
	description.HeightScale = 1
	description.ProportionScale = 1
	description.WidthScale = 1
end

return {
	["RigUtil"] = RigUtil
}
