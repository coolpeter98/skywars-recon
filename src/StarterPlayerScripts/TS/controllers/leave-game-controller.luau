-- LeaveGameController

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
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local LeaveGameScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "leave-game", "leave-game-screen").LeaveGameScreen

type LeaveGameController = {
	new: (...any) -> LeaveGameController,
	constructor: (self: LeaveGameController) -> (),
	onStart: (self: LeaveGameController) -> (),
}

local LeaveGameController = setmetatable({}, {
	["__tostring"] = function()
		return "LeaveGameController"
	end,
})
LeaveGameController.__index = LeaveGameController

function LeaveGameController.new(...)
	local self = setmetatable({}, LeaveGameController)
	return self:constructor(...) or self
end

function LeaveGameController.constructor(_) end

function LeaveGameController.onStart(_)
	if PlaceUtil.isLobbyServer() then
		return nil
	end

	Flamework.resolveDependency("xWL")
		:registerTopbarToggle(
			RobloxImage.Icon.HOUSE_LIGHT,
			RobloxImage.Icon.HOUSE_LIGHT,
			false,
			function(toggle, enabled: boolean)
				if enabled then
					toggle:deselect()
				else
					Flamework.resolveDependency("lB5"):toggle(LeaveGameScreen)
				end
			end,
			0.6
		)
		:setOrder(5)
end

Reflect.defineMetadata(LeaveGameController, "identifier", "lXl")
Reflect.defineMetadata(LeaveGameController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(LeaveGameController, "$:flamework@Controller", Controller, {})

return {
	["LeaveGameController"] = LeaveGameController,
}
