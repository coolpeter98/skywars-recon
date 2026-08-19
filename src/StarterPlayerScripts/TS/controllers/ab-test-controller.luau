-- AbTestController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local AbTestType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "ab-test", "ab-test-type").AbTestType
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

local AbTestController = setmetatable({}, {
	["__tostring"] = function()
		return "AbTestController"
	end,
})

AbTestController.__index = AbTestController

function AbTestController.new(...)
	local self = setmetatable({}, AbTestController)
	return self:constructor(...) or self
end

function AbTestController.constructor(_) end

function AbTestController.isInTest(self, testType): boolean?
	if testType == AbTestType.AutoQueue then
		return false
	end
	if testType == AbTestType.Shop then
		return true
	end
	if testType == AbTestType.VerifyFollowJay then
		return Players.LocalPlayer.UserId % 2 == 0
	end
	if testType == AbTestType.GemTiers then
		return true
	end
	if testType == AbTestType.FeaturedCosmetics then
		return true
	end
end

Reflect.defineMetadata(AbTestController, "identifier", "yAg")
Reflect.decorate(AbTestController, "$:flamework@Controller", Controller, {})

return {
	["AbTestController"] = AbTestController,
}
