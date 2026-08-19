-- SeasonPassGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Robux = RuntimeLib.import(script, script.Parent.Parent, "components", "robux").Robux
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local SeasonPass = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass")
local CurrentSeason = SeasonPass.CurrentSeason
local SeasonPassRewards = SeasonPass.SeasonPassRewards
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local SeasonPassRewardsList = RuntimeLib.import(script, script.Parent, "season-pass-rewards-list").SeasonPassRewardsList
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local MarketplaceService: MarketplaceService = Services.MarketplaceService
local Players: Players = Services.Players
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonGamepass = GameProduct.CurrentSeasonGamepass
local CurrentSeasonGamepassBundle = GameProduct.CurrentSeasonGamepassBundle
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile

type SeasonPassGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["SeasonPassGui"] = function(props: SeasonPassGuiProps)
		local profile = useProfile()
		local seasonData = profile.Season.SeasonData[CurrentSeason]
		local ownsPass = profile.Season.OwnedPasses[CurrentSeason] ~= nil
		local experience = seasonData.Experience
		local currentTier = SeasonUtil.getTier(experience)
		local progress = SeasonUtil.getProgress(experience)
		local nextTier = currentTier + 1
		local rewardCount = 0
		for _ in SeasonPassRewards do
			rewardCount = rewardCount + 1
		end
		local maxTierIndex = rewardCount - 1
		local selectedTier, setSelectedTier = useState(math.min(nextTier, maxTierIndex))
		local selectedReward = SeasonPassRewards[selectedTier]
		local cosmetic
		if selectedReward.Type == "Cosmetic" then
			cosmetic = Cosmetics[selectedReward.CosmeticId]
		else
			cosmetic = nil
		end
		local rewardDescription
		if selectedReward.Type == "Cosmetic" then
			local cosmeticDescription
			if cosmetic == nil then
				cosmeticDescription = cosmetic
			else
				cosmeticDescription = cosmetic.Description
			end
			rewardDescription = cosmeticDescription == nil and "" or cosmeticDescription
		else
			rewardDescription = ("%* Gems"):format(selectedReward.Quantity)
		end
		local isNextTier = selectedTier == currentTier + 1
		local tiersToSkip = selectedReward.Tier - currentTier
		local isUnlocked = selectedReward.Tier <= currentTier
		local canUnlock
		if isUnlocked then
			canUnlock = not selectedReward.Premium or ownsPass
		else
			canUnlock = isUnlocked
		end
		local skipPrice = SeasonUtil.getSkipPrice(tiersToSkip)
		local tierGain = SeasonUtil.getTier(experience + SeasonUtil.getExperience(15)) - SeasonUtil.getTier(experience)
		local windowProps = {
			["key"] = "SeasonPass",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleText"] = "SEASON REWARDS",
			["TitleImage"] = nil,
			["TitlePosition"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1240, 710),
			["TitleImage"] = RobloxImage.Icon.SEASON_PASS,
			["TitlePosition"] = UDim2.fromOffset(20, 20)
		}
		local purchasePanel = React.createElement(Grid, {
			["key"] = "SeasonPassPurchase",
			["Position"] = nil,
			["Size"] = nil,
			["CornerRadius"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(20, 64),
			["Size"] = UDim2.fromOffset(510, 258),
			["CornerRadius"] = {
				["TopLeft"] = 10,
				["TopRight"] = 10
			}
		}, React.createElement(Text, {
			["key"] = "Title",
			["Position"] = nil,
			["Text"] = "Premium Season Pass",
			["Bold"] = true,
			["TextSize"] = 28,
			["Position"] = UDim2.fromOffset(20, 20)
		}), React.createElement(Image, {
			["key"] = "Image",
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["Position"] = UDim2.fromOffset(20, 60),
			["Size"] = UDim2.fromOffset(168, 168),
			["Image"] = RobloxImage.Icon.SEASON_PASS_PREMIUM
		}, React.createElement(CornerRadius, {
			["Radius"] = 10
		})), React.createElement(Text, {
			["key"] = "FeatureList",
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 21,
			["TextWrapped"] = true,
			["RichText"] = true,
			["TextXAlignment"] = nil,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(208, 60),
			["Size"] = UDim2.fromOffset(282, 160),
			["Text"] = SeasonUtil.getFeatureList(currentTier, ownsPass),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		}), React.createElement(Grid, {
			["key"] = "ButtonClipping1",
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["Position"] = UDim2.fromScale(0, 1),
			["Size"] = UDim2.fromOffset(255, 50)
		}, React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["TextOffsetY"] = 5,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Color"] = nil,
			["Position"] = UDim2.fromOffset(0, -10),
			["Size"] = { 265, 60 },
			["Disabled"] = ownsPass,
			["Activated"] = function()
				MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CurrentSeasonGamepass)
			end,
			["Color"] = Color.Button.Green
		})), React.createElement(Grid, {
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.fromScale(0.75, 1),
			["Size"] = UDim2.fromOffset(145, 30),
			["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
			["CornerRadius"] = {
				["TopLeft"] = 10,
				["TopRight"] = 10
			}
		}, React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Text"] = ("+%* LEVELS"):format(tierGain)
		})), React.createElement(Grid, {
			["key"] = "ButtonClipping2",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.fromScale(1, 1),
			["Size"] = UDim2.fromOffset(255, 50)
		}, React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["TextOffsetY"] = 5,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Color"] = nil,
			["Position"] = UDim2.fromOffset(-10, -10),
			["Size"] = { 265, 60 },
			["Disabled"] = ownsPass,
			["Activated"] = function()
				MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CurrentSeasonGamepassBundle)
			end,
			["Color"] = Color.Button.Yellow
		})))
		local rewardPanelProps = {
			["key"] = "Reward",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(550, 64),
			["Size"] = UDim2.fromOffset(670, 308)
		}
		local rewardPreview
		if cosmetic then
			rewardPreview = React.createElement(CosmeticSlot, {
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = Size.new(268, 268),
				["CosmeticId"] = cosmetic.Id,
				["SeasonPassPremium"] = selectedReward.Premium
			})
		else
			rewardPreview = React.createElement(Image, {
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = UDim2.fromOffset(268, 268),
				["Image"] = RobloxImage.Icon.GEM_GREEN_256
			})
		end
		local rewardTitle = React.createElement(Text, {
			["key"] = "Title",
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["TextSize"] = 28,
			["Position"] = UDim2.fromOffset(308, 20),
			["Text"] = ("Tier %* Reward"):format(selectedReward.Tier + 1)
		})
		local descriptionElement = React.createElement(Text, {
			["key"] = "Description",
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["TextWrapped"] = true,
			["TextXAlignment"] = nil,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(308, 60),
			["Text"] = rewardDescription,
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		})
		local skipPriceElement
		if isUnlocked then
			skipPriceElement = nil
		else
			skipPriceElement = React.createElement(Robux, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["TextSize"] = 32,
				["Price"] = nil,
				["SubText"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromOffset(308, 203),
				["Price"] = skipPrice,
				["SubText"] = ("to skip %* %*"):format(tiersToSkip, tiersToSkip == 1 and "tier" or "tiers")
			})
		end
		local actionButton
		if isUnlocked and (canUnlock or selectedReward.PostponeReward) then
			actionButton = nil
		else
			actionButton = React.createElement(Button, {
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.new(1, -20, 0, 203),
				["Size"] = { 168, 50 },
				["Text"] = isUnlocked and "Unlock" or "Skip",
				["Activated"] = function()
					if isUnlocked then
						MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CurrentSeasonGamepass)
					else
						SeasonUtil.promptSkipTiers(tiersToSkip)
					end
				end,
				["Color"] = Color.Button.Green
			})
		end
		local progressBarProps = {
			["key"] = "ProgressBar",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(308, 248),
			["Size"] = UDim2.fromOffset(342, 8)
		}
		local progressBarFilledProps = {
			["key"] = "ProgressBarFilled",
			["Size"] = nil,
			["BackgroundColor3"] = nil
		}
		local progressFraction
		if isNextTier then
			progressFraction = SeasonUtil.getProgressDecimal(experience)
		else
			progressFraction = isUnlocked and 1 or 0
		end
		progressBarFilledProps.Size = UDim2.fromScale(progressFraction, 1)
		progressBarFilledProps.BackgroundColor3 = Color.Green
		local progressBar = React.createElement(Grid, progressBarProps, React.createElement(Grid, progressBarFilledProps))
		local tierTextProps = {
			["key"] = "TierText",
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["TextSize"] = 20,
			["RichText"] = true,
			["Position"] = UDim2.fromOffset(308, 266)
		}
		local tierText
		if isNextTier then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font>/<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP)"):format(selectedReward.Tier + 1, progress, SeasonUtil.getExperience(selectedReward.Tier) - SeasonUtil.getExperience(selectedReward.Tier - 1))
		elseif isUnlocked then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>DONE!</b></font>)"):format(selectedReward.Tier + 1)
		else
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP to unlock!)"):format(selectedReward.Tier + 1, SeasonUtil.getExperience(selectedReward.Tier) - experience)
		end
		tierTextProps.Text = tierText
		return React.createElement(Window, windowProps, purchasePanel, React.createElement(Grid, rewardPanelProps, rewardPreview, rewardTitle, descriptionElement, skipPriceElement, actionButton, progressBar, React.createElement(Text, tierTextProps), React.createElement(CornerRadius, {
			["Radius"] = 10
		})), React.createElement(SeasonPassRewardsList, {
			["Position"] = nil,
			["FrameSize"] = nil,
			["ItemSize"] = nil,
			["Padding"] = 20,
			["StepperHeight"] = 35,
			["SeasonPassExperience"] = nil,
			["SelectedTierId"] = nil,
			["SetSelectedTierId"] = nil,
			["Position"] = UDim2.fromOffset(20, 392),
			["FrameSize"] = Size.new(1200, 298),
			["ItemSize"] = Size.new(227, 227),
			["SeasonPassExperience"] = seasonData.Experience,
			["SelectedTierId"] = selectedTier,
			["SetSelectedTierId"] = setSelectedTier
		}))
	end
}
