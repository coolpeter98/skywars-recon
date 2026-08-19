-- SmokeKillEffect

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetic-decorator").CosmeticDecorator
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

local SmokeKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "SmokeKillEffect"
	end,
	["__index"] = KillEffect,
})
SmokeKillEffect.__index = SmokeKillEffect

function SmokeKillEffect.new(...)
	local class = SmokeKillEffect
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function SmokeKillEffect.constructor(self, ...)
	KillEffect.constructor(self, ...)
end

function SmokeKillEffect.playEffect(_, model: Model)
	local pivot: CFrame = model:GetPivot()
	model:Destroy()
	Flamework.resolveDependency("dm"):explodeParticlesAtPosition(pivot.Position - Vector3.new(0, 1.5, 0), {
		["Color"] = nil,
		["Size"] = nil,
		["Count"] = 40,
		["Speed"] = 2.8,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 5,
		["SpreadAngle"] = nil,
		["Color"] = ColorUtil.getColorSequence({ Color.Black, Color.Grey, Color.LightGrey }),
		["Size"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.05) }),
		["Lifetime"] = NumberRange.new(0.5, 1.2),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(90, 90)
	})
end

Reflect.defineMetadata(SmokeKillEffect, "identifier", "pl0")
Reflect.decorate(SmokeKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectSmoke })

return {
	["SmokeKillEffect"] = SmokeKillEffect
}
