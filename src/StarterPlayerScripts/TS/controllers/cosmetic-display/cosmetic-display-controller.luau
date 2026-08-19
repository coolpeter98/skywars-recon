-- CosmeticDisplayController

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
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local isCosmeticType = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-type"
).isCosmeticType
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "character-util").CharacterUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local getCosmeticDisplays =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").getCosmeticDisplays
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

type CosmeticDisplayController = {
	cosmeticDisplayControllerMap: { [string]: any },
	constructor: (self: CosmeticDisplayController) -> (),
	onStart: (self: CosmeticDisplayController) -> (),
	createBundleDisplay: (self: CosmeticDisplayController, displayInfo: any) -> any,
	createDisplay: (self: CosmeticDisplayController, displayInfo: any) -> any,
	createCarouselDisplay: (self: CosmeticDisplayController, displayInfo: any) -> any,
	updateDisplay: (self: CosmeticDisplayController, display: any) -> (),
	unequipAll: (self: CosmeticDisplayController, display: any) -> (),
	equipCosmetic: (self: CosmeticDisplayController, display: any, cosmeticId: string, material: any) -> (),
	unequipCosmetic: (self: CosmeticDisplayController, display: any, slot: string) -> (),
	shouldScheduleUpdates: (self: CosmeticDisplayController, display: any) -> boolean,
	createUpdateSchedule: (self: CosmeticDisplayController, display: any, interval: Vector2) -> any,
	createDisplayModel: (self: CosmeticDisplayController, maid: any, parent: Instance?) -> Model,
	createDisplayCharacter: (
		self: CosmeticDisplayController,
		maid: any,
		parent: Instance,
		position: Vector3,
		scale: number,
		animation: string?
	) -> Model,
}

local CosmeticDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticDisplayController"
	end,
})
CosmeticDisplayController.__index = CosmeticDisplayController

function CosmeticDisplayController.new(...)
	local self = CosmeticDisplayController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function CosmeticDisplayController.constructor(self: CosmeticDisplayController)
	self.cosmeticDisplayControllerMap = {}
end

function CosmeticDisplayController.onStart(self: CosmeticDisplayController)
	for _, displayEntry in getCosmeticDisplays() do
		local cosmeticType = displayEntry[1]
		local displayController = displayEntry[2]
		self.cosmeticDisplayControllerMap[cosmeticType] = displayController
	end
end

