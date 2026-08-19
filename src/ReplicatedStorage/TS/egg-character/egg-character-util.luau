-- EggCharacterUtil

type EggCharacterData = {
	HatType: string,
	ToolType: string,
	ColorId: string,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local EggCharacters: { [string]: EggCharacterData } = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character"
).EggCharacters

local EggCharacterUtil = {}
local styleEggPart: ((eggModel: Model, slotName: string, targetPartName: string, part: BasePart, isTool: boolean) -> nil?)? = nil

function EggCharacterUtil.createEggModel(colorName: string): Model
	local eggModel: Model = ReplicatedStorage.Misc:FindFirstChild("Egg"):Clone()
	local eggData: EggCharacterData = EggCharacters[colorName]
	if eggData == nil then
		eggData = EggCharacters.Red
	end
	local hatModel = ReplicatedStorage.Misc.EggMisc:FindFirstChild(eggData.HatType)
	local toolModel = ReplicatedStorage.Misc.EggMisc:FindFirstChild(eggData.ToolType)
	styleEggPart(eggModel, "HAT", "Hat", hatModel:Clone(), false)
	styleEggPart(eggModel, "TOOL ", "Tool", toolModel:Clone(), true)
	eggModel:FindFirstChild("EGGSHELL").TextureID = eggData.ColorId
	return eggModel
end

styleEggPart = function(eggModel: Model, slotName: string, targetPartName: string, part: BasePart, isTool: boolean)
	local placeholder = eggModel:FindFirstChild(slotName)
	if not placeholder then
		return nil
	end
	part.CanCollide = false
	part.Position = placeholder.Position
	part.Orientation = placeholder.Orientation
	part.Size = part.Size * 1.864
	local attachment: Attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.WorldCFrame = part.CFrame
	if isTool then
		attachment.Orientation = Vector3.new(90, 0, 0)
	else
		local halfHeight = -(part.Size.Y / 2)
		attachment.Position = Vector3.new(0, halfHeight, 0)
	end
	local targetPart = eggModel.PrimaryPart:FindFirstChild(targetPartName)
	local alignPosition: AlignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Attachment1 = targetPart
	alignPosition.RigidityEnabled = true
	alignPosition.Parent = part
	local alignOrientation: AlignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Attachment1 = targetPart
	alignOrientation.RigidityEnabled = true
	alignOrientation.Parent = part
	part.Parent = eggModel
	placeholder:Destroy()
end

return {
	["EggCharacterUtil"] = EggCharacterUtil,
}
