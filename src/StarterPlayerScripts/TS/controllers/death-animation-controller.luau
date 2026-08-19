-- DeathAnimationController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

local flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)

local Reflect = flamework.Reflect
local Flamework = flamework.Flamework

local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller

local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound

local GameConstants: { NEW_WIN_EFFECT_ENABLED: boolean } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

type DeathAnimationController = {
	new: (...any) -> DeathAnimationController,
	constructor: (self: DeathAnimationController) -> (),
	onStart: (self: DeathAnimationController) -> (),
}

local DeathAnimationController = setmetatable({}, {
	__tostring = function()
		return "DeathAnimationController"
	end,
})

DeathAnimationController.__index = DeathAnimationController

function DeathAnimationController.new(...)
	local self = DeathAnimationController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function DeathAnimationController.constructor(_) end

function DeathAnimationController.onStart(_)
	if not GameConstants.NEW_WIN_EFFECT_ENABLED then
		return nil
	end

	Flamework.resolveDependency("rB8").PlayerEliminated:bind(function(data: { Player: Player, GameEnding: boolean })
		if Players.LocalPlayer ~= data.Player or data.GameEnding then
			return nil
		end

		Flamework.resolveDependency("Or"):monochrome()
		Flamework.resolveDependency("XqN"):sendTitle({
			["Text"] = "YOU DIED",
			["Duration"] = 3,
			["Color"] = nil,
			["Styled"] = true,
			["Color"] = Color.Red,
		})
		Flamework.resolveDependency("qmA"):playEnding(false)
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.Misc.LOSS, {
			["Volume"] = 0.8,
		})

		task.wait(3)

		Flamework.resolveDependency("Or"):polychrome()
	end)
end

Reflect.defineMetadata(DeathAnimationController, "identifier", "gqP")
Reflect.defineMetadata(DeathAnimationController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(DeathAnimationController, "$:flamework@Controller", Controller, {})

return {
	["DeathAnimationController"] = DeathAnimationController,
}
