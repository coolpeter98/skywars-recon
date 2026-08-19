-- PrivateMatchSettingsTeams

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local PrivateMatchPage = RuntimeLib.import(script, script.Parent.Parent.Parent, "private-match-page").PrivateMatchPage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PrivateMatchSettingsTeam =
	RuntimeLib.import(script, script.Parent, "private-match-settings-team").PrivateMatchSettingsTeam

type Props = {
	Settings: {
		Teams: { any },
	},
}

return {
	["PrivateMatchSettingsTeams"] = function(props: Props)
		local teams = props.Settings.Teams
		local teamCount = #teams
		local contentHeight = teamCount * 146.66 + (teamCount - 1) * 10
		local teamsLabel = React.createElement(Text, {
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(0, 11),
			["Text"] = ("Teams: %*"):format(#teams),
		})
		local teamElements = table.create(#teams)
		for index, team in teams do
			local _ = index - 1
			teamElements[index] = React.createElement(PrivateMatchSettingsTeam, {
				["Team"] = team,
			})
		end
		return React.createElement(
			PrivateMatchPage,
			nil,
			teamsLabel,
			React.createElement(
				"scrollingframe",
				{
					["Position"] = nil,
					["Size"] = nil,
					["CanvasSize"] = nil,
					["ScrollingDirection"] = nil,
					["ScrollBarThickness"] = 10,
					["ScrollBarImageColor3"] = nil,
					["BackgroundTransparency"] = 1,
					["BorderSizePixel"] = 0,
					["Selectable"] = false,
					["Position"] = UDim2.fromOffset(0, 80),
					["Size"] = UDim2.fromOffset(690, 460),
					["CanvasSize"] = UDim2.fromOffset(0, contentHeight),
					["ScrollingDirection"] = Enum.ScrollingDirection.Y,
					["ScrollBarImageColor3"] = Color.White,
				},
				teamElements,
				React.createElement("uilistlayout", {
					["FillDirection"] = Enum.FillDirection.Vertical,
					["Padding"] = UDim.new(0, 10),
					["SortOrder"] = Enum.SortOrder.LayoutOrder,
				})
			)
		)
	end,
}
