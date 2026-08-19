-- Settings

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local SettingGroupId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "settings", "setting-group").SettingGroupId
local PartyInvitePrivacy = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"player-settings",
	"player-settings"
).PartyInvitePrivacy

local SettingType: { [string]: string } = {
	["Number"] = "Number",
	["Boolean"] = "Boolean",
	["Enum"] = "Enum",
}

local SettingId: { [string]: string } = {
	["FieldOfView"] = "FieldOfView",
	["AutoQueue"] = "AutoQueue",
	["PartyInvitePrivacy"] = "PartyInvitePrivacy",
	["MusicVolume"] = "MusicVolume",
	["SfxVolume"] = "SfxVolume",
}

type SettingDefinition = {
	Id: string,
	Type: string,
	GroupId: string,
	Name: string,
	Min: number?,
	Max: number?,
	TrueText: string?,
	FalseText: string?,
	Enum: { [string]: string }?,
	GetCurrentValue: (() -> any)?,
	OnChange: ((any) -> ())?,
}

local Settings: { [string]: SettingDefinition } = {}
local SettingsByGroup: { [string]: { SettingDefinition } } = {}

for _, settingDefinition: SettingDefinition in
	{
		{
			["Id"] = nil,
			["Type"] = nil,
			["GroupId"] = nil,
			["Name"] = "Field of View",
			["Min"] = 50,
			["Max"] = 90,
			["GetCurrentValue"] = nil,
			["OnChange"] = nil,
			["Id"] = SettingId.FieldOfView,
			["Type"] = SettingType.Number,
			["GroupId"] = SettingGroupId.Game,
			["GetCurrentValue"] = function(): any
				return Flamework.resolveDependency("7xl"):getSetting("FieldOfView")
			end,
			["OnChange"] = function(value: any)
				return Flamework.resolveDependency("7xl"):setSetting("FieldOfView", value)
			end,
		},
		{
			["Id"] = nil,
			["Type"] = nil,
			["GroupId"] = nil,
			["Name"] = "Game Auto-Queue",
			["TrueText"] = "Enabled",
			["FalseText"] = "Disabled",
			["GetCurrentValue"] = nil,
			["OnChange"] = nil,
			["Id"] = SettingId.AutoQueue,
			["Type"] = SettingType.Boolean,
			["GroupId"] = SettingGroupId.Game,
			["GetCurrentValue"] = function(): any
				return Flamework.resolveDependency("7xl"):getSetting("AutoQueue")
			end,
			["OnChange"] = function(value: any)
				return Flamework.resolveDependency("7xl"):setSetting("AutoQueue", value)
			end,
		},
		{
			["Id"] = nil,
			["Type"] = nil,
			["GroupId"] = nil,
			["Name"] = "Party Invite Privacy",
			["Enum"] = nil,
			["GetCurrentValue"] = nil,
			["OnChange"] = nil,
			["Id"] = SettingId.PartyInvitePrivacy,
			["Type"] = SettingType.Enum,
			["GroupId"] = SettingGroupId.Game,
			["Enum"] = PartyInvitePrivacy,
			["GetCurrentValue"] = function(): any
				return Flamework.resolveDependency("7xl"):getSetting("PartyInvitePrivacy")
			end,
			["OnChange"] = function(value: any)
				return Flamework.resolveDependency("7xl"):setSetting("PartyInvitePrivacy", value)
			end,
		},
		{
			["Id"] = nil,
			["Type"] = nil,
			["GroupId"] = nil,
			["Name"] = "Music Volume",
			["Min"] = 0,
			["Max"] = 100,
			["GetCurrentValue"] = nil,
			["OnChange"] = nil,
			["Id"] = SettingId.MusicVolume,
			["Type"] = SettingType.Number,
			["GroupId"] = SettingGroupId.Sound,
			["GetCurrentValue"] = function(): any
				return Flamework.resolveDependency("7xl"):getSetting("MusicVolume")
			end,
			["OnChange"] = function(value: any)
				return Flamework.resolveDependency("7xl"):setSetting("MusicVolume", value)
			end,
		},
		{
			["Id"] = nil,
			["Type"] = nil,
			["GroupId"] = nil,
			["Name"] = "SFX Volume",
			["Min"] = 0,
			["Max"] = 100,
			["GetCurrentValue"] = nil,
			["OnChange"] = nil,
			["Id"] = SettingId.SfxVolume,
			["Type"] = SettingType.Number,
			["GroupId"] = SettingGroupId.Sound,
			["GetCurrentValue"] = function(): any
				return Flamework.resolveDependency("7xl"):getSetting("SfxVolume")
			end,
			["OnChange"] = function(value: any)
				return Flamework.resolveDependency("7xl"):setSetting("SfxVolume", value)
			end,
		},
	}
do
	if SettingsByGroup[settingDefinition.GroupId] == nil then
		SettingsByGroup[settingDefinition.GroupId] = {}
	end
	Settings[settingDefinition.Id] = settingDefinition
	local group = SettingsByGroup[settingDefinition.GroupId]
	table.insert(group, settingDefinition)
end

return {
	["SettingType"] = SettingType,
	["SettingId"] = SettingId,
	["Settings"] = Settings,
	["SettingsByGroup"] = SettingsByGroup,
}
