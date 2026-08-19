-- UfoCage

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
local Cage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cage", "cage").Cage
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
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

local UfoCage = setmetatable({}, {
	["__tostring"] = function()
		return "UfoCage"
	end,
	["__index"] = Cage,
})
UfoCage.__index = UfoCage

type UfoCage = typeof(UfoCage)

function UfoCage.new(...)
	local selfClass = UfoCage
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function UfoCage.constructor(self: UfoCage, ...)
	Cage.constructor(self, ...)
end

function UfoCage.createCage(
	self: UfoCage,
	maid: { GiveTask: (task: unknown) -> () },
	part: BasePart,
	parent: Instance,
	_,
	spawnOnGround: boolean?
): Model
	if not spawnOnGround then
		self:createCageGuard(maid, part, parent)
	end
	local offset: Vector3 = part.Position + Vector3.new(0, 6, 0)
	local cage: Model = ReplicatedStorage.Cosmetic.Cage.CageUfo:Clone()
	cage:SetPrimaryPartCFrame(CFrame.new(offset))
	cage.Parent = parent
	maid:GiveTask(cage)
	maid:GiveTask((Flamework.resolveDependency("Gy"):playSoundAtPosition(RobloxSound.Cosmetic.UFO_IDLE, offset, {
		["Looped"] = true,
	})))
	return cage
end

Reflect.defineMetadata(UfoCage, "identifier", "oWo")
Reflect.decorate(UfoCage, "1YG", CosmeticDecorator, { CosmeticId.CageUfo })
return {
	["UfoCage"] = UfoCage,
}
