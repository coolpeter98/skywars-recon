-- CosmeticPackageDisplayController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CosmeticDisplayDecorator =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator

type Maid = typeof(Maid.new())

local CosmeticPackageDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticPackageDisplayController"
	end,
})
CosmeticPackageDisplayController.__index = CosmeticPackageDisplayController

function CosmeticPackageDisplayController.new(...)
	local self = setmetatable({}, CosmeticPackageDisplayController)
	return self:constructor(...) or self
end

function CosmeticPackageDisplayController.constructor(_) end

function CosmeticPackageDisplayController.equip(self, player: Player, cosmeticId: string, material: string?): Maid
	local maid = Maid.new()
	local cosmetic = Cosmetics[cosmeticId]
	if cosmetic.Type ~= "Package" then
		return maid
	end
	for _, innerCosmetic in cosmetic.Cosmetics do
		maid:GiveTask(Flamework.resolveDependency("XbN"):equip(player, innerCosmetic, material))
	end
	return maid
end

Reflect.defineMetadata(CosmeticPackageDisplayController, "identifier", "6GY")
Reflect.defineMetadata(CosmeticPackageDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticPackageDisplayController, "MJo", CosmeticDisplayDecorator, { "Package" })
Reflect.decorate(CosmeticPackageDisplayController, "$:flamework@Controller", Controller, {})

return {
	["CosmeticPackageDisplayController"] = CosmeticPackageDisplayController,
}
