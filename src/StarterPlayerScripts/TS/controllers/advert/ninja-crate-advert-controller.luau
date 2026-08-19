-- NinjaCrateAdvertController

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
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local _ = ProductId.NINJA_CRATE_1
local crateColor = Crates.NinjaCrate.Color
local NinjaCrateAdvertController = setmetatable({}, {
	["__tostring"] = function()
		return "NinjaCrateAdvertController"
	end,
})
NinjaCrateAdvertController.__index = NinjaCrateAdvertController
function NinjaCrateAdvertController.new(...)
	local class = NinjaCrateAdvertController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function NinjaCrateAdvertController.constructor(_) end
function NinjaCrateAdvertController.create(self, world, parent: Instance)
	local advertModel = self:createAdvertModel(parent)
	local platformL = Flamework.resolveDependency("VpL"):createPlatformL(world, crateColor, advertModel)
	Flamework.resolveDependency("VpL"):createBackdrop(world, platformL, crateColor, advertModel)
	local platformCFrame = platformL.PrimaryPart.CFrame
	local halfHeight = platformL.PrimaryPart.Size.Y / 2
	local cratePosition = platformCFrame + Vector3.new(0, halfHeight, 0)
	self:createCrate("NinjaCrate", cratePosition, advertModel)
	self:createCharacters(cratePosition, advertModel)
	self:createBillboard(cratePosition, advertModel)
