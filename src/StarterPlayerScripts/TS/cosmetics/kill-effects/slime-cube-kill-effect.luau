-- SlimeCubeKillEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
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
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local SlimeCubeKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "SlimeCubeKillEffect"
	end,
	["__index"] = KillEffect,
})
SlimeCubeKillEffect.__index = SlimeCubeKillEffect

function SlimeCubeKillEffect.new(...)
	local self = setmetatable({}, SlimeCubeKillEffect)
	return self:constructor(...) or self
end

function SlimeCubeKillEffect.constructor(self, ...)
	KillEffect.constructor(self, ...)
end

function SlimeCubeKillEffect.playEffect(self, character: Model, killEffectArgs)
	local pivot = character:GetPivot()
	local slimeCube = self:createSlimeCube(self:getSlimeCubePosition(killEffectArgs))
	local fadeTween = TweenUtil.fadeOutAsync(slimeCube, 0)
	slimeCube.Parent = killEffectArgs.Parent
	character.PrimaryPart.Anchored = true
	if not killEffectArgs.IsInViewportFrame then
		character:PivotTo(pivot + Vector3.new(0, 1, 0))
	end
	Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.SLIME_CUBE_CHARACTER, false, 0.5, character, true)
	local animationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(slimeCube, RobloxAnimation.SLIME_CUBE_MODEL, false, 0.5)
	ScheduleUtil.runTask(function()
		return TweenUtil.restoreTween(fadeTween, 0.1)
	end, 0.1)
	animationTrack.Stopped:Wait()
	TweenUtil.fadeOutAsync(character, 0.2)
	TweenUtil.fadeOutSync(slimeCube, 0.5)
end

function SlimeCubeKillEffect.getSlimeCubePosition(self, killEffectArgs): CFrame
	local boundingBox, boundingBoxSize = killEffectArgs.Character:GetBoundingBox()
	local groundPosition = self:getGroundPosition(killEffectArgs, boundingBox.Position)
	if groundPosition then
		return CFrame.new(groundPosition) * boundingBox.Rotation
	end
	local halfHeight = boundingBoxSize.Y / 2
	return boundingBox - Vector3.new(0, halfHeight, 0)
end

function SlimeCubeKillEffect.createSlimeCube(self, cframe: CFrame): Model
	local slimeCube = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.Goo)
	slimeCube:PivotTo(cframe)
	return slimeCube
end

Reflect.defineMetadata(SlimeCubeKillEffect, "identifier", "OX1")
Reflect.decorate(SlimeCubeKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectSlimeCube })
return {
	["SlimeCubeKillEffect"] = SlimeCubeKillEffect,
}
