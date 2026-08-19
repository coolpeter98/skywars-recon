-- PrivateMatchSettingsOptions

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
local useState = React.useState
local PrivateMatchPage = RuntimeLib.import(script, script.Parent.Parent.Parent, "private-match-page").PrivateMatchPage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local TextInput = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text-input").TextInput
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "button").Button
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes
local getGameModes =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").getGameModes

type GameMode = {
	Type: string,
	DisplayName: string,
	MaxTeams: number,
	TeamSize: number,
	AllowedInPrivate: boolean,
}

type PrivateMatchSettingsOptionsProps = {
	ServerData: {
		ServerName: string,
		Privacy: "Public" | "Private",
		Settings: {
			GameMode: string,
			AllowTeamSelection: boolean,
		},
	},
}

return {
	["PrivateMatchSettingsOptions"] = function(props: PrivateMatchSettingsOptionsProps)
		local serverName, setServerName = useState(props.ServerData.ServerName)
		local isPublic: boolean = props.ServerData.Privacy == "Public"
		local currentGameMode: GameMode = GameModes[props.ServerData.Settings.GameMode]
		local createElement = React.createElement
		local pageComponent = PrivateMatchPage
		local pageProps = nil
		local displayNameLabel = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Match Display Name",
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(0, 7),
		})
		local serverNameInput = createElement(TextInput, {
			["Position"] = nil,
			["Size"] = nil,
			["PlaceholderText"] = "Name...",
			["Value"] = nil,
			["SetValue"] = nil,
			["FocusLost"] = nil,
			["Position"] = UDim2.fromOffset(0, 52),
			["Size"] = UDim2.fromOffset(690, 50),
			["Value"] = serverName,
			["SetValue"] = setServerName,
			["FocusLost"] = function()
				return Flamework.resolveDependency("kXp"):setServerName(serverName)
			end,
		})
		local privacyLabel = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Privacy",
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(0, 134),
		})
		local createElement = React.createElement
		local buttonComponent = Button
		local privacyButtonProps = {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Color"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(0, 172),
			["Size"] = { 210, 50 },
			["Text"] = ("%*"):format(props.ServerData.Privacy),
		}
		local privacyButtonColor
		if isPublic then
			privacyButtonColor = Color.Button.Green
		else
			privacyButtonColor = Color.Button.Red
		end
		privacyButtonProps.Color = privacyButtonColor
		function privacyButtonProps.Activated()
			local newPrivacy: string = isPublic and "Private" or "Public"
			Flamework.resolveDependency("kXp"):setPrivacy(newPrivacy)
		end
		local privacyButton = createElement(buttonComponent, privacyButtonProps)
		local modeLabel = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Mode",
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(240, 134),
		})
		local modeButton = React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Color"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(240, 172),
			["Size"] = { 210, 50 },
			["Text"] = ("%*"):format(currentGameMode.DisplayName),
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				local count: number = 0
				local allowedGameModes = {}
				for index, gameMode: GameMode in getGameModes() do
					local _ = index - 1
					if gameMode.AllowedInPrivate == true then
						count = count + 1
						allowedGameModes[count] = gameMode
					end
				end
				local currentGameModeIndex: number = -1
				for index, gameMode: GameMode in allowedGameModes do
					local _ = index - 1
					if gameMode.Type == props.ServerData.Settings.GameMode == true then
						currentGameModeIndex = index - 1
						break
					end
				end
				local nextGameMode = nil
				for index, gameMode: GameMode in allowedGameModes do
					if currentGameModeIndex < index - 1 == true then
						nextGameMode = gameMode
						break
					end
				end
				if nextGameMode ~= nil then
					nextGameMode = nextGameMode.Type
				end
				if nextGameMode == nil then
					nextGameMode = allowedGameModes[1].Type
				end
				Flamework.resolveDependency("kXp"):setGameMode(nextGameMode)
			end,
		})
		local teamSelectionLabel = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Team Selection",
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(480, 134),
		})
		local createElement = React.createElement
		local buttonComponent = Button
		local teamSelectionButtonProps = {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Color"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(480, 172),
			["Size"] = { 210, 50 },
			["Text"] = ("%*"):format(props.ServerData.Settings.AllowTeamSelection and "On" or "Off"),
		}
		local teamSelectionButtonColor
		if props.ServerData.Settings.AllowTeamSelection then
			teamSelectionButtonColor = Color.Button.Green
		else
			teamSelectionButtonColor = Color.Button.Red
		end
		teamSelectionButtonProps.Color = teamSelectionButtonColor
		function teamSelectionButtonProps.Activated()
			Flamework.resolveDependency("kXp"):setAllowTeamSelection(not props.ServerData.Settings.AllowTeamSelection)
		end
		return React.createElement(
			pageComponent,
			pageProps,
			displayNameLabel,
			serverNameInput,
			privacyLabel,
			privacyButton,
			modeLabel,
			modeButton,
			teamSelectionLabel,
			createElement(buttonComponent, teamSelectionButtonProps),
			React.createElement(Text, {
				["Position"] = nil,
				["Text"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["Position"] = UDim2.fromOffset(0, 254),
				["Text"] = ("Player Capacity: %*"):format(currentGameMode.MaxTeams * currentGameMode.TeamSize),
			})
		)
	end,
}
