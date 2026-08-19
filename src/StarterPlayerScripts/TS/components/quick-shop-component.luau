-- ShopComponent

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local t = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out", "prelude").t
local Component = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "components", "out").Component
local ProximityUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "proximity", "proximity-util").ProximityUtil
local QuickShopScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "quick-shop", "quick-shop-screen").QuickShopScreen
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local DisposableComponent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "components", "disposable-component").DisposableComponent

type ShopComponent = {
	instance: Model,
}

local ShopComponent = setmetatable({}, {
	["__tostring"] = function()
		return "ShopComponent"
	end,
	["__index"] = DisposableComponent,
})
ShopComponent.__index = ShopComponent

function ShopComponent.new(...)
	local selfClass = ShopComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function ShopComponent.constructor(self: ShopComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function ShopComponent.onStart(self: ShopComponent)
	self:createProximityPrompt()
end

function ShopComponent.createProximityPrompt(self: ShopComponent)
	local proximityPrompt: ProximityPrompt = ProximityUtil.createTriggeredPrompt("Quick Shop", "Open", function()
		Flamework.resolveDependency("lB5"):open(QuickShopScreen, {
			["Model"] = self.instance,
		})
	end)
	proximityPrompt.ClickablePrompt = ScreenUtil.isMobile()
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 19.5
	proximityPrompt.Parent = self.instance
end

Reflect.defineMetadata(ShopComponent, "identifier", "Kbo")
Reflect.defineMetadata(ShopComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ShopComponent, "$c:components@Component", Component, {
	{
		["tag"] = "quick_shop",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	}
})

return {
	["ShopComponent"] = ShopComponent,
}
