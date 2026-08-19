-- LeaderboardGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local useState = React.useState
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Dropdown = RuntimeLib.import(script, script.Parent.Parent, "components", "dropdown", "dropdown").Dropdown
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Leaderboard = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "leaderboard", "leaderboard")
local Granularity = Leaderboard.Granularity
local LeaderboardType = Leaderboard.LeaderboardType
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local LeaderboardList = RuntimeLib.import(script, script.Parent, "leaderboard-list").LeaderboardList
local TextInput = RuntimeLib.import(script, script.Parent.Parent, "components", "text-input").TextInput
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
return {
	["LeaderboardGui"] = function(_)
		local scrollingFrameRef = useRef()
		local leaderboardType, setLeaderboardType = useState(LeaderboardType.Global)
		local granularity, setGranularity = useState(Granularity.All)
		local gameMode, setGameMode = useState(GameMode.SkyWarsSolo)
		local statistic, setStatistic = useState(Statistic.Wins)
		local searchValue, setSearchValue = useState("")
		local textProps = getTextProps({
			["Text"] = "Leaderboards are in BETA and may be reset at any time. Feel free to report any issues you run in to!",
			["TextSize"] = 20,
			["FrameSize"] = nil,
			["FrameSize"] = Vector2.new(180, 230),
		})
		local createElement = React.createElement
		local dropdown = Dropdown
		local leaderboardTypeProps = {
			["key"] = "LeaderboardType",
			["Position"] = nil,
			["Size"] = nil,
			["SelectedId"] = nil,
			["SetSelectedId"] = nil,
			["Items"] = nil,
			["Position"] = UDim2.fromOffset(30, 62),
			["Size"] = Size.new(220, 50),
			["SelectedId"] = leaderboardType,
			["SetSelectedId"] = function(value)
				return setLeaderboardType(value)
			end,
			["Items"] = {
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Global",
					["Id"] = LeaderboardType.Global,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Friends",
					["Id"] = LeaderboardType.Friends,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Personal",
					["Id"] = LeaderboardType.Personal,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
			},
		}
		local leaderboardTypeDropdown = createElement(dropdown, leaderboardTypeProps)
		local createElement = React.createElement
		local dropdown = Dropdown
		local granularityProps = {
			["key"] = "Granularity",
			["Position"] = nil,
			["Size"] = nil,
			["SelectedId"] = nil,
			["SetSelectedId"] = nil,
			["Items"] = nil,
			["Position"] = UDim2.fromOffset(30, 122),
			["Size"] = Size.new(220, 50),
			["SelectedId"] = granularity,
			["SetSelectedId"] = function(value)
				return setGranularity(value)
			end,
			["Items"] = {
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "All",
					["Id"] = Granularity.All,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Day",
					["Id"] = Granularity.Day,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Week",
					["Id"] = Granularity.Week,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Month",
					["Id"] = Granularity.Month,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Year",
					["Id"] = Granularity.Year,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
			},
		}
		local granularityDropdown = createElement(dropdown, granularityProps)
		local createElement = React.createElement
		local dropdown = Dropdown
		local gameModeProps = {
			["key"] = "GameMode",
			["Position"] = nil,
			["Size"] = nil,
			["SelectedId"] = nil,
			["SetSelectedId"] = nil,
			["Items"] = nil,
			["Position"] = UDim2.fromOffset(30, 182),
			["Size"] = Size.new(220, 50),
			["SelectedId"] = gameMode,
			["SetSelectedId"] = function(value)
				return setGameMode(value)
			end,
			["Items"] = {
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "SW Solo",
					["Id"] = GameMode.SkyWarsSolo,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "SW Duos",
					["Id"] = GameMode.SkyWarsDuos,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Duels",
					["Id"] = GameMode.DuelsSolo,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "EggWars",
					["Id"] = GameMode.EggWarsQuads,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
			},
		}
		local gameModeDropdown = createElement(dropdown, gameModeProps)
		local createElement = React.createElement
		local dropdown = Dropdown
		local statisticProps = {
			["key"] = "Statistic",
			["Position"] = nil,
			["Size"] = nil,
			["SelectedId"] = nil,
			["SetSelectedId"] = nil,
			["Items"] = nil,
			["Position"] = UDim2.fromOffset(30, 242),
			["Size"] = Size.new(220, 50),
			["SelectedId"] = statistic,
			["SetSelectedId"] = function(value)
				return setStatistic(value)
			end,
			["Items"] = {
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Wins",
					["Id"] = Statistic.Wins,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
				{
					["Id"] = nil,
					["Image"] = nil,
					["Text"] = "Kills",
					["Id"] = Statistic.Kills,
					["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
				},
			},
		}
		local statisticDropdown = createElement(dropdown, statisticProps)
		local infoImage = React.createElement(Image, {
			["key"] = "Image",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 30),
			["Size"] = UDim2.fromOffset(54, 48),
			["Image"] = RobloxImage.Icon.MEMO_CIRCLE_INFO,
		})
		local infoTextProps = {
			["key"] = "Text",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["TextWrapped"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 108),
		}
		for key, value in textProps do
			infoTextProps[key] = value
		end
		local createElement = React.createElement
		local window = Window
		local windowProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleText"] = "LEADERBOARDS",
			["TitleImage"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(920, 710),
			["TitleImage"] = RobloxImage.Icon.SWORDS,
		}
		local infoGrid = createElement(Grid, {
			["key"] = "Info",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 10,
			["Position"] = UDim2.fromOffset(30, 312),
			["Size"] = UDim2.fromOffset(220, 368),
		}, infoImage, React.createElement(Text, infoTextProps))
		local topButton = React.createElement(Button, {
			["key"] = "Top",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Icon"] = nil,
			["Text"] = "TOP",
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, -30, 0, 62),
			["Size"] = { 150, 50 },
			["Color"] = Color.Button.Green,
			["Icon"] = RobloxImage.Icon.CHEVRONS_UP,
			["Activated"] = function()
				local scrollingFrame = scrollingFrameRef.current
				print(("ScrollingFrame: %*"):format(scrollingFrame))
				if scrollingFrame then
					TweenService
						:Create(scrollingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							["CanvasPosition"] = Vector2.new(0, 0),
						})
						:Play()
				end
			end,
		})
		local searchInput = React.createElement(TextInput, {
			["Position"] = nil,
			["Size"] = nil,
			["PlaceholderText"] = "Search player...",
			["Value"] = nil,
			["SetValue"] = nil,
			["Position"] = UDim2.fromOffset(270, 62),
			["Size"] = UDim2.fromOffset(460, 50),
			["Value"] = searchValue,
			["SetValue"] = setSearchValue,
		})
		local createElement = React.createElement
		local leaderboardList = LeaderboardList
		local leaderboardListProps = {
			["Position"] = UDim2.fromOffset(270, 122),
			["LeaderboardType"] = leaderboardType,
		}
		local statisticIcon
		if statistic == Statistic.Wins then
			statisticIcon = RobloxImage.Emoji.TROPHY
		else
			statisticIcon = RobloxImage.Emoji.CROSSED_SWORDS
		end
		leaderboardListProps.Image = statisticIcon
		leaderboardListProps.StatId = ("%*-%*"):format(gameMode, statistic)
		leaderboardListProps.StatGranularity = granularity
		leaderboardListProps.TextFilter = searchValue
		leaderboardListProps.ScrollingFrameRef = scrollingFrameRef
		return createElement(
			window,
			windowProps,
			leaderboardTypeDropdown,
			granularityDropdown,
			gameModeDropdown,
			statisticDropdown,
			infoGrid,
			topButton,
			searchInput,
			createElement(leaderboardList, leaderboardListProps)
		)
	end,
}
