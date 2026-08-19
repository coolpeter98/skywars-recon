-- BalloonCage

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

local BalloonCage = setmetatable({}, {
	["__tostring"] = function()
		return "BalloonCage"
	end,
	["__index"] = Cage,
})
BalloonCage.__index = BalloonCage
function BalloonCage.new(...)
	local selfClass = BalloonCage
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end
function BalloonCage.constructor(self, ...)
	Cage.constructor(self, ...)
end
function BalloonCage.createCage(self, maid, cframe: CFrame, parent: Instance, _, skipGuard: boolean?)
	if not skipGuard then
		self:createCageGuard(maid, cframe, parent)
	end
	local balloonPosition = cframe.Position + Vector3.new(0, 21, 0)
	local balloon = ReplicatedStorage.Cosmetic.Cage.CageBalloon:Clone()
	balloon:SetPrimaryPartCFrame(CFrame.new(balloonPosition))
	balloon.Parent = parent
	maid:GiveTask(balloon)
	return balloon
end
Reflect.defineMetadata(BalloonCage, "identifier", "3Gp")
Reflect.decorate(BalloonCage, "1YG", CosmeticDecorator, { CosmeticId.CageBalloon })
return {
	["BalloonCage"] = BalloonCage,
}
