-- ShootingStarKillEffect

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
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
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
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local SHOOTING_STAR_COLORS = { Color3.fromRGB(255, 220, 0), Color3.fromRGB(255, 242, 34), Color3.fromRGB(255, 250, 90) }
local SPAWN_DELAY_RANGE = Vector2.new(0.1, 0.3)

type ShootingStarKillEffect = {}

local ShootingStarKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "ShootingStarKillEffect"
	end,
	["__index"] = KillEffect,
})
ShootingStarKillEffect.__index = ShootingStarKillEffect
function ShootingStarKillEffect.new(...)
	local self = ShootingStarKillEffect
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function ShootingStarKillEffect.constructor(self: ShootingStarKillEffect, ...)
	KillEffect.constructor(self, ...)
end
function ShootingStarKillEffect.playEffect(self: ShootingStarKillEffect, character: Model, effect)
	local characterPosition = character:GetPivot().Position
	RuntimeLib.Promise.delay(0.5):andThen(function()
		return TweenUtil.fadeOutAsync(character, 1)
	end)
	self:playShootingStarAnimation(effect, characterPosition)
	task.wait(1)
end
function ShootingStarKillEffect.playShootingStarAnimation(self: ShootingStarKillEffect, effect, origin: Vector3)
	for _ = 0, 7 do
		if effect.AnimationEnded then
			return nil
		end
		local shootingStar = self:createShootingStar(origin)
		shootingStar.Parent = effect.Parent
		self:launchShootingStar(effect, shootingStar)
		RuntimeLib.Promise.delay(1):andThen(function()
			return shootingStar:Destroy()
		end)
		local spawnDelay = MathUtil.random(SPAWN_DELAY_RANGE.X, SPAWN_DELAY_RANGE.Y)
		task.wait(spawnDelay)
	end
end
function ShootingStarKillEffect.createShootingStar(self: ShootingStarKillEffect, origin: Vector3)
	local shootingStar = ReplicatedStorage.Cosmetic.KillEffect.ShootingStar:Clone()
	local originCFrame = CFrame.new(origin)
	local cframeAngles = CFrame.Angles
	local yawDegrees = math.random() * 360
	shootingStar.CFrame = originCFrame * cframeAngles(0, math.rad(yawDegrees), 0)
	local topAttachment = Instance.new("Attachment")
	topAttachment.Position = Vector3.new(0, 0.2, 0)
	topAttachment.Parent = shootingStar
	local bottomAttachment = Instance.new("Attachment")
	bottomAttachment.Position = Vector3.new(0, -0.2, 0)
	bottomAttachment.Parent = shootingStar
	self:createTrail(topAttachment, bottomAttachment).Parent = shootingStar
	self:createParticleEmitter().Parent = shootingStar
	self:createPointLight().Parent = shootingStar
	return shootingStar
end
function ShootingStarKillEffect.createTrail(_, attachment0, attachment1)
	local trail = Instance.new("Trail")
	trail.Color = ColorUtil.getColorSequence(SHOOTING_STAR_COLORS)
	trail.LightEmission = 1
	trail.LightInfluence = 0
	trail.Lifetime = 0.25
	trail.MinLength = 0.1
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Transparency = NumberSequence.new(0.2, 0.8)
	trail.FaceCamera = true
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	return trail
end
function ShootingStarKillEffect.createParticleEmitter(_)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = RobloxImage.PARTICLE
	particleEmitter.Color = ColorUtil.getColorSequence(SHOOTING_STAR_COLORS)
	particleEmitter.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.05) })
	particleEmitter.Rate = 50
	particleEmitter.Speed = NumberRange.new(2, 2.5)
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.LightInfluence = 10
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.LockedToPart = false
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	return particleEmitter
end
function ShootingStarKillEffect.createPointLight(_)
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 5
	pointLight.Color = SHOOTING_STAR_COLORS[1]
	pointLight.Range = 3
	return pointLight
end
function ShootingStarKillEffect.launchShootingStar(_, effect, shootingStar)
	local velocityX = MathUtil.random(-0.5, 0.5)
	local velocityY = MathUtil.random(1.15, 1.35) * BlockConstants.BLOCK_SIZE
	local velocityZ = MathUtil.random(-0.5, 0.5)
	local launchVelocity = Vector3.new(velocityX, velocityY, velocityZ)
	if effect.IsInViewportFrame then
		shootingStar.Position = shootingStar.Position + launchVelocity
	else
		shootingStar:ApplyImpulse(launchVelocity)
	end
end
Reflect.defineMetadata(ShootingStarKillEffect, "identifier", "lVl")
Reflect.decorate(ShootingStarKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectShootingStar })
return {
	["ShootingStarKillEffect"] = ShootingStarKillEffect,
}
