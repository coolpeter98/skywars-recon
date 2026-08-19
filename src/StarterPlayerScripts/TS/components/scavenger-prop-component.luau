-- ScavengerPropComponent

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local globalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store")
local GlobalStore = globalStoreModule.GlobalStore
local GlobalStoreChanged = globalStoreModule.GlobalStoreChanged
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type ScavengerHuntAchievements = {
	Completed: boolean,
	Progress: { number },
}

type Profile = {
	Achievements: {
		SummerScavengerHunt: ScavengerHuntAchievements,
	},
}

type ScavengerPropComponent = {
	propId: number?,
	instance: Model,
	constructor: (self: ScavengerPropComponent, ...any) -> (),
	onStart: (self: ScavengerPropComponent) -> (),
	handleProfile: (self: ScavengerPropComponent, profile: Profile) -> (),
	createProximityPrompt: (self: ScavengerPropComponent) -> (),
}

local ScavengerPropComponent = setmetatable({}, {
	["__tostring"] = function()
		return "ScavengerPropComponent"
	end,
	["__index"] = DisposableComponent,
})
ScavengerPropComponent.__index = ScavengerPropComponent

function ScavengerPropComponent.new(...)
	local selfClass = ScavengerPropComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function ScavengerPropComponent.constructor(self: ScavengerPropComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function ScavengerPropComponent.onStart(self: ScavengerPropComponent)
	self.propId = self.instance:WaitForChild("PropId").Value
	self:createProximityPrompt()
	self:handleProfile(GlobalStore:getState().Profile)
	GlobalStoreChanged("Profile", function(profile: Profile)
		self:handleProfile(profile)
	end)
end

function ScavengerPropComponent.handleProfile(self: ScavengerPropComponent, profile: Profile)
	local scavengerHunt = profile.Achievements.SummerScavengerHunt
	local completed = scavengerHunt.Completed
	if not completed then
		local progress = scavengerHunt.Progress
		local propId = self.propId
		completed = table.find(progress, propId) ~= nil
	end
	if completed then
		self.instance:Destroy()
	end
end

function ScavengerPropComponent.createProximityPrompt(self: ScavengerPropComponent)
	local prompt = ProximityUtil.createTriggeredPrompt("Scavenger Hunt", "Find", function()
		if self.propId ~= nil then
			Events.ClaimScavengerProp:fire(self.propId)
		end
	end)
	prompt.RequiresLineOfSight = true
	prompt.MaxActivationDistance = 9
	prompt.Parent = self.instance
end

Reflect.defineMetadata(ScavengerPropComponent, "identifier", "8zG")
Reflect.defineMetadata(ScavengerPropComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ScavengerPropComponent, "$c:components@Component", Component, {
	{
		["tag"] = "scavenger_prop",
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["ScavengerPropComponent"] = ScavengerPropComponent,
}
