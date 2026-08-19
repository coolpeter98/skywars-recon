-- CosmeticSkinDisplayController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local RigUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "rig-util").RigUtil
local AccessoryUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "accessory-util").AccessoryUtil
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "character-util").CharacterUtil
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local CosmeticUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-util").CosmeticUtil
local CosmeticDisplayDecorator =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local ItemMaterial =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local InstanceUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "instance-util").InstanceUtil
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local DEFAULT_MATERIAL = ItemMaterial.Diamond

export type CosmeticSkinDisplayController = {
	new: (...any) -> CosmeticSkinDisplayController,
	constructor: (self: CosmeticSkinDisplayController, ...any) -> (),
	equip: (self: CosmeticSkinDisplayController, display: any, cosmeticId: string, material: string) -> any,
	equipArmour: (self: CosmeticSkinDisplayController, maid: any, display: any, item: any, cosmeticId: string) -> (),
	animationGiveTask: (self: CosmeticSkinDisplayController, maid: any, animation: any) -> (),
	equipTool: (self: CosmeticSkinDisplayController, maid: any, display: any, item: any, cosmeticId: string) -> (),
	createMeleeSchedule: (
		self: CosmeticSkinDisplayController,
		maid: any,
		display: any,
		item: any,
		cosmeticId: string
	) -> (),
	createPickaxeSchedule: (
		self: CosmeticSkinDisplayController,
		maid: any,
		display: any,
		item: any,
		cosmeticId: string
	) -> (),
	getCosmeticDisplayData: (self: CosmeticSkinDisplayController, cosmeticId: string) -> any,
	__tostring: () -> string,
}

local CosmeticSkinDisplayController: CosmeticSkinDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticSkinDisplayController"
	end,
})
CosmeticSkinDisplayController.__index = CosmeticSkinDisplayController

function CosmeticSkinDisplayController.new(...)
	local class = CosmeticSkinDisplayController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function CosmeticSkinDisplayController.constructor(self) end

function CosmeticSkinDisplayController.equip(self, display, cosmeticId, material)
	local maid = Maid.new()
	local material = material or (display.DefaultMaterial or DEFAULT_MATERIAL)
	local cosmeticItem = CosmeticUtil.getCosmeticItem(cosmeticId, material)
	local itemGroup
	if cosmeticItem == nil then
		itemGroup = cosmeticItem
	else
		itemGroup = cosmeticItem.ItemGroup
	end
	if not itemGroup then
		return maid
	end
	if display.Character then
		display.Character:ScaleTo(1)
		if cosmeticItem.Armour then
			self:equipArmour(maid, display, cosmeticItem, cosmeticId)
		else
			self:equipTool(maid, display, cosmeticItem, cosmeticId)
		end
		display.Character:ScaleTo(display.Scale)
	else
		local displayModel = Flamework.resolveDependency("wm8")
			:playCrateRewardAnimation(cosmeticId, display.Position.Position, display.DisplayModel)
		if displayModel then
			displayModel:ScaleTo(display.Scale)
			maid:GiveTask(displayModel)
			return maid
		end
	end
	return maid
end

function CosmeticSkinDisplayController.equipArmour(self, maid, display, item, cosmeticId)
	if not (item.Armour and item.ItemGroup) then
		return nil
	end
	local rig = RigUtil.equipArmour(display.Character, item.Name, cosmeticId)
	if not rig then
		return nil
	end
	local armourType = item.Armour.ArmourType
	AccessoryUtil.updateCharacterTransparency(display.Character, armourType, false)
	maid:GiveTask(rig)
	maid:GiveTask(function()
		return AccessoryUtil.updateCharacterTransparency(display.Character, armourType, true)
	end)
end

function CosmeticSkinDisplayController.animationGiveTask(self, maid, animation)
	if not animation then
		return nil
	end
	maid:GiveTask(function()
		return animation:Stop()
	end)
	maid:GiveTask(animation)
end

