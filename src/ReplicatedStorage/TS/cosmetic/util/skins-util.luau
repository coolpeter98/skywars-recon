-- SkinsUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Items: { [string]: any } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local Cosmetics: { [string]: any } = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics

local SkinsUtil = {}

local function getTool(itemId: string, skinId: string): Tool
	local itemData = Items[itemId]
	if itemData.Rewrite then
		local teamId: string? = Flamework.resolveDependency("x5"):getPlayerTeamId()
		local teamName = teamId == nil and "White" or teamId
		return getTool(string.gsub(itemData.Rewrite.Type, "{TeamId}", teamName), skinId)
	end
	local skin
	if skinId == "" or not skinId then
		skin = nil
	else
		skin = itemData.Skins
		if skin ~= nil then
			skin = skin[skinId]
		end
	end
	local tool: Tool = (skin or itemData.ToolRef):Clone()
	tool.Name = itemId
	return tool
end

SkinsUtil.getTool = getTool

function SkinsUtil.getViewportOptions(itemId: string, skinId: string)
	if skinId ~= "" and skinId then
		local cosmeticData = Cosmetics[skinId]
		if cosmeticData and (cosmeticData.Type == "Skin" and cosmeticData.ViewportOptions) then
			return cosmeticData.ViewportOptions
		end
	end
	return Items[itemId].ViewportOptions
end

function SkinsUtil.getArmour(itemId: string, skinId: string)
	local itemData = Items[itemId]
	local skinArmour
	if skinId == "" or not skinId then
		skinArmour = nil
	else
		skinArmour = itemData.Armour
		if skinArmour ~= nil then
			skinArmour = skinArmour.Skins
			if skinArmour ~= nil then
				skinArmour = skinArmour[skinId]
			end
		end
	end
	local armour = (skinArmour or itemData.Armour.Ref):Clone()
	armour.Name = itemId
	return armour
end

function SkinsUtil.isLegacyArmour(skinId: string)
	if skinId == "" or not skinId then
		return false
	end
	local cosmeticData = Cosmetics[skinId]
	return cosmeticData and (cosmeticData.Type == "Skin" and cosmeticData.LegacyAttachments) and true or false
end

return {
	["SkinsUtil"] = SkinsUtil
}
