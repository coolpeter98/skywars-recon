-- PurchaseController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = FlameworkCore.Controller
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonBundleProductId = GameProduct.CurrentSeasonBundleProductId
local CurrentSeasonProductId = GameProduct.CurrentSeasonProductId
local DeveloperProducts = GameProduct.DeveloperProducts
local PrimedCosmeticProducts = GameProduct.PrimedCosmeticProducts
local PurchaseType = GameProduct.PurchaseType
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local MarketplaceService: MarketplaceService = Services.MarketplaceService
local Players: Players = Services.Players
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ConfirmationScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "confirmation", "confirmation-screen").ConfirmationScreen
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GemsUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "gems", "gems-util").GemsUtil
local CurrentSeason = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeason

local PurchaseController = setmetatable({}, {
	["__tostring"] = function()
		return "PurchaseController"
	end
})
type PurchaseController = typeof(PurchaseController)
PurchaseController.__index = PurchaseController

function PurchaseController.new(...): PurchaseController
	local self = setmetatable({}, PurchaseController)
	return self:constructor(...) or self
end

function PurchaseController.constructor(_)
end

function PurchaseController.onStart(_)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, productId, purchased)
		local developerProduct = DeveloperProducts[productId]
		if developerProduct and developerProduct.Crate ~= nil then
			return nil
		end
		if purchased then
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Stats.LEVEL_UP, {
				["Volume"] = 0.8
			})
			Flamework.resolveDependency("qmA"):playPurchase()
		end
	end)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, _, purchased)
		if purchased then
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Stats.LEVEL_UP, {
				["Volume"] = 0.8
			})
			Flamework.resolveDependency("qmA"):playPurchase()
		end
	end)
end

function PurchaseController.canPurchasePrimedCosmetic(self: PurchaseController, cosmeticId, primedCosmeticType, purchaseType): boolean
	return self:canPurchase(PrimedCosmeticProducts[primedCosmeticType], purchaseType, cosmeticId)
end

function PurchaseController.canPurchase(self: PurchaseController, gameProductId, _, cosmeticId): boolean
	local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(gameProductId)
	if gameProduct.OneTimePurchase and self:ownsProduct(gameProduct.ProductId) then
		return false
	else
		local ownsCurrentSeasonPass = GlobalStore:getState().Profile.Season.OwnedPasses[CurrentSeason] ~= nil
		if (gameProduct.ProductId == CurrentSeasonProductId or gameProduct.ProductId == CurrentSeasonBundleProductId) and ownsCurrentSeasonPass then
			return false
		elseif gameProduct.Gambling and not Flamework.resolveDependency("D8k"):allowsGambling() then
			return false
		else
			return (not gameProduct.PrimedCosmeticType or cosmeticId and not Flamework.resolveDependency("Ggz"):ownsCosmetic(cosmeticId)) and true or false
		end
	end
end

function PurchaseController.promptPrimedCosmeticPurchase(self: PurchaseController, cosmeticId, primedCosmeticType, purchaseType): boolean
	return self:promptPurchase(PrimedCosmeticProducts[primedCosmeticType], purchaseType, cosmeticId)
end

function PurchaseController.promptPurchase(self: PurchaseController, gameProductId, purchaseType, cosmeticId): boolean
	if not self:canPurchase(gameProductId, purchaseType, cosmeticId) then
		return false
	end
	Flamework.resolveDependency("MMv"):tryLeaveQueue()
	local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(gameProductId)
	if gameProduct.PrimedCosmeticType and cosmeticId then
		Events.PrimeCosmeticPurchase:fire(cosmeticId)
	end
	if purchaseType == PurchaseType.Gems then
		self:promptPurchaseWithGems(gameProduct)
	elseif gameProduct.GamepassId then
		MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gameProduct.GamepassId)
	elseif gameProduct.DeveloperProductId then
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, gameProduct.DeveloperProductId)
	end
	return true
end

function PurchaseController.promptPurchaseWithGems(self: PurchaseController, gameProduct)
	if gameProduct.PriceInGems == nil then
		return nil
	end
	if not Flamework.resolveDependency("Eq8"):hasEnoughGems(gameProduct.PriceInGems) then
		self:promptPurchaseGems(gameProduct)
		return nil
	end
	local confirmationScreen = nil
	confirmationScreen = Flamework.resolveDependency("lB5"):open(ConfirmationScreen, {
		["Text"] = ("Would you like to purchase: %*?"):format(gameProduct.DisplayName),
		["OnConfirm"] = function()
			return Events.PurchaseProduct:fire(gameProduct.ProductId)
		end,
		["IsOpen"] = function()
			return confirmationScreen:isOpen()
		end,
		["Close"] = function()
			return confirmationScreen:close()
		end
	})
end

function PurchaseController.promptPurchaseGems(self: PurchaseController, gameProduct)
	local gems = GlobalStore:getState().Profile.Gems
	local requiredGemsProduct = GemsUtil.getRequiredGemsProduct(gems, gameProduct.PriceInGems)
	local gemsProduct = Flamework.resolveDependency("1EA"):getGameProduct(requiredGemsProduct)
	local confirmationScreen = nil
	confirmationScreen = Flamework.resolveDependency("lB5"):open(ConfirmationScreen, {
		["Text"] = ("You do not have enough gems for %*. Would you like to purchase %*?"):format(gameProduct.DisplayName, gemsProduct.DisplayName),
		["OnConfirm"] = function()
			return self:promptPurchase(gemsProduct.ProductId, PurchaseType.Robux)
		end,
		["IsOpen"] = function()
			return confirmationScreen:isOpen()
		end,
		["Close"] = function()
			return confirmationScreen:close()
		end
	})
end

function PurchaseController.getQuantity(_, purchaseType): number
	local count = 0
	local ownedProducts = {}
	for index, product in GlobalStore:getState().Profile.OwnedProducts do
		local _ = index - 1
		if product.Type == purchaseType == true then
			count = count + 1
			ownedProducts[count] = product
		end
	end
	return #ownedProducts
end

function PurchaseController.ownsProduct(self: PurchaseController, purchaseType): boolean
	return self:getQuantity(purchaseType) > 0
end

Reflect.defineMetadata(PurchaseController, "identifier", "YOK")
Reflect.defineMetadata(PurchaseController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PurchaseController, "$:flamework@Controller", Controller, {})
return {
	["PurchaseController"] = PurchaseController
}
