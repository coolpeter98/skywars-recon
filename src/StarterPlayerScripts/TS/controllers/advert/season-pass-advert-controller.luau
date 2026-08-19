-- SeasonPassAdvertController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local BlockConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local RobloxAnimation = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local ItemMaterial = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local TIER_SIX_COLOR = Color.Level.TierSix

type SeasonPassAdvertController = {
	maid: any,
}

local SeasonPassAdvertController = setmetatable({}, {
	["__tostring"] = function()
		return "SeasonPassAdvertController"
	end
})
SeasonPassAdvertController.__index = SeasonPassAdvertController

function SeasonPassAdvertController.new(...)
	local self = setmetatable({}, SeasonPassAdvertController)
	return self:constructor(...) or self
end

function SeasonPassAdvertController.constructor(self: SeasonPassAdvertController)
	self.maid = Maid.new()
end

function SeasonPassAdvertController.create(self: SeasonPassAdvertController, anchorCFrame: CFrame, parent: Instance)
	local advertModel = self:createAdvertModel(parent)
	local platformL = Flamework.resolveDependency("VpL"):createPlatformL(anchorCFrame, TIER_SIX_COLOR, advertModel)
	Flamework.resolveDependency("VpL"):createBackdrop(anchorCFrame, platformL, TIER_SIX_COLOR, advertModel)
	if Flamework.resolveDependency("9ll"):hasUpdated({ "GAME_PRODUCT_SEASON_PASS_3" }) then
		local _ = anchorCFrame:ToWorldSpace(CFrame.new(platformL.PrimaryPart.Size.X / 2 - 3, 16, platformL.PrimaryPart.Size.Z / 4)) * CFrame.Angles(-0.10471975511965978, 3.141592653589793, 0.10471975511965978)
	end
	local platformCFrame = platformL.PrimaryPart.CFrame
	local halfHeight = platformL.PrimaryPart.Size.Y / 2
	local centerPosition = platformCFrame + Vector3.new(0, halfHeight, 0)
	self:createCharacters(centerPosition, advertModel)
	self:createBillboard(centerPosition, advertModel)
end

