-- CosmeticsShopSeasonPassSidebar

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local ShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "shop-context").ShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local GameProduct = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local CurrentSeasonBundleProductId = GameProduct.CurrentSeasonBundleProductId
local CurrentSeasonProductId = GameProduct.CurrentSeasonProductId
local PurchaseType = GameProduct.PurchaseType
local CosmeticsShopSidebarButton = RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-button").CosmeticsShopSidebarButton
local CosmeticsShopSidebarList = RuntimeLib.import(script, script.Parent, "cosmetics-shop-sidebar-list").CosmeticsShopSidebarList
local SeasonPassRewards = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").SeasonPassRewards
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useState = React.useState
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

type Props = {
	SeasonData: {
		Experience: number
	},
	OwnsPremium: boolean
}

return {
	["CosmeticsShopSeasonPassSidebar"] = function(props: Props)
		local shopContext = useContext(ShopContext)
		local isPremiumBundle, setIsPremiumBundle = useState(false)
		local selectedProductType = shopContext.SelectedProductData
		if selectedProductType ~= nil then
			selectedProductType = selectedProductType.ProductType
		end
		if selectedProductType ~= "SeasonPass" then
			return React.createElement(React.Fragment)
		end
		local productId
		if isPremiumBundle then
			productId = CurrentSeasonBundleProductId
		else
			productId = CurrentSeasonProductId
		end
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(productId)
		local currentTier = SeasonUtil.getTier(props.SeasonData.Experience)
		local bonusLevels = SeasonUtil.getTier(props.SeasonData.Experience + SeasonUtil.getExperience(15)) - currentTier
		local isMobile = ScreenUtil.isMobile()
		if isMobile then
			isMobile = not ScreenUtil.isTablet()
		end
		local titleElement = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "Season Pass",
			["TextSize"] = 32,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 20)
		})
		local imageElement
		if isMobile then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 72),
				["Size"] = UDim2.fromOffset(374, 180),
				["Image"] = RobloxImage.GameProduct.AZAZEL_LARGE,
				["ScaleType"] = Enum.ScaleType.Crop
			})
		end
		local featureListElement = React.createElement(Text, {
			["Position"] = nil,
			["Size"] = nil,
			["AutomaticSize"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["TextWrapped"] = true,
			["RichText"] = true,
			["Bold"] = true,
			["TextXAlignment"] = nil,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(34, isMobile and 72 or 272),
			["Size"] = UDim2.fromOffset(374, 60),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["Text"] = SeasonUtil.getFeatureList(currentTier, props.OwnsPremium),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		})
		local listProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, (isMobile and 72 or 272) + 60 + 20),
			["Size"] = UDim2.new(0, 374, 1, -((isMobile and 72 or 272) + 60 + 20 + 327 + 20))
		}
		local rewardsValues = ObjectUtils.values(SeasonPassRewards)
		local cosmetics = table.create(#rewardsValues)
		for index, reward in rewardsValues do
			local _ = index - 1
			cosmetics[index] = reward.Type == "Cosmetic" and {
				["CosmeticId"] = reward.CosmeticId,
				["SubText"] = ("Tier %*"):format(reward.Tier + 1),
				["LayoutOrder"] = reward.Tier
			} or nil
		end
		listProps.Cosmetics = ArrayUtil.filterDefined(cosmetics)
		local createElement = React.createElement
		local fragment = React.Fragment
		local fragmentProps = nil
		local listElement = React.createElement(CosmeticsShopSidebarList, listProps)
		local createElement = React.createElement
		local button = Button
		local passOnlyButtonProps = {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Pass Only",
			["Color"] = nil,
			["Disabled"] = false,
			["Activated"] = nil,
			["Position"] = UDim2.new(0, 30, 1, -300),
			["Size"] = { 182, 50 }
		}
		local passOnlyColor
		if isPremiumBundle then
			passOnlyColor = Color.Button.Blue
		else
			passOnlyColor = Color.Button.Yellow
		end
		passOnlyButtonProps.Color = passOnlyColor
		function passOnlyButtonProps.Activated()
			setIsPremiumBundle(false)
		end
		local passOnlyButton = createElement(button, passOnlyButtonProps)
		local bonusLevelsBadge = React.createElement(Grid, {
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(0, 313, 1, -300),
			["Size"] = UDim2.fromOffset(115, 27),
			["BackgroundColor3"] = Color.Purple,
			["CornerRadius"] = {
				["TopLeft"] = 10,
				["TopRight"] = 10
			}
		}, React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 16,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Text"] = ("+%* LEVELS"):format(bonusLevels)
		}))
		local createElement = React.createElement
		local button = Button
		local passBonusButtonProps = {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Pass + Bonus",
			["Color"] = nil,
			["Disabled"] = false,
			["Activated"] = nil,
			["Position"] = UDim2.new(0, 222, 1, -300),
			["Size"] = { 182, 50 }
		}
		local passBonusColor
		if isPremiumBundle then
			passBonusColor = Color.Button.Yellow
		else
			passBonusColor = Color.Button.Blue
		end
		passBonusButtonProps.Color = passBonusColor
		function passBonusButtonProps.Activated()
			setIsPremiumBundle(true)
		end
		local passBonusButton = createElement(button, passBonusButtonProps)
		local gemsButton
		if gameProduct.PriceInGems == nil then
			gemsButton = nil
		else
			gemsButton = createElement(CosmeticsShopSidebarButton, {
				["Position"] = nil,
				["Text"] = "Buy",
				["Price"] = nil,
				["PurchaseType"] = nil,
				["Disabled"] = nil,
				["Activated"] = nil,
				["Position"] = UDim2.new(0, 30, 1, -240),
				["Price"] = gameProduct.PriceInGems,
				["PurchaseType"] = PurchaseType.Gems,
				["Disabled"] = props.OwnsPremium or not Flamework.resolveDependency("YOK"):canPurchase(productId, PurchaseType.Gems),
				["Activated"] = function()
					return shopContext.Purchase(productId, PurchaseType.Gems)
				end
			})
		end
		return createElement(fragment, fragmentProps, titleElement, imageElement, featureListElement, listElement, passOnlyButton, bonusLevelsBadge, passBonusButton, gemsButton, React.createElement(CosmeticsShopSidebarButton, {
			["Position"] = nil,
			["Text"] = "Buy",
			["Price"] = nil,
			["PurchaseType"] = nil,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.new(0, 30, 1, -130),
			["Price"] = gameProduct.PriceInRobux,
			["PurchaseType"] = PurchaseType.Robux,
			["Disabled"] = props.OwnsPremium or not Flamework.resolveDependency("YOK"):canPurchase(productId, PurchaseType.Robux),
			["Activated"] = function()
				return shopContext.Purchase(productId, PurchaseType.Robux)
			end
		}))
	end
}
