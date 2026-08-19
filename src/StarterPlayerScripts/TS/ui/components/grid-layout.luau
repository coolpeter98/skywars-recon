-- GridLayout

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local List = RuntimeLib.import(script, script.Parent, "list").List
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type GridLayoutProps = {
	Vertical: boolean,
}

return {
	["GridLayout"] = function(props: GridLayoutProps)
		return React.createElement(Grid, {
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, React.createElement(List, {
			["Vertical"] = props.Vertical
		}))
	end
}
