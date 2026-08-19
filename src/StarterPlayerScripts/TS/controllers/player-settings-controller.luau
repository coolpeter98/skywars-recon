-- PlayerSettingsController

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
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
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
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Event = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "event").Event
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type PlayerSettingsController = {
	SettingUpdatedEvent: any,
}

local PlayerSettingsController = setmetatable({}, {
	["__tostring"] = function()
		return "PlayerSettingsController"
	end,
})
PlayerSettingsController.__index = PlayerSettingsController
function PlayerSettingsController.new(...): PlayerSettingsController
	local instance = setmetatable({}, PlayerSettingsController)
	return instance:constructor(...) or instance
end
function PlayerSettingsController.constructor(self: PlayerSettingsController)
	self.SettingUpdatedEvent = Event.new()
end
function PlayerSettingsController.onStart(self: PlayerSettingsController)
	Flamework.resolveDependency("zG"):awaitLoadedProfile()
	self:handleProfile(GlobalStore:getState().Profile)
end
function PlayerSettingsController.handleProfile(self: PlayerSettingsController, profile: any)
	for _, key in ObjectUtils.keys(profile.Settings) do
		self.SettingUpdatedEvent:fire(key, profile.Settings[key], false)
	end
end
function PlayerSettingsController.onSettingChanged(
	self: PlayerSettingsController,
	settingId: string,
	callback: (value: any, skipNetwork: boolean) -> ()
)
	self.SettingUpdatedEvent:bind(function(changedSettingId, value, skipNetwork)
		if changedSettingId == settingId then
			callback(value, skipNetwork)
		end
	end)
end
function PlayerSettingsController.setSetting(
	self: PlayerSettingsController,
	settingId: string,
	value: any,
	skipNetwork: boolean?
)
	if skipNetwork == nil then
		skipNetwork = false
	end
	Events.UpdateSetting:fire(settingId, value)
	self.SettingUpdatedEvent:fire(settingId, value, skipNetwork)
end
function PlayerSettingsController.getSetting(_: PlayerSettingsController, settingId: string)
	return GlobalStore:getState().Profile.Settings[settingId]
end
Reflect.defineMetadata(PlayerSettingsController, "identifier", "7xl")
Reflect.defineMetadata(PlayerSettingsController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PlayerSettingsController, "$:flamework@Controller", Controller, {})
return {
	["PlayerSettingsController"] = PlayerSettingsController,
}
