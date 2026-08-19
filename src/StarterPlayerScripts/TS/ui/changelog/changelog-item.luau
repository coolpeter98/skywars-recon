-- ChangelogItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local useWindow = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local useChangelog = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-changelog").useChangelog

type ChangelogItemProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["ChangelogItem"] = function(props: ChangelogItemProps)
		local window = useWindow()
		useChangelog()

		local availableHeight = window.ContentFrameSize.Y - ScreenConstants.PADDING_3 * 2
		local width = window.ContentFrameSize.X * 0.65
		local roundedWidth = math.round(width)
		local aspectHeight = roundedWidth * 0.5625
		local minHeight = math.min(aspectHeight, availableHeight)
		local roundedHeight = math.round(minHeight)

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
		})
	end
}
