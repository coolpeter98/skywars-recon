-- EggWarsBillboard

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local StatsBillboardItem = RuntimeLib.import(script, script.Parent, "stats-billboard-item").StatsBillboardItem
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["EggWarsBillboard"] = function()
		return React.createElement(
			"surfacegui",
			{
				["CanvasSize"] = Vector2.new(1800, 1200),
				["Face"] = Enum.NormalId.Front,
			},
			React.createElement(
				Grid,
				{
					["key"] = "Background",
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["ZIndex"] = 0,
					["Size"] = UDim2.fromScale(1, 1),
					["BackgroundColor3"] = Color.White,
				},
				React.createElement("uigradient", {
					["Rotation"] = 90,
					["Color"] = nil,
					["Color"] = ColorSequence.new(Color3.fromRGB(123, 203, 164), Color3.fromRGB(0, 153, 122)),
				})
			),
			React.createElement(Image, {
				["key"] = "Logo",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 56),
				["Size"] = UDim2.fromOffset(956, 200),
				["Image"] = RobloxImage.EGGWARS_LOGO,
			}),
			React.createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 320),
					["AutomaticSize"] = Enum.AutomaticSize.XY,
				},
				React.createElement(StatsBillboardItem, {
					["Icon"] = nil,
					["GameType"] = "EggWars",
					["Statistic"] = nil,
					["Color"] = nil,
					["LayoutOrder"] = 1,
					["Icon"] = RobloxImage.Emoji.TROPHY,
					["Statistic"] = Statistic.Wins,
					["Color"] = Color.Card.Green,
				}),
				React.createElement(StatsBillboardItem, {
					["Icon"] = nil,
					["GameType"] = "EggWars",
					["Statistic"] = nil,
					["Color"] = nil,
					["LayoutOrder"] = 2,
					["Icon"] = RobloxImage.Emoji.CROSSED_SWORDS,
					["Statistic"] = Statistic.Kills,
					["Color"] = Color.Card.Blue,
				}),
				React.createElement(StatsBillboardItem, {
					["Icon"] = nil,
					["GameType"] = "EggWars",
					["Statistic"] = nil,
					["Color"] = nil,
					["LayoutOrder"] = 3,
					["Icon"] = RobloxImage.Emoji.SKULL,
					["Statistic"] = Statistic.Deaths,
					["Color"] = Color.Card.Red,
				}),
				React.createElement(StatsBillboardItem, {
					["Icon"] = nil,
					["GameType"] = "EggWars",
					["Statistic"] = nil,
					["Color"] = nil,
					["LayoutOrder"] = 4,
					["Icon"] = RobloxImage.Emoji.FLAME,
					["Statistic"] = Statistic.WinStreak,
					["Color"] = Color.Card.Purple,
				}),
				React.createElement("uilistlayout", {
					["FillDirection"] = Enum.FillDirection.Horizontal,
					["Padding"] = UDim.new(0, 30),
					["VerticalAlignment"] = Enum.VerticalAlignment.Center,
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
					["SortOrder"] = Enum.SortOrder.LayoutOrder,
				})
			)
		)
	end,
}
