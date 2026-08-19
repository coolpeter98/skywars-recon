-- LobbyDock

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
local DockProfile = RuntimeLib.import(script, script.Parent, "dock-profile").DockProfile
local DockParty = RuntimeLib.import(script, script.Parent, "dock-party").DockParty
local DockStats = RuntimeLib.import(script, script.Parent, "dock-stats").DockStats
local MobileDock = RuntimeLib.import(script, script.Parent.Parent, "mobile-dock").MobileDock
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local LeaveGameScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "leave-game", "leave-game-screen").LeaveGameScreen
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local DockVerifyButton = RuntimeLib.import(script, script.Parent, "dock-verify-button").DockVerifyButton
local CustomGameServerKey =
	RuntimeLib.import(script, script.Parent.Parent, "custom-game-server-key").CustomGameServerKey
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "events").Events
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local useFocused = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-focused").useFocused

type LobbyDockProps = {
	CustomGame: { ServerData: { InGame: boolean } }?,
	Party: any,
	IsCustomGame: boolean,
	IsCustomOwner: boolean,
	CustomGamePrivacy: any,
	CustomGameServerKey: any,
	SelfView: {
		UserId: number,
		Name: string,
		Experience: number,
		Rank: any,
	},
	GameState: any,
	ShowVerify: boolean,
}

return {
	LobbyDock = function(props: LobbyDockProps)
		local focused = useFocused()
		local isMobile = ScreenUtil.isMobile()

		local isMobileLobby
		if isMobile then
			isMobileLobby = PlaceUtil.isLobbyServer()
			if not isMobileLobby then
				isMobileLobby = PlaceUtil.isPrivateServer()
				if isMobileLobby then
					local customGame = props.CustomGame
					local inGame: boolean? = nil
					if customGame ~= nil then
						inGame = customGame.ServerData.InGame
					end
					isMobileLobby = inGame == false
				end
			end
		else
			isMobileLobby = isMobile
		end

		local dockProps = table.clone(props)
		setmetatable(dockProps, nil)
		dockProps.Hidden = isMobile

		local createElement = React.createElement
		local Fragment = React.Fragment

		local dock
		if focused then
			dock = nil
		else
			local gridProps = {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 0, -50),
				Size = UDim2.fromOffset(500, 80),
			}
			local dockParty = createElement(DockParty, {
				Party = props.Party,
			})
			local customGameServerKey = createElement(CustomGameServerKey, {
				IsCustomGame = props.IsCustomGame,
				IsCustomOwner = props.IsCustomOwner,
				CustomGamePrivacy = props.CustomGamePrivacy,
				CustomGameServerKey = props.CustomGameServerKey,
			})

			local leaveGameButton
			if PlaceUtil.isGameServer() or PlaceUtil.isPrivateServer() then
				leaveGameButton = createElement(
					Grid,
					{
						CornerRadius = 80,
						Selectable = true,
						Size = UDim2.fromOffset(200, 80),
						BackgroundColor3 = Color3.fromRGB(214, 54, 54),
						Activated = function()
							return Flamework.resolveDependency("lB5"):toggle(LeaveGameScreen)
						end,
						Visible = not focused,
					},
					createElement(
						Grid,
						{
							CornerRadius = 72,
							Size = UDim2.fromOffset(200, 72),
							BackgroundColor3 = Color3.fromRGB(255, 103, 103),
						},
						createElement(
							Grid,
							{
								CornerRadius = 68,
								Size = UDim2.fromOffset(200, 68),
								BackgroundColor3 = Color3.fromRGB(242, 77, 77),
							},
							createElement(Image, {
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 38, 0.5, 0),
								Size = UDim2.fromOffset(26, 24),
								Image = RobloxImage.Icon.HOUSE,
							}),
							createElement(Text, {
								Text = "LOBBY",
								Bold = true,
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 76, 0.5, 0),
							})
						)
					)
				)
			else
				leaveGameButton = nil
			end

			local spectateButton
			if GameConstants.POST_GAME_LOBBY_ENABLED and props.GameState == GameState.InGame then
				spectateButton = createElement(
					Grid,
					{
						CornerRadius = 80,
						Selectable = true,
						Size = UDim2.fromOffset(200, 80),
						BackgroundColor3 = Color3.fromRGB(50, 160, 255),
						Activated = function()
							return Events.RequestSpectate:fire()
						end,
						Visible = not focused,
					},
					createElement(
						Grid,
						{
							CornerRadius = 72,
							Size = UDim2.fromOffset(200, 72),
							BackgroundColor3 = Color3.fromRGB(142, 202, 255),
						},
						createElement(
							Grid,
							{
								CornerRadius = 68,
								Size = UDim2.fromOffset(200, 68),
								BackgroundColor3 = Color3.fromRGB(89, 178, 255),
							},
							createElement(Image, {
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 26, 0.5, 0),
								Size = UDim2.fromOffset(24, 24),
								Image = RobloxImage.Icon.PLAY,
							}),
							createElement(Text, {
								Text = "SPECTATE",
								Bold = true,
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 64, 0.5, 0),
							})
						)
					)
				)
			else
				spectateButton = nil
			end

			dock = createElement(
				Grid,
				gridProps,
				dockParty,
				customGameServerKey,
				leaveGameButton,
				spectateButton,
				createElement(List)
			)
		end

		local desktopDockContent
		if isMobileLobby then
			desktopDockContent = nil
		else
			desktopDockContent = createElement(
				Fragment,
				nil,
				createElement(DockProfile, {
					MobileLayout = false,
					UserId = props.SelfView.UserId,
					DisplayName = props.SelfView.Name,
					Experience = props.SelfView.Experience,
					GameState = props.GameState,
					Rank = props.SelfView.Rank,
					ShowVerify = props.ShowVerify,
				}),
				createElement(DockStats, {
					MobileLayout = false,
				})
			)
		end

		local dockElement = createElement(Dock, dockProps, dock, desktopDockContent)

		local mobileDock
		if isMobileLobby then
			local mobileProfile = createElement(DockProfile, {
				MobileLayout = true,
				UserId = props.SelfView.UserId,
				DisplayName = props.SelfView.Name,
				Experience = props.SelfView.Experience,
				GameState = props.GameState,
				Rank = props.SelfView.Rank,
				ShowVerify = props.ShowVerify,
			})
			local mobileStats = createElement(DockStats, {
				MobileLayout = true,
			})

			local verifyButton
			if Flamework.resolveDependency("0dL"):isVerified() or not props.ShowVerify then
				verifyButton = nil
			else
				verifyButton = createElement(DockVerifyButton, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 10, 0, 405),
					MobileLayout = true,
				})
			end

			mobileDock = createElement(MobileDock, nil, mobileProfile, mobileStats, verifyButton)
		else
			mobileDock = nil
		end

		return createElement(Fragment, nil, dockElement, mobileDock)
	end,
}
