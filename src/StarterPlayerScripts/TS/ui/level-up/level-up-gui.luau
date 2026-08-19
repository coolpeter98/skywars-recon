-- LevelUpGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local Banner = RuntimeLib.import(script, script.Parent.Parent, "components", "banner").Banner
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local LevelRewards =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "experience", "level-rewards").LevelRewards
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
return {
	["LevelUpGui"] = function(props)
		local profile = useProfile()
		local level = ExperienceUtil.getLevel(profile.Experience)
		local currentLevelExp = ExperienceUtil.getExperience(level)
		local nextLevelExp = ExperienceUtil.getExperience(level + 1)
		local progressExp = profile.Experience - currentLevelExp
		local requiredExp = nextLevelExp - currentLevelExp
		local levelColour = ColorUtil.getLevelColour(level)
		local nextRewardLevel = (1 / 0)
		local nextRewardId = nil
		for rewardLevel, rewardIds in LevelRewards do
			if level < rewardLevel and rewardLevel < nextRewardLevel then
				nextRewardId = rewardIds[1]
				nextRewardLevel = rewardLevel
			end
		end
		local createElement = React.createElement
		local rootGrid = Grid
		local rootProps = {
			["key"] = "LevelUpGui",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["Ref"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
			["Ref"] = props.FrameRef,
		}
		local title = createElement(
			Banner,
			{
				["key"] = "TitleGui",
				["Image"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["LayoutOrder"] = 1,
				["Image"] = RobloxImage.Icon.GEM,
				["Size"] = UDim2.fromOffset(760, 136),
				["BackgroundColor3"] = levelColour,
			},
			createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = "LEVEL UP",
				["TextSize"] = 96,
				["Bold"] = true,
				["DropShadow"] = nil,
				["ZIndex"] = 4,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["DropShadow"] = Vector2.new(0, 10),
			})
		)
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = "Grid",
			["Size"] = nil,
			["LayoutOrder"] = 2,
			["Size"] = UDim2.fromOffset(760, 210),
		}
		local leftColumn = createElement(
			Grid,
			{
				["key"] = "Left",
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["LayoutOrder"] = 1,
				["Size"] = UDim2.fromOffset(198, 210),
			},
			createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(138, 150),
				},
				createElement(Text, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Bold"] = true,
					["TextSize"] = 48,
					["Text"] = nil,
					["ZIndex"] = 2,
					["AnchorPoint"] = Vector2.new(0.5, 1),
					["Position"] = UDim2.new(0.5, 0, 1, -13),
					["Text"] = tostring(level),
				}),
				createElement(Image, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["ZIndex"] = 2,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 21),
					["Size"] = UDim2.fromOffset(60, 60),
					["Image"] = RobloxImage.Icon.CIRCLE_STAR,
				}),
				createElement(
					Grid,
					{
						["Size"] = UDim2.fromScale(1, 1),
						["BackgroundColor3"] = levelColour,
					},
					createElement("uicorner", {
						["CornerRadius"] = UDim.new(1),
					})
				),
				createElement(
					Grid,
					{
						["AnchorPoint"] = Vector2.new(0, 1),
						["Position"] = UDim2.fromScale(0, 1),
						["Size"] = UDim2.new(1, 0, 0, 111),
						["BackgroundColor3"] = levelColour,
					},
					createElement(CornerRadius, {
						["Radius"] = 30,
					})
				)
			),
			createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local middleColumn = createElement(
			Grid,
			{
				["key"] = "Middle",
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["LayoutOrder"] = 2,
				["Size"] = UDim2.fromOffset(332, 210),
			},
			createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["AutomaticSize"] = Enum.AutomaticSize.XY,
				},
				createElement(Text, {
					["key"] = "Coins",
					["Text"] = "\240\159\154\167 COMING\nSOON \240\159\154\167",
					["Bold"] = true,
					["TextSize"] = 48,
					["FixSize"] = true,
					["LayoutOrder"] = 1,
				}),
				createElement(List)
			),
			createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local rightColumn
		if nextRewardId then
			rightColumn = createElement(CosmeticSlot, {
				["CosmeticId"] = nil,
				["Active"] = false,
				["LayoutOrder"] = 3,
				["Locked"] = nil,
				["NextReward"] = true,
				["CosmeticId"] = nextRewardId,
				["Locked"] = LevelRewards[level] == nil,
			})
		else
			rightColumn = createElement(
				Grid,
				{
					["key"] = "Right",
					["Size"] = nil,
					["BackgroundTransparency"] = 0.6,
					["LayoutOrder"] = 3,
					["Size"] = UDim2.fromOffset(210, 210),
				},
				createElement(CornerRadius, {
					["Radius"] = 10,
				})
			)
		end
		return createElement(
			rootGrid,
			rootProps,
			title,
			createElement(grid, gridProps, leftColumn, middleColumn, rightColumn, createElement(List)),
			createElement(ProgressBarNew, {
				["Size"] = nil,
				["Progress"] = nil,
				["Image"] = nil,
				["Text"] = nil,
				["Colors"] = nil,
				["TweenTime"] = 1,
				["LayoutOrder"] = 3,
				["Size"] = UDim2.fromOffset(754, 29),
				["Progress"] = progressExp / requiredExp,
				["Image"] = RobloxImage.Icon.CIRCLE_STAR,
				["Text"] = ("LEVEL %*"):format(level),
				["Colors"] = { levelColour },
			}),
			createElement(List, {
				["Vertical"] = true,
				["Padding"] = nil,
				["Padding"] = UDim.new(0, 30),
			})
		)
	end,
}
