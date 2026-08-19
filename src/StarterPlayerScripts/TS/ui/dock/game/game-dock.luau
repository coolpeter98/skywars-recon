-- GameDock

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
local Dock = RuntimeLib.import(script, script.Parent.Parent, "dock").Dock
local RespawnCountdown = RuntimeLib.import(script, script.Parent, "respawn-countdown").RespawnCountdown
local Spectating = RuntimeLib.import(script, script.Parent, "spectating").Spectating
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local DockParty = RuntimeLib.import(script, script.Parent.Parent, "lobby", "dock-party").DockParty
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local LeaveGameScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "leave-game", "leave-game-screen").LeaveGameScreen
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local CustomGameServerKey =
	RuntimeLib.import(script, script.Parent.Parent, "custom-game-server-key").CustomGameServerKey
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "events").Events
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local useFocused = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-focused").useFocused

type SpectatingInfo = {
	UserId: number,
	Name: string,
}

type RespawnTimeInfo = {
	Time: number,
	Delay: number,
}

type GameDockProps = {
	Spectating: SpectatingInfo?,
	RespawnTime: RespawnTimeInfo?,
	GameState: number,
	Party: any,
	IsCustomGame: boolean?,
	IsCustomOwner: boolean?,
	CustomGamePrivacy: any,
	CustomGameServerKey: any,
	HideButtons: boolean?,
}

return {
	["GameDock"] = function(props: GameDockProps)
		local isFocused: boolean = useFocused()
		local playerColor = Color.White
		if props.Spectating then
			local spectatingUserId = props.Spectating
			if spectatingUserId ~= nil then
				spectatingUserId = spectatingUserId.UserId
			end
			local spectator: Player? = Players:GetPlayerByUserId(spectatingUserId)
			if spectator then
				playerColor = Flamework.resolveDependency("x5"):getPlayerTeam(spectator)
				if playerColor ~= nil then
					playerColor = playerColor.Color
				end
				if playerColor == nil then
					playerColor = Color.White
				end
			end
		end
		local isRespawning: boolean = props.RespawnTime ~= nil
		local dockedProps: GameDockProps = table.clone(props)
		setmetatable(dockedProps, nil)
		dockedProps.HideButtons = isRespawning
		local mainContent
		if isRespawning or isFocused then
			mainContent = nil
		else
			local gridProps = {
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 0, -50),
				["Size"] = UDim2.fromOffset(500, 80),
			}
			local partyElement = React.createElement(DockParty, {
				["Party"] = props.Party,
			})
			local customGameServerKeyElement = React.createElement(CustomGameServerKey, {
				["IsCustomGame"] = props.IsCustomGame,
				["IsCustomOwner"] = props.IsCustomOwner,
				["CustomGamePrivacy"] = props.CustomGamePrivacy,
				["CustomGameServerKey"] = props.CustomGameServerKey,
			})
			local lobbyButton = React.createElement(
				Grid,
				{
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["CornerRadius"] = 80,
					["Activated"] = nil,
					["Selectable"] = true,
					["Visible"] = nil,
					["Size"] = UDim2.fromOffset(200, 80),
					["BackgroundColor3"] = Color3.fromRGB(214, 54, 54),
					["Activated"] = function()
						return Flamework.resolveDependency("lB5"):toggle(LeaveGameScreen)
					end,
					["Visible"] = not isFocused,
				},
				React.createElement(
					Grid,
					{
						["Size"] = nil,
						["BackgroundColor3"] = nil,
						["CornerRadius"] = 72,
						["Size"] = UDim2.fromOffset(200, 72),
						["BackgroundColor3"] = Color3.fromRGB(255, 103, 103),
					},
					React.createElement(
						Grid,
						{
							["Size"] = nil,
							["BackgroundColor3"] = nil,
							["CornerRadius"] = 68,
							["Size"] = UDim2.fromOffset(200, 68),
							["BackgroundColor3"] = Color3.fromRGB(242, 77, 77),
						},
						React.createElement(Image, {
							["AnchorPoint"] = Vector2.new(0, 0.5),
							["Position"] = UDim2.new(0, 38, 0.5, 0),
							["Size"] = UDim2.fromOffset(26, 24),
							["Image"] = RobloxImage.Icon.HOUSE,
						}),
						React.createElement(Text, {
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Text"] = "LOBBY",
							["Bold"] = true,
							["AnchorPoint"] = Vector2.new(0, 0.5),
							["Position"] = UDim2.new(0, 76, 0.5, 0),
						})
					)
				)
			)
			local spectateButton
			if GameConstants.POST_GAME_LOBBY_ENABLED and props.GameState == GameState.InGame then
				spectateButton = React.createElement(
					Grid,
					{
						["Size"] = nil,
						["BackgroundColor3"] = nil,
						["CornerRadius"] = 80,
						["Activated"] = nil,
						["Selectable"] = true,
						["Visible"] = nil,
						["Size"] = UDim2.fromOffset(200, 80),
						["BackgroundColor3"] = Color3.fromRGB(50, 160, 255),
						["Activated"] = function()
							return Events.RequestSpectate:fire()
						end,
						["Visible"] = not isFocused,
					},
					React.createElement(
						Grid,
						{
							["Size"] = nil,
							["BackgroundColor3"] = nil,
							["CornerRadius"] = 72,
							["Size"] = UDim2.fromOffset(200, 72),
							["BackgroundColor3"] = Color3.fromRGB(142, 202, 255),
						},
						React.createElement(
							Grid,
							{
								["Size"] = nil,
								["BackgroundColor3"] = nil,
								["CornerRadius"] = 68,
								["Size"] = UDim2.fromOffset(200, 68),
								["BackgroundColor3"] = Color3.fromRGB(89, 178, 255),
							},
							React.createElement(Image, {
								["AnchorPoint"] = Vector2.new(0, 0.5),
								["Position"] = UDim2.new(0, 26, 0.5, 0),
								["Size"] = UDim2.fromOffset(24, 24),
								["Image"] = RobloxImage.Icon.PLAY,
							}),
							React.createElement(Text, {
								["AnchorPoint"] = nil,
								["Position"] = nil,
								["Text"] = "SPECTATE",
								["Bold"] = true,
								["AnchorPoint"] = Vector2.new(0, 0.5),
								["Position"] = UDim2.new(0, 64, 0.5, 0),
							})
						)
					)
				)
			else
				spectateButton = nil
			end
			mainContent = React.createElement(
				Grid,
				gridProps,
				React.createElement(
					React.Fragment,
					nil,
					partyElement,
					customGameServerKeyElement,
					lobbyButton,
					spectateButton
				),
				React.createElement(List)
			)
		end
		local spectatingElement
		if props.Spectating and props.GameState ~= GameState.Ended then
			spectatingElement = React.createElement(Spectating, {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 20, 0.5, 0),
				["UserId"] = props.Spectating.UserId,
				["DisplayName"] = props.Spectating.Name,
				["Color"] = playerColor,
			})
		else
			spectatingElement = nil
		end
		local respawnCountdownElement
		if props.RespawnTime and (props.RespawnTime.Time > os.clock() and props.GameState ~= GameState.Ended) then
			respawnCountdownElement = React.createElement(RespawnCountdown, {
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.new(1, -20, 0.5, 0),
				["RespawnDelay"] = props.RespawnTime.Delay,
				["RespawnTime"] = props.RespawnTime.Time,
			})
		else
			respawnCountdownElement = nil
		end
		return React.createElement(Dock, dockedProps, mainContent, spectatingElement, respawnCountdownElement)
	end,
}
