-- LockerSidebar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local CharacterViewport =
	RuntimeLib.import(script, script.Parent.Parent, "viewport", "character-viewport").CharacterViewport
local usePlayerTitle = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-player-title").usePlayerTitle
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local LobbyExperienceBar =
	RuntimeLib.import(script, script.Parent.Parent, "components", "lobby-experience-bar").LobbyExperienceBar
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local WinsCard = RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "wins-card").WinsCard
local KillsCard = RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "kills-card").KillsCard
local WinStreakCard =
	RuntimeLib.import(script, script.Parent.Parent, "components", "cards", "win-streak-card").WinStreakCard
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type LockerSidebarProps = {
	AnchorPoint: Vector2,
	Position: UDim2,
	Size: UDim2,
	Experience: number,
}

return {
	["LockerSidebar"] = function(props: LockerSidebarProps)
		local displayName = Players.LocalPlayer.DisplayName
		local title: { Title: string, Color: Color3 } | nil = usePlayerTitle({
			Player = Players.LocalPlayer,
		})
		local level: number = ExperienceUtil.getLevel(props.Experience)
		local levelColour: Color3 = ColorUtil.getLevelColour(level)
		local padding3: number = ScreenConstants.PADDING_3
		local nameOffset: number = padding3 + (not title and 0 or 24 + ScreenConstants.PADDING_1)
		local cardWidth: number = (props.Size.X.Offset - ScreenConstants.PADDING_1 * 2) / 3
		local width: number = props.Size.X.Offset
		local height: number = props.Size.Y.Offset - 50 - ScreenConstants.PADDING_1
		local barYOffset: number = -ScreenConstants.PADDING_3
		local barWidth: number = props.Size.X.Offset - ScreenConstants.PADDING_3 * 2
		local createElement = React.createElement
		local frameProps = {
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Size = props.Size,
		}
		local backgroundProps = {
			Size = UDim2.fromOffset(width, height),
			BackgroundTransparency = 0.6,
			CornerRadius = 10,
		}
		local gradientBar = createElement(
			Grid,
			{
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.3),
				BackgroundColor3 = levelColour,
				BackgroundTransparency = 0,
				CornerRadius = 10,
			},
			createElement("uigradient", {
				Rotation = 270,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(1, 1, 0),
				}),
			})
		)
		local characterViewport = createElement(CharacterViewport, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.9),
			FieldOfView = 30,
		})
		local titleElement
		if title then
			titleElement = createElement(Text, {
				Text = string.upper(title.Title),
				TextSize = 24,
				TextColor3 = title.Color,
				Bold = true,
				RichText = true,
				DropShadow = Vector2.new(0, 2),
				ZIndex = 10,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, padding3),
			})
		else
			titleElement = nil
		end
		return createElement(
			Grid,
			frameProps,
			createElement(
				Grid,
				backgroundProps,
				gradientBar,
				characterViewport,
				titleElement,
				createElement(Text, {
					Text = displayName,
					TextSize = 48,
					Bold = true,
					DropShadow = Vector2.new(0, 4),
					ZIndex = 10,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, nameOffset),
				}),
				createElement(LobbyExperienceBar, {
					Experience = props.Experience,
					ZIndex = 5,
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, barYOffset),
					Size = UDim2.fromOffset(barWidth, 40),
				})
			),
			createElement(
				Grid,
				{
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.fromOffset(props.Size.X.Offset, 50),
				},
				createElement(WinsCard, {
					Size = UDim2.fromOffset(cardWidth, 50),
					Padding = 0,
				}),
				createElement(KillsCard, {
					Size = UDim2.fromOffset(cardWidth, 50),
					Padding = 0,
				}),
				createElement(WinStreakCard, {
					Size = UDim2.fromOffset(cardWidth, 50),
					Padding = 0,
				}),
				createElement(List)
			)
		)
	end,
}