end
function NinjaCrateAdvertController.createAdvertModel(_, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "CrateAdvert"
	model.Parent = parent
	return model
end
function NinjaCrateAdvertController.createCrate(_, crateId: string, position: CFrame, parent: Instance): Model
	local crateModel = CrateUtil.createCrateModel(crateId)
	crateModel.Plate:Destroy()
	crateModel.Camera:Destroy()
	crateModel:ScaleTo(3)
	local boxFloorY = crateModel.Box.Position.Y - crateModel.Box.Size.Y / 2
	local rootPartHeight = crateModel.RootPart.Size.Y
	local offsetY = rootPartHeight - (crateModel.RootPart.Position.Y + rootPartHeight / 2 - boxFloorY)
	crateModel:SetPrimaryPartCFrame(
		position:ToWorldSpace(CFrame.new(0, rootPartHeight / 2 - offsetY, -7.5))
			* CFrame.Angles(0, 3.141592653589793, 0)
	)
	crateModel:SetAttribute(Attribute.CrateId, crateId)
	crateModel.Parent = parent
	CollectionService:AddTag(crateModel, "crate_advert")
	return crateModel
end
function NinjaCrateAdvertController.createCharacters(_, position: CFrame, parent: Instance)
	local platformSPosition = position:ToWorldSpace(CFrame.new(0, 0, 6))
	local platformS = Flamework.resolveDependency("VpL"):createPlatformS(platformSPosition, crateColor, parent)
	local bundleDisplayFactory = Flamework.resolveDependency("Wyw")
	local bundleConfig = {
		["Position"] = platformSPosition:ToWorldSpace(CFrame.new(0, platformS:GetExtentsSize().Y, 0))
			* CFrame.Angles(0, 0.19634954084936207, 0),
		["Parent"] = parent,
		["Scale"] = 3.5,
		["BundleId"] = "Ninja",
		["Animation"] = {
			["Idle"] = nil,
			["IdleOverride"] = true,
			["Idle"] = RobloxAnimation.ADVERT_IDLE_1,
		},
		["Materials"] = {
			["Sword"] = ItemMaterial.Diamond,
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	bundleDisplayFactory:createBundleDisplay(bundleConfig)
	local rightCarouselDisplayFactory = Flamework.resolveDependency("Wyw")
	local rightCarouselConfig = {
		["Position"] = position:ToWorldSpace(CFrame.new(12, 0, 0)) * CFrame.Angles(0, 0.19634954084936207, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.SwordOkatana,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateNinja,
				},
				{
					["Id"] = CosmeticId.LeggingsNinja,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordSaiDagger,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateNinja,
				},
				{
					["Id"] = CosmeticId.LeggingsNinja,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Diamond,
		["Animation"] = {
			["Idle"] = RobloxAnimation.IDLE_DEFAULT,
		},
	}
	rightCarouselDisplayFactory:createCarouselDisplay(rightCarouselConfig)
	local leftCarouselDisplayFactory = Flamework.resolveDependency("Wyw")
	local leftCarouselConfig = {
		["Position"] = position:ToWorldSpace(CFrame.new(-12, 0, 0)) * CFrame.Angles(0, -0.19634954084936207, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.PickaxePlasma,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateNinja,
				},
				{
					["Id"] = CosmeticId.LeggingsNinja,
				},
			},
			{
				{
					["Id"] = CosmeticId.BowPurpleTactical,
					["Material"] = ItemMaterial.Gold,
				},
				{
					["Id"] = CosmeticId.ChestplateNinja,
				},
				{
					["Id"] = CosmeticId.LeggingsNinja,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Diamond,
		["Animation"] = {
			["Idle"] = nil,
			["IdleOverride"] = true,
			["Idle"] = RobloxAnimation.ADVERT_IDLE_6,
		},
	}
	leftCarouselDisplayFactory:createCarouselDisplay(leftCarouselConfig)
	local farRightPosition = position:ToWorldSpace(CFrame.new(16.5, 0, -7.5))
	local farRightPlatform = Flamework.resolveDependency("VpL"):createPlatformXXS(farRightPosition, crateColor, parent)
	local farRightCarouselDisplayFactory = Flamework.resolveDependency("Wyw")
	local farRightCarouselConfig = {
		["Position"] = nil,
		["Parent"] = nil,
		["Scale"] = 2,
		["DisableCharacter"] = true,
		["Cosmetics"] = nil,
		["DefaultMaterial"] = nil,
		["Position"] = farRightPosition:ToWorldSpace(CFrame.new(0, farRightPlatform:GetExtentsSize().Y + 2.5, 0)),
		["Parent"] = parent,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.SwordDualDaggers,
				},
			},
			{
				{
					["Id"] = CosmeticId.SwordHeavyHammers,
				},
			},
			{
				{
					["Id"] = CosmeticId.LeggingsRocketBoots,
				},
			},
			{
				{
					["Id"] = CosmeticId.ChestplateJetPack,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	farRightCarouselDisplayFactory:createCarouselDisplay(farRightCarouselConfig)
	local farLeftPosition = position:ToWorldSpace(CFrame.new(-16.5, 0, -7.5))
	local farLeftPlatform = Flamework.resolveDependency("VpL"):createPlatformXXS(farLeftPosition, crateColor, parent)
	local farLeftCarouselDisplayFactory = Flamework.resolveDependency("Wyw")
	local farLeftCarouselConfig = {
		["Position"] = nil,
		["Parent"] = nil,
		["Scale"] = 2,
		["DisableCharacter"] = true,
		["Cosmetics"] = nil,
		["DefaultMaterial"] = nil,
		["Position"] = farLeftPosition:ToWorldSpace(CFrame.new(0, farLeftPlatform:GetExtentsSize().Y + 2.5, 0)),
		["Parent"] = parent,
		["Cosmetics"] = {
			{
				{
					["Id"] = CosmeticId.LeggingsBeachSlippers,
				},
			},
			{
				{
					["Id"] = CosmeticId.ChestplateFloatie,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetFireFighter,
				},
			},
			{
				{
					["Id"] = CosmeticId.HelmetTopHat,
				},
			},
		},
		["DefaultMaterial"] = ItemMaterial.Onyx,
	}
	farLeftCarouselDisplayFactory:createCarouselDisplay(farLeftCarouselConfig)
end
function NinjaCrateAdvertController.createBillboard(_, position: CFrame, parent: Instance)
	local billboardPosition = position:ToWorldSpace(CFrame.new(0, 2.5, -5.5 * BlockConstants.BLOCK_SIZE))
	local billboardGuiPart = Flamework.resolveDependency("B4z"):createBillboardGuiPart(billboardPosition, parent)
	Flamework.resolveDependency("B4z"):mountBillboardGui({
		["Text"] = {
			{
				["Text"] = "NINJA CRATE",
				["TextSize"] = 48,
				["Bold"] = true,
			},
		},
	}, billboardGuiPart)
	local promptConfig = {
		["ObjectText"] = "Ninja Crate",
		["ActionText"] = "Purchase",
		["Triggered"] = nil,
		["Triggered"] = function()
			return Flamework.resolveDependency("vbD"):openShop({
				["ProductType"] = "Crate",
				["CrateId"] = "NinjaCrate",
				["Quantity"] = 3,
			})
		end,
	}
	Flamework.resolveDependency("B4z"):createProximityPrompt(promptConfig, billboardGuiPart)
end
Reflect.defineMetadata(NinjaCrateAdvertController, "identifier", "dQV")
Reflect.decorate(NinjaCrateAdvertController, "$:flamework@Controller", Controller, {})
return {
	["NinjaCrateAdvertController"] = NinjaCrateAdvertController,
}
