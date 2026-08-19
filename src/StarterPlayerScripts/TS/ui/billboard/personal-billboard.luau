-- PersonalBillboard

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local GradientCard = RuntimeLib.import(script, script.Parent.Parent, "components", "gradient-card").GradientCard
local Size = RuntimeLib.import(script, script.Parent.Parent, "components", "size").Size
local usePlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-player-icon").usePlayerIcon
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local usePlayerTitle = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-player-title").usePlayerTitle
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local useExperience = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-experience").useExperience
local useSeasonData = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-season-data").useSeasonData
local SeasonUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["PersonalBillboard"] = function()
		local players = usePlayers()
		local playerIcon = usePlayerIcon({
			["UserId"] = players.LocalPlayer.UserId,
			["ThumbnailType"] = Enum.ThumbnailType.AvatarThumbnail,
			["ThumbnailSize"] = Enum.ThumbnailSize.Size420x420,
		})
		getTextProps({
			["Text"] = "940th",
			["TextSize"] = 40,
			["Bold"] = true,
		})
		getTextProps({
			["Text"] = "940th",
			["TextSize"] = 40,
			["Bold"] = true,
		})
		local playerTitle = usePlayerTitle({
			["Player"] = players.LocalPlayer,
		})
		local experience = useExperience()
		local level = ExperienceUtil.getLevel(experience)
		local levelProgress = experience - ExperienceUtil.getExperience(level)
		local levelRequirement = ExperienceUtil.getExperience(level + 1) - ExperienceUtil.getExperience(level)
		local levelColour = ColorUtil.getLevelColour(level)
		local seasonData = useSeasonData()
		local tier = SeasonUtil.getTier(seasonData.Experience)
		local _ = SeasonUtil.getTier(seasonData.Experience) + SeasonUtil.getProgressDecimal(seasonData.Experience)
		local surfaceGuiProps = {
			["CanvasSize"] = Vector2.new(1800, 1200),
			["Face"] = Enum.NormalId.Front,
		}
		local background = React.createElement(
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
				["Color"] = ColorSequence.new(Color3.fromRGB(251, 216, 133), Color3.fromRGB(251, 175, 43)),
			})
		)
		local logo = React.createElement(Image, {
			["key"] = "Logo",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 56),
			["Size"] = UDim2.fromOffset(1070, 200),
			["Image"] = RobloxImage.SKYWARS_LOGO,
		})
		local playerCardProps = {
			["key"] = "PlayerCard",
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["StrokeThickness"] = 12,
			["ScalingDisabled"] = true,
			["FooterHeight"] = 248,
			["FooterComponent"] = nil,
			["Position"] = UDim2.fromOffset(63, 320),
			["Size"] = Size.new(518, 820),
			["Color"] = Color3.fromRGB(235, 84, 253),
		}
		local rankTextProps = {
			["key"] = "RankText",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 32,
			["TextColor3"] = nil,
			["Bold"] = true,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 20),
			["Text"] = not playerTitle and "" or string.upper(playerTitle.Title),
		}
		local rankTextColor
		if playerTitle then
			rankTextColor = playerTitle.Color
		else
			rankTextColor = Color.Red
		end
		rankTextProps.TextColor3 = rankTextColor
		playerCardProps.FooterComponent = React.createElement(
			React.Fragment,
			nil,
			React.createElement(Text, rankTextProps),
			React.createElement(Text, {
				["key"] = "PlayerText",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextSize"] = 48,
				["TextColor3"] = nil,
				["Bold"] = true,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 55),
				["Text"] = players.LocalPlayer.DisplayName,
				["TextColor3"] = Color.White,
			}),
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = "LEADERBOARD RANKS\nCOMING SOON",
				["TextSize"] = 38,
				["Bold"] = true,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 128),
			})
		)
		return React.createElement(
			"surfacegui",
			surfaceGuiProps,
			background,
			logo,
			React.createElement(
				GradientCard,
				playerCardProps,
				React.createElement(Image, {
					["key"] = "PlayerIcon",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["ZIndex"] = 2,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.fromScale(0.5, 0),
					["Size"] = UDim2.fromScale(1, 1),
					["Image"] = playerIcon,
				})
			),
			React.createElement(
				GradientCard,
				{
					["key"] = "SeasonPassCard",
					["Position"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["StrokeThickness"] = 12,
					["ScalingDisabled"] = true,
					["FooterHeight"] = 248,
					["FooterComponent"] = nil,
					["Position"] = UDim2.fromOffset(641, 320),
					["Size"] = Size.new(518, 820),
					["Color"] = Color3.fromRGB(253, 206, 72),
					["FooterComponent"] = React.createElement(
						React.Fragment,
						nil,
						React.createElement(Text, {
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Text"] = nil,
							["TextSize"] = 48,
							["Bold"] = true,
							["ZIndex"] = 5,
							["AnchorPoint"] = Vector2.new(0.5, 0),
							["Position"] = UDim2.new(0.5, 0, 0, 41),
							["Text"] = ("Tier %*"):format(tier + 1),
						}),
						React.createElement(Text, {
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Text"] = nil,
							["TextSize"] = 40,
							["Bold"] = true,
							["ZIndex"] = 5,
							["AnchorPoint"] = Vector2.new(0.5, 0),
							["Position"] = UDim2.new(0.5, 0, 0, 94),
							["Text"] = ("%* / %* SP"):format(
								SeasonUtil.getProgress(seasonData.Experience),
								SeasonUtil.getExperience(tier + 1) - SeasonUtil.getExperience(tier)
							),
						}),
						React.createElement(
							Grid,
							{
								["key"] = "ProgressBar",
								["AnchorPoint"] = nil,
								["Position"] = nil,
								["Size"] = nil,
								["BackgroundTransparency"] = 0.6,
								["ZIndex"] = 5,
								["AnchorPoint"] = Vector2.new(0.5, 0),
								["Position"] = UDim2.new(0.5, 0, 0, 157),
								["Size"] = UDim2.fromOffset(414, 50),
							},
							React.createElement(
								Grid,
								{
									["key"] = "ProgressBarFilled",
									["Size"] = nil,
									["BackgroundColor3"] = nil,
									["ZIndex"] = 6,
									["Size"] = UDim2.fromScale(SeasonUtil.getProgressDecimal(seasonData.Experience), 1),
									["BackgroundColor3"] = Color.Green,
								},
								React.createElement(CornerRadius, {
									["Radius"] = 10,
								})
							),
							React.createElement(CornerRadius, {
								["Radius"] = 10,
							})
						)
					),
				},
				React.createElement(Image, {
					["key"] = "SeasonPassIcon",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 30),
					["Size"] = UDim2.fromOffset(178, 201),
					["Image"] = RobloxImage.SEASON_PASS,
				})
			),
			React.createElement(
				GradientCard,
				{
					["key"] = "LevelCard",
					["Position"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["StrokeThickness"] = 12,
					["ScalingDisabled"] = true,
					["FooterHeight"] = 248,
					["FooterComponent"] = nil,
					["Position"] = UDim2.fromOffset(1219, 320),
					["Size"] = Size.new(518, 820),
					["Color"] = Color3.fromRGB(249, 88, 78),
					["FooterComponent"] = React.createElement(
						React.Fragment,
						nil,
						React.createElement(Text, {
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Text"] = nil,
							["TextSize"] = 40,
							["Bold"] = true,
							["ZIndex"] = 5,
							["AnchorPoint"] = Vector2.new(0.5, 0),
							["Position"] = UDim2.new(0.5, 0, 0, 67),
							["Text"] = ("%* / %* XP"):format(levelProgress, levelRequirement),
						}),
						React.createElement(ProgressBarNew, {
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Size"] = nil,
							["Progress"] = nil,
							["Image"] = nil,
							["ImageSize"] = 16,
							["Text"] = nil,
							["TextSize"] = 20,
							["Colors"] = nil,
							["LayoutOrder"] = 3,
							["Outline"] = 0,
							["ZIndex"] = 5,
							["AnchorPoint"] = Vector2.new(0.5, 0),
							["Position"] = UDim2.new(0.5, 0, 0, 131),
							["Size"] = UDim2.fromOffset(414, 50),
							["Progress"] = levelProgress / levelRequirement,
							["Image"] = RobloxImage.Icon.CIRCLE_STAR,
							["Text"] = ("LEVEL %*"):format(level),
							["Colors"] = { levelColour },
						})
					),
				},
				React.createElement(Image, {
					["key"] = "StarIcon",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 30),
					["Size"] = UDim2.fromOffset(200, 200),
					["Image"] = RobloxImage.Icon.CIRCLE_STAR,
				}),
				React.createElement(Text, {
					["key"] = "LevelLabel",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = "LEVEL",
					["TextSize"] = 64,
					["Bold"] = true,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 276),
				}),
				React.createElement(Text, {
					["key"] = "Level",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = nil,
					["TextSize"] = 90,
					["Bold"] = true,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.new(0.5, 0, 0, 420),
					["Text"] = tostring(level),
				}),
				React.createElement("uiscale", {
					["Scale"] = 2,
				})
			)
		)
	end,
}
