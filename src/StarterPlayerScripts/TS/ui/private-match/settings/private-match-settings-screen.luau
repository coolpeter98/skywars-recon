-- PrivateMatchSettingsScreen

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local PrivateMatch = RuntimeLib.import(script, script.Parent.Parent, "private-match").PrivateMatch
local PrivateMatchSettingsSidebar =
	RuntimeLib.import(script, script.Parent, "private-match-settings-sidebar").PrivateMatchSettingsSidebar
local SettingsTabsModule = RuntimeLib.import(script, script.Parent, "private-match-settings-tabs")
local PrivateMatchClientSettingsTabs = SettingsTabsModule.PrivateMatchClientSettingsTabs
local PrivateMatchSettingsTabs = SettingsTabsModule.PrivateMatchSettingsTabs
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen").Screen
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useGlobalStore

export type PrivateMatchSettingsScreen = {}

local PrivateMatchSettingsScreen = setmetatable({}, {
	["__tostring"] = function()
		return "PrivateMatchSettingsScreen"
	end,
	["__index"] = Screen,
})
PrivateMatchSettingsScreen.__index = PrivateMatchSettingsScreen

function PrivateMatchSettingsScreen.new(...): PrivateMatchSettingsScreen
	local self = setmetatable({}, PrivateMatchSettingsScreen)
	return self:constructor(...) or self
end

function PrivateMatchSettingsScreen.constructor(self: PrivateMatchSettingsScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local state = useGlobalStore("CustomGame")
		local tab, setTab = useState(0)
		local serverData = state.ServerData
		local settings = state.Settings
		local isOwner = RunService:IsStudio() or serverData.OwnerId == Players.LocalPlayer.UserId
		local tabs
		if isOwner then
			tabs = PrivateMatchSettingsTabs
		else
			tabs = PrivateMatchClientSettingsTabs
		end
		local tabConfig = tabs[tab + 1]
		return React.createElement(PrivateMatch, {
			["Sidebar"] = React.createElement(PrivateMatchSettingsSidebar, {
				["Tab"] = tab,
				["SetTab"] = setTab,
				["IsOwner"] = isOwner,
			}),
			["Page"] = tabConfig.Render(serverData, settings),
		})
	end
end

Reflect.defineMetadata(PrivateMatchSettingsScreen, "identifier", "3ED")
Reflect.decorate(PrivateMatchSettingsScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "PrivateMatchSettings",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["PrivateMatchSettingsScreen"] = PrivateMatchSettingsScreen,
}
