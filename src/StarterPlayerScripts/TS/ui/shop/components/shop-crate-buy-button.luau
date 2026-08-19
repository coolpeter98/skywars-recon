-- ShopCrateBuyButton

type Props = {
	ProductId: string,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	ZIndex: number?,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProduct.GameProducts
local PurchaseType = GameProduct.PurchaseType
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local ProductConstants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"game-product",
	"product-constants"
).ProductConstants
local ShopScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "shop-screen-constants").ShopScreenConstants
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext

local CRATE_IMAGE_SIZE = Vector2.new(200, 200)
local BUTTON_SIZE = Vector2.new(ShopScreenConstants.CRATE_BUY_BUTTON_SIZE_X, 75)
local ROBUX_ICON_SIZE = Vector2.new(36, 36)
local GEM_ICON_SIZE = Vector2.new(36, 36)

return {
	["ShopCrateBuyButton"] = function(props: Props)
		local shopContext = useContext(NewShopContext)
		local gameProduct
		if RunService:IsRunning() then
			gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		else
			gameProduct = GameProducts[props.ProductId]
		end
		local crateId = gameProduct.Crate.Id
		local crateQuantity = gameProduct.Crate.Quantity
		local crate = Crates[crateId]
		local robuxTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 36,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(gameProduct.PriceInRobux),
		})
		local gemTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 36,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(gameProduct.PriceInGems),
		})
		local robuxRowWidth = ROBUX_ICON_SIZE.X + ScreenConstants.PADDING_1 + robuxTextProps.Size.X.Offset
		local gemRowWidth = GEM_ICON_SIZE.X + ScreenConstants.PADDING_1 + gemTextProps.Size.X.Offset
		local zIndex = props.ZIndex
		local resolvedZIndex = zIndex == nil and 1 or zIndex
		local singleProductId = nil
		for index, product in crate.Products do
			local _ = index - 1
			if product.Quantity == 1 == true then
				singleProductId = product
				break
			end
		end
		if singleProductId ~= nil then
			singleProductId = singleProductId.ProductId
		end
		local singleProductPrice
		if singleProductId then
			if RunService:IsRunning() then
				singleProductPrice = Flamework.resolveDependency("1EA"):getGameProduct(singleProductId)
			else
				singleProductPrice = GameProducts[singleProductId]
			end
		else
			singleProductPrice = nil
		end
		if singleProductId then
			if singleProductPrice ~= nil then
				singleProductPrice = singleProductPrice.PriceInRobux
			end
		else
			singleProductPrice = singleProductId
		end
		if singleProductPrice == nil then
			singleProductPrice = ProductConstants.DEFAULT_CRATE_PRICE_1_ROBUX
		end
		local savePercentRaw = (1 - gameProduct.PriceInRobux / (singleProductPrice * crateQuantity)) * 100 / 5
		local savePercent = math.round(savePercentRaw) * 5
		local saveTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 20,
			["Bold"] = true,
			["Text"] = ("SAVE %*%%"):format(savePercent),
		})
		local crateImage = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0),
			["Size"] = UDim2.fromOffset(CRATE_IMAGE_SIZE.X, CRATE_IMAGE_SIZE.Y),
			["Image"] = crate.Image,
		})
		local quantityText = React.createElement(
			Text,
			{
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextSize"] = 64,
				["Bold"] = true,
				["TextColor3"] = nil,
				["ZIndex"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 0),
				["Text"] = ("x%*"):format(crateQuantity),
				["TextColor3"] = Color.Yellow,
			},
			React.createElement(Outline, {
				["Thickness"] = 2,
				["Color"] = nil,
				["Color"] = ColorUtil.scaleValue(Color.Yellow, 0.5),
			})
		)
		local saveBadge
		if savePercent >= 5 then
			local saveBadgeTextProps = {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["ZIndex"] = 6,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
			}
			for key, value in saveTextProps do
				saveBadgeTextProps[key] = value
			end
			saveBadge = React.createElement(Grid, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["CornerRadius"] = 10,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 0, CRATE_IMAGE_SIZE.Y - ScreenConstants.PADDING_1 - 50),
				["Size"] = UDim2.fromOffset(saveTextProps.Size.X.Offset + 20, 30),
				["BackgroundColor3"] = Color3.fromRGB(193, 78, 222),
			}, React.createElement(Text, saveBadgeTextProps))
		else
			saveBadge = nil
		end
		local robuxIcon = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (BUTTON_SIZE.X - robuxRowWidth) / 2, 0.5, 0),
			["Image"] = RobloxImage.Icon.ROBUX,
			["Size"] = UDim2.fromOffset(ROBUX_ICON_SIZE.X, ROBUX_ICON_SIZE.Y),
			["ZIndex"] = resolvedZIndex + 2,
		})
		local robuxPriceTextProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(
				0,
				(BUTTON_SIZE.X - robuxRowWidth) / 2 + ROBUX_ICON_SIZE.X + ScreenConstants.PADDING_1,
				0.5,
				0
			),
			["ZIndex"] = resolvedZIndex + 2,
		}
		for key, value in robuxTextProps do
			robuxPriceTextProps[key] = value
		end
		local robuxButton = React.createElement(Button, {
			["Position"] = UDim2.fromOffset(0, CRATE_IMAGE_SIZE.Y - 50),
			["Size"] = { BUTTON_SIZE.X, BUTTON_SIZE.Y },
			["Color"] = Color.Button.Blue,
			["Disabled"] = not shopContext.CanPurchase(props.ProductId, PurchaseType.Robux),
			["Activated"] = function()
				return shopContext.Purchase(props.ProductId, PurchaseType.Robux)
			end,
		}, robuxIcon, React.createElement(Text, robuxPriceTextProps))
		local gemIcon = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (BUTTON_SIZE.X - gemRowWidth) / 2, 0.5, 0),
			["Image"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256,
			["Size"] = UDim2.fromOffset(GEM_ICON_SIZE.X, GEM_ICON_SIZE.Y),
			["ZIndex"] = resolvedZIndex + 2,
		})
		local gemPriceTextProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(
				0,
				(BUTTON_SIZE.X - gemRowWidth) / 2 + GEM_ICON_SIZE.X + ScreenConstants.PADDING_1,
				0.5,
				0
			),
			["ZIndex"] = resolvedZIndex + 2,
		}
		for key, value in gemTextProps do
			gemPriceTextProps[key] = value
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(
					ShopScreenConstants.CRATE_BUY_BUTTON_SIZE_X,
					CRATE_IMAGE_SIZE.Y + BUTTON_SIZE.Y + ScreenConstants.PADDING_1 + BUTTON_SIZE.Y - 50
				),
				["LayoutOrder"] = crateQuantity,
			},
			crateImage,
			quantityText,
			saveBadge,
			robuxButton,
			React.createElement(Button, {
				["Position"] = UDim2.fromOffset(0, CRATE_IMAGE_SIZE.Y + BUTTON_SIZE.Y + ScreenConstants.PADDING_1 - 50),
				["Size"] = { BUTTON_SIZE.X, BUTTON_SIZE.Y },
				["Color"] = Color.Button.Green,
				["Disabled"] = not shopContext.CanPurchase(props.ProductId, PurchaseType.Gems),
				["Activated"] = function()
					return shopContext.Purchase(props.ProductId, PurchaseType.Gems)
				end,
			}, gemIcon, React.createElement(Text, gemPriceTextProps))
		)
	end,
}
