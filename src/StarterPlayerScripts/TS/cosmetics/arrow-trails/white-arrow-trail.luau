-- WhiteArrowTrail

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

local WhiteArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "WhiteArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
WhiteArrowTrail.__index = WhiteArrowTrail

function WhiteArrowTrail.new(...)
	local self = setmetatable({}, WhiteArrowTrail)
	return self:constructor(...) or self
end

function WhiteArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
end

function WhiteArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	local trail = self:createTrail(attachment)
	trail.MaxLength = 18
	maid:GiveTask(function()
		trail.Enabled = false
		return trail.Enabled
	end)
	trail.Parent = attachment
end

Reflect.defineMetadata(WhiteArrowTrail, "identifier", "kdK")
Reflect.decorate(WhiteArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailWhite })

return {
	["WhiteArrowTrail"] = WhiteArrowTrail,
}
