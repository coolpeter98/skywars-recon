-- FireworkKillEffect

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
local WorldConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "world", "world-constants").WorldConstants
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants

type FireworkKillEffect = {
	new: (...any) -> FireworkKillEffect,
	constructor: (FireworkKillEffect, ...any) -> (),
	playEffect: (FireworkKillEffect, Model) -> (),
}

local FireworkKillEffect: FireworkKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "FireworkKillEffect"
	end,
	["__index"] = KillEffect,
})
FireworkKillEffect.__index = FireworkKillEffect
function FireworkKillEffect.new(...)
	local class = FireworkKillEffect
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function FireworkKillEffect.constructor(self: FireworkKillEffect, ...)
	KillEffect.constructor(self, ...)
end
function FireworkKillEffect.playEffect(_: FireworkKillEffect, character: Model)
	local partCount = 0
	local baseParts: { BasePart } = {}
	for index, descendant in character:GetDescendants() do
		local _ = index - 1
		if descendant:IsA("BasePart") == true then
			partCount = partCount + 1
			baseParts[partCount] = descendant
		end
	end
	for _, basePart in baseParts do
		basePart.CanCollide = false
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad)
	local goal: { CFrame: CFrame } = {}
	local rootPartCFrame = humanoidRootPart.CFrame
	local heightOffset = 32 * BlockConstants.BLOCK_SIZE
	goal.CFrame = rootPartCFrame + Vector3.new(0, heightOffset, 0)
	local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
	tween:Play()
	task.wait(2)
	tween:Destroy()
	Flamework.resolveDependency("dm"):explodeParticlesAtPosition(humanoidRootPart.Position, {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 30,
		["Acceleration"] = nil,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 100,
		["Color"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)),
		}),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.25, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.01),
		}),
		["Acceleration"] = WorldConstants.WORLD_ACCELERATION * 0.5,
		["Lifetime"] = NumberRange.new(0.5, 1),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180),
	})
end
Reflect.defineMetadata(FireworkKillEffect, "identifier", "VxL")
Reflect.decorate(FireworkKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectFirework })
return {
	["FireworkKillEffect"] = FireworkKillEffect,
}
