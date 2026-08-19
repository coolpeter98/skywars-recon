-- DuelsScoreboard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ScoreRowProps = {
	Score: number?,
	Color: Color3,
	ReverseOrder: boolean?,
	AnchorPoint: Vector2,
	Position: UDim2,
}

type DuelsScoreboardProps = {
	DuelsScore: {
		Red: number?,
		Blue: number?,
	},
}

local ScoreRow: ((props: ScoreRowProps) -> any)?

local function DuelsScoreboard(props: DuelsScoreboardProps)
	local redRowProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["TeamId"] = "Red",
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.new(0, 10, 0.5, 0)
	}
	local redScore = props.DuelsScore.Red
	redRowProps.Score = redScore == nil and 0 or redScore
	redRowProps.Color = Color.Red
	local redRowElement = React.createElement(ScoreRow, redRowProps)
	local blueRowProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["TeamId"] = "Blue",
		["AnchorPoint"] = Vector2.new(1, 0.5),
		["Position"] = UDim2.new(1, -10, 0.5, 0)
	}
	local blueScore = props.DuelsScore.Blue
	blueRowProps.Score = blueScore == nil and 0 or blueScore
	blueRowProps.Color = Color.LightBlue
	blueRowProps.ReverseOrder = true
	return React.createElement(Grid, {
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Size"] = UDim2.fromOffset(266, 50)
	}, redRowElement, React.createElement(ScoreRow, blueRowProps), React.createElement(CornerRadius, {
		["Radius"] = 10
	}))
end

ScoreRow = function(props: ScoreRowProps)
	local elements = {}
	for i = 0, 2 do
		local isFilled = i < props.Score
		local createElement = React.createElement
		local gridComponent = Grid
		local dotProps = {
			["Size"] = UDim2.fromOffset(26, 26)
		}
		local dotColor
		if isFilled then
			dotColor = props.Color
		else
			dotColor = Color.Black
		end
		dotProps.BackgroundColor3 = dotColor
		dotProps.BackgroundTransparency = isFilled and 0 or 0.6
		local layoutOrder
		if isFilled then
			layoutOrder = props.ReverseOrder and 1 or 0
		else
			layoutOrder = props.ReverseOrder and 0 or 1
		end
		dotProps.LayoutOrder = layoutOrder
		local outlineElement
		if isFilled then
			outlineElement = React.createElement(Outline, {
				["Thickness"] = 2
			})
		else
			outlineElement = nil
		end
		local dotElement = createElement(gridComponent, dotProps, outlineElement, React.createElement("uicorner", {
			["CornerRadius"] = UDim.new(1, 0)
		}))
		table.insert(elements, dotElement)
	end
	return React.createElement(Grid, {
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["AutomaticSize"] = Enum.AutomaticSize.XY
	}, elements, React.createElement("uilistlayout", {
		["FillDirection"] = Enum.FillDirection.Horizontal,
		["SortOrder"] = Enum.SortOrder.LayoutOrder,
		["Padding"] = UDim.new(0, 10),
		["VerticalAlignment"] = Enum.VerticalAlignment.Center,
		["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
	}))
end

return {
	["DuelsScoreboard"] = DuelsScoreboard
}
