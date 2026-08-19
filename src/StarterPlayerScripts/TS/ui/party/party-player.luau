-- PartyPlayer

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
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local useLevel = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-level").useLevel
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local TextService: TextService = Services.TextService
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local PartyInstance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance")
local PartyUtil = PartyInstance.PartyUtil
local SocialStatus = PartyInstance.SocialStatus
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GlobalStoreChanged = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").GlobalStoreChanged
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent, "events").Events
local getStatus

type PartyPlayerProps = {
	Player: {
		UserId: number,
		DisplayName: string,
		Status: string,
		PlaceId: number?,
		GameId: string?,
	},
	Party: any,
	LayoutOrder: number,
	IsFriend: boolean,
}

local function PartyPlayer(props: PartyPlayerProps)
	local players = usePlayers()
	local level = useLevel(props.Player)
	local levelColour = ColorUtil.getLevelColour(level)
	local displayNameSize =
		TextService:GetTextSize(props.Player.DisplayName, 24, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
	local inParty = PartyUtil.isInParty(props.Player, props.Party)
	local isOwner = PartyUtil.isOwnerId(players.LocalPlayer.UserId, props.Party)
	local status = getStatus(props.Player)
	local statusText = status[1]
	local statusColor = status[2]
	local canJoin
	if isOwner and inParty then
		canJoin = inParty
	elseif statusText == "In Lobby" then
		canJoin = not Players:GetPlayerByUserId(props.Player.UserId)
	else
		canJoin = false
	end
	local isBusy = not isOwner
	if isBusy then
		isBusy = not canJoin
	end
	local createElement = React.createElement
	local grid = Grid
	local rootProps = {
		["key"] = "Player",
		["Size"] = nil,
		["LayoutOrder"] = nil,
		["Size"] = UDim2.fromOffset(260, 112),
		["LayoutOrder"] = props.LayoutOrder,
	}
	local createElement = React.createElement
	local grid = Grid
	local viewportClippingProps = {
		["key"] = "ViewportBackgroundClipping",
		["Size"] = nil,
		["ClipsDescendants"] = nil,
		["Size"] = UDim2.fromOffset(260, 70),
		["ClipsDescendants"] = not isBusy,
	}
	local viewportBackground = createElement(
		Grid,
		{
			["key"] = "ViewportBackground",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Size"] = UDim2.fromOffset(260, (isBusy and 42 or 10) + 70),
		},
		createElement(CornerRadius, {
			["Radius"] = 10,
		})
	)
	local playerIcon = createElement(PlayerIcon, {
		["key"] = "PlayerIcon",
		["Position"] = nil,
		["Size"] = nil,
		["UserId"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0,
		["CornerRadius"] = nil,
		["ZIndex"] = 5,
		["Position"] = UDim2.fromOffset(10, 10),
		["Size"] = UDim2.fromOffset(50, 50),
		["UserId"] = props.Player.UserId,
		["BackgroundColor3"] = levelColour,
		["CornerRadius"] = UDim.new(1),
	})
	local titleElement = createElement(Text, {
		["key"] = "Title",
		["Position"] = nil,
		["Text"] = nil,
		["TextSize"] = 16,
		["TextColor3"] = nil,
		["Bold"] = true,
		["ZIndex"] = 5,
		["Position"] = UDim2.fromOffset(70, 10),
		["Text"] = string.upper(statusText),
		["TextColor3"] = statusColor,
	})
	local playerNameElement = createElement(Text, {
		["key"] = "PlayerName",
		["Position"] = nil,
		["Size"] = nil,
		["Text"] = nil,
		["TextSize"] = 24,
		["TextColor3"] = nil,
		["Bold"] = true,
		["ZIndex"] = 5,
		["Position"] = UDim2.fromOffset(70, 28),
		["Size"] = UDim2.fromOffset(displayNameSize.X, displayNameSize.Y),
		["Text"] = props.Player.DisplayName,
		["TextColor3"] = Color.White,
	})
	local friendElement
	if props.IsFriend then
		friendElement = createElement(Image, {
			["key"] = "Friend",
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ImageColor3"] = nil,
			["ZIndex"] = 5,
			["Position"] = UDim2.fromOffset(70 + displayNameSize.X + 6, 30),
			["Size"] = UDim2.fromOffset(20, 20),
			["Image"] = RobloxImage.Icon.PEOPLE,
			["ImageColor3"] = Color.Green,
		})
	else
		friendElement = nil
	end
	local viewportColumn = createElement(
		grid,
		viewportClippingProps,
		viewportBackground,
		playerIcon,
		titleElement,
		playerNameElement,
		friendElement
	)
	local leftButton
	if isOwner then
		leftButton = createElement(
			Grid,
			{
				["key"] = "LeftButtonClipping",
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Position"] = UDim2.fromOffset(0, 70),
				["Size"] = UDim2.fromOffset(canJoin and 130 or 260, 42),
			},
			createElement(Button, {
				["key"] = "LeftButton",
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = nil,
				["Color"] = nil,
				["TextOffsetX"] = nil,
				["TextOffsetY"] = 5,
				["Activated"] = nil,
				["Position"] = UDim2.fromOffset(0, -10),
				["Size"] = { canJoin and 140 or 260, 52 },
				["Text"] = inParty and "PROMOTE" or "INVITE",
				["Color"] = Color.Button.Blue,
				["TextOffsetX"] = canJoin and -5 or 0,
				["Activated"] = function()
					if inParty then
						Flamework.resolveDependency("PrB"):promotePlayer(props.Player)
						return nil
					elseif
						props.Player.Status == SocialStatus.InGame
						and (
							props.Player.PlaceId ~= nil
							and (props.Player.PlaceId ~= 0 and PlaceUtil.isOurUniverse(props.Player.PlaceId))
						)
					then
						Flamework.resolveDependency("PrB"):invitePlayer(props.Player, false)
					else
						Flamework.resolveDependency("PrB"):invitePlayer(props.Player, true)
						local partyId = Flamework.resolveDependency("PrB"):getPartyId()
						if partyId == "" or not partyId then
							local connection = nil
							connection = GlobalStoreChanged("Party", function(_)
								Flamework.resolveDependency("PrB"):sendOfflineInvite(props.Player.UserId)
								connection:disconnect()
							end)
							return nil
						end
						Flamework.resolveDependency("PrB"):sendOfflineInvite(props.Player.UserId)
					end
				end,
			})
		)
	else
		leftButton = nil
	end
	local rightButton
	if canJoin then
		local createElement = React.createElement
		local grid = Grid
		local rightClippingProps = {
			["key"] = "RightButtonClipping",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, 0, 0, 70),
			["Size"] = UDim2.fromOffset(isOwner and 130 or 260, 42),
		}
		local createElement = React.createElement
		local button = Button
		local rightButtonProps = {
			["key"] = "RightButton",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["Color"] = nil,
			["TextOffsetX"] = nil,
			["TextOffsetY"] = 5,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, 0, 0, -10),
			["Size"] = { isOwner and 140 or 260, 52 },
			["Text"] = isOwner and inParty and "KICK" or "JOIN",
		}
		local rightButtonColor
		if isOwner and inParty then
			rightButtonColor = Color.Button.Red
		else
			rightButtonColor = Color.Button.Green
		end
		rightButtonProps.Color = rightButtonColor
		rightButtonProps.TextOffsetX = isOwner and 5 or 0
		function rightButtonProps.Activated()
			if inParty then
				Flamework.resolveDependency("PrB"):removePlayer(props.Player.UserId)
				return nil
			end
			if props.Player.Status == SocialStatus.InGame then
				Events.JoinGame(props.Player.GameId)
			end
		end
		rightButton = createElement(grid, rightClippingProps, createElement(button, rightButtonProps))
	else
		rightButton = nil
	end
	return createElement(grid, rootProps, viewportColumn, leftButton, rightButton)
end
getStatus = function(player)
	if player.Status == SocialStatus.InGame then
		return (player.PlaceId == nil or (player.PlaceId == 0 or not PlaceUtil.isOurUniverse(player.PlaceId)))
				and { "On Roblox", Color.LightBlue }
			or (
				PlaceUtil.isLobbyServer(player.PlaceId) and { "In Lobby", Color.Green }
				or (
					PlaceUtil.isGamePlace(player.PlaceId) and { "In Game", Color.Green }
					or (
						PlaceUtil.isDuelsServer(player.PlaceId) and { "In Duels", Color.Green }
						or { "In Custom", Color.Green }
					)
				)
			)
	else
		return player.Status == SocialStatus.Online and { "On Roblox", Color.LightBlue } or { "Offline", Color.Grey }
	end
end
return {
	["PartyPlayer"] = PartyPlayer,
}
