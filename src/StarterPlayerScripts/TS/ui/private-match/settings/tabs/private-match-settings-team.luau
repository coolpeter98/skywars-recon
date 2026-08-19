-- PrivateMatchSettingsTeam

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local CornerRadius =
	RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type PrivateMatchSettingsTeamProps = {
	Team: {
		Players: { [any]: any },
		Color: Color3,
		Name: string,
		MaxPlayers: number,
	},
}

return {
	["PrivateMatchSettingsTeam"] = function(props: PrivateMatchSettingsTeamProps)
		local gridProps = {
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Size"] = UDim2.fromOffset(650, 146.66),
		}
		local playerCount = 0
		for _ in props.Team.Players do
			playerCount = playerCount + 1
		end
		gridProps.LayoutOrder = -playerCount
		local teamInfoRow = React.createElement(
			Grid,
			{
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = UDim2.fromOffset(610, 50),
			},
			React.createElement(
				Grid,
				{
					["Size"] = UDim2.fromOffset(50, 50),
					["BackgroundColor3"] = props.Team.Color,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			),
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextColor3"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 70, 0.5, 0),
				["Text"] = props.Team.Name,
				["TextColor3"] = Color.White,
			})
		)
		local teamSizeTextProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromScale(0, 0.5),
		}
		local teamSizeCount = 0
		for _ in props.Team.Players do
			teamSizeCount = teamSizeCount + 1
		end
		teamSizeTextProps.Text = ("Team Size \240\159\145\164 %*/%*"):format(teamSizeCount, props.Team.MaxPlayers)
		teamSizeTextProps.TextColor3 = Color.White
		teamSizeTextProps.Bold = true
		teamSizeTextProps.FixSize = true
		return React.createElement(
			Grid,
			gridProps,
			teamInfoRow,
			React.createElement(Grid, {
				["AnchorPoint"] = Vector2.new(0, 1),
				["Position"] = UDim2.new(0, 20, 1, -20),
				["Size"] = UDim2.fromOffset(610, 30),
			}, React.createElement(Text, teamSizeTextProps)),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
