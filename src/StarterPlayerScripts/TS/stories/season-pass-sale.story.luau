-- SeasonPassSale story

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local StoryUtil = RuntimeLib.import(script, script.Parent, "story-util").StoryUtil
local SeasonPassSale = RuntimeLib.import(script, script.Parent.Parent, "ui", "components", "season-pass-sale").SeasonPassSale
return StoryUtil.createStory({
	["name"] = "SeasonPassSale",
	["controls"] = nil,
	["controls"] = {
		["Visible"] = true
	}
}, (React.createElement(SeasonPassSale, {
	["AnchorPoint"] = Vector2.new(0.5, 0.5),
	["Position"] = UDim2.fromScale(0.5, 0.5)
})))
