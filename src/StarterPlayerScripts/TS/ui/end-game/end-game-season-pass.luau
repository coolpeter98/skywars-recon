-- EndGameSeasonPass

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local EndGameWindow = RuntimeLib.import(script, script.Parent, "end-game-window").EndGameWindow
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local MarketplaceService: MarketplaceService = Services.MarketplaceService
local Players: Players = Services.Players
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonGamepass = GameProduct.CurrentSeasonGamepass
local CurrentSeasonGamepassBundle = GameProduct.CurrentSeasonGamepassBundle
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local SeasonPassRewards = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").SeasonPassRewards
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent, "events").Events
local Robux = RuntimeLib.import(script, script.Parent.Parent, "components", "robux").Robux
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image

type EndGameSeasonPassProps = {
	SeasonData: { Experience: number, CurrentTierId: number },
	Profile: {
		OwnsPremium: boolean,
		Cosmetics: {
			ActiveSkinsGroup: { [string]: string },
			Active: { [string]: string },
		},
	},
	AnchorPoint: Vector2,
	Position: UDim2,
	Visible: boolean,
	FrameRef: any,
}

return {
	["EndGameSeasonPass"] = function(props: EndGameSeasonPassProps)
		local experience = props.SeasonData.Experience
		local currentTier = SeasonUtil.getTier(experience)
		local tierProgress = SeasonUtil.getProgress(experience)
		local currentTierId = props.SeasonData.CurrentTierId
		local rewardCount = 0
		for _ in SeasonPassRewards do
			rewardCount = rewardCount + 1
		end
		local maxTier = rewardCount - 1
		local tierIndex = math.min(currentTierId, maxTier)
		local reward = SeasonPassRewards[tierIndex]
		local isNextTier = tierIndex == currentTier + 1
		local tiersToSkip = reward.Tier - currentTier
		local rewardCosmetic
		if reward.Type == "Cosmetic" then
			rewardCosmetic = Cosmetics[reward.CosmeticId]
		else
			rewardCosmetic = nil
		end
		local rewardDescription
		if reward.Type == "Cosmetic" then
			local description = rewardCosmetic.Description
			rewardDescription = description == nil and "" or description
		else
			rewardDescription = ("%* Gems"):format(reward.Quantity)
		end
		local descriptionProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 16,
			["FrameSize"] = nil,
			["Text"] = rewardDescription,
			["FrameSize"] = Vector2.new(126, 164)
		})
		local tierReached = reward.Tier <= currentTier
		local canClaimNext = props.SeasonData.CurrentTierId <= currentTier
		local skipPrice = SeasonUtil.getSkipPrice(tiersToSkip)
		local bonusLevels = SeasonUtil.getTier(props.SeasonData.Experience + SeasonUtil.getExperience(15)) - SeasonUtil.getTier(props.SeasonData.Experience)
		local premiumTextProps = getTextProps({
			["Text"] = "Unlock premium rewards, faster progress & more!",
			["TextSize"] = 16,
			["FrameSize"] = nil,
			["FrameSize"] = Vector2.new(300, 40)
		})
		local rewardIcon
		if rewardCosmetic then
			rewardIcon = React.createElement(CosmeticSlot, {
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = Size.new(164, 164),
				["CosmeticId"] = rewardCosmetic.Id,
				["SeasonPassPremium"] = reward.Premium
			})
		else
			rewardIcon = React.createElement(Image, {
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = UDim2.fromOffset(164, 164),
				["Image"] = RobloxImage.Icon.GEM_GREEN_256
			})
		end
		local descriptionTextProps = {
			["key"] = "CosmeticDescription",
			["Position"] = nil,
			["TextWrapped"] = true,
			["TextYAlignment"] = nil,
			["TextXAlignment"] = nil,
			["Position"] = UDim2.fromOffset(194, 20),
			["TextYAlignment"] = Enum.TextYAlignment.Top,
			["TextXAlignment"] = Enum.TextXAlignment.Left
		}
		for key, value in descriptionProps do
			descriptionTextProps[key] = value
		end
		local createElement = React.createElement
		local selectedCosmeticProps = {
			["key"] = "SelectedCosmetic",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(20, 42),
			["Size"] = UDim2.fromOffset(340, 304)
		}
		local descriptionText = React.createElement(Text, descriptionTextProps)
		local createElement = React.createElement
		local progressBarProps = {
			["key"] = "ProgressBar",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(20, 194),
			["Size"] = UDim2.fromOffset(300, 8)
		}
		local createElement = React.createElement
		local progressBarFilledProps = {
			["key"] = "ProgressBarFilled",
			["Size"] = nil,
			["BackgroundColor3"] = nil
		}
		local fromScale = UDim2.fromScale
		local fillAmount
		if isNextTier then
			fillAmount = SeasonUtil.getProgressDecimal(experience)
		else
			fillAmount = tierReached and 1 or 0
		end
		progressBarFilledProps.Size = fromScale(fillAmount, 1)
		progressBarFilledProps.BackgroundColor3 = Color.Green
		local progressBar = createElement(Grid, progressBarProps, createElement(Grid, progressBarFilledProps))
		local createElement = React.createElement
		local tierTextProps = {
			["key"] = "TierText",
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["TextSize"] = 20,
			["RichText"] = true,
			["Position"] = UDim2.fromOffset(20, 212)
		}
		local tierText
		if isNextTier then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font>/<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP)"):format(reward.Tier + 1, tierProgress, SeasonUtil.getExperience(reward.Tier) - SeasonUtil.getExperience(reward.Tier - 1))
		elseif tierReached then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>DONE!</b></font>)"):format(reward.Tier + 1)
		else
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP to unlock!)"):format(reward.Tier + 1, SeasonUtil.getExperience(reward.Tier) - experience)
		end
		tierTextProps.Text = tierText
		local tierTextElement = createElement(Text, tierTextProps)
		local skipPriceElement
		if tierReached then
			skipPriceElement = nil
		else
			skipPriceElement = React.createElement(Robux, {
				["Position"] = nil,
				["TextSize"] = 32,
				["Price"] = nil,
				["SubText"] = nil,
				["Position"] = UDim2.fromOffset(20, 244),
				["Price"] = skipPrice,
				["SubText"] = ("to skip %* %*"):format(tiersToSkip, tiersToSkip == 1 and "tier" or "tiers")
			})
		end
		local equipButton
		if tierReached and rewardCosmetic then
			local createElement = React.createElement
			local Button = Button
			local equipButtonProps = {
				["key"] = "Equip",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = "Equip",
				["Color"] = nil,
				["Disabled"] = nil,
				["AbsorbInput"] = true,
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0),
				["Position"] = UDim2.new(0, 20, 0, 244),
				["Size"] = { 140, 50 },
				["Color"] = Color.Button.Green
			}
			local disabled = not canClaimNext
			if not disabled then
				if rewardCosmetic.Type == "Skin" then
					disabled = props.Profile.Cosmetics.ActiveSkinsGroup[rewardCosmetic.ItemGroup] == rewardCosmetic.Id
				else
					disabled = props.Profile.Cosmetics.Active[rewardCosmetic.Type] == rewardCosmetic.Id
				end
			end
			equipButtonProps.Disabled = disabled
			function equipButtonProps.Activated()
				if reward.Premium and not props.OwnsPremium then
					MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CurrentSeasonGamepass)
					return nil
				elseif reward.PostponeReward then
					return nil
				else
					local cosmetic = Cosmetics[rewardCosmetic.Id]
					if cosmetic.Type == "Package" then
						for _, cosmeticId in cosmetic.Cosmetics do
							Flamework.resolveDependency("Ggz"):enableCosmetic(cosmeticId)
						end
					else
						Flamework.resolveDependency("Ggz"):enableCosmetic(rewardCosmetic.Id)
					end
				end
			end
			equipButton = createElement(Button, equipButtonProps)
		else
			equipButton = nil
		end
		local selectedCosmeticSection = createElement(Grid, selectedCosmeticProps, rewardIcon, descriptionText, progressBar, tierTextElement, skipPriceElement, equipButton, React.createElement(Button, {
			["key"] = "NextTier",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["Color"] = nil,
			["AbsorbInput"] = true,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, -20, 0, 244),
			["Size"] = { 140, 50 },
			["Text"] = canClaimNext and "Next" or "Skip",
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				if canClaimNext then
					Events.ClaimSeasonPassTier:fire(props.SeasonData.CurrentTierId + 1)
				else
					SeasonUtil.promptSkipTiers(1)
				end
			end
		}), React.createElement(CornerRadius, {
			["Radius"] = 10
		}))
		local premiumTitle = React.createElement(Text, {
			["Position"] = nil,
			["Text"] = "Premium Season Pass",
			["Bold"] = true,
			["Position"] = UDim2.fromOffset(20, 10)
		})
		local premiumBodyProps = {
			["Position"] = UDim2.fromOffset(20, 43)
		}
		for key, value in premiumTextProps do
			premiumBodyProps[key] = value
		end
		premiumBodyProps.TextXAlignment = Enum.TextXAlignment.Left
		premiumBodyProps.TextYAlignment = Enum.TextYAlignment.Top
		premiumBodyProps.TextWrapped = true
		return React.createElement(EndGameWindow, {
			["key"] = "EndGameSeasonPass",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleText"] = "SEASON PASS",
			["TitleImage"] = nil,
			["Visible"] = nil,
			["FrameRef"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(380, 520),
			["TitleImage"] = RobloxImage.Icon.ARROW,
			["Visible"] = props.Visible,
			["FrameRef"] = props.FrameRef
		}, selectedCosmeticSection, React.createElement(Grid, {
			["key"] = "SeasonPassPurchase",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = nil,
			["Position"] = UDim2.fromOffset(20, 356),
			["Size"] = UDim2.fromOffset(340, 94),
			["CornerRadius"] = {
				["TopLeft"] = 10,
				["TopRight"] = 10
			}
		}, premiumTitle, React.createElement(Text, premiumBodyProps), React.createElement(Grid, {
			["key"] = "ButtonClipping1",
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["Position"] = UDim2.fromScale(0, 1),
			["Size"] = UDim2.fromOffset(170, 50)
		}, React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["TextOffsetY"] = 5,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Color"] = nil,
			["Position"] = UDim2.fromOffset(0, -10),
			["Size"] = { 180, 60 },
			["Disabled"] = props.OwnsPremium,
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
			["Text"] = ("+%* LEVELS"):format(bonusLevels)
		})), React.createElement(Grid, {
			["key"] = "ButtonClipping2",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.fromScale(1, 1),
			["Size"] = UDim2.fromOffset(170, 50)
		}, React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["TextOffsetY"] = 5,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Color"] = nil,
			["Position"] = UDim2.fromOffset(-10, -10),
			["Size"] = { 180, 60 },
			["Disabled"] = props.OwnsPremium,
			["Activated"] = function()
				MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CurrentSeasonGamepassBundle)
			end,
			["Color"] = Color.Button.Yellow
		}))))
	end
}
