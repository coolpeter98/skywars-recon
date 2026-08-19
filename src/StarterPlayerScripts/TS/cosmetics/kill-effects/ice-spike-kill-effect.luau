-- IceSpikeKillEffect

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
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil

type KillEffectArgs = {
	Character: Model?,
	Parent: Folder?,
	IsInViewportFrame: boolean?,
	AnimationEnded: boolean,
}

type IceSpikeKillEffect = {
	new: <T>(...any) -> T,
	constructor: (self: IceSpikeKillEffect, ...any) -> (),
	playEffect: (self: IceSpikeKillEffect, character: Model, killEffectArgs: KillEffectArgs) -> (),
	getIceSpikePosition: (self: IceSpikeKillEffect, killEffectArgs: KillEffectArgs) -> CFrame,
	createIceSpike: (self: IceSpikeKillEffect, position: CFrame) -> (Model, () -> ()),
	playIceSpikeAnimation: (
		self: IceSpikeKillEffect,
		killEffectArgs: KillEffectArgs,
		spikeModel: Model,
		restoreCallback: () -> ()
	) -> (),
}

local IceSpikeKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "IceSpikeKillEffect"
	end,
	["__index"] = KillEffect,
})
IceSpikeKillEffect.__index = IceSpikeKillEffect
function IceSpikeKillEffect.new<T>(...): T
	local self = setmetatable({}, IceSpikeKillEffect)
	return self:constructor(...) or self
end
function IceSpikeKillEffect.constructor(self: IceSpikeKillEffect, ...)
	KillEffect.constructor(self, ...)
end
function IceSpikeKillEffect.playEffect(self: IceSpikeKillEffect, character: Model, killEffectArgs: KillEffectArgs)
	local spikePosition = self:getIceSpikePosition(killEffectArgs)
	local animationTrack = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.ICE_PLAYER_FREEZE, false, 1, character, true)
	local highlightController = Flamework.resolveDependency("Ax3")
	if animationTrack ~= nil then
		animationTrack = animationTrack.Length
	end
	highlightController:playIceSpikeHighlight(character, animationTrack == nil and 3.7 or animationTrack)
	task.wait(1)
	local spike = self:createIceSpike(spikePosition)
	local spikeModel = spike[1]
	local restoreCallback = spike[2]
	spikeModel.Parent = killEffectArgs.Parent
	self:playIceSpikeAnimation(killEffectArgs, spikeModel, restoreCallback)
end
function IceSpikeKillEffect.getIceSpikePosition(self: IceSpikeKillEffect, killEffectArgs: KillEffectArgs)
	local cframe, size = killEffectArgs.Character:GetBoundingBox()
	local groundPosition = self:getGroundPosition(killEffectArgs, cframe.Position)
	if groundPosition then
		return CFrame.new(groundPosition) * cframe.Rotation
	end
	local halfHeight = size.Y / 2
	return cframe - Vector3.new(0, halfHeight, 0)
end
function IceSpikeKillEffect.createIceSpike(self: IceSpikeKillEffect, position: CFrame)
	local spikeModel = ReplicatedStorage.Cosmetic.KillEffect.IceSpike:Clone()
	for _, descendant in spikeModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = spikeModel.PrimaryPart
			weld.Part1 = descendant
			weld.Parent = descendant
		end
	end
	spikeModel:PivotTo(position + Vector3.new(0, 0.1, 0))
	spikeModel.PrimaryPart.Anchored = true
	local tween = TweenUtil.fadeOutAsync(spikeModel, 0)
	return {
		spikeModel,
		function()
			return TweenUtil.restoreTween(tween)
		end,
	}
end
function IceSpikeKillEffect.playIceSpikeAnimation(
	self: IceSpikeKillEffect,
	killEffectArgs: KillEffectArgs,
	spikeModel: Model,
	restoreCallback: () -> ()
)
	if killEffectArgs.AnimationEnded then
		return nil
	end
	local animationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(spikeModel, RobloxAnimation.ICE_SHOOT_SPIKES)
	AnimationUtil.waitForAnimation(animationTrack)
	local connection = nil
	connection = animationTrack.KeyframeReached:Connect(function(keyframeName)
		if keyframeName == "Start" then
			task.wait(0.05)
			restoreCallback()
		elseif keyframeName == "Pause" then
			animationTrack:AdjustSpeed(0)
			connection:Disconnect()
		end
	end)
	task.wait(animationTrack.Length)
	if not killEffectArgs.AnimationEnded then
		TweenUtil.fadeOutSync(spikeModel, 0.5)
	end
end
Reflect.defineMetadata(IceSpikeKillEffect, "identifier", "xP6")
Reflect.decorate(IceSpikeKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectIceSpike })
return {
	["IceSpikeKillEffect"] = IceSpikeKillEffect,
}
