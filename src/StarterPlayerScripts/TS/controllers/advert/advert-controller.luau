-- AdvertController

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
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonProductId = GameProduct.CurrentSeasonProductId
local GameProducts = GameProduct.GameProducts
local ProductId = GameProduct.ProductId
local PurchaseType = GameProduct.PurchaseType
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local Bundles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "bundles", "bundles").Bundles
local BundleUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"bundles",
	"bundle-util"
).BundleUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

local ADVERT_PRODUCTS = {
	CurrentSeasonProductId,
	ProductId.PLASMA_TITAN_BUNDLE,
	ProductId.NINJA_CRATE_1,
	ProductId.KNIGHT_BRUTE_CRATE_1,
	ProductId.SPACEMAN,
	ProductId.DWARVEN,
}

type AdvertController = {
	purchaseController: any,
	constructor: (self: AdvertController, purchaseController: any) -> (),
	onStart: (self: AdvertController) -> (),
	shouldPrioritiseProduct: (self: AdvertController, productId: number) -> boolean,
	createAdverts: (self: AdvertController, worldData: Instance, advertsFolder: Folder) -> (),
	createPlatformL: (self: AdvertController, position: CFrame, color: Color3, parent: Instance) -> Instance,
	createPlatformS: (self: AdvertController, position: CFrame, color: Color3, parent: Instance) -> Instance,
	createPlatformXXS: (self: AdvertController, position: CFrame, color: Color3, parent: Instance) -> Instance,
	createBackdrop: (
		self: AdvertController,
		baseCFrame: CFrame,
		platform: Instance,
		color: Color3,
		parent: Instance
	) -> Instance,
	createSkyText: (
		self: AdvertController,
		template: Instance,
		baseCFrame: CFrame,
		platform: Instance,
		parent: Instance
	) -> Instance,
}

local AdvertController = setmetatable({}, {
	["__tostring"] = function()
		return "AdvertController"
	end,
})
AdvertController.__index = AdvertController
function AdvertController.new(...)
	local self = AdvertController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function AdvertController.constructor(self: AdvertController, purchaseController)
	self.purchaseController = purchaseController
end
function AdvertController.onStart(self: AdvertController)
	Flamework.resolveDependency("zG"):awaitLoadedProfile()
	Flamework.resolveDependency("Jj"):bindWorldLoaded(function(world)
		local advertsFolder = Make("Folder", {
			["Name"] = "Adverts",
			["Parent"] = nil,
			["Parent"] = world,
		})
		self:createAdverts(world.WorldData, advertsFolder)
	end)
end
function AdvertController.shouldPrioritiseProduct(self: AdvertController, productId: number): boolean
	local product = GameProducts[productId]
	if not product.BundleId then
		return self.purchaseController:canPurchase(productId, PurchaseType.Robux)
	end
	local bundle = Bundles[product.BundleId]
	local armourCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Armour")
	local weaponsCosmeticId = BundleUtil.getPackageCosmeticId(bundle.BundleId, "Weapons")
	return self.purchaseController:canPurchase(productId, PurchaseType.Robux, armourCosmeticId)
		or self.purchaseController:canPurchase(productId, PurchaseType.Robux, weaponsCosmeticId)
