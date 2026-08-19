-- ChestComponent

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
local UserInputService: UserInputService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).UserInputService
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type ChestComponent = {
	chestController: any,
	instance: Model,
}

local ChestComponent = setmetatable({}, {
	__tostring = function()
		return "ChestComponent"
	end,
	__index = DisposableComponent,
})
ChestComponent.__index = ChestComponent

function ChestComponent.new(...)
	local self = ChestComponent
	local result = setmetatable({}, self)
	return result:constructor(...) or result
end

function ChestComponent.constructor(self: ChestComponent, chestController)
	DisposableComponent.constructor(self)
	self.chestController = chestController
end

function ChestComponent.onStart(self: ChestComponent)
	self:createProximityPrompt()
end

function ChestComponent.createProximityPrompt(self: ChestComponent)
	local proximityPrompt = ProximityUtil.createTriggeredPrompt("Chest", "Open", function()
		self.chestController:openChest(self.instance)
	end)
	if not UserInputService.TouchEnabled then
		proximityPrompt.ClickablePrompt = false
	end
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.Parent = self.instance
end

Reflect.defineMetadata(ChestComponent, "identifier", "a4K")
Reflect.defineMetadata(ChestComponent, "flamework:parameters", { "4El" })
Reflect.defineMetadata(ChestComponent, "flamework:implements", { "$:flamework@OnStart" })

local decorate = Reflect.decorate
local chestComponent = ChestComponent
local decoratorArgs = {}
local componentOptions = {
	tag = "block:chest",
	attributes = nil,
	instanceGuard = nil,
	attributes = {},
	instanceGuard = t.intersection(
		t.instanceIsA("Model"),
		t.children({
			AnimationController = t.instanceIsA("AnimationController"),
		})
	),
}
__set_list(decoratorArgs, 1, { componentOptions })
decorate(chestComponent, "$c:components@Component", Component, decoratorArgs)

return {
	["ChestComponent"] = ChestComponent,
}
