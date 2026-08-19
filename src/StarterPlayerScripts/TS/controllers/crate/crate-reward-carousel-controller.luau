-- CrateRewardCarouselController

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
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local ItemsByGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").ItemsByGroup
local CrateRewardResultType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").CrateRewardResultType
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local ItemMaterial =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local CageUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cage-util").CageUtil
local ToolUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "tool-util").ToolUtil
local scaleModel = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"scale-model",
	"out"
).scaleModel
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local CrateUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crate-util").CrateUtil
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type CrateRewardCarouselController = {
	parent: Model?,
	position: Vector3?,
	crateRewardResult: any?,
	model: Model?,
	sound: Sound?,
	currentIndex: number,
}

local CrateRewardCarouselController = setmetatable({}, {
	["__tostring"] = function()
		return "CrateRewardCarouselController"
	end,
})
CrateRewardCarouselController.__index = CrateRewardCarouselController
function CrateRewardCarouselController.new(...): CrateRewardCarouselController
	local instance = setmetatable({}, CrateRewardCarouselController)
	return instance:constructor(...) or instance
end
function CrateRewardCarouselController.constructor(self: CrateRewardCarouselController)
	self.parent = nil
	self.position = nil
	self.crateRewardResult = nil
	self.model = nil
	self.sound = nil
	self.currentIndex = 0
end
function CrateRewardCarouselController.onStart(self: CrateRewardCarouselController)
	Flamework.resolveDependency("dyD").CrateAnimationCompleted:bind(function(eventData)
		self.parent = eventData.CrateModel
		local position = eventData.Position
		local heightOffset = eventData.CrateModel.Plate.Size.Y / 2 + 0.2 + 0.15
		self.position = position + Vector3.new(0, heightOffset, 0)
		self:update(0)
	end)
	Flamework.resolveDependency("dyD").CrateAnimationCleanUp:bind(function(_)
		self:cleanup()
	end)
end
function CrateRewardCarouselController.shouldUpdateViewport(self: CrateRewardCarouselController, newReward)
	if self.crateRewardResult then
		if
			self.crateRewardResult.Type == CrateRewardResultType.Duplicate
			and (
				newReward.Type == CrateRewardResultType.Duplicate
				and self.crateRewardResult.GemsQuantity == newReward.GemsQuantity
			)
		then
			return false
		else
			return self.crateRewardResult.Type ~= CrateRewardResultType.Cosmetic
				or (
					newReward.Type ~= CrateRewardResultType.Cosmetic
					or self.crateRewardResult.CosmeticId ~= newReward.CosmeticId
				)
		end
	else
		return true
	end
end
function CrateRewardCarouselController.next(self: CrateRewardCarouselController)
	return self:update(self.currentIndex + 1)
end
function CrateRewardCarouselController.previous(self: CrateRewardCarouselController)
	return self:update(self.currentIndex - 1)
end
function CrateRewardCarouselController.update(self: CrateRewardCarouselController, index: number)
	if not (self.parent and self.position) then
		return nil
	end
	local rewards = Flamework.resolveDependency("jaW"):getCrateRewardResults()
	self.currentIndex = index % #rewards
	local reward = rewards[self.currentIndex + 1]
	if self.model then
		self.model:Destroy()
	end
	local model = self:playCrateRewardAnimation(reward.CosmeticId, self.position, self.parent)
	local soundId = CosmeticRarities[CrateUtil.getRarity(reward)].Sound
	local currentSoundId = self.sound
	if currentSoundId ~= nil then
		currentSoundId = currentSoundId.SoundId
	end
	if currentSoundId ~= soundId then
		local currentSound = self.sound
		if currentSound ~= nil then
			currentSound:Destroy()
		end
		self.sound = Flamework.resolveDependency("jL9"):playSound(soundId, {
			["SoundGroup"] = nil,
			["Looped"] = true,
			["SoundGroup"] = SoundGroupType.World,
		})
	end
	self.crateRewardResult = reward
	self.model = model
	return self.currentIndex
end
function CrateRewardCarouselController.playCrateRewardAnimation(
	self: CrateRewardCarouselController,
	cosmeticId: string,
	position: Vector3,
	parent: Model
): Model?
	self:playSmokeParticleEffect(position)
	local model = self:createRewardModel(cosmeticId, position, parent)
	if model ~= nil then
		model:SetAttribute(Attribute.HoverScale, 0.2)
		model:AddTag("animate:hover")
	end
	return model
