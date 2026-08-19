-- EndGameWindow

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["EndGameWindow"] = function(props)
		return React.createElement(Window, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["TitleAnchorPoint"] = Vector2.new(0.5, 0),
			["TitlePosition"] = UDim2.new(0.5, 0, 0, 10),
			["TitleImage"] = props.TitleImage,
			["TitleText"] = props.TitleText,
			["LayoutOrder"] = props.LayoutOrder,
			["Visible"] = props.Visible,
			["Ref"] = props.FrameRef,
		}, props.children)
	end,
}
