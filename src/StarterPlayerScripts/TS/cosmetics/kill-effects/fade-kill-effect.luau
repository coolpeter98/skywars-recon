-- FadeKillEffect

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetic-decorator").CosmeticDecorator

type FadeKillEffect = {
	new: (...any) -> FadeKillEffect,
	constructor: (self: FadeKillEffect, ...any) -> (),
	playEffect: (self: FadeKillEffect, character: Model) -> (),
}

local FadeKillEffect = setmetatable({}, {
	["__tostring"] = function(): string
		return "FadeKillEffect"
	end,
	["__index"] = KillEffect,
})
FadeKillEffect.__index = FadeKillEffect

function FadeKillEffect.new(...)
	local self = setmetatable({}, FadeKillEffect)
	return self:constructor(...) or self
end

function FadeKillEffect.constructor(self: FadeKillEffect, ...)
	KillEffect.constructor(self, ...)
end

function FadeKillEffect.playEffect(_: FadeKillEffect, character: Model)
	character:BreakJoints()
	local partCount = 0
	local parts: { BasePart } = {}
	for index, descendant in character:GetDescendants() do
		local _ = index - 1
		if descendant:IsA("BasePart") == true then
			partCount = partCount + 1
			parts[partCount] = descendant
		end
	end
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	for _, part in parts do
		TweenService:Create(part, tweenInfo, {
			["Transparency"] = 1
		}):Play()
	end
	task.wait(3)
end

Reflect.defineMetadata(FadeKillEffect, "identifier", "dBV")
Reflect.decorate(FadeKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectFade })

return {
	["FadeKillEffect"] = FadeKillEffect
}
