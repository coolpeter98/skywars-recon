-- MetricController

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local GuiService: GuiService = Services.GuiService
local LocalizationService: LocalizationService = Services.LocalizationService
local UserInputService: UserInputService = Services.UserInputService
local DeviceType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "metric", "device-type").DeviceType
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

local MetricController = setmetatable({}, {
	["__tostring"] = function()
		return "MetricController"
	end,
})

MetricController.__index = MetricController

function MetricController.new(...)
	local self = setmetatable({}, MetricController)
	return self:constructor(...) or self
end

function MetricController.constructor(_) end

function MetricController.onStart(self)
	Events.SendMetrics:fire(LocalizationService.RobloxLocaleId, self:getDeviceType())
end

function MetricController.getDeviceType(self): "MOBILE" | "CONSOLE" | "DESKTOP" | "UNKNOWN"
	if GuiService:IsTenFootInterface() then
		return DeviceType.CONSOLE
	elseif UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return DeviceType.MOBILE
	elseif UserInputService.KeyboardEnabled then
		return DeviceType.DESKTOP
	else
		return DeviceType.UNKNOWN
	end
end

Reflect.defineMetadata(MetricController, "identifier", "A8v")
Reflect.defineMetadata(MetricController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(MetricController, "$:flamework@Controller", Controller, {})

return {
	["MetricController"] = MetricController,
}
