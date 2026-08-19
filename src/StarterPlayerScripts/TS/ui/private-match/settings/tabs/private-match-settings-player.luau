-- PrivateMatchSettingsPlayer

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local CornerRadius =
	RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "button").Button
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local TeamPicker = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "team-picker").TeamPicker

type Team = {
	Id: string,
	Name: string,
	MaxPlayers: number,
	Players: { [string]: any },
}

type PrivateMatchSettingsPlayerProps = {
	Player: Player,
	Teams: { [string]: Team },
}

local function hashString(text: string): number
	local bytes = { string.byte(text) }
	local sum = 0
	for i = 1, #bytes do
		local byte = bytes[i]
		sum = sum + byte
	end
	return sum
end

return {
	["PrivateMatchSettingsPlayer"] = function(props: PrivateMatchSettingsPlayerProps)
		local isLocalPlayer = Players.LocalPlayer == props.Player
		local spectatorTeam = {
			Id = "",
			Name = "Spectators",
			MaxPlayers = 0,
			Color = Color.Grey,
			Players = {},
		}
		local playerTeam: Team? = nil
		for _, team in props.Teams do
			local teamPlayers = team.Players
			local userId = props.Player.UserId
			if teamPlayers[tostring(userId)] ~= nil == true then
				playerTeam = team
				break
			end
		end
		if playerTeam == nil then
			playerTeam = spectatorTeam
		end
		local teams: { Team } = {}
		local teamsCount = #teams
		local availableCount = 0
		local availableTeams: { Team } = {}
		for _, team in props.Teams do
			local playerCount = 0
			for _ in team.Players do
				playerCount = playerCount + 1
			end
			if playerCount < team.MaxPlayers == true then
				availableCount = availableCount + 1
				availableTeams[availableCount] = team
			end
		end
		local availableTeamsCount = #availableTeams
		table.move(availableTeams, 1, availableTeamsCount, teamsCount + 1, teams)
		teams[teamsCount + availableTeamsCount + 1] = spectatorTeam
		if table.find(teams, playerTeam) == nil then
			table.insert(teams, playerTeam)
		end
		table.sort(teams, function(teamA, teamB)
			return string.lower(teamA.Name) < string.lower(teamB.Name)
		end)
		local gridProps = {
			BackgroundTransparency = 0.6,
			Size = UDim2.fromOffset(650, 84),
			LayoutOrder = isLocalPlayer and 1 or 1 + hashString(props.Player.DisplayName),
		}
		local playerIcon = React.createElement(PlayerIcon, {
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.fromOffset(64, 64),
			UserId = props.Player.UserId,
		})
		local textProps = {
			Bold = true,
			FixSize = true,
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 84, 0.5, 0),
			Text = props.Player.DisplayName,
		}
		local textColor
		if isLocalPlayer then
			textColor = Color.HealthGreen
		else
			textColor = Color.White
		end
		textProps.TextColor3 = textColor
		local playerNameText = React.createElement(Text, textProps)
		local teamPickerProps = {
			Teams = teams,
			PlayerTeam = playerTeam,
			OnSelect = function(team: Team)
				return Flamework.resolveDependency("kXp"):setPlayerTeam(props.Player.UserId, team.Id)
			end,
		}
		local teamPicker = React.createElement(TeamPicker, teamPickerProps)
		local banButton
		if isLocalPlayer then
			banButton = nil
		else
			banButton = React.createElement(Button, {
				Text = "Ban",
				TextSize = 24,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -17, 0.5, 0),
				Size = { 150, 50 },
				Color = Color.Button.Red,
				Activated = function()
					Flamework.resolveDependency("kXp"):banPlayer(props.Player)
				end,
			})
		end
		return React.createElement(
			Grid,
			gridProps,
			playerIcon,
			playerNameText,
			teamPicker,
			banButton,
			React.createElement(CornerRadius, {
				Radius = 10,
			})
		)
	end,
}
