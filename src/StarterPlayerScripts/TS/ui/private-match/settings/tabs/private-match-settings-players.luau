-- PrivateMatchSettingsPlayers

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local PrivateMatchPage = RuntimeLib.import(script, script.Parent.Parent.Parent, "private-match-page").PrivateMatchPage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PrivateMatchSettingsPlayer = RuntimeLib.import(script, script.Parent, "private-match-settings-player").PrivateMatchSettingsPlayer
local usePlayerSearch = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-player-search").usePlayerSearch
local TextInput = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text-input").TextInput

type Props = {
	Settings: {
		MaxPlayers: number,
		Teams: any,
	},
}

return {
	["PrivateMatchSettingsPlayers"] = function(props: Props)
		local searchQuery, setSearchQuery = useState("")
		local players = usePlayerSearch(searchQuery)
		local playerCount = #players
		local contentHeight = playerCount * 84 + (playerCount - 1) * 10

		local playersText = React.createElement(Text, {
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(0, 11),
			["Text"] = ("Players \240\159\145\165  %*/%*"):format(#players, props.Settings.MaxPlayers)
		})
		local searchInput = React.createElement(TextInput, {
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
			["SetValue"] = setSearchQuery
		})
		local playerElements = table.create(#players)
		for index, player in players do
			local _ = index - 1
			playerElements[index] = React.createElement(PrivateMatchSettingsPlayer, {
				["Teams"] = props.Settings.Teams,
				["Player"] = player
			})
		end
		return React.createElement(PrivateMatchPage, nil, playersText, searchInput, React.createElement("scrollingframe", {
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
			["CanvasSize"] = UDim2.fromOffset(0, contentHeight),
			["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			["ScrollBarImageColor3"] = Color.White
		}, playerElements, React.createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Vertical,
			["Padding"] = UDim.new(0, 10),
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		})))
	end
}
