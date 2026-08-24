-- EggwarsScoreboardGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local EggwarsTeamGui = RuntimeLib.import(script, script.Parent, "eggwars-team-gui").EggwarsTeamGui
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type TeamData = {
	Id: number,
	Name: string,
	Color: Color3,
	AliveCount: number,
	CanRespawn: boolean,
}

type ScoreboardProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

return {
	["EggwarsScoreboardGui"] = function(props: ScoreboardProps)
		local gameTeams = useGlobalStore("GameTeams")
		local nearbyEgg = useGlobalStore("NearbyEgg")
		local teamColor = Color.Green
		if nearbyEgg then
			local hue, saturation, _ = nearbyEgg.TeamColor:ToHSV()
			teamColor = Color3.fromHSV(hue, saturation * 0.7, 1)
		end

		local teams = ObjectUtils.values(gameTeams)
		local teamElements = table.create(#teams)

		local function renderTeam(team: TeamData)
			local teamProps = {
				["TeamId"] = team.Id,
				["TeamName"] = team.Name,
				["NearbyEgg"] = nearbyEgg,
				["Color"] = team.Color,
				["AliveCount"] = team.AliveCount,
			}
			-- CanRespawn is the authoritative replicated egg state. AliveCount is
			-- independent (and can be zero in a partial/local round), so folding it
			-- into HasEgg makes the scoreboard disagree with the island keypoint.
			teamProps.HasEgg = team.CanRespawn
			return React.createElement(EggwarsTeamGui, teamProps)
		end

		for index, team in teams do
			teamElements[index] = renderTeam(team, index - 1, teams)
		end

		local gridProps = {
			["key"] = "EggwarsScoreboard",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(430, 95),
		}
		local teamsGrid = React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.fromScale(0.5, 0),
				["Size"] = UDim2.fromOffset(430, 95),
			},
			teamElements,
			React.createElement(List, {
				["VerticalAlignment"] = nil,
				["Offset"] = 20,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			})
		)

		local healthBarContainer
		if nearbyEgg then
			healthBarContainer = React.createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0, 0),
					["Position"] = UDim2.new(0, -1, 0, 60),
					["Size"] = UDim2.fromOffset(446, 35),
					["BackgroundColor3"] = nearbyEgg.TeamColor,
				},
				React.createElement(ProgressBarNew, {
					["key"] = "HealthBar",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Progress"] = nil,
					["Colors"] = nil,
					["Outline"] = 0,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(426, 15),
					["Progress"] = nearbyEgg.Health / HealthConstants.EGG_DEFAULT_HEALTH,
					["Colors"] = { teamColor },
				}),
				React.createElement(CornerRadius, {
					["Radius"] = 10,
				})
			)
		else
			healthBarContainer = nil
		end

		return React.createElement(Grid, gridProps, teamsGrid, healthBarContainer)
	end,
}
