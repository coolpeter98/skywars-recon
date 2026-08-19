-- ChangelogStory

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local StoryUtil = RuntimeLib.import(script, script.Parent, "story-util").StoryUtil
local ChangelogGui = RuntimeLib.import(script, script.Parent.Parent, "ui", "changelog", "changelog-gui").ChangelogGui
return StoryUtil.createStory({
	["name"] = "Changelog",
	["controls"] = nil,
	["controls"] = {
		["Visible"] = true,
	},
}, (React.createElement(ChangelogGui, {
	["AnchorPoint"] = Vector2.new(0.5, 0.5),
	["Position"] = UDim2.fromScale(0.5, 0.5),
})))
