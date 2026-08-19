-- FeaturedCosmeticsController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkModule = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkModule.Reflect
local Flamework = FlameworkModule.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local SeededPoolModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "seeded-pool", "seeded-pool")
local Period = SeededPoolModule.Period
local SeededPool = SeededPoolModule.SeededPool
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local GameProductModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProductModule.GameProducts
local ProductId = GameProductModule.ProductId
local PurchaseType = GameProductModule.PurchaseType
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local Particles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "particle", "particles").Particles
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local FeaturedCosmeticsModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "shop", "featured-cosmetics")
local FeaturedCosmetics = FeaturedCosmeticsModule.FeaturedCosmetics
local FeaturedCosmeticsByProductId = FeaturedCosmeticsModule.FeaturedCosmeticsByProductId
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local AbTestType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "ab-test", "ab-test-type").AbTestType

type FeaturedCosmeticsController = {
	abTestController: any,
	cosmeticsController: any,
	purchaseController: any,
	roduxController: any,
	lobbyWorldController: any,
}

local FeaturedCosmeticsController = setmetatable({}, {
	["__tostring"] = function()
		return "FeaturedCosmeticsController"
	end,
})

FeaturedCosmeticsController.__index = FeaturedCosmeticsController

function FeaturedCosmeticsController.new(...)
	local class = FeaturedCosmeticsController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function FeaturedCosmeticsController.constructor(
	self: FeaturedCosmeticsController,
	abTestController,
	cosmeticsController,
	purchaseController,
	roduxController,
	lobbyWorldController
)
	self.abTestController = abTestController
	self.cosmeticsController = cosmeticsController
	self.purchaseController = purchaseController
	self.roduxController = roduxController
	self.lobbyWorldController = lobbyWorldController
end

function FeaturedCosmeticsController.onStart(self: FeaturedCosmeticsController)
	if not self.abTestController:isInTest(AbTestType.FeaturedCosmetics) then
		return nil
	end
	self.roduxController:awaitLoadedProfile()
	self.lobbyWorldController:bindWorldLoaded(function(world)
		local folder = Make("Folder", {
			["Name"] = "FeaturedCosmetics",
			["Parent"] = nil,
			["Parent"] = world,
		})
		self:createFeaturedCosmeticsDisplays(world.WorldData, folder)
	end)
end

function FeaturedCosmeticsController.getFeaturedCosmeticsByTier(self: FeaturedCosmeticsController, tier)
	local cosmetics = FeaturedCosmeticsByProductId[tier]
	if not cosmetics then
		return {}
	end
	local count = 0
	local result = {}
	for index, cosmetic in cosmetics do
		local _ = index - 1
		if not self.cosmeticsController:ownsCosmetic(cosmetic) == true then
			count = count + 1
			result[count] = cosmetic
		end
	end
	return result
end

