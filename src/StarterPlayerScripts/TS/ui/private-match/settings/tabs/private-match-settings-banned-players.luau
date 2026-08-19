-- PrivateMatchSettingsBannedPlayers

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local PrivateMatchPage = RuntimeLib.import(script, script.Parent.Parent.Parent, "private-match-page").PrivateMatchPage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local TextInput = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text-input").TextInput
local PrivateMatchSettingsBannedPlayer =
	RuntimeLib.import(script, script.Parent, "private-match-settings-banned-player").PrivateMatchSettingsBannedPlayer

type Props = {
	ServerData: {
		BannedPlayers: { { DisplayName: string } },
	},
}

local function PrivateMatchSettingsBannedPlayers(props: Props)
	local searchQuery: string, setSearchQuery: (string) -> () = useState("")
	local bannedPlayers = props.ServerData.BannedPlayers

	local function matchesSearch(player: { DisplayName: string }): boolean
		local searchTerm
		if searchQuery == "" then
			searchTerm = false
		else
			searchTerm = searchQuery
		end

		local isMatch = not searchTerm
		if not isMatch then
			local playerName = string.lower(player.DisplayName)
			local query = string.lower(searchQuery)
			local matchIndex = string.match(playerName, query)
			if matchIndex == 0 or matchIndex ~= matchIndex then
				matchIndex = false
			elseif matchIndex == "" then
				matchIndex = false
			end
			isMatch = matchIndex and true or false
		end
		return isMatch
	end

	local filteredCount = 0
	local filteredPlayers = {}
	for index, player in bannedPlayers do
		if matchesSearch(player, index - 1, bannedPlayers) == true then
			filteredCount = filteredCount + 1
			filteredPlayers[filteredCount] = player
		end
	end

	local numFiltered = #filteredPlayers
	local canvasHeight = numFiltered * 84 + (numFiltered - 1) * 10

	local titleElement = React.createElement(Text, {
		["Position"] = nil,
		["Text"] = nil,
		["Bold"] = true,
		["FixSize"] = true,
		["Position"] = UDim2.fromOffset(0, 11),
		["Text"] = ("Banned Players \240\159\145\165  %*/%*"):format(#filteredPlayers, #props.ServerData.BannedPlayers),
	})

	local searchInputElement = React.createElement(TextInput, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["PlaceholderText"] = "Search player...",
		["Value"] = nil,
		["SetValue"] = nil,
		["AnchorPoint"] = Vector2.new(1, 0),
		["Position"] = UDim2.new(1, -40, 0, 0),
		["Size"] = UDim2.fromOffset(325, 50),
		["Value"] = searchQuery,
		["SetValue"] = setSearchQuery,
	})

	local playerElements = table.create(#filteredPlayers)
	for index, player in filteredPlayers do
		local _ = index - 1
		playerElements[index] = React.createElement(PrivateMatchSettingsBannedPlayer, {
			["Player"] = player,
		})
	end

	return React.createElement(
		PrivateMatchPage,
		nil,
		titleElement,
		searchInputElement,
		React.createElement(
			"scrollingframe",
			{
				["Position"] = nil,
				["Size"] = nil,
				["CanvasSize"] = nil,
				["ScrollingDirection"] = nil,
				["ScrollBarThickness"] = 10,
				["ScrollBarImageColor3"] = nil,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Selectable"] = false,
				["Position"] = UDim2.fromOffset(0, 80),
				["Size"] = UDim2.fromOffset(690, 460),
				["CanvasSize"] = UDim2.fromOffset(0, canvasHeight),
				["ScrollingDirection"] = Enum.ScrollingDirection.Y,
				["ScrollBarImageColor3"] = Color.White,
			},
			playerElements,
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Vertical,
				["Padding"] = UDim.new(0, 10),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			})
		)
	)
end

return {
	["PrivateMatchSettingsBannedPlayers"] = PrivateMatchSettingsBannedPlayers,
}
