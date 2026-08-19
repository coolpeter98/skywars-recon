-- CosmeticCageDisplayController

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
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Controller = Flamework.Controller
local Modding = Flamework.Modding
local GenericCage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"cage",
	"generic-cage"
).GenericCage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CosmeticDisplayDecorator =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator
local InstanceUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "instance-util").InstanceUtil
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage

export type CosmeticCageDisplayController = {
	new: (...any) -> CosmeticCageDisplayController,
	constructor: (self: CosmeticCageDisplayController, cosmeticDecoratorModule: any) -> (),
	equip: (self: CosmeticCageDisplayController, id: string, cosmetic: any) -> any,
	createCage: (
		self: CosmeticCageDisplayController,
		position: CFrame,
		displayModel: Model,
		color: Color3,
		id: string,
		scale: number
	) -> (Model, any),
	cosmeticDecoratorModule: any,
}

local CosmeticCageDisplayController: CosmeticCageDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticCageDisplayController"
	end,
})
CosmeticCageDisplayController.__index = CosmeticCageDisplayController
function CosmeticCageDisplayController.new(...)
	local self = CosmeticCageDisplayController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function CosmeticCageDisplayController.constructor(self: CosmeticCageDisplayController, cosmeticDecoratorModule)
	self.cosmeticDecoratorModule = cosmeticDecoratorModule
end
function CosmeticCageDisplayController.equip(self: CosmeticCageDisplayController, id: string, cosmetic): any
	local definition = Cosmetics[id]
	local maid = Maid.new()
	if definition == nil or definition.Type ~= "Cage" then
		return maid
	end
	local position = cosmetic.Position
	local cageOffset = definition.Display
	if cageOffset ~= nil then
		cageOffset = cageOffset.CageOffset
	end
	if cageOffset then
		position = position:ToWorldSpace(definition.Display.CageOffset)
	end
	local isInViewport = InstanceUtil.isViewportFrameDescendent(cosmetic.DisplayModel)
	if isInViewport then
		position = position * CFrame.Angles(0, -0.4363323129985824, 0)
	end
	if isInViewport and cosmetic.Character then
		cosmetic.Character.Parent = ReplicatedStorage
	end
	local scale = cosmetic.Scale
	local cageScale = definition.Display
	if cageScale ~= nil then
		cageScale = cageScale.CageScale
	end
	local finalScale = scale * (cageScale == nil and 1 or cageScale)
	local cageParts = self:createCage(position, cosmetic.DisplayModel, Color.White, id, finalScale)
	local cageModel = cageParts[1]
	local cageMaid = cageParts[2]
	local boundingBox, boundingBoxSize = cageModel:GetBoundingBox()
	local halfHeight = boundingBoxSize.Y / 2
	local bottomCenter = boundingBox - Vector3.new(0, halfHeight, 0)
	local yOffset = cageModel:GetPrimaryPartCFrame().Y - bottomCenter.Y
	local translation = Vector3.new(0, yOffset, 0)
	cageModel:TranslateBy(translation)
	local shouldTranslateCharacter = not isInViewport
	if shouldTranslateCharacter then
		shouldTranslateCharacter = cosmetic.Character
	end
	if shouldTranslateCharacter then
		local cageOffset = definition.Display
		if cageOffset ~= nil then
			cageOffset = cageOffset.CageOffset
		end
		shouldTranslateCharacter = not cageOffset
		if shouldTranslateCharacter then
			local characterOffset = definition.Display
			if characterOffset ~= nil then
				characterOffset = characterOffset.CharacterOffset
			end
			shouldTranslateCharacter = not characterOffset
		end
	end
	if shouldTranslateCharacter then
		cosmetic.Character:TranslateBy(translation)
	end
	local shouldRepositionCharacter = not isInViewport
	if shouldRepositionCharacter then
		shouldRepositionCharacter = cosmetic.Character
	end
	if shouldRepositionCharacter then
		shouldRepositionCharacter = definition.Display
		if shouldRepositionCharacter ~= nil then
			shouldRepositionCharacter = shouldRepositionCharacter.CharacterOffset
		end
	end
	if shouldRepositionCharacter then
		local characterPosition = cosmetic.Position
		local halfCharacterHeight = cosmetic.Character:GetExtentsSize().Y / 2
		local targetCFrame = characterPosition + Vector3.new(0, halfCharacterHeight, 0)
		cosmetic.Character:SetPrimaryPartCFrame(targetCFrame:ToWorldSpace(definition.Display.CharacterOffset))
	end
	maid:GiveTask(function()
		cageMaid:DoCleaning()
		local shouldRestoreParent = isInViewport
		if shouldRestoreParent then
			shouldRestoreParent = cosmetic.Character
			if shouldRestoreParent ~= nil then
				shouldRestoreParent = shouldRestoreParent.Parent
			end
		end
		if shouldRestoreParent then
			cosmetic.Character.Parent = cosmetic.DisplayModel
		end
		local shouldResetCharacterPosition = not isInViewport
		if shouldResetCharacterPosition then
			shouldResetCharacterPosition = cosmetic.Character
			if shouldResetCharacterPosition ~= nil then
				shouldResetCharacterPosition = shouldResetCharacterPosition.Parent
			end
		end
		if shouldResetCharacterPosition then
			local character = cosmetic.Character
			local position = cosmetic.Position
			local halfCharacterHeight = cosmetic.Character:GetExtentsSize().Y / 2
			character:SetPrimaryPartCFrame(position + Vector3.new(0, halfCharacterHeight, 0))
		end
	end)
	return maid
end
function CosmeticCageDisplayController.createCage(
	self: CosmeticCageDisplayController,
	position: CFrame,
	displayModel: Model,
	color: Color3,
	id: string,
	scale: number
): (Model, any)
	local genericCage = Modding.resolveSingleton(GenericCage)
	RuntimeLib.try(function()
		genericCage = self.cosmeticDecoratorModule:resolveCage(id)
	end, function(_) end)
	local maid = Maid.new()
	local cage = genericCage:createCage(maid, position, displayModel, color, true, id)
	cage:ScaleTo(scale)
	return { cage, maid }
end
Reflect.defineMetadata(CosmeticCageDisplayController, "identifier", "Yww")
Reflect.defineMetadata(CosmeticCageDisplayController, "flamework:parameters", { "Jkb" })
Reflect.defineMetadata(CosmeticCageDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticCageDisplayController, "MJo", CosmeticDisplayDecorator, { "Cage" })
Reflect.decorate(CosmeticCageDisplayController, "$:flamework@Controller", Controller, {})
return {
	["CosmeticCageDisplayController"] = CosmeticCageDisplayController,
}
