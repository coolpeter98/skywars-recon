-- CapybaraArrowTrail

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

local CAPYBARA_COLORS: { Color3 } =
	{ Color3.fromRGB(129, 100, 50), Color3.fromRGB(142, 98, 66), Color3.fromRGB(196, 153, 99) }

local CapybaraArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "CapybaraArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
CapybaraArrowTrail.__index = CapybaraArrowTrail

function CapybaraArrowTrail.new(...)
	local self = setmetatable({}, CapybaraArrowTrail)
	return self:constructor(...) or self
end

function CapybaraArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function CapybaraArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment, CAPYBARA_COLORS)
	local particleEmitter = self:createParticleEmitter(attachment, CAPYBARA_COLORS)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	self:createItemTrail(attachment, maid, "Capybara", {
		["ItemScale"] = 1,
	})
	trail.Parent = attachment
end

Reflect.defineMetadata(CapybaraArrowTrail, "identifier", "rlG")
Reflect.decorate(CapybaraArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailCapybara })

return {
	["CapybaraArrowTrail"] = CapybaraArrowTrail,
}
