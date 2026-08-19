-- SamuraiCage

type SamuraiCage = {
	new: (...any) -> SamuraiCage,
	constructor: (SamuraiCage, ...any) -> (),
	createCage: (SamuraiCage, { GiveTask: (Instance) -> () }, BasePart, Instance, any?, boolean?) -> Model,
}

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
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
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

local SamuraiCage = setmetatable({}, {
	["__tostring"] = function()
		return "SamuraiCage"
	end,
	["__index"] = Cage,
})
SamuraiCage.__index = SamuraiCage

function SamuraiCage.new(...)
	local self = SamuraiCage
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function SamuraiCage.constructor(self: SamuraiCage, ...)
	Cage.constructor(self, ...)
end

function SamuraiCage.createCage(
	self: SamuraiCage,
	maid: { GiveTask: (Instance) -> () },
	part: BasePart,
	parent: Instance,
	_,
	playAnimation: boolean?
): Model
	if not playAnimation then
		self:createCageGuard(maid, part, parent)
	end

	local position = part.Position + Vector3.new(0, 11, 0)
	local cage: Model = ReplicatedStorage.Cosmetic.Cage.CageSamurai:Clone()
	cage:SetPrimaryPartCFrame(CFrame.new(position))
	cage.Parent = parent
	maid:GiveTask(cage)
	return cage
end

Reflect.defineMetadata(SamuraiCage, "identifier", "kkg")
Reflect.decorate(SamuraiCage, "1YG", CosmeticDecorator, { CosmeticId.CageSamurai })
return {
	["SamuraiCage"] = SamuraiCage,
}