function FeaturedCosmeticsController.createFeaturedCosmeticsDisplays(
	self: FeaturedCosmeticsController,
	worldData,
	folder
)
	local tier1Cosmetics = self:getFeaturedCosmeticsByTier(ProductId.FEATURED_COSMETIC_TIER_1)
	local tier2Cosmetics = self:getFeaturedCosmeticsByTier(ProductId.FEATURED_COSMETIC_TIER_2)
	local tier3Cosmetics = self:getFeaturedCosmeticsByTier(ProductId.FEATURED_COSMETIC_TIER_3)
	local tier1Active = SeededPool.getActiveRotation(tier1Cosmetics, Period.Daily, 1)
	local tier2Active = SeededPool.getActiveRotation(tier2Cosmetics, Period.Daily, 1)
	local tier3Active = SeededPool.getActiveRotation(tier3Cosmetics, Period.Daily, 1)
	local allCosmetics = {}
	local count = #allCosmetics
	local tier1Count = #tier1Active
	table.move(tier1Active, 1, tier1Count, count + 1, allCosmetics)
	local afterTier1 = count + tier1Count
	local tier3Count = #tier3Active
	table.move(tier3Active, 1, tier3Count, afterTier1 + 1, allCosmetics)
	local afterTier3 = afterTier1 + tier3Count
	table.move(tier2Active, 1, #tier2Active, afterTier3 + 1, allCosmetics)
	if not worldData:FindFirstChild("FeaturedCosmetics") then
		return nil
	end
	local centerCFrame: CFrame = worldData.FeaturedCosmetics.Value
	local offset = 0
	local function createDisplay(cosmeticId, index)
		local featuredCosmetic = FeaturedCosmetics[cosmeticId]
		local gameProduct = GameProducts[featuredCosmetic]
		local cosmetic = Cosmetics[cosmeticId]
		local rarity = CosmeticRarities[cosmetic.Rarity]
		local horizontalOffset = (#allCosmetics - 1) * -5
		local indexOffset = 10 * index
		offset = offset + (index < #allCosmetics / 2 and 1 or (index == #allCosmetics / 2 and 0 or -1))
		local position = centerCFrame:ToWorldSpace(CFrame.new(-(horizontalOffset + indexOffset), 1, offset))
		local platform = Flamework.resolveDependency("VpL"):createPlatformXXS(position, rarity.Color, folder)
		Make("SurfaceLight", {
			["Color"] = nil,
			["Brightness"] = 2,
			["Angle"] = 180,
			["Face"] = nil,
			["Parent"] = nil,
			["Color"] = rarity.Color,
			["Face"] = Enum.NormalId.Bottom,
			["Parent"] = platform:FindFirstChild("Neon"),
		})
		local part = Make("Part", {
			["Name"] = "Particle",
			["CFrame"] = nil,
			["Size"] = Vector3.new(6, 9, 6),
			["Anchored"] = true,
			["CanCollide"] = false,
			["Transparency"] = 1,
			["Parent"] = nil,
			["CFrame"] = position:ToWorldSpace(CFrame.new(0, platform:GetExtentsSize().Y + 4.5, 0)),
			["Parent"] = folder,
		})
		Flamework.resolveDependency("dm")
			:attachParticleEmitter(part, Particles.sparkle(ColorUtil.scaleValue(rarity.Color, 0.9)))
		Flamework.resolveDependency("Wyw"):createDisplay({
			["Position"] = nil,
			["Parent"] = nil,
			["Scale"] = 2.5,
			["DisableCharacter"] = true,
			["Cosmetics"] = nil,
			["Position"] = position:ToWorldSpace(CFrame.new(0, platform:GetExtentsSize().Y + 3, 0)),
			["Parent"] = folder,
			["Cosmetics"] = {
				{
					["Id"] = cosmeticId,
				},
			},
		})
		local billboardPart = Flamework.resolveDependency("B4z")
			:createBillboardGuiPart(position:ToWorldSpace(CFrame.new(0, -2, -4.5)), folder)
		Flamework.resolveDependency("B4z"):mountBillboardGui({
			["Text"] = nil,
			["PriceInRobux"] = nil,
			["ExpireTime"] = nil,
			["BackgroundTransparency"] = 0.4,
			["StudsOffset"] = Vector3.new(0, 0, 0),
			["Text"] = {
				{
					["Text"] = nil,
					["TextSize"] = 48,
					["Color"] = nil,
					["Bold"] = true,
					["Text"] = rarity.Id,
					["Color"] = rarity.Color,
				},
				{
					["Text"] = nil,
					["TextSize"] = 48,
					["Bold"] = true,
					["Text"] = cosmetic.Name,
				},
			},
			["PriceInRobux"] = gameProduct.PriceInRobux,
			["ExpireTime"] = SeededPool.getNextPeriodTime(Period.Daily),
		}, billboardPart)
		local proximityPrompt = Flamework.resolveDependency("B4z"):createProximityPrompt({
			["ObjectText"] = nil,
			["ActionText"] = "Buy",
			["MaxActivationDistance"] = 12,
			["Triggered"] = nil,
			["ObjectText"] = cosmetic.Name,
			["Triggered"] = function()
				if not self.purchaseController:promptPurchase(featuredCosmetic, PurchaseType.Robux, cosmeticId) then
					Flamework.resolveDependency("Odx"):displayNotification({
						["Title"] = "Purchase Failed",
						["Message"] = "You already own this item!",
						["Icon"] = nil,
						["IconColor"] = nil,
						["Duration"] = 2,
						["Icon"] = RobloxImage.Icon.EXCLAMATION,
						["IconColor"] = Color.Red,
					})
				end
			end,
		}, billboardPart)
		local billboardGui = billboardPart:FindFirstChildOfClass("BillboardGui")
		proximityPrompt.PromptShown:Connect(function()
			if billboardGui then
				billboardGui.Enabled = false
			end
		end)
		proximityPrompt.PromptHidden:Connect(function()
			if billboardGui then
				billboardGui.Enabled = true
			end
		end)
	end
	for index, cosmeticId in allCosmetics do
		createDisplay(cosmeticId, index - 1, allCosmetics)
	end
end

Reflect.defineMetadata(FeaturedCosmeticsController, "identifier", "00V")
Reflect.defineMetadata(FeaturedCosmeticsController, "flamework:parameters", {
	"yAg",
	"Ggz",
	"YOK",
	"zG",
	"Jj",
})
Reflect.defineMetadata(FeaturedCosmeticsController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(FeaturedCosmeticsController, "$:flamework@Controller", Controller, {})
return {
	["FeaturedCosmeticsController"] = FeaturedCosmeticsController,
}
