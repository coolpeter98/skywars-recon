-- VoidArrowTrail

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

local VOID_TRAIL_COLORS = {
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(27, 27, 27),
	Color3.fromRGB(42, 30, 54),
	Color3.fromRGB(58, 33, 82),
	Color3.fromRGB(73, 35, 109),
	Color3.fromRGB(88, 38, 136),
}

type VoidArrowTrail = {
	new: (...any) -> VoidArrowTrail,
	constructor: (VoidArrowTrail, ...any) -> (),
	playEffect: (VoidArrowTrail, Instance, Maid) -> (),
}

local VoidArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "VoidArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
VoidArrowTrail.__index = VoidArrowTrail

function VoidArrowTrail.new(...)
	local self = setmetatable({}, VoidArrowTrail)
	return self:constructor(...) or self
end

function VoidArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function VoidArrowTrail.playEffect(self, target, maid)
	local trail = self:createTrail(target, VOID_TRAIL_COLORS)
	local darkEmitter =
		self:createParticleEmitter(target, { VOID_TRAIL_COLORS[1], VOID_TRAIL_COLORS[2], VOID_TRAIL_COLORS[3] })
	local brightEmitter =
		self:createParticleEmitter(target, { VOID_TRAIL_COLORS[4], VOID_TRAIL_COLORS[5], VOID_TRAIL_COLORS[6] })
	maid:GiveTask(function()
		darkEmitter.Enabled = false
		return darkEmitter.Enabled
	end)
	maid:GiveTask(function()
		brightEmitter.Enabled = false
		return brightEmitter.Enabled
	end)
	trail.Parent = target
end

Reflect.defineMetadata(VoidArrowTrail, "identifier", "BJz")
Reflect.decorate(VoidArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailVoid })

return {
	["VoidArrowTrail"] = VoidArrowTrail,
}
