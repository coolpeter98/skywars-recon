-- SettingsList

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local SettingsByGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "settings", "settings").SettingsByGroup
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local SettingGroups = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "settings", "setting-group").SettingGroups
local SettingsItem = RuntimeLib.import(script, script.Parent, "settings-item").SettingsItem
return {
	["SettingsList"] = function(props: { SettingGroupId: string })
		local group = SettingGroups[props.SettingGroupId]
		local settings = SettingsByGroup[props.SettingGroupId]
		local children = table.create(#settings)
		for index, setting in settings do
			local _ = index - 1
			children[index] = React.createElement(SettingsItem, {
				["SettingId"] = setting.Id
			})
		end
		return React.createElement(Grid, {
			["key"] = ("%*"):format(props.SettingGroupId),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
			["TitleText"] = string.upper((("%* Settings"):format(group.Name))),
			["TitleImage"] = group.Image,
			["TitlePosition"] = UDim2.new(),
			["LayoutOrder"] = group.LayoutOrder
		}, React.createElement(Grid, {
			["key"] = "Settings",
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["Position"] = UDim2.fromOffset(0, 42),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, children, React.createElement(List, {
			["Vertical"] = true,
			["HorizontalAlignment"] = nil,
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Left
		})))
	end
}
