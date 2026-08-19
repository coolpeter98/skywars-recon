-- PrivateMatchPage

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React: React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid

type PrivateMatchPageProps = {
	children: any?,
}

return {
	["PrivateMatchPage"] = function(props: PrivateMatchPageProps)
		return React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(300, 30),
			["Size"] = UDim2.fromOffset(690, 540)
		}, props.children)
	end
}
