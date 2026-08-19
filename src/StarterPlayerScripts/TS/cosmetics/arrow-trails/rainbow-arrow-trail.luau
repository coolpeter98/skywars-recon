-- RainbowArrowTrail

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

type RainbowArrowTrail = typeof(ArrowTrailEffect)

local RainbowArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "RainbowArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
RainbowArrowTrail.__index = RainbowArrowTrail
function RainbowArrowTrail.new(...)
	local class = RainbowArrowTrail
	local object = setmetatable({}, class)
	return object:constructor(...) or object
end
function RainbowArrowTrail.constructor(self: RainbowArrowTrail, ...)
	ArrowTrailEffect.constructor(self, ...)
end
function RainbowArrowTrail.playEffect(self: RainbowArrowTrail, arrow: Model)
	local trail = self:createTrail(arrow)
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(237, 31, 36)),
		ColorSequenceKeypoint.new(0.16666666666666666, Color3.fromRGB(242, 103, 34)),
		ColorSequenceKeypoint.new(0.3333333333333333, Color3.fromRGB(242, 235, 25)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(105, 189, 69)),
		ColorSequenceKeypoint.new(0.6666666666666666, Color3.fromRGB(56, 83, 164)),
		ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(56, 45, 136)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 81, 161)),
	})
	trail.LightEmission = 0.5
	trail.Parent = arrow
end
Reflect.defineMetadata(RainbowArrowTrail, "identifier", "vW0")
Reflect.decorate(RainbowArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailRainbow })
return {
	["RainbowArrowTrail"] = RainbowArrowTrail,
}
