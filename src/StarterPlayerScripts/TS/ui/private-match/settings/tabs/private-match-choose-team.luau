-- PrivateMatchChooseTeam

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PrivateMatchChooseTeamItem = RuntimeLib.import(script, script.Parent, "private-match-choose-team-item").PrivateMatchChooseTeamItem

type Props = {
	Settings: {
		Teams: { any },
	},
	ServerData: {
		Settings: {
			AllowTeamSelection: boolean,
		},
	},
}

return {
	["PrivateMatchChooseTeam"] = function(props: Props)
		local teams = props.Settings.Teams
		local rows = #teams / 3
		local rowCount = math.ceil(rows)
		local canvasHeight = rowCount * 266 + (rowCount - 1) * 10
		local teamItems = table.create(#teams)
		for index, team in teams do
			local _ = index - 1
			teamItems[index] = React.createElement(PrivateMatchChooseTeamItem, {
				["Team"] = team,
				["AllowTeamSelection"] = props.ServerData.Settings.AllowTeamSelection
			})
		end
		return React.createElement("scrollingframe", {
			["Position"] = nil,
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 10,
			["ScrollBarImageColor3"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["Position"] = UDim2.fromOffset(300, 30),
			["Size"] = UDim2.fromOffset(690, 540),
			["CanvasSize"] = UDim2.fromOffset(0, canvasHeight),
			["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			["ScrollBarImageColor3"] = Color.White
		}, teamItems, React.createElement("uigridlayout", {
			["FillDirection"] = nil,
			["FillDirectionMaxCells"] = 3,
			["CellSize"] = nil,
			["CellPadding"] = nil,
			["SortOrder"] = nil,
			["FillDirection"] = Enum.FillDirection.Horizontal,
			["CellSize"] = UDim2.fromOffset(210, 266),
			["CellPadding"] = UDim2.fromOffset(10, 10),
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		}))
	end
}
