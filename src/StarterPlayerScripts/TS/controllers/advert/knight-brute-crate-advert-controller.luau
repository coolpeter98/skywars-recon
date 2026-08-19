-- KnightBruteCrateAdvertController

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
local Controller = FlameworkCore.Controller
local CollectionService: CollectionService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).CollectionService
local CrateUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crate-util").CrateUtil
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local ItemMaterial =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local _ = ProductId.KNIGHT_BRUTE_CRATE_1
local knightBruteCrateColor: Color3 = Crates.KnightBruteCrate.Color

local KnightBruteCrateAdvertController = setmetatable({}, {
	["__tostring"] = function()
		return "KnightBruteCrateAdvertController"
	end,
})
KnightBruteCrateAdvertController.__index = KnightBruteCrateAdvertController

function KnightBruteCrateAdvertController.new(...)
	local self = KnightBruteCrateAdvertController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function KnightBruteCrateAdvertController.constructor(_) end

function KnightBruteCrateAdvertController.create(advertUtil, rootCFrame: CFrame, parent: Instance)
	local advertModel = advertUtil:createAdvertModel(parent)
	local platformL = Flamework.resolveDependency("VpL"):createPlatformL(rootCFrame, knightBruteCrateColor, advertModel)
	Flamework.resolveDependency("VpL"):createBackdrop(rootCFrame, platformL, knightBruteCrateColor, advertModel)
	local primaryCFrame = platformL.PrimaryPart.CFrame
	local halfHeight = platformL.PrimaryPart.Size.Y / 2
	local advertPosition = primaryCFrame + Vector3.new(0, halfHeight, 0)
	advertUtil:createCrate("KnightBruteCrate", advertPosition, advertModel)
	advertUtil:createCharacters(advertPosition, advertModel)
	advertUtil:createBillboard(advertPosition, advertModel)
end

function KnightBruteCrateAdvertController.createAdvertModel(_, parent: Instance): Model
	local advertModel = Instance.new("Model")
	advertModel.Name = "CrateAdvert"
	advertModel.Parent = parent
	return advertModel
end

function KnightBruteCrateAdvertController.createCrate(_, crateId: string, position: CFrame, parent: Instance): Model
	local crateModel = CrateUtil.createCrateModel(crateId)
	crateModel.Plate:Destroy()
	crateModel.Camera:Destroy()
	crateModel:ScaleTo(3)
	local boxBottomY = crateModel.Box.Position.Y - crateModel.Box.Size.Y / 2
	local rootPartHeight = crateModel.RootPart.Size.Y
	local heightOffset = rootPartHeight - (crateModel.RootPart.Position.Y + rootPartHeight / 2 - boxBottomY)
	crateModel:SetPrimaryPartCFrame(
		position:ToWorldSpace(CFrame.new(0, rootPartHeight / 2 - heightOffset, -7.5))
			* CFrame.Angles(0, 3.141592653589793, 0)
	)
	crateModel:SetAttribute(Attribute.CrateId, crateId)
	crateModel.Parent = parent
	CollectionService:AddTag(crateModel, "crate_advert")
	return crateModel
end

