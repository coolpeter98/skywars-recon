-- ZoneController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type Zone = {
	StartTime: number,
	EndTime: number,
}

type ZoneController = {
	new: (...any) -> ZoneController,
	constructor: (ZoneController) -> (),
	onStart: (ZoneController) -> (),
}

local ZoneController = setmetatable({}, {
	__tostring = function()
		return "ZoneController"
	end,
})

ZoneController.__index = ZoneController

function ZoneController.new(...)
	local self = setmetatable({}, ZoneController)
	return self:constructor(...) or self
end

function ZoneController.constructor(_) end

function ZoneController.onStart(_: ZoneController)
	Events["e88d40f9-258d-4c98-b45c-42562f7cd881"]:connect(function(zoneId: string, duration: number)
		local startTime: number = os.time()
		local endTime: number = startTime + duration
		local zones: { [string]: Zone } = GlobalStore:getState().Zones
		local newZones: { [string]: Zone } = {}
		for _, zoneEntry in ObjectUtils.entries(zones) do
			newZones[zoneEntry[1]] = zoneEntry[2]
		end
		newZones[zoneId] = {
			["StartTime"] = startTime,
			["EndTime"] = endTime,
		}
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "Zones",
			["Value"] = nil,
			["Value"] = newZones,
		})
	end)
end

Reflect.defineMetadata(ZoneController, "identifier", "qLb")
Reflect.defineMetadata(ZoneController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ZoneController, "$:flamework@Controller", Controller, {})

return {
	["ZoneController"] = ZoneController,
}
