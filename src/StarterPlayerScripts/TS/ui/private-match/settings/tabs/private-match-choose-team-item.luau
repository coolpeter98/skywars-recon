-- PrivateMatchChooseTeamItem

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
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "button").Button
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local Separator = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "separator").Separator
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "player-icon").PlayerIcon

type PrivateMatchChooseTeamItemProps = {
	Team: {
		Players: { [any]: any },
		MaxPlayers: number,
		Name: string,
		Color: Color3,
		Id: string,
	},
	AllowTeamSelection: boolean,
}

return {
	["PrivateMatchChooseTeamItem"] = function(props: PrivateMatchChooseTeamItemProps)
		local players = {}
		local index = #players
		for userId in props.Team.Players do
			index = index + 1
			players[index] = userId
		end
		local playerIds: { number } = table.create(#players)
		for index, userId in players do
			local _ = index - 1
			playerIds[index] = tonumber(userId)
		end
		local teamPlayers: { Player } = PlayerUtil.getPlayers(playerIds)
		local playersByUserId = props.Team.Players
		local localPlayerId: number = Players.LocalPlayer.UserId
		local isOnTeam: boolean = playersByUserId[tostring(localPlayerId)] ~= nil
		local playerCount = 0
		for _ in props.Team.Players do
			playerCount = playerCount + 1
		end
		local isFull: boolean = props.Team.MaxPlayers <= playerCount
		local layoutOrderCount = 0
		local gridProps = {}
		for _ in props.Team.Players do
			layoutOrderCount = layoutOrderCount + 1
		end
		gridProps.LayoutOrder = -layoutOrderCount
		local teamHeader = React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 15),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(
				Grid,
				{
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["LayoutOrder"] = 1,
					["Size"] = UDim2.fromOffset(30, 30),
					["BackgroundColor3"] = props.Team.Color,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			),
			React.createElement(Text, {
				["Text"] = nil,
				["TextColor3"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["LayoutOrder"] = 2,
				["Text"] = props.Team.Name,
				["TextColor3"] = Color.White,
			}),
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["Padding"] = UDim.new(0, 10),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
				["VerticalAlignment"] = Enum.VerticalAlignment.Center,
			})
		)
		local separatorElement = React.createElement(Separator, {
			["AnchorPoint"] = Vector2.new(),
			["Position"] = UDim2.fromOffset(10, 60),
			["Size"] = UDim2.fromOffset(190, 3),
		})
		local playerIcons = table.create(#teamPlayers)
		local function renderPlayerIcon(player: Player, index: number)
			if index >= 6 then
				return React.createElement(React.Fragment)
			end
			local isLocalPlayer: boolean = player == Players.LocalPlayer
			local iconGridProps = {
				["LayoutOrder"] = isLocalPlayer and 1 or 2,
			}
			local content
			if #teamPlayers > 6 and index == 5 then
				content = React.createElement(Text, {
					["Text"] = ("+%*"):format(#teamPlayers - 5),
				})
			else
				content = React.createElement(PlayerIcon, {
					["Size"] = UDim2.fromScale(1, 1),
					["UserId"] = player.UserId,
					["CornerRadius"] = UDim.new(1, 0),
				})
			end
			local strokeProps = {
				["Color"] = nil,
				["Thickness"] = 1.5,
			}
			local strokeColor: Color3
			if isLocalPlayer then
				strokeColor = Color.HealthGreen
			else
				strokeColor = Color.White
			end
			strokeProps.Color = strokeColor
			return React.createElement(
				Grid,
				iconGridProps,
				content,
				React.createElement("uistroke", strokeProps),
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			)
		end
		for index, player in teamPlayers do
			playerIcons[index] = renderPlayerIcon(player, index - 1, teamPlayers)
		end
		local container = React.createElement(
			Grid,
			{
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["Size"] = UDim2.fromOffset(210, 205),
			},
			teamHeader,
			separatorElement,
			React.createElement(
				Grid,
				{
					["Position"] = UDim2.fromOffset(20, 75),
					["AutomaticSize"] = Enum.AutomaticSize.XY,
				},
				playerIcons,
				React.createElement("uigridlayout", {
					["FillDirection"] = nil,
					["FillDirectionMaxCells"] = 3,
					["CellSize"] = nil,
					["CellPadding"] = nil,
					["SortOrder"] = nil,
					["FillDirection"] = Enum.FillDirection.Horizontal,
					["CellSize"] = UDim2.fromOffset(50, 50),
					["CellPadding"] = UDim2.fromOffset(10, 10),
					["SortOrder"] = Enum.SortOrder.LayoutOrder,
				})
			),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local buttonProps = {
			["Position"] = UDim2.fromOffset(0, 215),
			["Size"] = { 210, 50 },
		}
		local buttonColor
		if isOnTeam then
			buttonColor = Color.Button.Red
		elseif isFull then
			buttonColor = Color.Button.Blue
		else
			buttonColor = Color.Button.Green
		end
		buttonProps.Color = buttonColor
		buttonProps.Text = isOnTeam and "Leave" or (isFull and "Full" or "Join")
		buttonProps.Disabled = not props.AllowTeamSelection
		function buttonProps.Activated()
			if isOnTeam then
				Flamework.resolveDependency("kXp"):leaveTeam()
			elseif not isFull then
				Flamework.resolveDependency("kXp"):joinTeam(props.Team.Id)
			end
		end
		return React.createElement(Grid, gridProps, container, React.createElement(Button, buttonProps))
	end,
}
