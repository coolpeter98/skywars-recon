-- ShopSeasonPassSkip

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local MarketplaceService: MarketplaceService = Services.MarketplaceService
local Players: Players = Services.Players
local CurrentSeasonGamepass = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").CurrentSeasonGamepass
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useProfile = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useProfile
local SeasonPass = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass")
local CurrentSeason = SeasonPass.CurrentSeason
local SeasonPassRewards = SeasonPass.SeasonPassRewards
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local Robux = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "robux").Robux

type ShopSeasonPassSkipProps = {
	SelectedTierId: number,
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["ShopSeasonPassSkip"] = function(props: ShopSeasonPassSkipProps)
		local profile = useProfile()
		local seasonData = profile.Season.SeasonData[CurrentSeason]
		local ownsPass: boolean = profile.Season.OwnedPasses[CurrentSeason] ~= nil
		local currentTier = SeasonUtil.getTier(seasonData.Experience)
		local currentProgress = SeasonUtil.getProgress(seasonData.Experience)
		local reward = SeasonPassRewards[props.SelectedTierId]
		local isNextTier: boolean = reward.Tier == currentTier + 1
		local tiersToSkip: number = reward.Tier - currentTier
		local isUnlocked: boolean = reward.Tier <= currentTier
		local canClaim
		if isUnlocked then
			canClaim = not reward.Premium or ownsPass
		else
			canClaim = isUnlocked
		end
		local needsPass: boolean = not canClaim
		if needsPass then
			needsPass = not reward.PostponeReward
		end
		local skipPrice = SeasonUtil.getSkipPrice(tiersToSkip)
		local isEquipped: boolean
		if reward.Type == "Cosmetic" then
			isEquipped = Flamework.resolveDependency("Ggz"):isActive(reward.CosmeticId, profile.Cosmetics)
		else
			isEquipped = false
		end
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(420, 144)
		}
		local skipButton
		if isUnlocked and not needsPass then
			skipButton = nil
		else
			skipButton = React.createElement(Button, {
				["Size"] = nil,
				["Text"] = nil,
				["TextSize"] = 36,
				["Activated"] = nil,
				["Color"] = nil,
				["Size"] = { 200, 80 },
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
		if canClaim then
			if reward.Type == "Cosmetic" then
				canClaim = React.createElement(Button, {
					["Size"] = nil,
					["Text"] = nil,
					["Disabled"] = nil,
					["Muted"] = true,
					["TextSize"] = 36,
					["Activated"] = nil,
					["Color"] = nil,
					["Size"] = { 200, 80 },
					["Text"] = isEquipped and "Equipped" or "Equip",
					["Disabled"] = isEquipped,
					["Activated"] = function()
						Flamework.resolveDependency("jL9"):playSound(RobloxSound.Inventory.MOVE_ITEM, {
							["Volume"] = 1
						})
						Flamework.resolveDependency("Ggz"):enableCosmetic(reward.CosmeticId)
					end,
					["Color"] = Color.Button.Green
				})
			else
				canClaim = false
			end
		end
		local priceDisplay
		if isUnlocked then
			priceDisplay = nil
		else
			priceDisplay = React.createElement(Robux, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["TextSize"] = 36,
				["Price"] = nil,
				["SubText"] = nil,
				["SubTextSize"] = 24,
				["SubTextColor"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromOffset(320, 40),
				["Price"] = skipPrice,
				["SubText"] = ("to skip %* %*"):format(tiersToSkip, tiersToSkip == 1 and "tier" or "tiers"),
				["SubTextColor"] = Color3.fromRGB(200, 200, 200)
			})
		end
		local buyPassText
		if isUnlocked and needsPass then
			buyPassText = React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = "Buy Season Pass\nTo Unlock!",
				["TextSize"] = 24,
				["TextWrapped"] = true,
				["Bold"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromOffset(320, 40)
			})
		else
			buyPassText = nil
		end
		local createProgressBar = React.createElement
		local progressBarGrid = Grid
		local progressBarProps = {
			["key"] = "ProgressBar",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(0, 100),
			["Size"] = UDim2.fromOffset(420, 10)
		}
		local createFilledBar = React.createElement
		local fillGrid = Grid
		local fillProps = {
			["key"] = "ProgressBarFilled",
			["Size"] = nil,
			["BackgroundColor3"] = nil
		}
		local fromScale = UDim2.fromScale
		local fillWidth: number
		if isNextTier then
			fillWidth = SeasonUtil.getProgressDecimal(seasonData.Experience)
		else
			fillWidth = isUnlocked and 1 or 0
		end
		fillProps.Size = fromScale(fillWidth, 1)
		fillProps.BackgroundColor3 = Color.Green
		local progressBar = createProgressBar(progressBarGrid, progressBarProps, createFilledBar(fillGrid, fillProps))
		local createTierText = React.createElement
		local textComponent = Text
		local tierTextProps = {
			["key"] = "TierText",
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["TextSize"] = 24,
			["RichText"] = true,
			["Position"] = UDim2.fromOffset(0, 120)
		}
		local tierText: string
		if isNextTier then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font>/<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP)"):format(reward.Tier + 1, currentProgress, SeasonUtil.getExperience(reward.Tier) - SeasonUtil.getExperience(reward.Tier - 1))
		elseif isUnlocked then
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>DONE!</b></font>)"):format(reward.Tier + 1)
		else
			tierText = ("Tier %* (<font face=\'Gotham\' color=\'#36E270\'><b>%*</b></font> SP to unlock!)"):format(reward.Tier + 1, SeasonUtil.getExperience(reward.Tier) - seasonData.Experience)
		end
		tierTextProps.Text = tierText
		return createElement(grid, gridProps, skipButton, canClaim, priceDisplay, buyPassText, progressBar, createTierText(textComponent, tierTextProps))
	end
}
