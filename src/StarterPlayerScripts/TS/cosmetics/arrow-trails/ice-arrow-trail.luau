-- IceArrowTrail

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

local ICE_TRAIL_COLORS = {
	Color3.fromRGB(227, 253, 255),
	Color3.fromRGB(209, 247, 255),
	Color3.fromRGB(192, 247, 255),
	Color3.fromRGB(148, 247, 255),
	Color3.fromRGB(73, 232, 255),
}

local IceArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "IceArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
IceArrowTrail.__index = IceArrowTrail

function IceArrowTrail.new(...)
	local self = setmetatable({}, IceArrowTrail)
	return self:constructor(...) or self
end

function IceArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function IceArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment, ICE_TRAIL_COLORS)
	local particleEmitter = self:createParticleEmitter(attachment, ICE_TRAIL_COLORS)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	self:createItemTrail(attachment, maid, "Ice")
	trail.Parent = attachment
end

Reflect.defineMetadata(IceArrowTrail, "identifier", "GzZ")
Reflect.decorate(IceArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailIce })

return {
	["IceArrowTrail"] = IceArrowTrail,
}