end
function AdvertController.createAdverts(self: AdvertController, worldData: Instance, advertsFolder: Folder)
	local allowsGambling = Flamework.resolveDependency("D8k"):allowsGambling()
	local eligibleCount = 0
	local eligibleProducts = {}
	for index, product in ADVERT_PRODUCTS do
		local _ = index - 1
		if (not GameProducts[product].Gambling or allowsGambling) == true then
			eligibleCount = eligibleCount + 1
			eligibleProducts[eligibleCount] = product
		end
	end
	local prioritisedCount = 0
	local prioritisedProducts = {}
	for index, product in eligibleProducts do
		local _ = index - 1
		if self:shouldPrioritiseProduct(product) == true then
			prioritisedCount = prioritisedCount + 1
			prioritisedProducts[prioritisedCount] = product
		end
	end
	local nonPrioritisedCount = 0
	local nonPrioritisedProducts = {}
	for index, product in eligibleProducts do
		local _ = index - 1
		if not self:shouldPrioritiseProduct(product) == true then
			nonPrioritisedCount = nonPrioritisedCount + 1
			nonPrioritisedProducts[nonPrioritisedCount] = product
		end
	end
	local orderedProducts = {}
	local orderedCount = #orderedProducts
	local prioritisedLength = #prioritisedProducts
	table.move(prioritisedProducts, 1, prioritisedLength, orderedCount + 1, orderedProducts)
	local nonPrioritisedOffset = orderedCount + prioritisedLength
	table.move(nonPrioritisedProducts, 1, #nonPrioritisedProducts, nonPrioritisedOffset + 1, orderedProducts)
	local locations = ArrayUtil.filterDefined({
		worldData:FindFirstChild("FrontRight"),
		worldData:FindFirstChild("FrontLeft"),
		worldData:FindFirstChild("MiddleRight"),
		worldData:FindFirstChild("MiddleLeft"),
		worldData:FindFirstChild("BackRight"),
		worldData:FindFirstChild("BackLeft"),
	})
	for i = 0, #orderedProducts - 1 do
		local product = orderedProducts[i + 1]
		local location = locations[i + 1]
		if location then
			local productDefinition = GameProducts[product]
			if productDefinition.SeasonPass then
				Flamework.resolveDependency("aBK"):create(location.Value, advertsFolder)
			elseif product == ProductId.NINJA_CRATE_1 then
				Flamework.resolveDependency("dQV"):create(location.Value, advertsFolder)
			elseif product == ProductId.KNIGHT_BRUTE_CRATE_1 then
				Flamework.resolveDependency("kwK"):create(location.Value, advertsFolder)
			elseif productDefinition.BundleId then
				Flamework.resolveDependency("owr"):create(product, location.Value, advertsFolder)
			else
				print((("Unknown Advert for ProductId %*"):format(product)))
			end
		end
	end
end
function AdvertController.createPlatformL(_, position: CFrame, color: Color3, parent: Instance): Instance
	local platform = ReplicatedStorage.Misc.AdvertPlatformL:Clone()
	local halfHeight = platform:GetExtentsSize().Y / 2
	platform:SetPrimaryPartCFrame(position + Vector3.new(0, halfHeight, 0))
	platform.Neon.Color = color
	platform.Neon.Transparency = 0.3
	platform.Parent = parent
	return platform
end
function AdvertController.createPlatformS(_, position: CFrame, color: Color3, parent: Instance): Instance
	local platform = ReplicatedStorage.Misc.AdvertPlatformS:Clone()
	local size, boundingBox = platform:GetBoundingBox()
	local offsetY = platform.PrimaryPart.CFrame.Y - (size.Y - boundingBox.Y / 2)
	platform:SetPrimaryPartCFrame(position + Vector3.new(0, offsetY, 0))
	platform.Neon.Color = color
	platform.Neon.Transparency = 0.3
	platform.Parent = parent
	return platform
end
function AdvertController.createPlatformXXS(_, position: CFrame, color: Color3, parent: Instance): Instance
	local platform = ReplicatedStorage.Misc.AdvertPlatformXXS:Clone()
	platform:ScaleTo(1.5)
	local size, boundingBox = platform:GetBoundingBox()
	local offsetY = platform.PrimaryPart.CFrame.Y - (size.Y - boundingBox.Y / 2)
	platform:SetPrimaryPartCFrame(position + Vector3.new(0, offsetY, 0))
	platform.Neon.Color = color
	platform.Neon.Transparency = 0.3
	platform.Parent = parent
	return platform
end
function AdvertController.createBackdrop(
	_,
	baseCFrame: CFrame,
	platform: Instance,
	color: Color3,
	parent: Instance
): Instance
	local backdrop = Instance.new("Part")
	local width = platform:GetExtentsSize().X + 6
	backdrop.Size = Vector3.new(width, 30, 0.1)
	backdrop.Transparency = 1
	backdrop.Anchored = true
	backdrop.CanCollide = false
	backdrop.CFrame = baseCFrame:ToWorldSpace(
		CFrame.new(0, backdrop.Size.Y / 2, platform:GetExtentsSize().Z / 2 + backdrop.Size.Z / 2 + 3)
	)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Parent = backdrop
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color.White
	frame.BorderSizePixel = 0
	frame.Parent = surfaceGui
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(color)
	gradient.Transparency = NumberSequence.new(0, 1)
	gradient.Rotation = 270
	gradient.Parent = frame
	local backGui = surfaceGui:Clone()
	backGui.Face = Enum.NormalId.Back
	backGui.Parent = backdrop
	local particlePart = Instance.new("Part")
	local particleWidth = backdrop.Size.X
	particlePart.Size = Vector3.new(particleWidth, 6, 3)
	particlePart.CFrame = backdrop.CFrame:ToWorldSpace(
		CFrame.new(0, backdrop.Size.Y / 2 - particlePart.Size.Y / 2, -particlePart.Size.Z / 2)
	)
	particlePart.Transparency = 1
	particlePart.Anchored = true
	particlePart.CanCollide = false
	particlePart.Parent = backdrop
	local particleEmitter = Flamework.resolveDependency("dm"):attachParticleEmitter(particlePart, {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 20,
		["Speed"] = 4,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 10,
		["Color"] = ColorUtil.getColorSequence({
			ColorUtil.scaleValue(color, 1.2),
			ColorUtil.scaleValue(color, 0.8),
			ColorUtil.scaleValue(color, 0.5),
		}),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.1, 0.35),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		["Lifetime"] = NumberRange.new(2, 10),
		["Rotation"] = NumberRange.new(0, 360),
	})
	particleEmitter.LockedToPart = false
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, 0),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	backdrop.Parent = parent
	return platform
end
function AdvertController.createSkyText(
	_,
	template: Instance,
	baseCFrame: CFrame,
	platform: Instance,
	parent: Instance
): Instance
	local skyText = template:Clone()
	skyText:PivotTo(
		baseCFrame:ToWorldSpace(CFrame.new(0, 30, platform.PrimaryPart.Size.Z / 2))
			* CFrame.Angles(0.39269908169872414, 3.141592653589793, 0)
	)
	skyText.Parent = parent
	return skyText
end
Reflect.defineMetadata(AdvertController, "identifier", "VpL")
Reflect.defineMetadata(AdvertController, "flamework:parameters", { "YOK" })
Reflect.defineMetadata(AdvertController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(AdvertController, "$:flamework@Controller", Controller, {})
return {
	["AdvertController"] = AdvertController,
}
