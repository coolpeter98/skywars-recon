-- ArmourController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local ItemModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item")
local ArmourType = ItemModule.ArmourType
local Items = ItemModule.Items
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants

type ArmourType = "Helmet" | "Chestplate" | "Leggings"
type ArmourController = {}

local ArmourController = setmetatable({}, {
	["__tostring"] = function()
		return "ArmourController"
	end,
})
ArmourController.__index = ArmourController

function ArmourController.new(...)
	local self = ArmourController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function ArmourController.constructor(self) end

function ArmourController.getArmourHealth(self: ArmourController, armour: number): number
	local armourHealth = (1 - armour) * HealthConstants.MAX_HEALTH
	local segmentCount = (
		HealthConstants.MAX_HEALTH / armourHealth * HealthConstants.MAX_HEALTH - HealthConstants.MAX_HEALTH
	) / HealthConstants.HEALTH_PER_SEGMENT
	return math.round(segmentCount) * HealthConstants.HEALTH_PER_SEGMENT
end

function ArmourController.getArmourMitigation(self: ArmourController, character: Model): number
	local totalMitigation = 0
	for _, armourType in ObjectUtils.values(ArmourType) do
		local attributeValue = character:GetAttribute(armourType)
		if attributeValue then
			local itemInfo = Items[attributeValue]
			local armourInfo
			if itemInfo == nil then
				armourInfo = itemInfo
			else
				armourInfo = itemInfo.Armour
			end
			if armourInfo then
				totalMitigation = totalMitigation + itemInfo.Armour.DamageMitigation
			end
		end
	end
	return totalMitigation
end

function ArmourController.getItemInfoFromArmourType(self: ArmourController, armourType: ArmourType)
	local character = Players.LocalPlayer.Character
	if not character then
		return nil
	end
	for _, child in character:GetChildren() do
		local attributeValue = child:GetAttribute(Attribute.Armour)
		if attributeValue ~= 0 and (attributeValue == attributeValue and (attributeValue ~= "" and attributeValue)) then
			local itemInfo = Items[child.Name]
			local itemArmourType
			if itemInfo == nil then
				itemArmourType = itemInfo
			else
				itemArmourType = itemInfo.Armour
				if itemArmourType ~= nil then
					itemArmourType = itemArmourType.ArmourType
				end
			end
			if itemArmourType == armourType then
				return itemInfo
			end
		end
	end
	return nil
end

Reflect.defineMetadata(ArmourController, "identifier", "JXb")
Reflect.decorate(ArmourController, "$:flamework@Controller", Controller, {})
return {
	["ArmourController"] = ArmourController,
}
