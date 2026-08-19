-- EndGameStats

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local EndGameWindow = RuntimeLib.import(script, script.Parent, "end-game-window").EndGameWindow
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local GradientCard = RuntimeLib.import(script, script.Parent.Parent, "components", "gradient-card").GradientCard
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type EndGameStatsProps = {
	Winner: boolean?,
	GameEnded: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Visible: boolean?,
	FrameRef: any?,
}

return {
	["EndGameStats"] = function(props: EndGameStatsProps)
		getTextProps({
			["Text"] = "940th",
			["TextSize"] = 24,
			["Bold"] = true,
		})
		getTextProps({
			["Text"] = "940th",
			["TextSize"] = 24,
			["Bold"] = true,
		})
		local titleProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["FrameSize"] = nil,
			["Text"] = props.Winner and "YOU WON!" or (props.GameEnded and "GAME OVER!" or "YOU DIED!"),
			["FrameSize"] = Vector2.new(220, 106),
		})
		local titleColor
		if props.Winner then
			titleColor = Color.Green
		elseif props.GameEnded then
			titleColor = Color.Grey
		else
			titleColor = Color.Red
		end
		local titleImage
		if props.Winner then
			titleImage = RobloxImage.Emoji.TROPHY
		elseif props.GameEnded then
			titleImage = RobloxImage.Emoji.CROSSED_SWORDS
		else
			titleImage = RobloxImage.Emoji.SKULL
		end
		local backgroundProps = {
			["key"] = "CharacterBackground",
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["FooterHeight"] = 126,
			["StrokeThickness"] = 0,
			["CornerRadius"] = 10,
			["ScalingDisabled"] = true,
			["Position"] = UDim2.fromOffset(20, 42),
			["Size"] = Size.new(240, 366),
			["Color"] = titleColor,
		}
		local footerTextProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["TextWrapped"] = true,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in titleProps do
			footerTextProps[key] = value
		end
		backgroundProps.FooterComponent = React.createElement(Text, footerTextProps)
		return React.createElement(
			EndGameWindow,
			{
				["key"] = "EndGameStats",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleText"] = "GAME OVER",
				["TitleImage"] = nil,
				["Visible"] = nil,
				["FrameRef"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(280, 520),
				["TitleImage"] = RobloxImage.Icon.GAMEPAD,
				["Visible"] = props.Visible,
				["FrameRef"] = props.FrameRef,
			},
			React.createElement(
				GradientCard,
				backgroundProps,
				React.createElement(Image, {
					["key"] = "Skull",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["ZIndex"] = 5,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(156, 156),
					["Image"] = titleImage,
				})
			),
			React.createElement(
				Grid,
				{
					["key"] = "Leaderboard",
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundTransparency"] = 0.6,
					["Position"] = UDim2.fromOffset(20, 418),
					["Size"] = UDim2.fromOffset(240, 82),
				},
				React.createElement(Text, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = "LEADERBOARD RANKS\n\nCOMING SOON",
					["TextSize"] = 16,
					["Bold"] = true,
					["ZIndex"] = 5,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 15),
				}),
				React.createElement(CornerRadius, {
					["Radius"] = 10,
				})
			)
		)
	end,
}
