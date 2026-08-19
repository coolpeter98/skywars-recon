-- FireworkArrowTrail

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
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-decorator"
).CosmeticDecorator
local ArrowTrailEffect = RuntimeLib.import(script, script.Parent.Parent, "arrow-trail-effect").ArrowTrailEffect
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local WorldConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "world", "world-constants").WorldConstants
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace

local TRAIL_COLORS: { Color3 } = {
	Color3.fromRGB(182, 34, 3),
	Color3.fromRGB(215, 53, 2),
	Color3.fromRGB(252, 100, 0),
	Color3.fromRGB(255, 117, 0),
	Color3.fromRGB(250, 192, 0),
}

local FireworkArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "FireworkArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
FireworkArrowTrail.__index = FireworkArrowTrail

function FireworkArrowTrail.new(...)
	local self = setmetatable({}, FireworkArrowTrail)
	return self:constructor(...) or self
end

function FireworkArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function FireworkArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment, TRAIL_COLORS)
	local particleEmitter = self:createParticleEmitter(attachment, TRAIL_COLORS)
	maid:GiveTask(ScheduleUtil.createSchedule(0.3333333333333333, function()
		local position = attachment.Position
		local offsetX = (math.random() - 0.5) * 1.5
		local offsetY = (math.random() - 0.5) * 1.5
		local offsetZ = (math.random() - 0.5) * 1.5
		self:launchFirework(position + Vector3.new(offsetX, offsetY, offsetZ), particleEmitter)
	end))
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	trail.Parent = attachment
end

function FireworkArrowTrail.launchFirework(self, position: Vector3, particleEmitter: ParticleEmitter)
	local fireworkPart = self:createFireworkPart(position, particleEmitter)
	self:launchFireworkPart(fireworkPart)
	task.wait(0.5)
	Flamework.resolveDependency("dm"):explodeParticlesAtPosition(fireworkPart.Position, {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 30,
		["Acceleration"] = nil,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 50,
		["Color"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)),
		}),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.25, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.01),
		}),
		["Acceleration"] = WorldConstants.WORLD_ACCELERATION * 0.5,
		["Lifetime"] = NumberRange.new(0.5, 1),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180),
	})
	fireworkPart:Destroy()
end

function FireworkArrowTrail.createFireworkPart(_, position: Vector3, particleEmitter: ParticleEmitter)
	local clonedEmitter = particleEmitter:Clone()
	clonedEmitter.Lifetime = NumberRange.new(0.2, 0.4)
	return Make("Part", {
		["Position"] = nil,
		["Size"] = Vector3.new(1.2, 1.2, 1.2),
		["Transparency"] = 1,
		["CanCollide"] = false,
		["Anchored"] = false,
		["Parent"] = nil,
		["Children"] = nil,
		["Position"] = position,
		["Parent"] = Workspace,
		["Children"] = { clonedEmitter },
	})
end

function FireworkArrowTrail.launchFireworkPart(_, part: BasePart)
	local randomX = MathUtil.random(-0.5, 0.5)
	local randomY = MathUtil.random(40, 40) * BlockConstants.BLOCK_SIZE
	local randomZ = MathUtil.random(-0.5, 0.5)
	part:ApplyImpulse(Vector3.new(randomX, randomY, randomZ))
end

Reflect.defineMetadata(FireworkArrowTrail, "identifier", "gBP")
Reflect.decorate(FireworkArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailFirework })

return {
	["FireworkArrowTrail"] = FireworkArrowTrail,
}
