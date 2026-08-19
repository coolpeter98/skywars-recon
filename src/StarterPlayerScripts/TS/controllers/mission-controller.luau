-- MissionController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type MissionRewardEvent = {
	Reward: {
		RewardType: string,
		Quantity: number,
	},
}

type MissionController = {
	new: (...any) -> any,
	constructor: (self: MissionController, ...any) -> (),
	onStart: (self: MissionController) -> (),
}

local MissionController = setmetatable({}, {
	["__tostring"] = function()
		return "MissionController"
	end,
})
MissionController.__index = MissionController

function MissionController.new(...)
	local class = MissionController
	local self: MissionController = setmetatable({}, class)
	return self:constructor(...) or self
end

function MissionController.constructor(self: MissionController) end

function MissionController.onStart(self: MissionController)
	Events["169c2a72-ec9b-448c-bc73-5fe585a216d4"]:connect(function(mission: MissionRewardEvent)
		if mission.Reward.RewardType ~= "Gems" then
			return nil
		end
		Flamework.resolveDependency("Odx"):displayNotification({
			["Title"] = nil,
			["Icon"] = nil,
			["IconColor"] = nil,
			["IconScale"] = 0.8,
			["Message"] = "Daily mission complete!",
			["Duration"] = 5,
			["Activated"] = nil,
			["ActivatedText"] = "Shop",
			["Title"] = ("+%* Gems"):format(mission.Reward.Quantity),
			["Icon"] = RobloxImage.Icon.GEM,
			["IconColor"] = Color.Green,
			["Activated"] = function()
				return Flamework.resolveDependency("vbD"):openShop()
			end,
		})
	end)
end

Reflect.defineMetadata(MissionController, "identifier", "50g")
Reflect.defineMetadata(MissionController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(MissionController, "$:flamework@Controller", Controller, {})

return {
	["MissionController"] = MissionController,
}