end
function CrateRewardCarouselController.createRewardModel(
	self: CrateRewardCarouselController,
	cosmeticId: string,
	position: Vector3,
	parent: Model
): Model?
	local cosmeticType = Cosmetics[cosmeticId].Type
	if cosmeticType == "Skin" then
		return self:createSkinModel(cosmeticId, position, parent)
	elseif cosmeticType == "Cage" then
		return self:createCageModel(cosmeticId, position, parent)
	else
		return nil
	end
end
function CrateRewardCarouselController.createGemsModel(_, _, position: Vector3, parent: Model): Model
	local gem = ReplicatedStorage.Misc.Gem:Clone()
	local model = Instance.new("Model")
	local halfHeight = gem.Size.Y / 2
	gem.Position = position + Vector3.new(0, halfHeight, 0)
	gem.Anchored = true
	gem.Parent = model
	model.PrimaryPart = gem
	model.Parent = parent
	return model
end
function CrateRewardCarouselController.createCageModel(_, cosmeticId: string, position: Vector3, parent: Model): Model
	local cage = CageUtil.createCage(cosmeticId, CFrame.new(position))
	scaleModel(cage, 0.15)
	local cagePosition = CFrame.new(position)
	local halfHeight = cage:GetExtentsSize().Y / 2
	cage:SetPrimaryPartCFrame(cagePosition + Vector3.new(0, halfHeight, 0))
	cage.Parent = parent
	return cage
end
function CrateRewardCarouselController.createSkinModel(
	self: CrateRewardCarouselController,
	cosmeticId: string,
	position: Vector3,
	parent: Model
): Model?
	local itemInfo = self:getCosmeticItemInfo(cosmeticId)
	if not itemInfo then
		return nil
	end
	local tool = SkinsUtil.getTool(itemInfo.Name, cosmeticId)
	tool.Handle.Anchored = true
	local rotate = SkinsUtil.getViewportOptions(itemInfo.Name, cosmeticId)
	if rotate ~= nil then
		rotate = rotate.Rotate
	end
	local model = ToolUtil.createToolModel(tool, rotate)
	scaleModel(model, itemInfo.ItemGroup == ItemGroup.Sword and 0.6 or 0.8)
	local modelPosition = CFrame.new(position)
	local halfHeight = model:GetExtentsSize().Y / 2
	model:SetPrimaryPartCFrame(modelPosition + Vector3.new(0, halfHeight, 0))
	model.Parent = parent
	return model
end
function CrateRewardCarouselController.getCosmeticItemInfo(_, cosmeticId: string)
	local cosmetic = Cosmetics[cosmeticId]
	if cosmetic.Type ~= "Skin" then
		return nil
	end
	local items = ItemsByGroup[cosmetic.ItemGroup]
	if not items then
		return nil
	end
	local onyxItem = nil
	for index, item in items do
		local _ = index - 1
		if item.ItemMaterial == ItemMaterial.Onyx == true then
			onyxItem = item
			break
		end
	end
	return onyxItem or ArrayUtil.random(items)
end
function CrateRewardCarouselController.cleanup(self: CrateRewardCarouselController)
	if not self.model then
		return nil
	end
	self.model:Destroy()
	if self.sound then
		self.sound:Destroy()
	end
	self.parent = nil
	self.position = nil
	self.model = nil
	self.sound = nil
	self.currentIndex = 0
end
function CrateRewardCarouselController.playSmokeParticleEffect(_, position: Vector3)
	return Flamework.resolveDependency("dm"):explodeParticlesAtPosition(position + Vector3.new(0, 1, 0), {
		["Color"] = nil,
		["Size"] = nil,
		["Count"] = 20,
		["Speed"] = 1.5,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 10,
		["SpreadAngle"] = nil,
		["Color"] = ColorUtil.getColorSequence({ Color.Grey, Color.LightGrey, Color.White }),
		["Size"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.05) }),
		["Lifetime"] = NumberRange.new(0.2, 0.5),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(360, 360),
	})
end
function CrateRewardCarouselController.getCurrentIndex(self: CrateRewardCarouselController): number
	return self.currentIndex
end
Reflect.defineMetadata(CrateRewardCarouselController, "identifier", "wm8")
Reflect.defineMetadata(CrateRewardCarouselController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CrateRewardCarouselController, "$:flamework@Controller", Controller, {})
return {
	["CrateRewardCarouselController"] = CrateRewardCarouselController,
}
