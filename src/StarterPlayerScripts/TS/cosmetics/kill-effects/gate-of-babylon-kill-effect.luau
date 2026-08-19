-- GateOfBabylonKillEffect

type KillEffectArgs = {
	Parent: Instance,
}

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
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local StringUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"string-utils"
)

local GateOfBabylonKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "GateOfBabylonKillEffect"
	end,
	["__index"] = KillEffect,
})
GateOfBabylonKillEffect.__index = GateOfBabylonKillEffect

function GateOfBabylonKillEffect.new(...)
	local self = setmetatable({}, GateOfBabylonKillEffect)
	return self:constructor(...) or self
end

function GateOfBabylonKillEffect.constructor(self, ...)
	KillEffect.constructor(self, ...)
end

function GateOfBabylonKillEffect.playEffect(self, character: Model, killEffectArgs: KillEffectArgs)
	local center, size = character:GetBoundingBox()
	local halfHeight = size.Y / 2
	local gate = self:createGateOfBabylon(center - Vector3.new(0, halfHeight, 0))
	Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.GATE_OF_BABYLON_CHARACTER, false, 1, character, true)
	self:animatePortals(gate, killEffectArgs.Parent)
	task.wait(1)
	TweenUtil.fadeOutAsync(character, 1)
	TweenUtil.fadeOutAsync(gate, 1)
	task.wait(2)
end

function GateOfBabylonKillEffect.createGateOfBabylon(self, position: CFrame)
	local gate = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.GateOfBabylon)
	gate:PivotTo(position * CFrame.Angles(0, 3.141592653589793, 0))
	return gate
end

function GateOfBabylonKillEffect.animatePortals(_, portals: Model, parent: Instance)
	local tweens = {}
	for _, part in portals:GetChildren() do
		if
			part:IsA("BasePart")
			and (StringUtils.startsWith(part.Name, "Portal") or StringUtils.startsWith(part.Name, "Weapon"))
		then
			tweens[part] = TweenUtil.fadeOutAsync(part, 0)
		end
	end
	portals.Parent = parent
	local animationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(portals, RobloxAnimation.GATE_OF_BABYLON_PORTALS, false, 1)
	AnimationUtil.waitForAnimation(animationTrack)
	local portalIndex = 0
	AnimationUtil.keyframeReached(animationTrack, "FadeIn", function()
		local portal = portals:FindFirstChild(("Portal%*"):format(portalIndex))
		local weapon = portals:FindFirstChild(("Weapon%*"):format(portalIndex))
		portalIndex = portalIndex + 1
		if not (portal and weapon) then
			return true
		end
		local portalTween = tweens[portal]
		local weaponTween = tweens[weapon]
		if portalTween then
			TweenUtil.restoreTween(portalTween, 0.5)
		end
		if weaponTween then
			TweenUtil.restoreTween(weaponTween, 0.5)
		end
		return false
	end)
	task.wait(animationTrack.Length)
end

Reflect.defineMetadata(GateOfBabylonKillEffect, "identifier", "0YV")
Reflect.decorate(GateOfBabylonKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectGateOfBabylon })
return {
	["GateOfBabylonKillEffect"] = GateOfBabylonKillEffect,
}