function KnightBruteCrateAdvertController.createCharacters(_, position: CFrame, parent: Instance)
	local bundlePosition = position:ToWorldSpace(CFrame.new(0, 0, 6))
	local bundlePlatform = Flamework.resolveDependency("VpL")
		:createPlatformS(bundlePosition, knightBruteCrateColor, parent)
	local characterDisplay = Flamework.resolveDependency("Wyw")
	local bundleDisplayConfig = {
		["Position"] = bundlePosition:ToWorldSpace(CFrame.new(0, bundlePlatform:GetExtentsSize().Y, 0))
			* CFrame.Angles(0, 0.39269908169872414, 0),
		["Parent"] = parent,
		["Scale"] = 3.5,
		["BundleId"] = "KnightBrute",
		["Animation"] = {
			["Idle"] = nil,
			["IdleOverride"] = true,
			["Idle"] = RobloxAnimation.ADVERT_IDLE_2,
		},
		["Materials"] = {
			["Sword"] = ItemMaterial.Diamond,
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	characterDisplay:createBundleDisplay(bundleDisplayConfig)
	local characterDisplay = Flamework.resolveDependency("Wyw")
	local rightSwordCarouselConfig = {
		["Position"] = position:ToWorldSpace(CFrame.new(12, 0, 0)) * CFrame.Angles(0, 0.19634954084936207, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.SwordChainsaw,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordBoxingGloves,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordClaws,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Iron,
		["Animation"] = {
			["Idle"] = RobloxAnimation.IDLE_DEFAULT,
		},
	}
	characterDisplay:createCarouselDisplay(rightSwordCarouselConfig)
	local characterDisplay = Flamework.resolveDependency("Wyw")
	local leftSwordCarouselConfig = {
		["Position"] = position:ToWorldSpace(CFrame.new(-12, 0, 0)) * CFrame.Angles(0, -0.19634954084936207, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.SwordKnockyaOut3310,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordBaseballBat,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordGolfClub,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateKnightBrute,
				},
				{
					["Id"] = CosmeticId.LeggingsKnightBrute,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Iron,
		["Animation"] = {
			["Idle"] = RobloxAnimation.IDLE_DEFAULT,
		},
	}
	characterDisplay:createCarouselDisplay(leftSwordCarouselConfig)
	local pickaxePosition = position:ToWorldSpace(CFrame.new(16.5, 0, -7.5))
	local pickaxePlatform = Flamework.resolveDependency("VpL")
		:createPlatformXXS(pickaxePosition, knightBruteCrateColor, parent)
	local characterDisplay = Flamework.resolveDependency("Wyw")
	local pickaxeCarouselConfig = {
		["Position"] = nil,
		["Parent"] = nil,
		["Scale"] = 2,
		["DisableCharacter"] = true,
		["Cosmetics"] = nil,
		["DefaultMaterial"] = nil,
		["Position"] = pickaxePosition:ToWorldSpace(CFrame.new(0, pickaxePlatform:GetExtentsSize().Y + 2.5, 0)),
		["Parent"] = parent,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.PickaxeToucan,
				},
			},
			{
				{
					["Id"] = CosmeticId.PickaxeHoned,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	characterDisplay:createCarouselDisplay(pickaxeCarouselConfig)
	local helmetPosition = position:ToWorldSpace(CFrame.new(-16.5, 0, -7.5))
	local helmetPlatform = Flamework.resolveDependency("VpL")
		:createPlatformXXS(helmetPosition, knightBruteCrateColor, parent)
	local characterDisplay = Flamework.resolveDependency("Wyw")
	local helmetCarouselConfig = {
		["Position"] = nil,
		["Parent"] = nil,
		["Scale"] = 2,
		["DisableCharacter"] = true,
		["Cosmetics"] = nil,
		["DefaultMaterial"] = nil,
		["Position"] = helmetPosition:ToWorldSpace(CFrame.new(0, helmetPlatform:GetExtentsSize().Y + 2.5, 0)),
		["Parent"] = parent,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.HelmetWizardHat,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetBucket,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetFootball,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetTvHead,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetCrown,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	characterDisplay:createCarouselDisplay(helmetCarouselConfig)
end

function KnightBruteCrateAdvertController.createBillboard(_, position: CFrame, parent: Instance)
	local billboardPosition = position:ToWorldSpace(CFrame.new(0, 2.5, -5.5 * BlockConstants.BLOCK_SIZE))
	local billboardPart = Flamework.resolveDependency("B4z"):createBillboardGuiPart(billboardPosition, parent)
	Flamework.resolveDependency("B4z"):mountBillboardGui({
		["Text"] = {
			{
				["Text"] = "KNIGHT BRUTE CRATE",
				["TextSize"] = 48,
				["Bold"] = true,
			},
		},
	}, billboardPart)
	local promptConfig = {
		["ObjectText"] = "Knight Brute Crate",
		["ActionText"] = "Purchase",
		["Triggered"] = nil,
		["Triggered"] = function()
			return Flamework.resolveDependency("vbD"):openShop({
				["ProductType"] = "Crate",
				["CrateId"] = "KnightBruteCrate",
				["Quantity"] = 3,
			})
		end,
	}
	Flamework.resolveDependency("B4z"):createProximityPrompt(promptConfig, billboardPart)
end

Reflect.defineMetadata(KnightBruteCrateAdvertController, "identifier", "kwK")
Reflect.decorate(KnightBruteCrateAdvertController, "$:flamework@Controller", Controller, {})

return {
	["KnightBruteCrateAdvertController"] = KnightBruteCrateAdvertController,
}
