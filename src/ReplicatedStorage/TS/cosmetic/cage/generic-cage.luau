-- GenericCage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Cage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cage", "cage").Cage
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CageUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cage-util").CageUtil

-- Cages whose guard should skip the downward part
local skipDownCageIds = { CosmeticId.CageSoupPot, CosmeticId.CageCrusader, CosmeticId.CageRoman }

local GenericCage = setmetatable({}, {
	["__tostring"] = function()
		return "GenericCage"
	end,
	["__index"] = Cage,
})
GenericCage.__index = GenericCage

type GenericCage = typeof(GenericCage)

function GenericCage.new(...): GenericCage
	local class = GenericCage
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function GenericCage.constructor(self: GenericCage, ...)
	Cage.constructor(self, ...)
end

function GenericCage.createCage(
	self: GenericCage,
	maid: { GiveTask: (Instance) -> () },
	center: CFrame,
	parent: Instance,
	_color: Color3,
	skipGuard: boolean,
	cosmeticId: string
): Model
	local skipDown = table.find(skipDownCageIds, cosmeticId) ~= nil
	if not skipGuard then
		self:createCageGuard(maid, center - Vector3.new(0, 1.5, 0), parent, skipDown)
	end
	local cage = CageUtil.createCage(cosmeticId, center)
	cage.Parent = parent
	maid:GiveTask(cage)
	return cage
end

return {
	["GenericCage"] = GenericCage,
}
