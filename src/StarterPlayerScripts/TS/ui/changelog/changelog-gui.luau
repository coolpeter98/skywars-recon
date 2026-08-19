-- ChangelogGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local useWindow = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local useChangelog = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-changelog").useChangelog
local ChangelogItem = RuntimeLib.import(script, script.Parent, "changelog-item").ChangelogItem

type ChangelogGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["ChangelogGui"] = function(props: ChangelogGuiProps)
		local window = useWindow()
		local changelog = useChangelog()

		local availableHeight = window.ContentFrameSize.Y - ScreenConstants.PADDING_3 * 2
		local width = window.ContentFrameSize.X * 0.65
		local roundedWidth = math.round(width)
		local aspectHeight = roundedWidth * 0.5625
		local minHeight = math.min(aspectHeight, availableHeight)
		local roundedHeight = math.round(minHeight)

		local elements = table.create(#changelog)
		for index, entry in changelog do
			local _ = index - 1
			local itemProps = {
				["ChangelogInfo"] = entry[1],
				["HasSeen"] = entry[2]
			}
			elements[index] = React.createElement(ChangelogItem, itemProps)
		end

		return React.createElement(Window, {
			["key"] = "Changelog",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleImage"] = nil,
			["TitleText"] = "CHANGELOG",
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(roundedWidth, roundedHeight),
			["TitleImage"] = RobloxImage.Icon.LIST_CHECK
		}, elements)
	end
}
