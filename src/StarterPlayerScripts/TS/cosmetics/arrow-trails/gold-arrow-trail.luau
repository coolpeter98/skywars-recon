-- GoldArrowTrail

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

type GoldArrowTrail = typeof(ArrowTrailEffect)

local GOLD_COLORS: { Color3 } = {
	Color3.fromRGB(209, 176, 0),
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(255, 222, 46),
	Color3.fromRGB(255, 229, 92),
}
local GoldArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "GoldArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
GoldArrowTrail.__index = GoldArrowTrail
function GoldArrowTrail.new(...)
	local self = GoldArrowTrail
	local object = setmetatable({}, self)
	return object:constructor(...) or object
end
function GoldArrowTrail.constructor(self: GoldArrowTrail, ...)
	ArrowTrailEffect.constructor(self, ...)
end
function GoldArrowTrail.playEffect(self: GoldArrowTrail, arrow, maid)
	local trail = self:createTrail(arrow, GOLD_COLORS)
	local particleEmitter = self:createParticleEmitter(arrow, GOLD_COLORS)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	self:createItemTrail(arrow, maid, "GoldCoin")
	trail.Parent = arrow
end
Reflect.defineMetadata(GoldArrowTrail, "identifier", "Wjk")
Reflect.decorate(GoldArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailGold })
return {
	["GoldArrowTrail"] = GoldArrowTrail,
}
