-- FireArrowTrail

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

local FireArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "FireArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
FireArrowTrail.__index = FireArrowTrail

function FireArrowTrail.new(...)
	local self = setmetatable({}, FireArrowTrail)
	return self:constructor(...) or self
end

function FireArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function FireArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment)
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(182, 34, 3)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(215, 53, 2)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(252, 100, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 117, 0)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(250, 192, 0)),
		ColorSequenceKeypoint.new(1, Color.White),
	})
	local particleEmitter = self:createParticleEmitter(attachment, {
		Color3.fromRGB(215, 53, 2),
		Color3.fromRGB(252, 100, 0),
		Color3.fromRGB(255, 117, 0),
	})
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	trail.Parent = attachment
end

Reflect.defineMetadata(FireArrowTrail, "identifier", "9Dw")
Reflect.decorate(FireArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailFire })

return {
	["FireArrowTrail"] = FireArrowTrail,
}
