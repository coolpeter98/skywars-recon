-- PrivateMatchSettingsSidebar

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local PrivateMatchSidebar = RuntimeLib.import(script, script.Parent.Parent, "private-match-sidebar").PrivateMatchSidebar
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local tabsModule = RuntimeLib.import(script, script.Parent, "private-match-settings-tabs")
local PrivateMatchClientSettingsTabs = tabsModule.PrivateMatchClientSettingsTabs
local PrivateMatchSettingsTabs = tabsModule.PrivateMatchSettingsTabs
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid

type PrivateMatchSettingsSidebarProps = {
	IsOwner: boolean,
	Tab: number,
	SetTab: (tabId: number) -> (),
}

type SettingsTab = {
	Id: number,
	Name: string,
}

return {
	["PrivateMatchSettingsSidebar"] = function(props: PrivateMatchSettingsSidebarProps)
		local headerText = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "Settings",
			["TextSize"] = 36,
			["Bold"] = true,
			["FixSize"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0)
		})
		local tabs
		if props.IsOwner then
			tabs = PrivateMatchSettingsTabs
		else
			tabs = PrivateMatchClientSettingsTabs
		end
		local tabButtons = table.create(#tabs)
		local function renderTabButton(tab: SettingsTab)
			local isActive = props.Tab == tab.Id
			local createElement = React.createElement
			local button = Button
			local buttonProps = {
				["Position"] = UDim2.fromOffset(0, 52),
				["Size"] = { 210, 50 },
				["Text"] = tab.Name
			}
			local buttonColor
			if isActive then
				buttonColor = Color.Button.Green
			else
				buttonColor = Color.Button.Blue
			end
			buttonProps.Color = buttonColor
			function buttonProps.Activated()
				props.SetTab(tab.Id)
			end
			return createElement(button, buttonProps)
		end
		for index, tab in tabs do
			tabButtons[index] = renderTabButton(tab, index - 1, tabs)
		end
		return React.createElement(PrivateMatchSidebar, nil, headerText, React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(0, 52),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, tabButtons, React.createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Vertical,
			["Padding"] = UDim.new(0, 10),
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		})))
	end
}
