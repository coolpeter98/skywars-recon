-- CharacterUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ToolUtil = RuntimeLib.import(script, script.Parent, "tool-util").ToolUtil
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local RigUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "rig-util").RigUtil

local CharacterUtil = {}

local characterCache = {}

function CharacterUtil.equipTool(parent: Instance, itemType: string, cosmeticType: string?): { Instance }
	local tool = SkinsUtil.getTool(itemType, cosmeticType)

	for _, child in parent:GetChildren() do
		if child:IsA("Tool") then
			child:Destroy()
		end
	end

	local cosmetic
	if cosmeticType == nil then
		cosmetic = nil
	else
		cosmetic = Cosmetics[cosmeticType]
	end

	local item = Items[itemType]
	local tools = {}

	if (not cosmetic or (cosmetic.Type ~= "Skin" or not cosmetic.DualWield)) and item.DualWield ~= true then
		local leftHanded = Items[itemType]
		if leftHanded ~= nil then
			leftHanded = leftHanded.LeftHanded
		end
		if leftHanded == nil then
			leftHanded = false
		end

		ToolUtil.weldTool(parent, tool, leftHanded)
		table.insert(tools, tool)
		return tools
	end

	local firstTool = tool:Clone()
	local secondTool = tool:Clone()

	ToolUtil.weldTool(parent, firstTool, false)
	ToolUtil.weldTool(parent, secondTool, true)

	table.insert(tools, firstTool)
	table.insert(tools, secondTool)

	return tools
end

local getHumanoidDescription: (userId: number) -> HumanoidDescription?

function CharacterUtil.createCharacter(userId: number?): Model
	if userId == nil then
		userId = Players.LocalPlayer.UserId
	end

	local cachedModel = characterCache[userId]
	if not cachedModel then
		local humanoidDescription = getHumanoidDescription(userId)
		RigUtil.applyHumanoidDescriptionConfig(humanoidDescription)
		cachedModel = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
		characterCache[userId] = cachedModel
	end

	local character = cachedModel:Clone()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	return character
end

getHumanoidDescription = function(userId: number)
	local ok, result = RuntimeLib.try(function()
		return RuntimeLib.TRY_RETURN, { Players:GetHumanoidDescriptionFromUserId(userId) }
	end, function(_)
		return RuntimeLib.TRY_RETURN, { Players:GetHumanoidDescriptionFromUserId(1800687521) }
	end)

	if ok then
		return unpack(result)
	end
end

return {
	["CharacterUtil"] = CharacterUtil,
}
