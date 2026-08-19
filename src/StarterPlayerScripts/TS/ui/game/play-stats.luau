-- PlayStats

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local WinsCard = RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "wins-card").WinsCard
local KillsCard = RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "kills-card").KillsCard
local WinStreakCard =
	RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "win-streak-card").WinStreakCard
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type PlayStatsProps = {
	InLobby: boolean,
	children: any,
}

return {
	["PlayStats"] = function(props: PlayStatsProps)
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, props.InLobby and -211 or -120),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(WinsCard, {
				["LayoutOrder"] = 1,
			}),
			React.createElement(KillsCard, {
				["LayoutOrder"] = 2,
			}),
			React.createElement(WinStreakCard, {
				["LayoutOrder"] = 3,
			}),
			props.children,
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["Padding"] = UDim.new(0, 10),
				["VerticalAlignment"] = Enum.VerticalAlignment.Center,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
			})
		)
	end,
}
