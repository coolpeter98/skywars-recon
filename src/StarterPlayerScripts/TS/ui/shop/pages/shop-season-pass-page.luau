-- ShopSeasonPassPage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useState = React.useState
local useProfile = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useProfile
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local SeasonPassRewardsList = RuntimeLib.import(
	script,
	script.Parent.Parent.Parent,
	"season-pass",
	"season-pass-rewards-list"
).SeasonPassRewardsList
local SeasonPass = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass")
local CurrentSeason = SeasonPass.CurrentSeason
local SeasonPassRewards = SeasonPass.SeasonPassRewards
local SeasonUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local CosmeticDisplayViewport = RuntimeLib.import(
	script,
	script.Parent.Parent.Parent,
	"viewport",
	"cosmetic-display-viewport"
).CosmeticDisplayViewport
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local ShopSeasonPassBuyButton =
	RuntimeLib.import(script, script.Parent.Parent, "components", "shop-season-pass-buy-button").ShopSeasonPassBuyButton
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonBundleProductId = GameProduct.CurrentSeasonBundleProductId
local CurrentSeasonProductId = GameProduct.CurrentSeasonProductId
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ShopSeasonPassSkip =
	RuntimeLib.import(script, script.Parent.Parent, "components", "shop-season-pass-skip").ShopSeasonPassSkip
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
return {
	["ShopSeasonPassPage"] = function(_)
		local shopContext: { PageSize: Vector2 } = useContext(NewShopContext)
		local profile = useProfile()
		local seasonData = profile.Season.SeasonData[CurrentSeason]
		local ownsPass: boolean = profile.Season.OwnedPasses[CurrentSeason] ~= nil
		local currentTier: number = SeasonUtil.getTier(seasonData.Experience)
		local nextTier: number = currentTier + 1
		local tierCount: number = 0
		for _ in SeasonPassRewards do
			tierCount = tierCount + 1
		end
		local maxTier: number = tierCount - 1
		local selectedTierId: number, setSelectedTierId: (tierId: number) -> () = useState(math.min(nextTier, maxTier))
		local selectedReward = SeasonPassRewards[selectedTierId]
		local levelsGained: number = SeasonUtil.getTier(seasonData.Experience + SeasonUtil.getExperience(15))
			- currentTier
		local contentTooTall: boolean = ScreenConstants.PADDING_2 * 4
				+ ScreenConstants.PADDING_1 * 2
				+ 72
				+ 281.25
				+ 72
				+ 30
				+ 100
				+ 30
				+ 100
			> shopContext.PageSize.Y - 298 - ScreenConstants.PADDING_2
		local seasonInfoHeight: number
		if contentTooTall then
			seasonInfoHeight = shopContext.PageSize.Y
		else
			seasonInfoHeight = shopContext.PageSize.Y - 298 - ScreenConstants.PADDING_2
		end
		local rightPanelOffset: number = 540 + ScreenConstants.PADDING_2
		local rewardsGridWidth: number
		if contentTooTall then
			rewardsGridWidth = shopContext.PageSize.X - rightPanelOffset
		else
			rewardsGridWidth = shopContext.PageSize.X
		end
		local rightPanelWidth: number = shopContext.PageSize.X - rightPanelOffset
		local rightPanelHeight: number = shopContext.PageSize.Y - 298 - ScreenConstants.PADDING_2
		local rewardsGridY: number = rightPanelHeight + ScreenConstants.PADDING_2
		local buyPassTextProps = getTextProps({
			["Text"] = "BUY SEASON PASS",
			["TextSize"] = 20,
			["Bold"] = true,
		})
		local bundleTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 20,
			["Bold"] = true,
			["Text"] = ("BUY PASS + %* LEVELS"):format(levelsGained),
		})
		local titleElement = React.createElement(Text, {
			["key"] = "SeasonPassTitle",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "SEASON 3",
			["TextSize"] = 72,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, ScreenConstants.PADDING_2),
		})
		local logoElement = React.createElement(Image, {
			["key"] = "Image",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, ScreenConstants.PADDING_2 + 72),
			["Size"] = UDim2.fromOffset(500, 281.25),
			["Image"] = RobloxImage.GameProduct.SEASON_3_LOGO,
		})
		local featureListElement = React.createElement(Text, {
			["key"] = "FeatureList",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["TextWrapped"] = true,
			["RichText"] = true,
			["Bold"] = true,
			["TextYAlignment"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, ScreenConstants.PADDING_2 + 72 + 281.25),
			["Size"] = UDim2.fromOffset(500, 72),
			["Text"] = SeasonUtil.getFeatureList(currentTier, ownsPass),
			["TextYAlignment"] = Enum.TextYAlignment.Top,
		})
		local buyPassTextMergedProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 6,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		local rewardsGridX: number = not contentTooTall and 0 or rightPanelOffset
		for key, value in buyPassTextProps do
			buyPassTextMergedProps[key] = value
		end
		local buyPassGrid = React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["CornerRadius"] = 10,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(
				0.5,
				0,
				1,
				-ScreenConstants.PADDING_2
					- 100
					- ScreenConstants.PADDING_1
					- 30
					- ScreenConstants.PADDING_3
					- 100
					- ScreenConstants.PADDING_1
			),
			["Size"] = UDim2.fromOffset(buyPassTextProps.Size.X.Offset + 20, 30),
			["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
		}, React.createElement(Text, buyPassTextMergedProps))
		local buyPassButton = React.createElement(ShopSeasonPassBuyButton, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ProductId"] = nil,
			["TextSize"] = 36,
			["TextPadding"] = 12,
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(
				0.5,
				0,
				1,
				-ScreenConstants.PADDING_2 - 100 - ScreenConstants.PADDING_1 - 30 - ScreenConstants.PADDING_3
			),
			["Size"] = UDim2.fromOffset(540 - ScreenConstants.PADDING_2 * 2, 100),
			["ProductId"] = CurrentSeasonProductId,
		})
		local bundleTextMergedProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 6,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in bundleTextProps do
			bundleTextMergedProps[key] = value
		end
		local createElement = React.createElement
		local Fragment = React.Fragment
		local seasonInfoElement = createElement(
			Grid,
			{
				["key"] = "SeasonInfo",
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["CornerRadius"] = 10,
				["Size"] = UDim2.fromOffset(540, seasonInfoHeight),
			},
			titleElement,
			logoElement,
			featureListElement,
			buyPassGrid,
			buyPassButton,
			createElement(Grid, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["CornerRadius"] = 10,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -ScreenConstants.PADDING_2 - 100 - ScreenConstants.PADDING_1),
				["Size"] = UDim2.fromOffset(bundleTextProps.Size.X.Offset + 20, 30),
				["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
			}, createElement(Text, bundleTextMergedProps)),
			createElement(ShopSeasonPassBuyButton, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ProductId"] = nil,
				["TextSize"] = 36,
				["TextPadding"] = 12,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -ScreenConstants.PADDING_2),
				["Size"] = UDim2.fromOffset(540 - ScreenConstants.PADDING_2 * 2, 100),
				["ProductId"] = CurrentSeasonBundleProductId,
			})
		)
		local previewElement
		if selectedReward.Type == "Cosmetic" then
			previewElement = createElement(CosmeticDisplayViewport, {
				["key"] = "Viewport",
				["Position"] = nil,
				["Size"] = nil,
				["Cosmetics"] = nil,
				["Position"] = UDim2.fromOffset(rightPanelOffset, 0),
				["Size"] = UDim2.fromOffset(rightPanelWidth, rightPanelHeight),
				["Cosmetics"] = { selectedReward.CosmeticId },
			})
		else
			previewElement = createElement(
				Image,
				{
					["key"] = "Gems",
					["Position"] = nil,
					["Size"] = nil,
					["Image"] = nil,
					["Position"] = UDim2.fromOffset(rightPanelOffset, 0),
					["Size"] = UDim2.fromOffset(rightPanelWidth, rightPanelHeight),
					["Image"] = RobloxImage.Icon.GEM_GREEN_256,
				},
				createElement(
					Text,
					{
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Text"] = nil,
						["TextSize"] = 96,
						["Bold"] = true,
						["TextColor3"] = nil,
						["ZIndex"] = 5,
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.5),
						["Text"] = ("%* Gem%*"):format(
							StringUtil.formatNumber(selectedReward.Quantity),
							selectedReward.Quantity == 1 and "" or "s"
						),
						["TextColor3"] = Color.Green,
					},
					createElement(Outline, {
						["Thickness"] = 5,
						["Color"] = nil,
						["Color"] = Color3.fromRGB(0, 89, 42),
					})
				)
			)
		end
		return createElement(
			Fragment,
			nil,
			seasonInfoElement,
			previewElement,
			React.createElement(ShopSeasonPassSkip, {
				["AnchorPoint"] = Vector2.new(1, 1),
				["Position"] = UDim2.fromOffset(rightPanelOffset + rightPanelWidth, rightPanelHeight),
				["SelectedTierId"] = selectedTierId,
			}),
			React.createElement(SeasonPassRewardsList, {
				["Position"] = nil,
				["FrameSize"] = nil,
				["ItemSize"] = nil,
				["Padding"] = 20,
				["StepperHeight"] = 35,
				["SeasonPassExperience"] = nil,
				["SelectedTierId"] = nil,
				["SetSelectedTierId"] = nil,
				["Position"] = UDim2.fromOffset(rewardsGridX, rewardsGridY),
				["FrameSize"] = Size.new(rewardsGridWidth, 298),
				["ItemSize"] = Size.new(227, 227),
				["SeasonPassExperience"] = seasonData.Experience,
				["SelectedTierId"] = selectedTierId,
				["SetSelectedTierId"] = setSelectedTierId,
			})
		)
	end,
}
