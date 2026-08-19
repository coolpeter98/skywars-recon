-- AngelKillEffect

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
local WINGS_WELD_CFRAME: CFrame = CFrame.new(Vector3.new(0, 2.95, 0)) * CFrame.Angles(0, 3.141592653589793, 0)

type KillEffectArgs = {
	Maid: any?,
	IsInViewportFrame: boolean?,
}

type AngelKillEffect = {
	new: (...any) -> AngelKillEffect,
	constructor: (self: AngelKillEffect, ...any) -> (),
	playEffect: (self: AngelKillEffect, character: Model, killEffectArgs: KillEffectArgs) -> (),
	weldWingsToCharacter: (self: AngelKillEffect, character: Model, wingsModel: Model) -> (),
}

local AngelKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "AngelKillEffect"
	end,
	["__index"] = KillEffect,
})
AngelKillEffect.__index = AngelKillEffect

function AngelKillEffect.new(...)
	local cls: AngelKillEffect = AngelKillEffect
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end

function AngelKillEffect.constructor(self: AngelKillEffect, ...)
	KillEffect.constructor(self, ...)
end

function AngelKillEffect.playEffect(self: AngelKillEffect, character: Model, killEffectArgs: KillEffectArgs)
	local wingsModel = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.AngelWings)
	killEffectArgs.Maid:GiveTask(wingsModel)
	wingsModel:PivotTo(character:GetPivot())
	self:weldWingsToCharacter(character, wingsModel)
	wingsModel.Parent = character
	local ascendAnimation = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.ANGEL_PLAYER_ASCEND, false, 1, character)
	if not killEffectArgs.IsInViewportFrame then
		Flamework.resolveDependency("Kp"):playAnimationTrack(wingsModel, RobloxAnimation.ANGEL_WINGS_FLAP, true)
	end
	if not ascendAnimation then
		return nil
	end
	AnimationUtil.waitForAnimation(ascendAnimation)
	TweenUtil.fadeOutAsync(character, ascendAnimation.Length)
	ascendAnimation.Stopped:Wait()
end

function AngelKillEffect.weldWingsToCharacter(_, character: Model, wingsModel: Model)
	local upperTorso = character:FindFirstChild("UpperTorso")
	local weld = Instance.new("Weld")
	weld.Part0 = upperTorso
	weld.Part1 = wingsModel.PrimaryPart
	weld.C1 = WINGS_WELD_CFRAME
	weld.Parent = wingsModel
end

Reflect.defineMetadata(AngelKillEffect, "identifier", "o3r")
Reflect.decorate(AngelKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectAngel })
return {
	["AngelKillEffect"] = AngelKillEffect,
}
