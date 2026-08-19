-- ShopCrate

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useState = React.useState
local NewShopContext = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local ShopCrateBuyButton = RuntimeLib.import(script, script.Parent, "shop-crate-buy-button").ShopCrateBuyButton
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local ScrollingFrame = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "common", "scrolling-frame").ScrollingFrame
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local Badge = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "badge").Badge
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local CosmeticRarities = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetic-rarity").CosmeticRarities
local ShopScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "shop-screen-constants").ShopScreenConstants
local SLOT_SIZE = Vector2.new(360, 360)

type ShopCrateProps = {
	CrateId: string,
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["ShopCrate"] = function(props: ShopCrateProps)
		local shopContext = useContext(NewShopContext)
		local crate = Crates[props.CrateId]
		local _, setSelectedCosmetic = useState(nil)
		local filteredCount: number = 0
		local filteredProducts = {}
		for index, product in crate.Products do
			local _ = index - 1
			if product.Quantity ~= 5 == true then
				filteredCount = filteredCount + 1
				filteredProducts[filteredCount] = product
			end
		end
		local productIds = table.create(#filteredProducts)
		for index, product in filteredProducts do
			local _ = index - 1
			productIds[index] = product.ProductId
		end
		local rewards = crate.Rewards
		local probabilities = table.create(#rewards)
		for index, reward in rewards do
			local _ = index - 1
			probabilities[index] = reward.Probability
		end
		local probabilitySum = ArrayUtil.sum(probabilities)
		local pageWidth: number = shopContext.PageSize.X
		local buttonsWidth: number = ScreenUtil.getGridSize(ShopScreenConstants.CRATE_BUY_BUTTON_SIZE_X, ScreenConstants.PADDING_1, 3)
		local buttonsHeight: number = 250 + ScreenConstants.PADDING_1 + 50
		local rewardListX: number = ScreenConstants.PADDING_2 + buttonsWidth + ScreenConstants.PADDING_2
		local rewardListWidth: number = pageWidth - rewardListX - ScreenConstants.PADDING_2
		local rewardListHeight: number = SLOT_SIZE.Y
		local titleElement = React.createElement(Text, {
			["ZIndex"] = 4,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextColor3"] = nil,
			["Bold"] = true,
			["TextSize"] = 48,
			["DropShadow"] = nil,
			["Position"] = UDim2.fromOffset(ScreenConstants.PADDING_2, ScreenConstants.PADDING_2),
			["Size"] = UDim2.fromOffset(buttonsWidth, 48),
			["Text"] = ("%*"):format((string.upper(crate.DisplayName))),
			["TextColor3"] = crate.Color,
			["DropShadow"] = Vector2.new(2, 4),
		})
		local buyButtons = table.create(#productIds)
		for index, productId in productIds do
			local _ = index - 1
			buyButtons[index] = React.createElement(ShopCrateBuyButton, {
				["key"] = productId,
				["ProductId"] = productId,
			})
		end
		local buttonsGrid = React.createElement(Grid, {
			["key"] = "Buttons",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.new(0, ScreenConstants.PADDING_2, 1, -ScreenConstants.PADDING_2),
			["Size"] = UDim2.fromOffset(buttonsWidth, buttonsHeight),
		}, buyButtons, React.createElement(List, {
			["Padding"] = UDim.new(0, ScreenConstants.PADDING_1),
		}))
		local rewards = crate.Rewards
		local rewardSlots = table.create(#rewards)
		local function createRewardSlot(reward, index: number)
			local cosmetic = Cosmetics[reward.CosmeticId]
			local rarity = CosmeticRarities[cosmetic.Rarity]
			local chancePercent: number = reward.Probability / probabilitySum * 100
			return React.createElement(CosmeticSlot, {
				["Size"] = nil,
				["CosmeticId"] = nil,
				["LayoutOrder"] = nil,
				["Activated"] = nil,
				["ActivateReroute"] = true,
				["Size"] = Size.new(SLOT_SIZE.X, SLOT_SIZE.Y),
				["CosmeticId"] = cosmetic.Id,
				["LayoutOrder"] = index,
				["Activated"] = function()
					setSelectedCosmetic(cosmetic.Id)
				end,
			}, React.createElement(Badge, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextSize"] = nil,
				["Color"] = nil,
				["ZIndex"] = 5,
				["LayoutOrder"] = 1,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.new(1, -10, 0, 10),
				["Text"] = ("%*%%"):format((string.format("%.1f", chancePercent))),
				["TextSize"] = 0.06666666666666667 * SLOT_SIZE.X,
				["Color"] = rarity.Color,
			}))
		end
		for index, reward in rewards do
			rewardSlots[index] = createRewardSlot(reward, index - 1, rewards)
		end
		return React.createElement(Grid, {
			["key"] = nil,
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 10,
			["key"] = props.CrateId,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(pageWidth, 400),
		}, titleElement, buttonsGrid, React.createElement(ScrollingFrame, {
			["key"] = "RewardList",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["CanvasWidth"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 0,
			["ListLayout"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, rewardListX, 0.5, 0),
			["Size"] = UDim2.fromOffset(rewardListWidth, rewardListHeight),
			["CanvasWidth"] = ScreenUtil.getGridSize(SLOT_SIZE.X, ScreenConstants.PADDING_1, #crate.Rewards),
			["ScrollingDirection"] = Enum.ScrollingDirection.X,
			["ListLayout"] = {
				["Padding"] = UDim.new(0, 10),
			},
		}, rewardSlots))
	end,
}
