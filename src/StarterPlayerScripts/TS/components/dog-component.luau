-- DogComponent

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
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local ProximityUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "proximity", "proximity-util").ProximityUtil
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

local DogComponent = setmetatable({}, {
	["__tostring"] = function()
		return "DogComponent"
	end,
	["__index"] = DisposableComponent,
})
DogComponent.__index = DogComponent
function DogComponent.new(...)
	local self = setmetatable({}, DogComponent)
	return self:constructor(...) or self
end
function DogComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
	self.initialized = false
end
function DogComponent.onStart(self)
	RunService.Heartbeat:Wait()
	while self.instance:IsDescendantOf(Workspace) and not self.initialized do
		RuntimeLib.try(function()
			task.wait(1)
			self:setup()
			self.initialized = true
		end, function(_) end)
	end
	self:createProximityPrompt()
end
function DogComponent.setup(self)
	local animationController: AnimationController = Instance.new("AnimationController")
	animationController.Parent = self.instance.PrimaryPart
	local animator: Animator? = animationController:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = animationController
	end
	local animation: Animation = Instance.new("Animation")
	local animationId = ""
	local instanceName = self.instance.Name
	if instanceName == "Husky" then
		animationId = RobloxAnimation.HUSKY_SIT
	elseif instanceName == "Spaniel" then
		animationId = RobloxAnimation.SPANIEL_SIT
	elseif instanceName == "Corgi" then
		animationId = RobloxAnimation.CORGI_SIT
	end
	animation.AnimationId = animationId
	local animationTrack: AnimationTrack = animator:LoadAnimation(animation)
	animationTrack.Looped = true
	animationTrack:Play()
end
function DogComponent.createProximityPrompt(self)
	local prompt = ProximityUtil.createTriggeredPrompt("Dog", "Pet", function()
		Flamework.resolveDependency("Kp"):playHumanoidAnimation(RobloxAnimation.DOG_PET)
	end)
	if not UserInputService.TouchEnabled then
		prompt.ClickablePrompt = false
	end
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 5
	prompt.Parent = self.instance
end
Reflect.defineMetadata(DogComponent, "identifier", "VJL")
Reflect.defineMetadata(DogComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(DogComponent, "$c:components@Component", Component, {
	{
		["tag"] = "dog",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})
return {
	["DogComponent"] = DogComponent,
}
