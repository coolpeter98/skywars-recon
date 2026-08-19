-- DockProfile

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local ExperienceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "experience", "experience-util").ExperienceUtil
local ProgressBarNew = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Ranks = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "ranks").Ranks
local DockVerifyButton = RuntimeLib.import(script, script.Parent, "dock-verify-button").DockVerifyButton
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type DockProfileProps = {
	Experience: number,
	MobileLayout: boolean,
	UserId: number,
	Rank: number?,
	DisplayName: string,
	ShowVerify: boolean,
	GameState: number,
}

return {
	["DockProfile"] = function(props: DockProfileProps)
		local experience: number = props.Experience
		local level = ExperienceUtil.getLevel(props.Experience)
		local experienceIntoLevel = experience - ExperienceUtil.getExperience(level)
		local experienceToNextLevel = ExperienceUtil.getExperience(level + 1) - ExperienceUtil.getExperience(level)
		local levelColor = ColorUtil.getLevelColour(level)

		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = "DockProfile",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil
		}
		local gridAnchorPoint
		if props.MobileLayout then
			gridAnchorPoint = Vector2.new(0.5, 0)
		else
			gridAnchorPoint = Vector2.new(0, 0.5)
		end
		gridProps.AnchorPoint = gridAnchorPoint
		local gridPosition
		if props.MobileLayout then
			gridPosition = UDim2.new(0.5, 10, 0, 20)
		else
			gridPosition = UDim2.new(0, 20, 0.5, 0)
		end
		gridProps.Position = gridPosition
		local gridSize
		if props.MobileLayout then
			gridSize = UDim2.fromOffset(178, 175)
		else
			gridSize = UDim2.fromOffset(320, 84)
		end
		gridProps.Size = gridSize

		local createElement = React.createElement
		local playerIcon = PlayerIcon
		local playerIconProps = {
			["key"] = "PlayerIcon",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["UserId"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = 0,
			["CornerRadius"] = nil
		}
		local playerIconAnchorPoint
		if props.MobileLayout then
			playerIconAnchorPoint = Vector2.new(0.5, 0)
		else
			playerIconAnchorPoint = Vector2.new()
		end
		playerIconProps.AnchorPoint = playerIconAnchorPoint
		local playerIconPosition
		if props.MobileLayout then
			playerIconPosition = UDim2.fromScale(0.5, 0)
		else
			playerIconPosition = UDim2.new()
		end
		playerIconProps.Position = playerIconPosition
		playerIconProps.Size = UDim2.fromOffset(80, 80)
		playerIconProps.UserId = props.UserId
		playerIconProps.BackgroundColor3 = levelColor
		playerIconProps.CornerRadius = UDim.new(1)
		local playerIconElement = createElement(playerIcon, playerIconProps)

		local createElement = React.createElement
		local grid = Grid
		local textGridProps = {
			["key"] = "Text",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil
		}
		local textGridAnchorPoint
		if props.MobileLayout then
			textGridAnchorPoint = Vector2.new(0.5, 0)
		else
			textGridAnchorPoint = Vector2.new(0, 0.5)
		end
		textGridProps.AnchorPoint = textGridAnchorPoint
		local textGridPosition
		if props.MobileLayout then
			textGridPosition = UDim2.new(0.5, 0, 0, 90)
		else
			textGridPosition = UDim2.new(0, 100, 0.5, 0)
		end
		textGridProps.Position = textGridPosition
		local textGridSize
		if props.MobileLayout then
			textGridSize = UDim2.fromOffset(178, 85)
		else
			textGridSize = UDim2.fromOffset(220, 82)
		end
		textGridProps.Size = textGridSize

		local createElement = React.createElement
		local text = Text
		local rankTextProps = {
			["key"] = "RankText",
			["Text"] = nil,
			["TextSize"] = 16,
			["TextColor3"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 1,
			["Text"] = not props.Rank and "" or string.upper(Ranks[props.Rank].Name)
		}
		local rankTextColor
		if props.Rank then
			rankTextColor = Ranks[props.Rank].Color
		else
			rankTextColor = Color.Red
		end
		rankTextProps.TextColor3 = rankTextColor
		local rankTextElement = createElement(text, rankTextProps)
		local playerTextElement = React.createElement(Text, {
			["key"] = "PlayerText",
			["Text"] = nil,
			["TextSize"] = 24,
			["TextColor3"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 2,
			["Text"] = props.DisplayName,
			["TextColor3"] = Color.White
		})

		local createElement = React.createElement
		local progressBar = ProgressBarNew
		local progressBarProps = {
			["Size"] = nil,
			["Progress"] = nil,
			["Image"] = nil,
			["ImageSize"] = 16,
			["Text"] = nil,
			["TextSize"] = 20,
			["Colors"] = nil,
			["LayoutOrder"] = 3,
			["Outline"] = 2
		}
		local progressBarSize
		if props.MobileLayout then
			progressBarSize = UDim2.fromOffset(178, 28)
		else
			progressBarSize = UDim2.fromOffset(220, 28)
		end
		progressBarProps.Size = progressBarSize
		progressBarProps.Progress = experienceIntoLevel / experienceToNextLevel
		progressBarProps.Image = RobloxImage.Icon.CIRCLE_STAR
		progressBarProps.Text = ("LEVEL %*"):format(level)
		progressBarProps.Colors = { levelColor }
		local progressBarElement = createElement(progressBar, progressBarProps)

		local createElement = React.createElement
		local list = List
		local listProps = {
			["Vertical"] = true,
			["Padding"] = nil,
			["HorizontalAlignment"] = nil,
			["Padding"] = UDim.new(0, 6)
		}
		local listHorizontalAlignment
		if props.MobileLayout then
			listHorizontalAlignment = Enum.HorizontalAlignment.Center
		else
			listHorizontalAlignment = Enum.HorizontalAlignment.Left
		end
		listProps.HorizontalAlignment = listHorizontalAlignment
		local textGridElement = createElement(grid, textGridProps, rankTextElement, playerTextElement, progressBarElement, createElement(list, listProps))

		local verifyButtonElement
		if props.MobileLayout or (Flamework.resolveDependency("0dL"):isVerified() or (not props.ShowVerify or ScreenUtil.isMobile() and props.GameState == GameState.Ended)) then
			verifyButtonElement = nil
		else
			verifyButtonElement = React.createElement(DockVerifyButton, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["MobileLayout"] = false,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 362, 0.5, 0)
			})
		end
		return createElement(grid, gridProps, playerIconElement, textGridElement, verifyButtonElement)
	end
}
