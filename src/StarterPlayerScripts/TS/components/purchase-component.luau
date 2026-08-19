-- PurchaseComponent

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
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type PurchaseComponent = {
	new: (...any) -> PurchaseComponent,
	constructor: (self: PurchaseComponent, ...any) -> (),
	onStart: (self: PurchaseComponent) -> (),
	createProximityPrompt: (self: PurchaseComponent) -> (),
}

local PurchaseComponent = setmetatable({}, {
	["__tostring"] = function()
		return "PurchaseComponent"
	end,
	["__index"] = DisposableComponent,
})
PurchaseComponent.__index = PurchaseComponent

function PurchaseComponent.new(...)
	local self = PurchaseComponent
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function PurchaseComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
end

function PurchaseComponent.onStart(self)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	self:createProximityPrompt()
end

function PurchaseComponent.createProximityPrompt(self)
	local prompt = ProximityUtil.createTriggeredPrompt(self.instance.Name, "Open", function()
		Flamework.resolveDependency("vbD"):toggleShop()
	end)
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 19.5
	prompt.Parent = self.instance.PrimaryPart
end

Reflect.defineMetadata(PurchaseComponent, "identifier", "bDg")
Reflect.defineMetadata(PurchaseComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PurchaseComponent, "$c:components@Component", Component, {
	{
		["tag"] = "purchase",
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["PurchaseComponent"] = PurchaseComponent,
}
