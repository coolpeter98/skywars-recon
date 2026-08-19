-- DownsizingKillEffect

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
local scaleModel = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"scale-model",
	"out"
).scaleModel
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil

local DownsizingKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "DownsizingKillEffect"
	end,
	["__index"] = KillEffect,
})
DownsizingKillEffect.__index = DownsizingKillEffect

function DownsizingKillEffect.new(...)
	local class = DownsizingKillEffect
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function DownsizingKillEffect.constructor(self, ...)
	KillEffect.constructor(self, ...)
end

function DownsizingKillEffect.playEffect(self, target: Model)
	local partCount = 0
	local parts: { BasePart } = {}
	for index, descendant in target:GetDescendants() do
		local _ = index - 1
		if descendant:IsA("BasePart") == true then
			partCount = partCount + 1
			parts[partCount] = descendant
		end
	end
	for _, part in parts do
		part.CanCollide = false
		part.Anchored = true
	end
	local tween: Tween = TweenUtil.simple(1, 0.001, TweenInfo.new(10, Enum.EasingStyle.Linear), function(scale: number)
		scaleModel(target, scale)
	end)
	task.wait(10)
	tween:Destroy()
end

Reflect.defineMetadata(DownsizingKillEffect, "identifier", "ayK")
Reflect.decorate(DownsizingKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectDownsizing })

return {
	["DownsizingKillEffect"] = DownsizingKillEffect,
}
