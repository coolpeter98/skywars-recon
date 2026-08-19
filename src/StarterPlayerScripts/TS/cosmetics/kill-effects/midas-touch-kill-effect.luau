-- MidasTouchKillEffect

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

type MidasTouchKillEffect = typeof(KillEffect)

local MidasTouchKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "MidasTouchKillEffect"
	end,
	["__index"] = KillEffect,
})
MidasTouchKillEffect.__index = MidasTouchKillEffect
function MidasTouchKillEffect.new(...)
	local class = MidasTouchKillEffect
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function MidasTouchKillEffect.constructor(self: MidasTouchKillEffect, ...)
	KillEffect.constructor(self, ...)
end
function MidasTouchKillEffect.playEffect(_, target: Model)
	local partCount = 0
	local parts = {}
	for index, descendant in target:GetDescendants() do
		local _ = index - 1
		if descendant:IsA("BasePart") == true then
			partCount = partCount + 1
			parts[partCount] = descendant
		end
	end
	for _, part in parts do
		if part:IsA("MeshPart") then
			part.TextureID = ""
			local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
			if surfaceAppearance ~= nil then
				surfaceAppearance:Destroy()
			end
		end
		if part.Name == "Hitbox" or part.Name == "ProjectileHitbox" then
			part:Destroy()
		else
			part.Color = Color3.fromRGB(212, 175, 55)
			part.Material = Enum.Material.Glass
			part.Reflectance = 0
			part.CanCollide = true
		end
	end
	local headPart = target:FindFirstChild("Head")
	if headPart and headPart:IsA("BasePart") then
		headPart:ApplyImpulseAtPosition(headPart.CFrame.LookVector * -1 * 300, headPart.CFrame.Position)
	end
	task.wait(1)
	target:BreakJoints()
	task.wait(1)
end
Reflect.defineMetadata(MidasTouchKillEffect, "identifier", "Zw3")
Reflect.decorate(MidasTouchKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectMidasTouch })
return {
	["MidasTouchKillEffect"] = MidasTouchKillEffect,
}
