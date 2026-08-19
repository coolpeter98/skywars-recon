-- LeaderboardScrollingFrame

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local LeaderboardPlayer = RuntimeLib.import(script, script.Parent, "leaderboard-player").LeaderboardPlayer
local useLeaderboard = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-leaderboard").useLeaderboard
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local CircularProgress =
	RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress

type LeaderboardScrollingFrameProps = {
	LeaderboardType: string,
	StatId: string,
	StatGranularity: string,
	TextFilter: string,
	Size: UDim2,
	Image: string,
	AnchorPoint: Vector2,
	Position: UDim2,
	ScrollingFrameRef: any,
}

type LeaderboardPlayerData = {
	UserId: number,
	DisplayName: string,
	Value: number,
	Position: number,
}

return {
	["LeaderboardScrollingFrame"] = function(props: LeaderboardScrollingFrameProps)
		local leaderboard: { Loading: boolean, Players: { LeaderboardPlayerData } } = useLeaderboard({
			["LeaderboardType"] = props.LeaderboardType,
			["StatId"] = props.StatId,
			["StatGranularity"] = props.StatGranularity,
			["TextFilter"] = props.TextFilter,
		})
		local gridSize: number = ScreenUtil.getGridSize(60, 10, #leaderboard.Players)
		local content
		if leaderboard.Loading then
			content = React.createElement(CircularProgress, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(80, 80),
				["Color"] = Color.White,
			})
		else
			local players = leaderboard.Players
			local playerElements = table.create(#players)
			local function renderPlayer(player: LeaderboardPlayerData)
				return React.createElement(LeaderboardPlayer, {
					["Width"] = props.Size.X.Offset - 30,
					["UserId"] = player.UserId,
					["DisplayName"] = player.DisplayName,
					["StatImage"] = props.Image,
					["StatValue"] = player.Value,
					["LeaderboardPosition"] = player.Position,
				})
			end
			for index, player in players do
				playerElements[index] = renderPlayer(player, index - 1, players)
			end
			content = React.createElement(
				React.Fragment,
				nil,
				playerElements,
				React.createElement(List, {
					["VerticalAlignment"] = nil,
					["HorizontalAlignment"] = nil,
					["Vertical"] = true,
					["VerticalAlignment"] = Enum.VerticalAlignment.Top,
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				})
			)
		end
		local createElement = React.createElement
		local elementType = "scrollingframe"
		local frameProps = {
			["key"] = "ScrollingFrame",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 10,
			["ScrollBarImageColor3"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["ref"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
		}
		local canvasSize
		if leaderboard.Loading then
			canvasSize = UDim2.fromScale(0, 0)
		else
			canvasSize = UDim2.fromOffset(0, gridSize)
		end
		frameProps.CanvasSize = canvasSize
		frameProps.ScrollingDirection = Enum.ScrollingDirection.Y
		frameProps.ScrollBarImageColor3 = Color.White
		frameProps.ref = props.ScrollingFrameRef
		return createElement(elementType, frameProps, content)
	end,
}
