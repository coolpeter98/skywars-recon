-- CosmeticsController

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
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local CosmeticsOverride =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetics-override")
local getCosmeticOverride = CosmeticsOverride.getCosmeticOverride
local getSkinOverride = CosmeticsOverride.getSkinOverride

type CosmeticsProfile = {
	Active: { [string]: string },
	ActiveSkinsGroup: { [string]: string },
	Owned: { [string]: boolean },
}

type Item = {
	ItemGroup: string?,
	Animation: string?,
	Ranged: { Animation: string? }?,
}

type CosmeticsController = {
	new: (...any) -> CosmeticsController,
	enableCosmetic: (self: CosmeticsController, cosmeticId: string) -> (),
	getActiveCosmetic: (self: CosmeticsController, cosmeticId: string, cosmetics: CosmeticsProfile?) -> string?,
	getItemAnimation: (self: CosmeticsController, item: Item, cosmeticId: string?) -> string?,
	getProjectileAnimation: (self: CosmeticsController, item: Item, cosmeticId: string?) -> string?,
	getActiveSkinFromItem: (self: CosmeticsController, itemId: string) -> string?,
	getActiveSkin: (self: CosmeticsController, itemGroup: string, cosmetics: CosmeticsProfile?) -> string?,
	isActive: (self: CosmeticsController, cosmeticId: string, cosmetics: CosmeticsProfile?) -> boolean,
	getTool: (self: CosmeticsController, itemId: string) -> Tool,
	getArmour: (self: CosmeticsController, itemId: string) -> Instance,
	ownsCosmetic: (self: CosmeticsController, cosmeticId: string) -> boolean,
}

local CosmeticsController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticsController"
	end,
})
CosmeticsController.__index = CosmeticsController

function CosmeticsController.new(...): CosmeticsController
	local self = CosmeticsController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function CosmeticsController.constructor(self: CosmeticsController) end

function CosmeticsController.enableCosmetic(self: CosmeticsController, cosmeticId: string)
	Events["9ef2e22a-1792-414c-affd-aaa036086098"]:fire(cosmeticId)
end

function CosmeticsController.getActiveCosmetic(
	self: CosmeticsController,
	cosmeticId: string,
	cosmetics: CosmeticsProfile?
): string?
	if cosmetics == nil then
		cosmetics = GlobalStore:getState().Profile.Cosmetics
	end
	return getCosmeticOverride(cosmeticId) or cosmetics.Active[cosmeticId]
end

function CosmeticsController.getItemAnimation(self: CosmeticsController, item: Item, cosmeticId: string?): string?
	if cosmeticId then
		local cosmetic = Cosmetics[cosmeticId]
		local cosmeticType
		if cosmetic == nil then
			cosmeticType = cosmetic
		else
			cosmeticType = cosmetic.Type
		end
		if cosmeticType == "Skin" then
			if item.ItemGroup == cosmetic.ItemGroup then
				return cosmetic.ItemAnimation or item.Animation
			else
				return item.Animation
			end
		else
			return item.Animation
		end
	else
		return item.Animation
	end
end

function CosmeticsController.getProjectileAnimation(self: CosmeticsController, item: Item, cosmeticId: string?): string?
	if cosmeticId then
		local cosmetic = Cosmetics[cosmeticId]
		local cosmeticType
		if cosmetic == nil then
			cosmeticType = cosmetic
		else
			cosmeticType = cosmetic.Type
		end
		if cosmeticType == "Skin" then
			if item.ItemGroup == cosmetic.ItemGroup then
				local projectileAnimation = cosmetic.ProjectileAnimation
				if projectileAnimation == nil then
					projectileAnimation = item.Ranged
					if projectileAnimation ~= nil then
						projectileAnimation = projectileAnimation.Animation
					end
				end
				return projectileAnimation
			else
				local rangedAnimation = item.Ranged
				if rangedAnimation ~= nil then
					rangedAnimation = rangedAnimation.Animation
				end
				return rangedAnimation
			end
		else
			local rangedAnimation = item.Ranged
			if rangedAnimation ~= nil then
				rangedAnimation = rangedAnimation.Animation
			end
			return rangedAnimation
		end
	else
		local rangedAnimation = item.Ranged
		if rangedAnimation ~= nil then
			rangedAnimation = rangedAnimation.Animation
		end
		return rangedAnimation
	end
end

function CosmeticsController.getActiveSkinFromItem(self: CosmeticsController, itemId: string): string?
	local itemGroup = Items[itemId].ItemGroup
	if itemGroup then
		return self:getActiveSkin(itemGroup)
	else
		return nil
	end
end

function CosmeticsController.getActiveSkin(
	self: CosmeticsController,
	itemGroup: string,
	cosmetics: CosmeticsProfile?
): string?
	if cosmetics == nil then
		cosmetics = GlobalStore:getState().Profile.Cosmetics
	end
	local skinOverride = getSkinOverride(itemGroup)
	if skinOverride then
		return skinOverride
	else
		local skinId = cosmetics.ActiveSkinsGroup[itemGroup]
		if skinId then
			local cosmetic = Cosmetics[skinId]
			if cosmetic and cosmetic.Type == "Skin" then
				return skinId
			else
				return nil
			end
		else
			return nil
		end
	end
end

function CosmeticsController.isActive(
	self: CosmeticsController,
	cosmeticId: string,
	cosmetics: CosmeticsProfile?
): boolean
	if cosmetics == nil then
		cosmetics = GlobalStore:getState().Profile.Cosmetics
	end
	local cosmetic = Cosmetics[cosmeticId]
	local activeCosmetic
	if cosmetic.Type == "Skin" then
		activeCosmetic = self:getActiveSkin(cosmetic.ItemGroup, cosmetics)
	else
		activeCosmetic = self:getActiveCosmetic(cosmetic.Type, cosmetics)
	end
	local result
	if activeCosmetic == nil then
		result = false
	else
		result = activeCosmetic == cosmetic.Id
	end
	return result
end

function CosmeticsController.getTool(self: CosmeticsController, itemId: string): Tool
	local activeSkin = self:getActiveSkinFromItem(itemId)
	return SkinsUtil.getTool(itemId, activeSkin)
end

function CosmeticsController.getArmour(self: CosmeticsController, itemId: string): Instance
	local activeSkin = self:getActiveSkinFromItem(itemId)
	return SkinsUtil.getArmour(itemId, activeSkin)
end

function CosmeticsController.ownsCosmetic(self: CosmeticsController, cosmeticId: string): boolean
	local cosmetic = Cosmetics[cosmeticId]
	if not cosmetic then
		return false
	end
	if cosmetic.Type ~= "Package" then
		return GlobalStore:getState().Profile.Cosmetics.Owned[cosmeticId] ~= nil
	end
	for _, cosmeticId in cosmetic.Cosmetics do
		if not self:ownsCosmetic(cosmeticId) then
			return false
		end
	end
	return true
end

Reflect.defineMetadata(CosmeticsController, "identifier", "Ggz")
Reflect.decorate(CosmeticsController, "$:flamework@Controller", Controller, {})

return {
	["CosmeticsController"] = CosmeticsController,
}
