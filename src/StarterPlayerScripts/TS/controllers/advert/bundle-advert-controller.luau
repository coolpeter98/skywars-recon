-- BundleAdvertController

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
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProduct.GameProducts
local ProductId = GameProduct.ProductId
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local ItemMaterial =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local BundleGreen = Color.Shop.BundleGreen

type BundleAdvertController = {
	maid: any,
	create: (self: BundleAdvertController, productId: any, cframe: CFrame, parent: Instance) -> (),
	createAdvertModel: (self: BundleAdvertController, parent: Instance) -> Model,
	createPlatform: (self: BundleAdvertController, cframe: CFrame, color: Color3, parent: Instance) -> Model,
	createBundle: (self: BundleAdvertController, bundle: any, position: CFrame, parent: Instance) -> Model,
	createBillboard: (self: BundleAdvertController, gameProduct: any, position: CFrame, parent: Instance) -> (),
}

local BundleAdvertController = setmetatable({}, {
	["__tostring"] = function()
		return "BundleAdvertController"
	end,
})
BundleAdvertController.__index = BundleAdvertController
function BundleAdvertController.new(...)
	local self = setmetatable({}, BundleAdvertController)
	return self:constructor(...) or self
end
function BundleAdvertController.constructor(self)
	self.maid = Maid.new()
end
function BundleAdvertController.create(self, productId, cframe: CFrame, parent: Instance)
	local gameProduct = GameProducts[productId]
	if not gameProduct.BundleId then
		return nil
	end
	local bundle = Bundles[gameProduct.BundleId]
	local model = self:createAdvertModel(parent)
	local platform = self:createPlatform(cframe, BundleGreen, model)
	Flamework.resolveDependency("VpL"):createBackdrop(cframe, platform, BundleGreen, model)
	ReplicatedStorage.Misc.Logos:FindFirstChild(("SkyText%*"):format(bundle.BundleId))
	if
		productId == ProductId.PLASMA_TITAN_BUNDLE
		and Flamework.resolveDependency("9ll"):hasUpdated({ "GAME_PRODUCT_PLASMA_TITAN_BUNDLE" })
	then
		local _ = cframe:ToWorldSpace(
			CFrame.new(platform.PrimaryPart.Size.X / 2 - 3, 16, platform.PrimaryPart.Size.Z / 4)
		) * CFrame.Angles(-0.10471975511965978, 3.141592653589793, 0.10471975511965978)
	end
	local platformCframe = platform.PrimaryPart.CFrame
	local halfHeight = platform.PrimaryPart.Size.Y / 2
	local bundlePosition = platformCframe + Vector3.new(0, halfHeight, 0)
	self:createBundle(bundle, bundlePosition, model)
	self:createBillboard(gameProduct, bundlePosition, model)
end
function BundleAdvertController.createAdvertModel(self, parent: Instance)
	local model = Instance.new("Model")
	model.Name = "BundleAdvert"
	model.Parent = parent
	self.maid:GiveTask(model)
	return model
end
function BundleAdvertController.createPlatform(_, cframe: CFrame, color: Color3, parent: Instance)
	local platform = ReplicatedStorage.Misc.AdvertPlatformM:Clone()
	local halfHeight = platform.PrimaryPart.Size.Y / 2
	platform:SetPrimaryPartCFrame(cframe + Vector3.new(0, halfHeight, 0))
	platform.Neon.Color = color
	platform.Neon.Transparency = 0.5
	platform.Parent = parent
	return platform
end
function BundleAdvertController.createBundle(_, bundle, position: CFrame, parent: Instance)
	return Flamework.resolveDependency("Wyw"):createBundleDisplay({
		["Position"] = nil,
		["Parent"] = nil,
		["BundleId"] = nil,
		["Materials"] = nil,
		["OnlySword"] = true,
		["Scale"] = 1.5,
		["Animation"] = nil,
		["Position"] = position,
		["Parent"] = parent,
		["BundleId"] = bundle.BundleId,
		["Materials"] = bundle.BundleId == "PlasmaTitan" and {
			["Helmet"] = ItemMaterial.Iron,
			["Chestplate"] = ItemMaterial.Iron,
			["Leggings"] = ItemMaterial.Iron,
		} or nil,
		["Animation"] = {
			["Idle"] = RobloxAnimation.IDLE_DEFAULT,
		},
	}).DisplayModel
end
function BundleAdvertController.createBillboard(_, gameProduct, position: CFrame, parent: Instance)
	local billboardCframe = position:ToWorldSpace(CFrame.new(0, 2.5, -5.5 * BlockConstants.BLOCK_SIZE))
	local billboardPart = Flamework.resolveDependency("B4z"):createBillboardGuiPart(billboardCframe, parent)
	local advertBillboardController = Flamework.resolveDependency("B4z")
	local mountOptions = {
		["Text"] = {
			{
				["Text"] = nil,
				["TextSize"] = 48,
				["Bold"] = true,
				["Text"] = string.upper(gameProduct.DisplayName),
			},
		},
	}
	advertBillboardController:mountBillboardGui(mountOptions, billboardPart)
	Flamework.resolveDependency("B4z"):createProximityPrompt({
		["ObjectText"] = nil,
		["ActionText"] = "Purchase",
		["Triggered"] = nil,
		["ObjectText"] = gameProduct.DisplayName,
		["Triggered"] = function()
			return Flamework.resolveDependency("vbD"):openShop({
				["ProductType"] = "Bundle",
				["ProductId"] = nil,
				["PrimedCosmeticType"] = nil,
				["ProductId"] = gameProduct.ProductId,
			})
		end,
	}, billboardPart)
end
Reflect.defineMetadata(BundleAdvertController, "identifier", "owr")
Reflect.decorate(BundleAdvertController, "$:flamework@Controller", Controller, {})
return {
	["BundleAdvertController"] = BundleAdvertController,
}
