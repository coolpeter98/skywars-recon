-- ShopComponent

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
local t = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out",
	"prelude"
).t
local Component = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"components",
	"out"
).Component
local ProximityUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "proximity", "proximity-util").ProximityUtil
local ShopType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop").ShopType
local BlacksmithShopScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"blacksmith-shop",
	"blacksmith-shop-screen"
).BlacksmithShopScreen
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local WizardShopScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "wizard-shop", "wizard-shop-screen").WizardShopScreen
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type ShopComponent = {
	instance: Model,
	shopType: string,
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
	self.shopType = self.instance.Name
	self:createProximityPrompt()
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end
end

function ShopComponent.createProximityPrompt(self: ShopComponent)
	local prompt: ProximityPrompt = ProximityUtil.createTriggeredPrompt(self.shopType, "Open", function()
		if self.shopType == ShopType.Blacksmith then
			Flamework.resolveDependency("lB5"):open(BlacksmithShopScreen, {})
		elseif self.shopType == ShopType.Merchant then
			Flamework.resolveDependency("lB5"):open(WizardShopScreen, {})
		end
	end)
	prompt.ClickablePrompt = ScreenUtil.isMobile()
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 19.5
	prompt.Parent = self.instance
end

Reflect.defineMetadata(ShopComponent, "identifier", "7bZ")
Reflect.defineMetadata(ShopComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ShopComponent, "$c:components@Component", Component, {
	{
		["tag"] = "shop",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["ShopComponent"] = ShopComponent,
}
