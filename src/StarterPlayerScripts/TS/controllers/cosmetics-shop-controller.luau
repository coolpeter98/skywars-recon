-- CosmeticsShopController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flamework.Reflect
local Flamework = flamework.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local CosmeticsShopScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "cosmetics-shop", "cosmetics-shop-screen").CosmeticsShopScreen
local ShopScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "shop", "shop-screen").ShopScreen

type CosmeticsShopController = {
	abTestController: any,
	matchmakingController: any,
	screenController: any,
	new: (...any) -> CosmeticsShopController,
	constructor: (
		self: CosmeticsShopController,
		abTestController: any,
		matchmakingController: any,
		screenController: any
	) -> (),
	openShop: (self: CosmeticsShopController, productData: any) -> (),
	closeShop: (self: CosmeticsShopController) -> (),
	toggleShop: (self: CosmeticsShopController) -> boolean,
	isOpen: (_: CosmeticsShopController) -> boolean,
}

local CosmeticsShopController = setmetatable({}, {
	__tostring = function()
		return "CosmeticsShopController"
	end,
})
CosmeticsShopController.__index = CosmeticsShopController

function CosmeticsShopController.new(...)
	local self = setmetatable({}, CosmeticsShopController)
	return self:constructor(...) or self
end

function CosmeticsShopController.constructor(
	self: CosmeticsShopController,
	abTestController: any,
	matchmakingController: any,
	screenController: any
)
	self.abTestController = abTestController
	self.matchmakingController = matchmakingController
	self.screenController = screenController
end

function CosmeticsShopController.openShop(self: CosmeticsShopController, productData: any)
	GlobalStore:dispatch({
		["type"] = "SetValue",
		["Key"] = "SelectedShopProductData",
		["Value"] = nil,
		["Value"] = productData == nil and {
			["ProductType"] = "undefined",
		} or productData,
	})
	if self.screenController:isOpen("Shop") then
		return nil
	end
	self.matchmakingController:tryLeaveQueue()
	self.screenController:open(ShopScreen, {})
end

function CosmeticsShopController.closeShop(self: CosmeticsShopController)
	self.screenController:close(CosmeticsShopScreen)
	self.screenController:close(ShopScreen)
end

function CosmeticsShopController.toggleShop(self: CosmeticsShopController)
	if self.screenController:isOpen("Shop") then
		self:closeShop()
		return false
	else
		self:openShop()
		return true
	end
end

function CosmeticsShopController.isOpen(_)
	return Flamework.resolveDependency("lB5"):isOpen("Shop")
end

Reflect.defineMetadata(CosmeticsShopController, "identifier", "vbD")
Reflect.defineMetadata(CosmeticsShopController, "flamework:parameters", { "yAg", "MMv", "lB5" })
Reflect.decorate(CosmeticsShopController, "$:flamework@Controller", Controller, {})
return {
	["CosmeticsShopController"] = CosmeticsShopController,
}
