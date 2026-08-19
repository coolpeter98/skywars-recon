-- PrivateMatchSettingsTabs

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local PrivateMatchSettingsOptions = RuntimeLib.import(script, script.Parent, "tabs", "private-match-settings-options").PrivateMatchSettingsOptions
local PrivateMatchSettingsMaps = RuntimeLib.import(script, script.Parent, "tabs", "private-match-settings-maps").PrivateMatchSettingsMaps
local PrivateMatchSettingsPlayers = RuntimeLib.import(script, script.Parent, "tabs", "private-match-settings-players").PrivateMatchSettingsPlayers
local PrivateMatchSettingsBannedPlayers = RuntimeLib.import(script, script.Parent, "tabs", "private-match-settings-banned-players").PrivateMatchSettingsBannedPlayers
local PrivateMatchSettingsTeams = RuntimeLib.import(script, script.Parent, "tabs", "private-match-settings-teams").PrivateMatchSettingsTeams
local PrivateMatchChooseTeam = RuntimeLib.import(script, script.Parent, "tabs", "private-match-choose-team").PrivateMatchChooseTeam

type SettingsTab = {
	Id: number,
	Name: string,
	Render: (serverData: any?, settings: any?) -> any,
}

return {
	["PrivateMatchSettingsTabs"] = {
		{
			["Id"] = 0,
			["Name"] = "Options",
			["Render"] = nil,
			["Render"] = function(serverData: any?, settings: any?)
				return React.createElement(PrivateMatchSettingsOptions, {
					["ServerData"] = serverData,
					["Settings"] = settings
				})
			end
		},
		{
			["Id"] = 1,
			["Name"] = "Maps",
			["Render"] = nil,
			["Render"] = function(serverData: any?, settings: any?)
				return React.createElement(PrivateMatchSettingsMaps, {
					["ServerData"] = serverData,
					["Settings"] = settings
				})
			end
		},
		{
			["Id"] = 2,
			["Name"] = "Teams",
			["Render"] = nil,
			["Render"] = function(_, settings: any?)
				return React.createElement(PrivateMatchSettingsTeams, {
					["Settings"] = settings
				})
			end
		},
		{
			["Id"] = 3,
			["Name"] = "Players",
			["Render"] = nil,
			["Render"] = function(_, settings: any?)
				return React.createElement(PrivateMatchSettingsPlayers, {
					["Settings"] = settings
				})
			end
		},
		{
			["Id"] = 4,
			["Name"] = "Ban List",
			["Render"] = nil,
			["Render"] = function(serverData: any?)
				return React.createElement(PrivateMatchSettingsBannedPlayers, {
					["ServerData"] = serverData
				})
			end
		},
		{
			["Id"] = 5,
			["Name"] = "Choose Team",
			["Render"] = nil,
			["Render"] = function(serverData: any?, settings: any?)
				return React.createElement(PrivateMatchChooseTeam, {
					["ServerData"] = serverData,
					["Settings"] = settings
				})
			end
		}
	},
	["PrivateMatchClientSettingsTabs"] = {
		{
			["Id"] = 0,
			["Name"] = "Choose Team",
			["Render"] = nil,
			["Render"] = function(serverData: any?, settings: any?)
				return React.createElement(PrivateMatchChooseTeam, {
					["ServerData"] = serverData,
					["Settings"] = settings
				})
			end
		}
	}
}
