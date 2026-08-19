-- PartyGui

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
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Separator = RuntimeLib.import(script, script.Parent.Parent, "components", "separator").Separator
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local PartyEmptySlot = RuntimeLib.import(script, script.Parent, "party-empty-slot").PartyEmptySlot
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local PartyLeader = RuntimeLib.import(script, script.Parent, "party-leader").PartyLeader
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local PartyPlayer = RuntimeLib.import(script, script.Parent, "party-player").PartyPlayer
local TextInput = RuntimeLib.import(script, script.Parent.Parent, "components", "text-input").TextInput
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil

local SocialFilterType = {
	["All"] = "All",
	["Friends"] = "Friends",
	["Nearby"] = "Nearby",
}
local ALL_SOCIAL_FILTERS = { SocialFilterType.All, SocialFilterType.Friends, SocialFilterType.Nearby }

type PartyGuiProps = {
	PlayerList: { Player },
	FriendIds: { number },
	Party: { Owner: { UserId: number } },
	Filter: string,
	SetFilter: (filter: string) -> (),
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["PartyGui"] = function(props: PartyGuiProps)
		local players = usePlayers()
		local searchValue: string, setSearchValue: (string) -> () = useState("")
		local playerList = props.PlayerList

		local function filterPlayer(player: Player): boolean
			local query: string | false
			if searchValue == "" then
				query = false
			else
				query = searchValue
			end
			local matches = not query
			if not matches then
				local lowerUserName = string.lower(player.UserName)
				local lowerQuery = string.lower(searchValue)
				local userNameMatch = string.match(lowerUserName, lowerQuery)
				if userNameMatch == 0 or userNameMatch ~= userNameMatch then
					userNameMatch = false
				elseif userNameMatch == "" then
					userNameMatch = false
				end
				matches = userNameMatch and true or false
				if not matches then
					local lowerDisplayName = string.lower(player.DisplayName)
					local lowerQuery2 = string.lower(searchValue)
					local displayNameMatch = string.match(lowerDisplayName, lowerQuery2)
					if displayNameMatch == 0 or displayNameMatch ~= displayNameMatch then
						displayNameMatch = false
					elseif displayNameMatch == "" then
						displayNameMatch = false
					end
					matches = displayNameMatch and true or false
				end
			end
			return matches
		end

		local matchCount = 0
		local filteredPlayers = {}
		for _, player in playerList do
			if filterPlayer(player) == true then
				matchCount = matchCount + 1
				filteredPlayers[matchCount] = player
			end
		end

		local members = PartyUtil.getMembers(props.Party)
		local emptySlots = {}
		for i = #members + 1, 3 do
			local emptySlotElement = React.createElement(PartyEmptySlot, {
				["LayoutOrder"] = i + 1,
			})
			table.insert(emptySlots, emptySlotElement)
		end

		local leaderPlayer = players.GetPlayerByUserId(props.Party.Owner.UserId)
		local leaderProps = {}
		local ownerFriendId = nil
		for _, friendId in props.FriendIds do
			if friendId == leaderPlayer.UserId == true then
				ownerFriendId = friendId
				break
			end
		end
		leaderProps.IsFriend = ownerFriendId ~= nil
		leaderProps.Player = leaderPlayer
		local leaderElement = React.createElement(PartyLeader, leaderProps)

		local memberElements = table.create(#members)
		local function createMemberElement(member: Player, index: number)
			local elementProps = {
				["key"] = member.UserId,
			}
			local foundFriendId = nil
			for _, friendId in props.FriendIds do
				if friendId == member.UserId == true then
					foundFriendId = friendId
					break
				end
			end
			elementProps.IsFriend = foundFriendId ~= nil
			elementProps.Player = member
			elementProps.Party = props.Party
			elementProps.LayoutOrder = index + 1
			return React.createElement(PartyPlayer, elementProps)
		end
		for index, member in members do
			memberElements[index] = createMemberElement(member, index - 1)
		end

		local createElement = React.createElement
		local grid = Grid
		local yourPartyGridProps = {
			["key"] = "YourParty",
			["Position"] = nil,
			["Size"] = nil,
			["Position"] = UDim2.fromOffset(30, 62),
			["Size"] = UDim2.fromOffset(260, 618),
		}
		local membersGrid = React.createElement(
			grid,
			{
				["key"] = "Members",
				["Position"] = nil,
				["AutomaticSize"] = nil,
				["Position"] = UDim2.fromOffset(0, 140),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			memberElements,
			emptySlots,
			React.createElement(List, {
				["Vertical"] = true,
			})
		)
		local leaveButton
		if
			PartyUtil.isOwnerId(players.LocalPlayer.UserId, props.Party)
			and not PartyUtil.isHostingMultiplayerParty(PlayerUtil.toReplicated(players.LocalPlayer), props.Party)
		then
			leaveButton = nil
		else
			leaveButton = React.createElement(Button, {
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.fromScale(0.5, 1),
				["Size"] = { 150, 50 },
				["Text"] = PartyUtil.isOwnerId(players.LocalPlayer.UserId, props.Party) and "Disband" or "Leave",
				["Color"] = Color.Button.Red,
				["Activated"] = function()
					Flamework.resolveDependency("PrB"):leaveParty()
				end,
			})
		end
		local yourPartyElement = createElement(grid, yourPartyGridProps, leaderElement, membersGrid, leaveButton)
		local separatorElement = React.createElement(Separator, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromOffset(320, 62),
			["Size"] = UDim2.fromOffset(3, 618),
		})
		local searchInput = React.createElement(TextInput, {
			["Size"] = nil,
			["PlaceholderText"] = "Search player...",
			["Value"] = "",
			["SetValue"] = nil,
			["Size"] = UDim2.fromOffset(300, 50),
			["SetValue"] = setSearchValue,
		})
		local filterButtons = table.create(#ALL_SOCIAL_FILTERS)
		local function createFilterButton(filterName: string, index: number)
			local button = Button
			local buttonProps = {
				["Size"] = nil,
				["Text"] = nil,
				["TextSize"] = 24,
				["Color"] = nil,
				["LayoutOrder"] = nil,
				["Activated"] = nil,
				["Size"] = { "auto", 50 },
				["Text"] = filterName,
			}
			local buttonColor
			if props.Filter == filterName then
				buttonColor = Color.Button.Green
			else
				buttonColor = Color.Button.Grey
			end
			buttonProps.Color = buttonColor
			buttonProps.LayoutOrder = index + 1
			function buttonProps.Activated()
				props.SetFilter(filterName)
			end
			return createElement(button, buttonProps)
		end
		for index, filterName in ALL_SOCIAL_FILTERS do
			filterButtons[index] = createFilterButton(filterName, index - 1)
		end
		local filterButtonsGrid = React.createElement(
			grid,
			{
				["key"] = "FilterButtons",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["AutomaticSize"] = nil,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			filterButtons,
			React.createElement(List, {
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			})
		)
		local searchResultElements = table.create(#filteredPlayers)
		local function createSearchResultElement(player: Player, index: number)
			local elementProps = {
				["key"] = player.UserId,
			}
			local foundFriendId = nil
			for _, friendId in props.FriendIds do
				if friendId == player.UserId == true then
					foundFriendId = friendId
					break
				end
			end
			elementProps.IsFriend = foundFriendId ~= nil
			elementProps.Player = player
			elementProps.Party = props.Party
			elementProps.LayoutOrder = index
			return React.createElement(PartyPlayer, elementProps)
		end
		for index, player in filteredPlayers do
			searchResultElements[index] = createSearchResultElement(player, index - 1)
		end

		local window = Window
		local windowProps = {
			["key"] = "Party",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleText"] = "YOUR PARTY",
			["TitleImage"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1240, 710),
			["TitleImage"] = RobloxImage.Icon.ARROW,
		}
		local pageGridProps = {
			["key"] = "Page",
			["Position"] = nil,
			["Size"] = nil,
			["Position"] = UDim2.fromOffset(350, 62),
			["Size"] = UDim2.fromOffset(840, 618),
		}
		local scrollingFrameProps = {
			["key"] = "PlayerList",
			["Position"] = nil,
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 10,
			["ScrollBarImageColor3"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["Position"] = UDim2.fromOffset(0, 70),
			["Size"] = UDim2.fromOffset(840, 548),
		}
		local rowCount = #props.PlayerList / 3
		scrollingFrameProps.CanvasSize = UDim2.fromOffset(0, ScreenUtil.getGridSize(112, 10, math.ceil(rowCount)))
		scrollingFrameProps.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollingFrameProps.ScrollBarImageColor3 = Color.White
		return createElement(
			window,
			windowProps,
			yourPartyElement,
			separatorElement,
			createElement(
				grid,
				pageGridProps,
				searchInput,
				filterButtonsGrid,
				createElement(
					"scrollingframe",
					scrollingFrameProps,
					searchResultElements,
					React.createElement("uigridlayout", {
						["FillDirection"] = nil,
						["FillDirectionMaxCells"] = 3,
						["CellSize"] = nil,
						["CellPadding"] = nil,
						["SortOrder"] = nil,
						["FillDirection"] = Enum.FillDirection.Horizontal,
						["CellSize"] = UDim2.fromOffset(260, 112),
						["CellPadding"] = UDim2.fromOffset(10, 10),
						["SortOrder"] = Enum.SortOrder.LayoutOrder,
					})
				)
			)
		)
	end,
	["SocialFilterType"] = SocialFilterType,
}
