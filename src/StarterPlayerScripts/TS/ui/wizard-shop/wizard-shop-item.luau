-- WizardShopItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local GameCurrencyItem = RuntimeLib.import(script, script.Parent.Parent, "blacksmith-shop", "game-currency-item").GameCurrencyItem
local ShopType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop").ShopType
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type TeamUpgradeTier = {
	Description: string,
	CurrencyType: any,
	Price: number,
}

type WizardShopItemProps = {
	TeamUpgrades: { [string]: number? },
	TeamUpgrade: {
		Id: string,
		Name: string,
		Icon: string,
		ItemIndex: number,
		Tiers: { TeamUpgradeTier },
	},
	CanPurchaseItem: (currencyType: any, price: number) -> boolean,
}

return {
	["WizardShopItem"] = function(props: WizardShopItemProps)
		local currentLevel: number? = props.TeamUpgrades[props.TeamUpgrade.Id]
		local nextTier = (currentLevel == nil and 0 or currentLevel) + 1
		local maxTier = #props.TeamUpgrade.Tiers
		local displayTier = math.min(nextTier, maxTier)
		local tier: TeamUpgradeTier = props.TeamUpgrade.Tiers[displayTier]
		local hasNextTier = nextTier <= #props.TeamUpgrade.Tiers
		local displayName = ("%* %*"):format(props.TeamUpgrade.Name, (MathUtil.toRomanNumeral(nextTier)))
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 18,
			["FrameSize"] = nil,
			["Text"] = tier.Description,
			["FrameSize"] = Vector2.new(190, 90)
		})
		local viewportBackground = React.createElement(Grid, {
			["key"] = "ViewportBackground",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = nil,
			["Size"] = UDim2.fromOffset(350, 150),
			["CornerRadius"] = {
				["TopLeft"] = 10,
				["TopRight"] = 10
			}
		}, React.createElement(Grid, {
			["key"] = "Viewport",
			["Size"] = nil,
			["Size"] = UDim2.fromOffset(150, 150)
		}, React.createElement(Image, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromScale(0.65, 0.65),
			["Image"] = props.TeamUpgrade.Icon
		}), React.createElement(GameCurrencyItem, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TextSize"] = 18,
			["CurrencyType"] = nil,
			["Quantity"] = nil,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.new(1, -10, 0, 10),
			["Size"] = UDim2.fromOffset(32, 32),
			["CurrencyType"] = tier.CurrencyType,
			["Quantity"] = tier.Price
		})))
		local buttonElement = React.createElement(Grid, {
			["key"] = "ButtonClipping",
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["Position"] = UDim2.fromOffset(0, 150),
			["Size"] = UDim2.fromOffset(350, 50)
		}, React.createElement(Button, {
			["key"] = "Button",
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["Color"] = nil,
			["Disabled"] = nil,
			["TextOffsetY"] = 5,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(0, -10),
			["Size"] = { 350, 60 },
			["Color"] = Color.Button.Green,
			["Disabled"] = not (props.CanPurchaseItem(tier.CurrencyType, tier.Price) and hasNextTier),
			["Activated"] = function()
				Flamework.resolveDependency("ADv"):purchaseTeamUpgrade(ShopType.Merchant, props.TeamUpgrade.ItemIndex)
			end
		}))
		local displayNameElement = React.createElement(Text, {
			["key"] = "DisplayName",
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Position"] = UDim2.fromOffset(150, 16),
			["Text"] = displayName
		})
		local descriptionProps = {
			["key"] = "Description",
			["Position"] = nil,
			["TextXAlignment"] = nil,
			["TextWrapped"] = true,
			["Position"] = UDim2.fromOffset(150, 49),
			["TextXAlignment"] = Enum.TextXAlignment.Left
		}
		for propName, propValue in textProps do
			descriptionProps[propName] = propValue
		end
		descriptionProps.Size = UDim2.fromOffset(190, 90)
		return React.createElement(Grid, {
			["key"] = props.TeamUpgrade.Id,
			["Size"] = UDim2.fromOffset(350, 200),
			["LayoutOrder"] = props.TeamUpgrade.ItemIndex
		}, viewportBackground, buttonElement, displayNameElement, React.createElement(Text, descriptionProps))
	end
}
