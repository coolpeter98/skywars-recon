-- DockStats

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
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local useStats = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-stats").useStats
local DockStatsItem = RuntimeLib.import(script, script.Parent, "dock-stats-item").DockStatsItem
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local LeaderboardScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "leaderboard", "leaderboard-screen").LeaderboardScreen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local STATS = {
	{ Statistic.Wins, RobloxImage.Emoji.TROPHY },
	{ Statistic.Kills, RobloxImage.Emoji.CROSSED_SWORDS },
	{ Statistic.WinStreak, RobloxImage.Emoji.FLAME },
}

type Props = {
	MobileLayout: boolean,
}

return {
	["DockStats"] = function(props: Props)
		local elements: { any } = table.create(#STATS)

		local function renderStatItem(entry: { any }, index: number)
			local stat = entry[1]
			local emoji = entry[2]
			local statValue = useStats(nil, stat)
			return React.createElement(DockStatsItem, {
				["key"] = nil,
				["Image"] = nil,
				["Text"] = nil,
				["LayoutOrder"] = nil,
				["Activated"] = nil,
				["Selectable"] = true,
				["key"] = stat,
				["Image"] = emoji,
				["Text"] = StringUtil.formatNumber(statValue),
				["LayoutOrder"] = index,
				["Activated"] = function()
					return Flamework.resolveDependency("lB5"):toggle(LeaderboardScreen)
				end,
			})
		end

		for index, entry in STATS do
			elements[index] = renderStatItem(entry, index - 1, STATS)
		end

		local createElement = React.createElement
		local grid = Grid
		local frameProps = {
			["key"] = "DockStats",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
		}
		local anchorPoint: Vector2
		if props.MobileLayout then
			anchorPoint = Vector2.new(0.5, 0)
		else
			anchorPoint = Vector2.new(1, 1)
		end
		frameProps.AnchorPoint = anchorPoint
		local position: UDim2
		if props.MobileLayout then
			position = UDim2.new(0.5, 10, 0, 215)
		else
			position = UDim2.new(1, -20, 1, -20)
		end
		frameProps.Position = position
		local size: UDim2
		if props.MobileLayout then
			size = UDim2.fromOffset(182, 170)
		else
			size = UDim2.fromOffset(ScreenUtil.getGridSize(86, 10, #STATS + 1), 80)
		end
		frameProps.Size = size
		return createElement(
			grid,
			frameProps,
			elements,
			React.createElement(DockStatsItem, {
				["key"] = "More",
				["Image"] = nil,
				["Text"] = "MORE",
				["LayoutOrder"] = nil,
				["Activated"] = nil,
				["Selectable"] = true,
				["Image"] = RobloxImage.Icon.BAR_CHART,
				["LayoutOrder"] = #STATS,
				["Activated"] = function()
					return Flamework.resolveDependency("lB5"):toggle(LeaderboardScreen)
				end,
			}),
			React.createElement("uigridlayout", {
				["key"] = "UIGridLayout",
				["FillDirection"] = nil,
				["FillDirectionMaxCells"] = nil,
				["CellPadding"] = nil,
				["CellSize"] = nil,
				["SortOrder"] = nil,
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["FillDirectionMaxCells"] = props.MobileLayout and 2 or 4,
				["CellPadding"] = UDim2.fromOffset(10, 10),
				["CellSize"] = UDim2.fromOffset(86, 80),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			})
		)
	end,
}