function CosmeticDisplayController.createBundleDisplay(self: CosmeticDisplayController, displayInfo: any)
	local bundle = Bundles[displayInfo.BundleId]
	local function createCosmeticItem(cosmeticId: string)
		local cosmetic = Cosmetics[cosmeticId]
		if cosmetic.Type ~= "Skin" then
			return {
				["Id"] = cosmeticId,
			}
		end
		local item = {
			["Id"] = cosmeticId,
		}
		local material = displayInfo.Materials
		if material ~= nil then
			material = material[cosmetic.ItemGroup]
		end
		item.Material = material
		return item
	end
	local cosmeticGroups = {}
	local helmetId = bundle.Helmet
	if helmetId ~= nil then
		helmetId = helmetId.Id
	end
	local chestplateId = bundle.Chestplate
	if chestplateId ~= nil then
		chestplateId = chestplateId.Id
	end
	local leggingsId = bundle.Leggings
	if leggingsId ~= nil then
		leggingsId = leggingsId.Id
	end
	local armorIds = ArrayUtil.filterDefined({ helmetId, chestplateId, leggingsId })
	local cosmetics = table.create(#armorIds)
	for i, cosmeticId in armorIds do
		cosmetics[i] = createCosmeticItem(cosmeticId, i - 1, armorIds)
	end
	if not displayInfo.DisableCage and bundle.Cage then
		local cageCosmetic = createCosmeticItem(bundle.Cage.Id)
		table.insert(cosmetics, cageCosmetic)
	end
	if bundle.Sword then
		local swordCosmetics = { (createCosmeticItem(bundle.Sword.Id)) }
		local swordCount = #swordCosmetics
		table.move(cosmetics, 1, #cosmetics, swordCount + 1, swordCosmetics)
		table.insert(cosmeticGroups, swordCosmetics)
	end
	if not displayInfo.OnlySword and bundle.Bow then
		local bowCosmetics = { (createCosmeticItem(bundle.Bow.Id)) }
		local bowCount = #bowCosmetics
		table.move(cosmetics, 1, #cosmetics, bowCount + 1, bowCosmetics)
		table.insert(cosmeticGroups, bowCosmetics)
	end
	if not displayInfo.OnlySword and bundle.Pickaxe then
		local pickaxeCosmetics = { (createCosmeticItem(bundle.Pickaxe.Id)) }
		local pickaxeCount = #pickaxeCosmetics
		table.move(cosmetics, 1, #cosmetics, pickaxeCount + 1, pickaxeCosmetics)
		table.insert(cosmeticGroups, pickaxeCosmetics)
	end
	if #cosmeticGroups == 0 then
		table.insert(cosmeticGroups, cosmetics)
	end
	local clone = table.clone(displayInfo)
	setmetatable(clone, nil)
	clone.Cosmetics = cosmeticGroups
	return self:createCarouselDisplay(clone)
end

function CosmeticDisplayController.createDisplay(self: CosmeticDisplayController, displayInfo: any)
	local clone = table.clone(displayInfo)
	setmetatable(clone, nil)
	clone.Cosmetics = { displayInfo.Cosmetics }
	return self:createCarouselDisplay(clone)
end

function CosmeticDisplayController.createCarouselDisplay(self: CosmeticDisplayController, displayInfo: any)
	local maid = Maid.new()
	local displayModel = self:createDisplayModel(maid, displayInfo.Parent)
	local scale = displayInfo.Scale
	local resolvedScale = scale == nil and 2 or scale
	local character
	if displayInfo.DisableCharacter then
		character = nil
	else
		local position = displayInfo.Position
		local animation = displayInfo.Animation
		if animation ~= nil then
			animation = animation.Idle
		end
		character = self:createDisplayCharacter(maid, displayModel, position, resolvedScale, animation)
	end
	local display = table.clone(displayInfo)
	setmetatable(display, nil)
	display.Maid = maid
	display.DisplayModel = displayModel
	display.Character = character
	display.ActiveIndex = 0
	display.Active = {}
	display.ActiveSkins = {}
	display.Scale = resolvedScale
	ScheduleUtil.runTask(function()
		if self:shouldScheduleUpdates(display) then
			maid:GiveTask(self:createUpdateSchedule(display, display.UpdateInterval or Vector2.new(10, 10)))
		else
			self:updateDisplay(display)
		end
	end)
	return display
end

function CosmeticDisplayController.updateDisplay(self: CosmeticDisplayController, display: any)
	local nextGroup = display.Cosmetics[display.ActiveIndex + 1]
	display.ActiveIndex = (display.ActiveIndex + 1) % #display.Cosmetics
	for key in display.Active do
		self:unequipCosmetic(display, key)
	end
	for key in display.ActiveSkins do
		self:unequipCosmetic(display, key)
	end
	for _, cosmetic in nextGroup do
		self:equipCosmetic(display, cosmetic.Id, cosmetic.Material)
	end
end

function CosmeticDisplayController.unequipAll(self: CosmeticDisplayController, display: any)
	for key in display.Active do
		self:unequipCosmetic(display, key)
	end
	for key in display.ActiveSkins do
		self:unequipCosmetic(display, key)
	end
end

function CosmeticDisplayController.equipCosmetic(
	self: CosmeticDisplayController,
	display: any,
	cosmeticId: string,
	material: any
)
	local cosmetic = Cosmetics[cosmeticId]
	local slot
	if cosmetic.Type == "Skin" then
		slot = cosmetic.ItemGroup
	else
		slot = cosmetic.Type
	end
	self:unequipCosmetic(display, slot)
	local displayController = self.cosmeticDisplayControllerMap[cosmetic.Type]
	if displayController then
		local equipTask = displayController:equip(display, cosmeticId, material)
		display.Maid:GiveTask(equipTask)
		if cosmetic.Type == "Skin" then
			display.ActiveSkins[cosmetic.ItemGroup] = {
				["CosmeticId"] = cosmeticId,
				["Maid"] = equipTask,
			}
		else
			display.Active[cosmetic.Type] = {
				["CosmeticId"] = cosmeticId,
				["Maid"] = equipTask,
			}
		end
	else
		return nil
	end
end

function CosmeticDisplayController.unequipCosmetic(_: CosmeticDisplayController, display: any, slot: string)
	local entry
	if isCosmeticType(slot) then
		entry = display.Active[slot]
	else
		entry = display.ActiveSkins[slot]
	end
	if entry then
		entry.Maid:DoCleaning()
		if isCosmeticType(slot) then
			local active = display.Active
			local _ = active[slot] == nil
			active[slot] = nil
		else
			local activeSkins = display.ActiveSkins
			local _ = activeSkins[slot] == nil
			activeSkins[slot] = nil
		end
	else
		return nil
	end
end

function CosmeticDisplayController.shouldScheduleUpdates(_: CosmeticDisplayController, display: any): boolean
	local equippedMap = {}
	local cosmeticGroups = display.Cosmetics
	local function groupHasChanges(group: any)
		local function checkCosmetic(cosmeticItem: any)
			local cosmetic = Cosmetics[cosmeticItem.Id]
			local slot
			if cosmetic.Type == "Skin" then
				slot = cosmetic.ItemGroup
			else
				slot = cosmetic.Type
			end
			local slotMap = equippedMap[slot]
			local changed
			if slotMap then
				changed = slotMap[cosmetic.Id] == nil or slotMap[cosmetic.Id] ~= cosmeticItem.Material
			else
				changed = slotMap
			end
			if changed then
				return true
			end
			local updatedSlotMap = slotMap == nil and {} or slotMap
			updatedSlotMap[cosmetic.Id] = cosmeticItem.Material
			equippedMap[slot] = updatedSlotMap
		end
		local changedCosmetic = nil
		for i, cosmeticItem in group do
			if checkCosmetic(cosmeticItem, i - 1, group) == true then
				changedCosmetic = cosmeticItem
				break
			end
		end
		return changedCosmetic and true or false
	end
	local changedGroup = nil
	for i, group in cosmeticGroups do
		if groupHasChanges(group, i - 1, cosmeticGroups) == true then
			changedGroup = group
			break
		end
	end
	return changedGroup and true or false
end

function CosmeticDisplayController.createUpdateSchedule(
	self: CosmeticDisplayController,
	display: any,
	interval: Vector2
)
	return ScheduleUtil.createIntermittentSchedule(interval, function()
		self:updateDisplay(display)
	end)
end

function CosmeticDisplayController.createDisplayModel(_: CosmeticDisplayController, maid: any, parent: Instance?): Model
	local model = Instance.new("Model")
	model.Name = "Display"
	model.Parent = parent
	maid:GiveTask(model)
	return model
end

function CosmeticDisplayController.createDisplayCharacter(
	_: CosmeticDisplayController,
	maid: any,
	parent: Instance,
	position: Vector3,
	scale: number,
	animation: string?
): Model
	local character = CharacterUtil.createCharacter()
	character.Name = Players.LocalPlayer.Name
	character.PrimaryPart.Anchored = true
	character.Parent = parent
	character:ScaleTo(scale)
	local boundingCFrame, boundingSize = character:GetBoundingBox()
	local boundingPosition = boundingCFrame.Position
	local halfHeight = boundingSize.Y / 2
	local bottomCenter = boundingPosition - Vector3.new(0, halfHeight, 0)
	local heightOffset = character:GetPivot().Y - bottomCenter.Y
	character:PivotTo(position + Vector3.new(0, heightOffset, 0))
	if animation ~= "" and animation then
		Flamework.resolveDependency("Kp"):playHumanoidAnimation(animation, true, 1, character)
	end
	maid:GiveTask(character)
	return character
end

Reflect.defineMetadata(CosmeticDisplayController, "identifier", "Wyw")
Reflect.defineMetadata(CosmeticDisplayController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CosmeticDisplayController, "$:flamework@Controller", Controller, {})
return {
	["CosmeticDisplayController"] = CosmeticDisplayController,
}
