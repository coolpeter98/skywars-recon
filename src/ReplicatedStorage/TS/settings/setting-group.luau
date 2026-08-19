-- SettingGroup

type RobloxImageModule = {
	Icon: {
		GAMEPAD: string,
		SOUND: string,
	},
}

type SettingGroup = {
	Id: string,
	Name: string,
	Image: string,
	LayoutOrder: number,
}

type SettingGroupId = {
	Game: "Game",
	Sound: "Sound",
}

local RobloxImage: RobloxImageModule = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage

local SettingGroupId: SettingGroupId = {
	["Game"] = "Game",
	["Sound"] = "Sound",
}

local SettingGroups: { [string]: SettingGroup } = {}

for _, settingGroup: SettingGroup in
	{
		{
			["Id"] = nil,
			["Name"] = "Game",
			["Image"] = nil,
			["LayoutOrder"] = 1,
			["Id"] = SettingGroupId.Game,
			["Image"] = RobloxImage.Icon.GAMEPAD,
		},
		{
			["Id"] = nil,
			["Name"] = "Sound",
			["Image"] = nil,
			["LayoutOrder"] = 2,
			["Id"] = SettingGroupId.Sound,
			["Image"] = RobloxImage.Icon.SOUND,
		},
	}
do
	SettingGroups[settingGroup.Id] = settingGroup
end

return {
	["SettingGroupId"] = SettingGroupId,
	["SettingGroups"] = SettingGroups,
}
