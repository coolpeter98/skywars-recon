-- SpiralArrowTrail

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
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type SpiralArrowTrail = typeof(ArrowTrailEffect)

local SpiralArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "SpiralArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
SpiralArrowTrail.__index = SpiralArrowTrail
function SpiralArrowTrail.new(...)
	local self = SpiralArrowTrail
	local object = setmetatable({}, self)
	return object:constructor(...) or object
end
function SpiralArrowTrail.constructor(self: SpiralArrowTrail, ...)
	ArrowTrailEffect.constructor(self, ...)
end
function SpiralArrowTrail.playEffect(self: SpiralArrowTrail, arrow, maid)
	local trail = self:createTrail(arrow)
	local particlePart = self:createParticlePart()
	local particleEmitter = self:createSpiralParticleEmitter(particlePart)
	self:setupAnimation(arrow, particlePart, maid)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	trail.Parent = arrow
	particlePart.Parent = arrow
end
function SpiralArrowTrail.createParticlePart(self)
	local part = Instance.new("Part")
	part.Name = "ParticlePart"
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Anchored = true
	part.Transparency = 1
	return part
end
function SpiralArrowTrail.createSpiralParticleEmitter(self, part)
	local particleEmitter = Flamework.resolveDependency("dm"):attachParticleEmitter(part, {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 100,
		["Speed"] = 1,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["SpreadAngle"] = nil,
		["Color"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color.Yellow),
			ColorSequenceKeypoint.new(1, Color.White),
		}),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01),
		}),
		["Lifetime"] = NumberRange.new(0.4, 0.8),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180),
	})
	particleEmitter.LockedToPart = false
	return particleEmitter
end
function SpiralArrowTrail.setupAnimation(self, arrow, particlePart, maid)
	local angle = 0
	maid:GiveTask(RunService.Heartbeat:Connect(function()
		local x = math.cos(angle) * 1
		local y = math.sin(angle) * 1
		local offset = Vector3.new(x, y, 0)
		particlePart.Position = arrow.CFrame:PointToWorldSpace(offset * -1)
		angle = angle + 0.2617993877991494
		if angle >= 6.283185307179586 then
			angle = 0
		end
	end))
end
Reflect.defineMetadata(SpiralArrowTrail, "identifier", "33X")
Reflect.decorate(SpiralArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailSpiral })
return {
	["SpiralArrowTrail"] = SpiralArrowTrail,
}