function CosmeticSkinDisplayController.equipTool(self, maid, display, item, cosmeticId)
	if not item.ItemGroup then
		return nil
	end
	local displayData = self:getCosmeticDisplayData(cosmeticId)
	for index, task in CharacterUtil.equipTool(display.Character, item.Name, cosmeticId) do
		local _ = index - 1
		maid:GiveTask(task)
	end
	self:animationGiveTask(
		maid,
		Flamework.resolveDependency("jBW"):playEquipAnimation(display.Character, item, cosmeticId)
	)
	self:animationGiveTask(
		maid,
		Flamework.resolveDependency("jBW"):playToolAnimation(display.Character, item, cosmeticId)
	)
	local idleOverride
	if display == nil then
		idleOverride = display
	else
		idleOverride = display.Animation
		if idleOverride ~= nil then
			idleOverride = idleOverride.IdleOverride
		end
	end
	if not idleOverride then
		local animationController = Flamework.resolveDependency("jBW")
		local character = display.Character
		if displayData ~= nil then
			displayData = displayData.Sprinting
		end
		self:animationGiveTask(maid, animationController:playIdleAnimation(character, item, cosmeticId, displayData))
	end
	local idle = display.Animation
	if idle ~= nil then
		idle = idle.Idle
	end
	if idle ~= "" and idle then
		self:animationGiveTask(
			maid,
			Flamework.resolveDependency("Kp"):playHumanoidAnimation(display.Animation.Idle, true, 1, display.Character)
		)
	end
	self:createMeleeSchedule(maid, display, item, cosmeticId)
	self:createPickaxeSchedule(maid, display, item, cosmeticId)
	if item.Ranged then
		Flamework.resolveDependency("Elz"):createFireBowSchedule(maid, display, nil)
	end
end

function CosmeticSkinDisplayController.createMeleeSchedule(self, maid, display, item, cosmeticId)
	local meleeInterval = self:getCosmeticDisplayData(cosmeticId)
	local hasMelee = InstanceUtil.isViewportFrameDescendent(display.DisplayModel)
	if hasMelee then
		hasMelee = item.Melee
	end
	local skipMelee = not hasMelee
	if skipMelee then
		local displayDataMelee
		if meleeInterval == nil then
			displayDataMelee = meleeInterval
		else
			displayDataMelee = meleeInterval.Melee
		end
		skipMelee = not displayDataMelee
	end
	if skipMelee then
		return nil
	end
	if meleeInterval ~= nil then
		meleeInterval = meleeInterval.MeleeInterval
	end
	if meleeInterval == nil then
		meleeInterval = Vector2.new(4, 6)
	end
	maid:GiveTask(ScheduleUtil.createIntermittentSchedule(meleeInterval, function()
		local parent = display.Character
		if parent ~= nil then
			parent = parent.Parent
		end
		if not parent then
			return nil
		end
		Flamework.resolveDependency("Gpz"):playAnimation(display.Character, item, cosmeticId)
	end, 3))
end

function CosmeticSkinDisplayController.createPickaxeSchedule(self, maid, display, item, _)
	if not (InstanceUtil.isViewportFrameDescendent(display.DisplayModel) and item.Pickaxe) then
		return nil
	end
	local PICKAXE_INTERVAL = Vector2.new(4, 6)
	maid:GiveTask(ScheduleUtil.createIntermittentSchedule(PICKAXE_INTERVAL, function()
		local parent = display.Character
		if parent ~= nil then
			parent = parent.Parent
		end
		if not parent then
			return nil
		end
		local animation = Flamework.resolveDependency("Kp")
			:playHumanoidAnimation(RobloxAnimation.PICKAXE_BREAK_LOOPED, true, 1, display.Character)
		if not animation then
			return nil
		end
		task.wait(MathUtil.random(0.4, 0.8))
		Flamework.resolveDependency("NaX"):stopBreakingAnimation(animation, 1 / 0)
	end, 3))
end

function CosmeticSkinDisplayController.getCosmeticDisplayData(self, cosmeticId)
	if cosmeticId then
		local cosmetic = Cosmetics[cosmeticId]
		local cosmeticType
		if cosmetic == nil then
			cosmeticType = cosmetic
		else
			cosmeticType = cosmetic.Type
		end
		if cosmeticType == "Skin" then
			return cosmetic.Display
		else
			return nil
		end
	else
		return nil
	end
end

Reflect.defineMetadata(CosmeticSkinDisplayController, "identifier", "XbN")
Reflect.defineMetadata(CosmeticSkinDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticSkinDisplayController, "MJo", CosmeticDisplayDecorator, { "Skin" })
Reflect.decorate(CosmeticSkinDisplayController, "$:flamework@Controller", Controller, {})
return {
	["CosmeticSkinDisplayController"] = CosmeticSkinDisplayController,
}