function SeasonPassAdvertController.createAdvertModel(self: SeasonPassAdvertController, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "SeasonPassAdvert"
	model.Parent = parent
	self.maid:GiveTask(model)
	return model
end

function SeasonPassAdvertController.createCharacters(_, anchorCFrame: CFrame, parent: Instance)
	local deathKnightPosition = anchorCFrame:ToWorldSpace(CFrame.new(0, 0, 6))
	local deathKnightPlatform = Flamework.resolveDependency("VpL"):createPlatformS(deathKnightPosition, TIER_SIX_COLOR, parent)
	local bundleDisplayService = Flamework.resolveDependency("Wyw")
	local deathKnightConfig = {
		["Position"] = deathKnightPosition:ToWorldSpace(CFrame.new(0, deathKnightPlatform:GetExtentsSize().Y, 0)) * CFrame.Angles(0, 0.39269908169872414, 0),
		["Parent"] = parent,
		["Scale"] = 3.5,
		["BundleId"] = "DeathKnight",
		["Materials"] = {
			["Sword"] = ItemMaterial.Gold
		},
		["DefaultMaterial"] = ItemMaterial.Diamond,
		["OnlySword"] = true,
		["DisableCage"] = true,
		["Animation"] = {
			["Idle"] = nil,
			["IdleOverride"] = true,
			["Idle"] = RobloxAnimation.ADVERT_IDLE_4
		}
	}
	bundleDisplayService:createBundleDisplay(deathKnightConfig)
	local bundleDisplayService = Flamework.resolveDependency("Wyw")
	local mayanWarriorConfig = {
		["Position"] = anchorCFrame:ToWorldSpace(CFrame.new(13.5, 0, 3)) * CFrame.Angles(0, 1.3744467859455345, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["BundleId"] = "MayanWarrior",
		["Materials"] = {
			["Sword"] = ItemMaterial.Onyx
		},
		["DefaultMaterial"] = ItemMaterial.Gold,
		["OnlySword"] = true,
		["DisableCage"] = true,
		["Animation"] = {
			["Idle"] = nil,
			["IdleOverride"] = true,
			["Idle"] = RobloxAnimation.ADVERT_IDLE_5
		}
	}
	bundleDisplayService:createBundleDisplay(mayanWarriorConfig)
	local bundleDisplayService = Flamework.resolveDependency("Wyw")
	local nordicWarriorConfig = {
		["Position"] = anchorCFrame:ToWorldSpace(CFrame.new(-16, 0, 3)) * CFrame.Angles(0, -0.39269908169872414, 0),
		["Parent"] = parent,
		["Scale"] = 2.5,
		["BundleId"] = "NordicWarrior",
		["Materials"] = {
			["Sword"] = ItemMaterial.Onyx
		},
		["DefaultMaterial"] = ItemMaterial.Iron,
		["OnlySword"] = true,
		["DisableCage"] = true,
		["Animation"] = {
			["Idle"] = RobloxAnimation.IDLE_DEFAULT
		}
	}
	bundleDisplayService:createBundleDisplay(nordicWarriorConfig)
	local featuredCosmetics = {
		CosmeticId.KillEffectGateOfBabylon,
		CosmeticId.PickaxeLight,
		CosmeticId.SwordRoyalBlade,
		CosmeticId.SwordBruteSawblade,
		CosmeticId.KillEffectSlimeCube,
		CosmeticId.PickaxeBooster
	}
	local cosmeticOffset = 0
	local function createCosmeticDisplay(cosmeticId, index)
		local cosmetic = Cosmetics[cosmeticId]
		local isKillEffect = cosmetic.Type == "KillEffect"
		local startOffset = (#featuredCosmetics - 1) * -3.5
		local indexOffset = 7 * index
		cosmeticOffset = cosmeticOffset + (index < #featuredCosmetics / 2 and 1 or (index == #featuredCosmetics / 2 and 0 or -1))
		local cosmeticPosition = anchorCFrame:ToWorldSpace(CFrame.new(-(startOffset + indexOffset), 0, cosmeticOffset + -8))
		local cosmeticPlatform = Flamework.resolveDependency("VpL"):createPlatformXXS(cosmeticPosition, TIER_SIX_COLOR, parent)
		Flamework.resolveDependency("Wyw"):createDisplay({
			["Position"] = cosmeticPosition:ToWorldSpace(CFrame.new(0, cosmeticPlatform:GetExtentsSize().Y + (isKillEffect and 0 or 2.5), 0)),
			["Parent"] = parent,
			["Scale"] = cosmetic.Type == "KillEffect" and 0.5 or 2,
			["DisableCharacter"] = not isKillEffect,
			["Cosmetics"] = {
				{
					["Id"] = cosmeticId,
					["Material"] = ItemMaterial.Onyx
				}
			}
		})
	end
	for index, cosmeticId in featuredCosmetics do
		createCosmeticDisplay(cosmeticId, index - 1, featuredCosmetics)
	end
end

function SeasonPassAdvertController.createBillboard(_, anchorCFrame: CFrame, parent: Instance)
	local billboardPosition = anchorCFrame:ToWorldSpace(CFrame.new(0, 3.5, -5.5 * BlockConstants.BLOCK_SIZE))
	local billboardGuiPart = Flamework.resolveDependency("B4z"):createBillboardGuiPart(billboardPosition, parent)
	Flamework.resolveDependency("B4z"):mountBillboardGui({
		["Text"] = {
			{
				["Text"] = "SEASON 3",
				["TextSize"] = 48,
				["Bold"] = true
			}
		}
	}, billboardGuiPart)
	local promptConfig = {
		["ObjectText"] = "Season Pass",
		["ActionText"] = "Open",
		["Triggered"] = nil,
		["Triggered"] = function()
			Flamework.resolveDependency("vbD"):openShop({
				["ProductType"] = "SeasonPass"
			})
		end
	}
	Flamework.resolveDependency("B4z"):createProximityPrompt(promptConfig, billboardGuiPart)
end

Reflect.defineMetadata(SeasonPassAdvertController, "identifier", "aBK")
Reflect.decorate(SeasonPassAdvertController, "$:flamework@Controller", Controller, {})
return {
	["SeasonPassAdvertController"] = SeasonPassAdvertController
}
