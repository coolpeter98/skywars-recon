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

function EggCharacterUtil.createEggModel(colorName: string): Model?
	-- The egg/hog content lives in ReplicatedStorage.Misc (egg model
	-- blobs); in an unpublished Studio place those assets are missing, so
	-- guard every step instead of erroring during Flamework preload.
	local eggTemplate = ReplicatedStorage.Misc:FindFirstChild("Egg")
	if eggTemplate == nil then
		return nil
	end
	local eggModel: Model = eggTemplate:Clone()
	local eggData: EggCharacterData = EggCharacters[colorName]
	if eggData == nil then
		eggData = EggCharacters.Red
	end
	local eggMisc = ReplicatedStorage.Misc:FindFirstChild("EggMisc")
	local hatModel = eggMisc and eggMisc:FindFirstChild(eggData.HatType)
	local toolModel = eggMisc and eggMisc:FindFirstChild(eggData.ToolType)
	if hatModel then
		styleEggPart(eggModel, "HAT", "Hat", hatModel:Clone(), false)
	end
	if toolModel then
		styleEggPart(eggModel, "TOOL ", "Tool", toolModel:Clone(), true)
	end
	local eggShell = eggModel:FindFirstChild("EGGSHELL")
	if eggShell then
		eggShell.TextureID = eggData.ColorId
	end
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
	local primaryPart = eggModel.PrimaryPart
	local targetPart = primaryPart and primaryPart:FindFirstChild(targetPartName)
	if targetPart == nil then
		return nil
	end
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
