-- SidebarGrid

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type SidebarGridProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2,
	children: any?,
}

local function SidebarGrid(props: SidebarGridProps)
	return React.createElement(
		Grid,
		{
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(props.Size.X.Offset + 10, props.Size.Y.Offset)
		},
		React.createElement(
			Grid,
			{
				["Position"] = UDim2.fromOffset(10, 0),
				["Size"] = props.Size
			},
			props.children
		),
		React.createElement(CornerRadius, {
			["Radius"] = 10
		}),
		React.createElement("uigradient", {
			["Rotation"] = 270,
			["Transparency"] = nil,
			["Transparency"] = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.8)
			})
		})
	)
end

return {
	SidebarGrid = SidebarGrid,
}
