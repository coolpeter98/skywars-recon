-- shop.story

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ShopGui = RuntimeLib.import(script, script.Parent.Parent, "ui", "shop", "shop-gui").ShopGui

return RuntimeLib.import(script, script.Parent, "story-util").StoryUtil.createStory({
	["name"] = "Shop",
	["controls"] = nil,
	["controls"] = {
		["Visible"] = true,
	},
}, (React.createElement(ShopGui, {
	["AnchorPoint"] = Vector2.new(0.5, 0.5),
	["Position"] = UDim2.fromScale(0.5, 0.5),
})))
