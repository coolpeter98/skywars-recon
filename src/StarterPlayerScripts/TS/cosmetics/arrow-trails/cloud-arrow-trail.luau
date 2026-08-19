-- CloudArrowTrail

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetic-decorator").CosmeticDecorator
local ArrowTrailEffect = RuntimeLib.import(script, script.Parent.Parent, "arrow-trail-effect").ArrowTrailEffect
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil

type CloudArrowTrail = {
	new: <T>(...any) -> T,
	constructor: (self: CloudArrowTrail, ...any) -> (),
	playEffect: (self: CloudArrowTrail, character: BasePart, maid: any) -> (),
}

local CLOUD_COLORS: { Color3 } = {
	Color3.fromRGB(246, 246, 246),
	Color3.fromRGB(204, 204, 204),
	Color3.fromRGB(171, 171, 171),
	Color3.fromRGB(144, 144, 144),
	Color3.fromRGB(116, 116, 116)
}
local CloudArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "CloudArrowTrail"
	end,
	["__index"] = ArrowTrailEffect
})
CloudArrowTrail.__index = CloudArrowTrail
function CloudArrowTrail.new<T>(...): T
	local cls: CloudArrowTrail = CloudArrowTrail
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end
function CloudArrowTrail.constructor(self: CloudArrowTrail, ...)
	ArrowTrailEffect.constructor(self, ...)
end
function CloudArrowTrail.playEffect(self: CloudArrowTrail, character: BasePart, maid: any)
	local trail = self:createTrail(character, CLOUD_COLORS)
	local particleEmitter = self:createParticleEmitter(character, CLOUD_COLORS)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	local itemTrailProps = {
		OnItemAdded = function(item)
			local tween = TweenUtil.fadeOutAsync(item, 0)
			TweenUtil.restoreTween(tween, 0.3)
		end,
		OnItemRemoved = function(item)
			local tween = TweenUtil.fadeOutAsync(item, 0.3)
			if not tween.Completed then
				return true
			end
			tween.Completed:Connect(function()
				return item:Destroy()
			end)
			return false
		end
	}
	self:createModelTrail(character, maid, ReplicatedStorage.Cosmetic.ArrowTrail.Cloud, itemTrailProps)
	trail.Parent = character
end
Reflect.defineMetadata(CloudArrowTrail, "identifier", "D45")
Reflect.decorate(CloudArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailCloud })
return {
	["CloudArrowTrail"] = CloudArrowTrail
}
