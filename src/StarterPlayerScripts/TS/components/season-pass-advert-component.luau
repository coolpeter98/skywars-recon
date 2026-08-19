-- SeasonPassAdvertComponent

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local t = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out", "prelude").t
local Component = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "components", "out").Component
local ProximityUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "proximity", "proximity-util").ProximityUtil
local SeasonPassScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "season-pass", "season-pass-screen").SeasonPassScreen
local DisposableComponent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "components", "disposable-component").DisposableComponent

type SeasonPassAdvertComponent = {
	instance: Model,
	onStart: (self: SeasonPassAdvertComponent) -> (),
	createProximityPrompt: (self: SeasonPassAdvertComponent) -> (),
}

local SeasonPassAdvertComponent = setmetatable({}, {
	["__tostring"] = function()
		return "SeasonPassAdvertComponent"
	end,
	["__index"] = DisposableComponent,
})
SeasonPassAdvertComponent.__index = SeasonPassAdvertComponent

function SeasonPassAdvertComponent.new(...)
	local selfClass = SeasonPassAdvertComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function SeasonPassAdvertComponent.constructor(self: SeasonPassAdvertComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function SeasonPassAdvertComponent.onStart(self: SeasonPassAdvertComponent)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end
	self:createProximityPrompt()
end

function SeasonPassAdvertComponent.createProximityPrompt(self: SeasonPassAdvertComponent)
	local prompt = ProximityUtil.createTriggeredPrompt("Season Pass", "Open", function()
		Flamework.resolveDependency("lB5"):toggle(SeasonPassScreen)
	end)
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 19.5
	prompt.Parent = self.instance.PrimaryPart
end

Reflect.defineMetadata(SeasonPassAdvertComponent, "identifier", "Jzd")
Reflect.defineMetadata(SeasonPassAdvertComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(SeasonPassAdvertComponent, "$c:components@Component", Component, {
	{
		["tag"] = "season_pass_advert",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["SeasonPassAdvertComponent"] = SeasonPassAdvertComponent,
}
