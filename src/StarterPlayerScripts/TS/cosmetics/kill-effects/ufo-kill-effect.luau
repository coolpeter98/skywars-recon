-- UfoKillEffect

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
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local scaleModel = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"scale-model",
	"out"
).scaleModel

type KillEffectArgs = {
	Character: Model,
	AnimationEnded: boolean,
	Parent: Instance,
}

type UfoKillEffect = {
	new: (...any) -> UfoKillEffect,
	constructor: (self: UfoKillEffect, ...any) -> (),
	playEffect: (self: UfoKillEffect, character: Model, killEffectArgs: KillEffectArgs) -> (),
	getUfoPosition: (self: UfoKillEffect, killEffectArgs: KillEffectArgs) -> CFrame,
	createUfo: (self: UfoKillEffect, position: CFrame) -> Model,
}

local UfoKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "UfoKillEffect"
	end,
	["__index"] = KillEffect,
})
UfoKillEffect.__index = UfoKillEffect

function UfoKillEffect.new(...)
	local cls: UfoKillEffect = UfoKillEffect
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end

function UfoKillEffect.constructor(self: UfoKillEffect, ...)
	KillEffect.constructor(self, ...)
end

function UfoKillEffect.playEffect(self: UfoKillEffect, character: Model, killEffectArgs: KillEffectArgs)
	local ufoPosition: CFrame = self:getUfoPosition(killEffectArgs)
	local rotation: CFrame = CFrame.Angles(1.5707963267948966, 0, 0)
	local ufoModel: Model = self:createUfo((ufoPosition + Vector3.new(0, 20, 0)) * rotation)
	local fadeOutTween = TweenUtil.fadeOutAsync(ufoModel, 0)
	ufoModel.Parent = killEffectArgs.Parent
	local ufoAnimation = Flamework.resolveDependency("Kp")
		:playAnimationTrack(ufoModel, RobloxAnimation.UFO_MODEL, false, 0.5)
	ScheduleUtil.runTask(function()
		return TweenUtil.restoreTween(fadeOutTween, 0.4)
	end, 0.1)
	AnimationUtil.keyframeReached(ufoAnimation, "UfoOut", function()
		local lastProgress: number = 1
		TweenUtil.simple(
			1,
			0,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
			function(progress: number)
				if killEffectArgs.AnimationEnded then
					return nil
				end
				local upperTorso = character:FindFirstChild("UpperTorso")
				if not upperTorso then
					return nil
				end
				local waist = upperTorso:FindFirstChild("Waist")
				if not waist then
					return nil
				end
				scaleModel(
					character,
					1 - (lastProgress - progress) / lastProgress,
					upperTorso.CFrame:ToWorldSpace(waist.Transform).Position
				)
				lastProgress = progress
			end,
			function()
				return character:Destroy()
			end
		)
		task.wait(0.1)
		if killEffectArgs.AnimationEnded then
			return true
		end
		TweenUtil.fadeOutAsync(character, 0.1)
		return true
	end)
	task.wait(0.5)
	if killEffectArgs.AnimationEnded then
		return nil
	end
	Flamework.resolveDependency("Kp"):playHumanoidAnimation(RobloxAnimation.UFO_CHARACTER, false, 0.5, character, true)
	task.wait(ufoAnimation.Length / 0.5 - 0.4 - 0.5)
	if killEffectArgs.AnimationEnded then
		return nil
	end
	TweenUtil.fadeOutSync(ufoModel, 0.4)
end

function UfoKillEffect.getUfoPosition(self: UfoKillEffect, killEffectArgs: KillEffectArgs): CFrame
	local cframe: CFrame, size: Vector3 = killEffectArgs.Character:GetBoundingBox()
	local groundPosition: Vector3? = self:getGroundPosition(killEffectArgs, cframe.Position)
	if groundPosition then
		return CFrame.new(groundPosition) * cframe.Rotation
	end
	local halfHeight: number = size.Y / 2
	return cframe - Vector3.new(0, halfHeight, 0)
end

function UfoKillEffect.createUfo(self: UfoKillEffect, position: CFrame): Model
	local ufoModel = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.Ufo)
	ufoModel:PivotTo(position)
	return ufoModel
end

Reflect.defineMetadata(UfoKillEffect, "identifier", "ayZ")
Reflect.decorate(UfoKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectUfo })
return {
	["UfoKillEffect"] = UfoKillEffect,
}
