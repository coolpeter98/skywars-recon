-- SettingsGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local SettingsByGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "settings", "settings").SettingsByGroup
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local SettingsList = RuntimeLib.import(script, script.Parent, "settings-list").SettingsList
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window

type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

return {
	["SettingsGui"] = function(props: Props)
		local groupKeys = ObjectUtils.keys(SettingsByGroup)
		local settingsGroups = ObjectUtils.values(SettingsByGroup)
		local totalSettings = 0
		for i = 1, #settingsGroups do
			local settingsGroup = settingsGroups[i]
			local _ = i - 1
			totalSettings = totalSettings + #settingsGroup
		end

		local canvasHeight = totalSettings * 60 + (totalSettings - 1) * 10 + #groupKeys * 42 + (#groupKeys - 1) * 10
		local children = table.create(#groupKeys)
		for index, groupKey in groupKeys do
			local _ = index - 1
			children[index] = React.createElement(SettingsList, {
				["SettingGroupId"] = groupKey,
			})
		end

		return React.createElement(Window, {
			["key"] = "Settings",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(780, 710),
		}, React.createElement("scrollingframe", {
			["key"] = "SettingsList",
			["Position"] = nil,
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 6,
			["ScrollBarImageColor3"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["Position"] = UDim2.fromOffset(20, 20),
			["Size"] = UDim2.fromOffset(740, 600),
			["CanvasSize"] = UDim2.fromOffset(740, canvasHeight),
			["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			["ScrollBarImageColor3"] = Color.White,
		}, children, React.createElement(List, {
			["Vertical"] = true,
			["Padding"] = nil,
			["HorizontalAlignment"] = nil,
			["VerticalAlignment"] = nil,
			["Padding"] = UDim.new(0, 20),
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			["VerticalAlignment"] = Enum.VerticalAlignment.Top,
		})))
	end,
}
