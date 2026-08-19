-- TombstoneKillEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
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

type TombstoneKillEffect = {
	new: (...any) -> TombstoneKillEffect,
	constructor: (self: TombstoneKillEffect, ...any) -> (),
	playEffect: (self: TombstoneKillEffect, character: Model, killEffectArgs) -> (),
	createTombstone: (self: TombstoneKillEffect, pivot: CFrame) -> Model,
	getTombstonePosition: (
		self: TombstoneKillEffect,
		killEffectArgs,
		pivot: CFrame,
		killerPosition: CFrame?
	) -> CFrame?,
	getKillerPosition: (self: TombstoneKillEffect, killEffectArgs) -> CFrame,
	disableCharacterCollisions: (self: TombstoneKillEffect, character: Model) -> (),
}

local TombstoneKillEffect = setmetatable({}, {
	["__tostring"] = function(): string
		return "TombstoneKillEffect"
	end,
	["__index"] = KillEffect,
})
TombstoneKillEffect.__index = TombstoneKillEffect

function TombstoneKillEffect.new(...)
	local self = setmetatable({}, TombstoneKillEffect)
	return self:constructor(...) or self
end

function TombstoneKillEffect.constructor(self: TombstoneKillEffect, ...)
	KillEffect.constructor(self, ...)
end

function TombstoneKillEffect.playEffect(self: TombstoneKillEffect, character: Model, killEffectArgs)
	local tombstonePosition =
		self:getTombstonePosition(killEffectArgs, character:GetPivot(), (self:getKillerPosition(killEffectArgs)))
	if not tombstonePosition then
		return nil
	end
	local tombstone = self:createTombstone(tombstonePosition)
	tombstone.Parent = killEffectArgs.Parent
	self:disableCharacterCollisions(character)
	local playerFallAnimation = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.TOMBSTONE_PLAYER_FALL, false, 1, character)
	if not playerFallAnimation then
		return nil
	end
	playerFallAnimation.Stopped:Wait()
	character:Destroy()
	Flamework.resolveDependency("Kp"):playAnimationTrack(tombstone, RobloxAnimation.TOMBSTONE_ANIMATION).Stopped:Wait()
	TweenUtil.fadeOutSync(tombstone, 0.5)
end

function TombstoneKillEffect.createTombstone(self: TombstoneKillEffect, pivot: CFrame): Model
	local tombstoneModel = self:createModel(ReplicatedStorage.Cosmetic.KillEffect.Tombstone)
	local heightOffset = 11.25 - tombstoneModel:GetExtentsSize().Y / 2
	local positionOffset = Vector3.new(0, heightOffset, 0)
	tombstoneModel:PivotTo(pivot * CFrame.Angles(0, 3.141592653589793, 0) - positionOffset)
	return tombstoneModel
end

function TombstoneKillEffect.getTombstonePosition(
	self: TombstoneKillEffect,
	killEffectArgs,
	pivot: CFrame,
	killerPosition: CFrame?
): CFrame?
	if killerPosition == nil then
		killerPosition = CFrame.new()
	end
	local groundPosition = self:getGroundPosition(killEffectArgs, pivot.Position)
	if not groundPosition then
		return nil
	end
	local lookX = killerPosition.Position.X
	local lookY = groundPosition.Y
	local lookZ = killerPosition.Position.Z
	local lookPosition = Vector3.new(lookX, lookY, lookZ)
	return CFrame.new(groundPosition, lookPosition)
end

function TombstoneKillEffect.getKillerPosition(_: TombstoneKillEffect, killEffectArgs): CFrame
	if killEffectArgs.IsInViewportFrame then
		return CFrame.new(Vector3.new(10, 10, 10))
	else
		local killer = killEffectArgs.Killer
		if killer ~= nil then
			killer = killer.Character
		end
		if killer then
			return killEffectArgs.Killer.Character:GetPrimaryPartCFrame()
		else
			return killEffectArgs.Character:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(0, 0, -10))
		end
	end
end

function TombstoneKillEffect.disableCharacterCollisions(_: TombstoneKillEffect, character: Model)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

Reflect.defineMetadata(TombstoneKillEffect, "identifier", "bjg")
Reflect.decorate(TombstoneKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectTombstone })
return {
	["TombstoneKillEffect"] = TombstoneKillEffect,
}
