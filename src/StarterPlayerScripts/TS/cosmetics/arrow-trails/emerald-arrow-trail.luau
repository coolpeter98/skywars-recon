-- EmeraldArrowTrail

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
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

local EmeraldArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "EmeraldArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
EmeraldArrowTrail.__index = EmeraldArrowTrail

function EmeraldArrowTrail.new(...)
	local self = setmetatable({}, EmeraldArrowTrail)
	return self:constructor(...) or self
end

function EmeraldArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function EmeraldArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment)
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 71, 33)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(0, 156, 74)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 208, 98)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(124, 235, 161)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(179, 255, 222)),
		ColorSequenceKeypoint.new(1, Color.White),
	})
	local particleEmitter = self:createParticleEmitter(attachment, {
		Color3.fromRGB(0, 156, 74),
		Color3.fromRGB(0, 208, 98),
		Color3.fromRGB(124, 235, 161),
	})
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	trail.Parent = attachment
end

Reflect.defineMetadata(EmeraldArrowTrail, "identifier", "ykL")
Reflect.decorate(EmeraldArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailEmerald })

return {
	["EmeraldArrowTrail"] = EmeraldArrowTrail,
}
