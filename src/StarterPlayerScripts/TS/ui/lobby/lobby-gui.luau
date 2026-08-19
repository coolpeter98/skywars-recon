-- LobbyGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local LobbyDock = RuntimeLib.import(script, script.Parent.Parent, "dock", "lobby", "lobby-dock").LobbyDock
local GameDock = RuntimeLib.import(script, script.Parent.Parent, "dock", "game", "game-dock").GameDock
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local useScreenDependency =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-screen-dependency").useScreenDependency
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
local SeasonPassSale = RuntimeLib.import(script, script.Parent.Parent, "components", "season-pass-sale").SeasonPassSale

type LobbyGuiProps = {
	InLobby: boolean,
}

return {
	["LobbyGui"] = function(props: LobbyGuiProps)
		local players = usePlayers()
		local gameState = useGlobalStore("GameState")
		useGlobalStore("QueueStartTime")
		local party = useGlobalStore("Party")
		local profile = useGlobalStore("Profile")
		local customGame = useGlobalStore("CustomGame")
		local respawnTime = useGlobalStore("RespawnTime")
		local spectating = useGlobalStore("Spectating")
		local showVerify = useGlobalStore("ShowVerify")
		local screenDependency = useScreenDependency({
			["ScreenId"] = "EndGame",
		})
		local playerData = not RunService:IsRunning()
				and {
					["UserId"] = 1800687521,
					["UserName"] = "Sobkiv2",
					["DisplayName"] = "Jay",
				}
			or PlayerUtil.toReplicated(Players.LocalPlayer)
		local isPartyOwner = PartyUtil.canQueue(playerData, party)
		local customGameOwnerId
		if customGame == nil then
			customGameOwnerId = customGame
		else
			customGameOwnerId = customGame.ServerData.OwnerId
		end
		local isCustomOwner = customGameOwnerId == playerData.UserId or RunService:IsStudio()
		local isCustomGameOverFull
		if customGame then
			isCustomGameOverFull = customGame.ServerData.PlayersOnline > customGame.Settings.MaxPlayers
		else
			isCustomGameOverFull = false
		end
		local dockProps = {
			["IsPartyOwner"] = isPartyOwner,
			["IsGameServer"] = PlaceUtil.isGameServer(),
			["IsCustomGame"] = PlaceUtil.isPrivateServer(),
			["IsCustomOwner"] = isCustomOwner,
			["IsCustomGameOverFull"] = isCustomGameOverFull,
		}
		local customGamePrivacy
		if customGame == nil then
			customGamePrivacy = customGame
		else
			customGamePrivacy = customGame.ServerData.Privacy
		end
		dockProps.CustomGamePrivacy = customGamePrivacy
		local customGameServerKey
		if customGame == nil then
			customGameServerKey = customGame
		else
			customGameServerKey = customGame.ServerData.ServerKey
		end
		dockProps.CustomGameServerKey = customGameServerKey
		dockProps.ShowVerify = showVerify
		local rank = players.LocalPlayer:GetAttribute(Attribute.Rank)
		local showSeasonPassSale = not (ScreenUtil.isMobile() and screenDependency.IsOpen)
		if showSeasonPassSale then
			local respawnTimeValue
			if respawnTime == nil then
				respawnTimeValue = respawnTime
			else
				respawnTimeValue = respawnTime.Time
			end
			showSeasonPassSale = respawnTimeValue == nil
		end
		local seasonPassSaleElement
		if showSeasonPassSale then
			seasonPassSaleElement = React.createElement(
				React.Fragment,
				nil,
				React.createElement(SeasonPassSale, {
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 40, 0, 30),
				})
			)
		else
			seasonPassSaleElement = nil
		end
		local dockElement
		if props.InLobby or gameState == GameState.Ended then
			local lobbyDockProps = table.clone(dockProps)
			setmetatable(lobbyDockProps, nil)
			local selfView = {
				["Name"] = playerData.DisplayName,
				["UserId"] = playerData.UserId,
				["Experience"] = profile.Experience,
			}
			if rank == 0 or (rank ~= rank or (rank == "" or not rank)) then
				rank = nil
			end
			selfView.Rank = rank
			lobbyDockProps.SelfView = selfView
			lobbyDockProps.Party = party
			lobbyDockProps.GameState = gameState
			lobbyDockProps.CustomGame = customGame
			dockElement = React.createElement(LobbyDock, lobbyDockProps)
		else
			local gameDockProps = table.clone(dockProps)
			setmetatable(gameDockProps, nil)
			gameDockProps.GameState = gameState
			gameDockProps.RespawnTime = respawnTime
			gameDockProps.Spectating = spectating
			gameDockProps.Party = party
			dockElement = React.createElement(GameDock, gameDockProps)
		end
		return React.createElement(React.Fragment, nil, seasonPassSaleElement, dockElement)
	end,
}
