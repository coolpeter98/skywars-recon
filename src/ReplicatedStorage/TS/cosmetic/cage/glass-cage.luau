-- GlassCage

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
local Cage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cage", "cage").Cage
local VectorUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil
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

local GlassCage = setmetatable({}, {
	__tostring = function()
		return "GlassCage"
	end,
	__index = Cage,
})
GlassCage.__index = GlassCage

function GlassCage.new(...)
	local self = setmetatable({}, GlassCage)
	return self:constructor(...) or self
end

function GlassCage.constructor(self, ...)
	Cage.constructor(self, ...)
end

function GlassCage.createCage(self, maid, position: CFrame, parent: Instance, color: Color3): Model
	local origin = position.Position + Vector3.new(0, 6, 0) - Vector3.new(0, 0, 0)
	local cage = Instance.new("Model")
	cage.Name = "CageGlass"
	for _, normal in VectorUtil.NORMALS do
		local offset = normal * 6
		GlassCage:createBoxPart(CFrame.new(origin + offset, origin), cage, color)
	end
	cage.Parent = parent
	maid:GiveTask(cage)
	return cage
end

function GlassCage.createBoxPart(self, cframe: CFrame, parent: Instance, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = "SpawnGlass"
	part.Reflectance = 1
	part.Transparency = 0.8
	part.Color = color
	part.Size = Vector3.new(11, 11, 1)
	part.Material = Enum.Material.SmoothPlastic
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.Parent = parent
	return part
end

Reflect.defineMetadata(GlassCage, "identifier", "B0W")
Reflect.decorate(GlassCage, "1YG", CosmeticDecorator, { CosmeticId.CageGlass })
return {
	["GlassCage"] = GlassCage,
}
