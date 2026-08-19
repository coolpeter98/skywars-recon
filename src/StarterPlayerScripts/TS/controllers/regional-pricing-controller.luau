-- RegionalPricingController

type RegionalPricingController = {
	new: (...any) -> RegionalPricingController,
	constructor: (self: RegionalPricingController) -> (),
	getPrimedCosmeticProduct: (self: RegionalPricingController, productId: string) -> any,
	getGameProduct: (self: RegionalPricingController, gameProduct: any) -> any,
}

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local PrimedCosmeticProducts = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"game-product",
	"game-product"
).PrimedCosmeticProducts
local RegionalPricingUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"regional-pricing",
	"regional-pricing-util"
).RegionalPricingUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore

local RegionalPricingController = setmetatable({}, {
	["__tostring"] = function()
		return "RegionalPricingController"
	end,
})

RegionalPricingController.__index = RegionalPricingController

function RegionalPricingController.new(...): RegionalPricingController
	local class = RegionalPricingController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function RegionalPricingController.constructor(self: RegionalPricingController) end

function RegionalPricingController.getPrimedCosmeticProduct(self: RegionalPricingController, productId: string)
	return self:getGameProduct(PrimedCosmeticProducts[productId])
end

function RegionalPricingController.getGameProduct(self: RegionalPricingController, gameProduct)
	local countryHistory = GlobalStore:getState().Profile.CountryHistory
	return RegionalPricingUtil.getGameProduct(gameProduct, countryHistory)
end

Reflect.defineMetadata(RegionalPricingController, "identifier", "1EA")
Reflect.decorate(RegionalPricingController, "$:flamework@Controller", Controller, {})

return {
	["RegionalPricingController"] = RegionalPricingController,
}
