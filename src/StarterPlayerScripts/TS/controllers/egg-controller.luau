-- EggController

type EggController = {
	new: (...any) -> EggController,
	constructor: (self: EggController) -> (),
	onStart: (self: EggController) -> (),
	hasNearbyEggChanged: (self: EggController, previousEgg: any, currentEgg: any) -> boolean,
	updateNearbyEgg: (self: EggController) -> (),
	getNearbyEgg: (self: EggController, target: Player) -> any,
	findNearbyEgg: (self: EggController, target: Player) -> Model?,
}

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local CollectionService: CollectionService = Services.CollectionService
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local Distance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").Distance
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

local EGG_SEARCH_RADIUS = 24 * BlockConstants.BLOCK_SIZE

local EggController = setmetatable({}, {
	["__tostring"] = function()
		return "EggController"
	end,
})
EggController.__index = EggController

function EggController.new(...)
	local self = setmetatable({}, EggController)
	return self:constructor(...) or self
end

function EggController.constructor(_) end

function EggController.onStart(self)
	local lastEggCheckTime = os.clock()
	RunService.Heartbeat:Connect(function()
		if not TimeUtil.elapsed(lastEggCheckTime, 0.2) then
			return nil
		end
		lastEggCheckTime = os.clock()
		self:updateNearbyEgg()
	end)
	Events["1f8d0466-8b5b-4eaf-a662-1d5a42459023"]:connect(function(egg)
		local eggId = egg:GetAttribute(Attribute.EggId)
		if eggId == 0 or (eggId ~= eggId or (eggId == "" or not eggId)) then
			return nil
		end
		local distance = Distance(Players.LocalPlayer, egg)
		if distance ~= nil and distance <= EGG_SEARCH_RADIUS then
			self:updateNearbyEgg()
		end
	end)
end

function EggController.hasNearbyEggChanged(_, previousEgg, currentEgg)
	if previousEgg == nil or currentEgg == nil then
		return previousEgg ~= currentEgg
	else
		return not ObjectUtils.deepEquals(previousEgg, currentEgg)
	end
end

function EggController.updateNearbyEgg(self)
	local nearbyEgg = self:getNearbyEgg(Flamework.resolveDependency("1LA"):getSpectating() or Players.LocalPlayer)
	if self:hasNearbyEggChanged(GlobalStore:getState().NearbyEgg, nearbyEgg) then
		Flamework.resolveDependency("zG"):setValue("NearbyEgg", nearbyEgg)
	end
end

function EggController.getNearbyEgg(self, target)
	local egg = self:findNearbyEgg(target)
	if not egg then
		return nil
	end
	local teamId = egg:GetAttribute(Attribute.TeamId)
	if teamId == nil then
		return nil
	end
	local teamData = GlobalStore:getState().GameTeams[teamId]
	if not teamData then
		return nil
	end
	local health = egg:GetAttribute(Attribute.Health)
	return {
		["TeamId"] = teamData.Id,
		["TeamName"] = teamData.Name,
		["TeamColor"] = teamData.Color,
		["Health"] = health == nil and 0 or health,
	}
end

function EggController.findNearbyEgg(_, target)
	local nearestEgg = nil
	for _, egg in CollectionService:GetTagged("egg") do
		if egg:IsA("Model") then
			local distance = Distance(target, egg)
			if
				distance ~= nil and (EGG_SEARCH_RADIUS >= distance and (not nearestEgg or nearestEgg[2] >= distance))
			then
				nearestEgg = { egg, distance }
			end
		end
	end
	if nearestEgg then
		return nearestEgg[1]
	else
		return nil
	end
end

Reflect.defineMetadata(EggController, "identifier", "Wwk")
Reflect.defineMetadata(EggController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(EggController, "$:flamework@Controller", Controller, {})
return {
	["EggController"] = EggController,
}
