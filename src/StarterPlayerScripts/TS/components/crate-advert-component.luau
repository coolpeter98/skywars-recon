-- CrateAdvertComponent

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
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
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
local BaseComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"components",
	"out"
).BaseComponent
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil

local CRATE_IDLE_ANIMATIONS =
	{ RobloxAnimation.CRATE_IDLE_JUMP, RobloxAnimation.CRATE_IDLE_LEFT_TO_RIGHT, RobloxAnimation.CRATE_IDLE_SPIN }

type CrateAdvertComponent = {
	new: (...any) -> CrateAdvertComponent,
	constructor: (self: CrateAdvertComponent, ...any) -> (),
	onStart: (self: CrateAdvertComponent) -> (),
	destroy: (self: CrateAdvertComponent) -> (),
	scheduleIdleAnimations: (self: CrateAdvertComponent) -> (),
	playIdleAnimation: (self: CrateAdvertComponent) -> AnimationTrack,
	playSounds: (self: CrateAdvertComponent) -> (),
	updateParticleRate: (self: CrateAdvertComponent, rate: number) -> (),
}

local CrateAdvertComponent = setmetatable({}, {
	["__tostring"] = function()
		return "CrateAdvertComponent"
	end,
	["__index"] = BaseComponent,
})
CrateAdvertComponent.__index = CrateAdvertComponent

function CrateAdvertComponent.new(...)
	local self = CrateAdvertComponent
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function CrateAdvertComponent.constructor(self, ...)
	BaseComponent.constructor(self, ...)
	self.connection = nil
end

function CrateAdvertComponent.onStart(self)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local crateId: string? = self.instance:GetAttribute(Attribute.CrateId)
	if not crateId then
		return nil
	end
	if not Crates[crateId] then
		return nil
	end

	self:scheduleIdleAnimations()
	self:playSounds()
end

function CrateAdvertComponent.destroy(self)
	BaseComponent.destroy(self)
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

function CrateAdvertComponent.scheduleIdleAnimations(self)
	Flamework.resolveDependency("Kp"):playAnimationTrack(self.instance, RobloxAnimation.CRATE_IDLE, true)

	self.connection = ScheduleUtil.createIntermittentSchedule(Vector2.new(5, 10), function()
		local animationTrack: AnimationTrack = self:playIdleAnimation()
		self:updateParticleRate(50)
		AnimationUtil.waitForAnimation(animationTrack)

		local stoppedConnection: RBXScriptConnection? = nil
		stoppedConnection = animationTrack.Stopped:Connect(function()
			self:updateParticleRate(20)
			stoppedConnection:Disconnect()
			animationTrack:Destroy()
		end)

		return animationTrack.Length
	end)
end

function CrateAdvertComponent.playIdleAnimation(self)
	local animationId = ArrayUtil.random(CRATE_IDLE_ANIMATIONS)
	return Flamework.resolveDependency("Kp"):playAnimationTrack(self.instance, animationId)
end

function CrateAdvertComponent.playSounds(self)
	Flamework.resolveDependency("jL9")
		:playSoundAttachedToPart(RobloxSound.Crate.CRATE_OPENED_LOOP_06, self.instance.PrimaryPart, {
			["Looped"] = true,
			["RollOffMinDistance"] = 3,
			["RollOffMaxDistance"] = 72,
			["SoundGroup"] = SoundGroupType.World,
		})
end

function CrateAdvertComponent.updateParticleRate(self, rate: number)
	local particleEmitter = self.instance.PrimaryPart
	if particleEmitter ~= nil then
		particleEmitter = particleEmitter:FindFirstChildOfClass("Attachment")
		if particleEmitter ~= nil then
			particleEmitter = particleEmitter:FindFirstChildOfClass("ParticleEmitter")
		end
	end
	if not particleEmitter then
		return nil
	end
	particleEmitter.Rate = rate
end

Reflect.defineMetadata(CrateAdvertComponent, "identifier", "dyV")
Reflect.defineMetadata(CrateAdvertComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CrateAdvertComponent, "$c:components@Component", Component, {
	{
		["tag"] = "crate_advert",
		["attributes"] = {},
		["instanceGuard"] = t.intersection(
			t.instanceIsA("Model"),
			t.children({
				["AnimationController"] = t.instanceIsA("AnimationController"),
			})
		),
	},
})

return {
	["CrateAdvertComponent"] = CrateAdvertComponent,
}
