-- TornadoKillEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkImport = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkImport.Reflect
local Flamework = FlameworkImport.Flamework
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
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
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil

type TornadoKillEffect = {
	new: (...any) -> TornadoKillEffect,
	constructor: (self: TornadoKillEffect, ...any) -> (),
	playEffect: (self: TornadoKillEffect, character: Model, player: Player) -> (),
	getTornadoPosition: (self: TornadoKillEffect, player: Player) -> CFrame,
	createTornado: (self: TornadoKillEffect, position: Vector3) -> Model,
}

local TornadoKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "TornadoKillEffect"
	end,
	["__index"] = KillEffect,
})
TornadoKillEffect.__index = TornadoKillEffect

function TornadoKillEffect.new(...)
	local class = TornadoKillEffect
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function TornadoKillEffect.constructor(self: TornadoKillEffect, ...)
	KillEffect.constructor(self, ...)
end

function TornadoKillEffect.playEffect(self: TornadoKillEffect, character: Model, player: Player)
	character:GetPivot()
	local tornadoPosition = self:getTornadoPosition(player)
	local tornado = self:createTornado(tornadoPosition)
	local originalScale = tornado:GetScale()
	local fadeTween = TweenUtil.fadeOutAsync(tornado, 0)
	tornado.Parent = player.Parent
	character.PrimaryPart.Anchored = true
	Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.TORNADO_CHARACTER, false, 1, character, true)
	local animationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(tornado, RobloxAnimation.TORNADO_VORTICES, false, 1)
	ScheduleUtil.runTask(function()
		return TweenUtil.restoreTween(fadeTween, 1.5)
	end, 0.1)
	AnimationUtil.waitForAnimation(animationTrack)
	task.wait(animationTrack.Length / 1 - 0.5)
	TweenUtil.simple(
		character:GetScale(),
		0.01,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		function(scale)
			character:ScaleTo(scale)
		end,
		function()
			return character:Destroy()
		end
	)
	task.wait(0.1)
	if not tornado.PrimaryPart then
		return nil
	end
	local yOffset = tornado:GetBoundingBox().Y - tornado.PrimaryPart.CFrame.Y
	TweenUtil.simple(
		originalScale,
		0.01,
		TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		function(scale)
			tornado:ScaleTo(scale)
			if not tornado.PrimaryPart then
				return nil
			end
			local primaryPartY = tornado.PrimaryPart.Position.Y
			local deltaY = yOffset - (tornado:GetBoundingBox().Y - primaryPartY)
			tornado:PivotTo(tornadoPosition + Vector3.new(0, deltaY, 0))
		end
	)
	task.wait(0.30000000000000004)
	TweenUtil.fadeOutSync(tornado, 0.1)
end

function TornadoKillEffect.getTornadoPosition(self: TornadoKillEffect, player: Player): CFrame
	local boundingBox, boundingBoxSize = player.Character:GetBoundingBox()
	local groundPosition = self:getGroundPosition(player, boundingBox.Position)
	if groundPosition then
		return CFrame.new(groundPosition) * boundingBox.Rotation
	end
	local halfHeight = boundingBoxSize.Y / 2
	return boundingBox - Vector3.new(0, halfHeight, 0)
end

function TornadoKillEffect.createTornado(self: TornadoKillEffect, position: Vector3): Model
	local tornado = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.Tornado)
	tornado:PivotTo(position)
	return tornado
end

Reflect.defineMetadata(TornadoKillEffect, "identifier", "o3o")
Reflect.decorate(TornadoKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectTornado })

return {
	["TornadoKillEffect"] = TornadoKillEffect,
}
