-- ProfileSidebar

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local SidebarGrid = RuntimeLib.import(script, script.Parent, "sidebar-grid").SidebarGrid
local PlayerLevel = RuntimeLib.import(script, script.Parent.Parent, "components", "player-level").PlayerLevel
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players

type ProfileSidebarProps = {
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["ProfileSidebar"] = function(props: ProfileSidebarProps)
		return React.createElement(SidebarGrid, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(222, 370)
		}, React.createElement(PlayerLevel, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 30),
			["Size"] = UDim2.fromOffset(100, 100),
			["UserId"] = Players.LocalPlayer.UserId
		}))
	end
}
