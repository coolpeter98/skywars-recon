-- PrivateMatchSidebar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid

return {
	["PrivateMatchSidebar"] = function(props)
		return React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(30, 30),
			["Size"] = UDim2.fromOffset(210, 540),
		}, props.children)
	end,
}
