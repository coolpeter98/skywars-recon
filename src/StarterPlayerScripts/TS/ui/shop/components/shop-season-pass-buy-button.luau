-- ShopSeasonPassBuyButton

type Props = {
	ProductId: string,
	PrimedCosmeticId: string?,
	Size: UDim2?,
	TextSize: number?,
	TextPadding: number?,
	ZIndex: number?,
	CornerRadius: number?,
	CornerRadiusTopCorner: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
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
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local GameProduct =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProduct.GameProducts
local PurchaseType = GameProduct.PurchaseType
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService

return {
	["ShopSeasonPassBuyButton"] = function(props: Props)
		local shopContext = useContext(NewShopContext)
		local gameProduct
		if RunService:IsRunning() then
			gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		else
			gameProduct = GameProducts[props.ProductId]
		end
		local sizeX = props.Size
		if sizeX ~= nil then
			sizeX = sizeX.X.Offset
		end
		local width = sizeX == nil and 250 or sizeX
		local sizeY = props.Size
		if sizeY ~= nil then
			sizeY = sizeY.Y.Offset
		end
		local height = sizeY == nil and 50 or sizeY
		local textSizeValue = props.TextSize
		local textSize = textSizeValue == nil and 24 or textSizeValue
		local textPaddingValue = props.TextPadding
		local textPadding = textPaddingValue == nil and 4 or textPaddingValue
		local robuxTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(gameProduct.PriceInRobux),
			["TextSize"] = textSize,
		})
		local gemTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(gameProduct.PriceInGems),
			["TextSize"] = textSize,
		})
		local robuxRowWidth = textSize + textPadding + robuxTextProps.Size.X.Offset
		local gemRowWidth = textSize + textPadding + gemTextProps.Size.X.Offset
		local zIndexValue = props.ZIndex
		local zIndex = zIndexValue == nil and 1 or zIndexValue
		local cornerRadiusValue = props.CornerRadius
		local cornerRadius = cornerRadiusValue == nil and 10 or cornerRadiusValue
		local topCornerRadius = props.CornerRadiusTopCorner ~= false and 0 or cornerRadius
		local leftHalfWidth = width / 2
		local leftWidth = math.floor(leftHalfWidth)
		local rightHalfWidth = width / 2
		local rightWidth = math.ceil(rightHalfWidth)
		local robuxIcon = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (leftWidth - robuxRowWidth) / 2, 0.5, topCornerRadius / 2),
			["Image"] = RobloxImage.Icon.ROBUX,
			["Size"] = UDim2.fromOffset(textSize, textSize),
			["ZIndex"] = zIndex + 2,
		})
		local robuxPriceTextProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(
				0,
				(leftWidth - robuxRowWidth) / 2 + textSize + textPadding,
				0.5,
				topCornerRadius / 2
			),
			["ZIndex"] = zIndex + 2,
		}
		for key, value in robuxTextProps do
			robuxPriceTextProps[key] = value
		end
		local robuxButton = React.createElement(
			Grid,
			{
				["key"] = "RobuxClipping",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Size"] = UDim2.fromOffset(leftWidth, height),
			},
			React.createElement(Button, {
				["Size"] = { leftWidth + cornerRadius, height + topCornerRadius },
				["Position"] = UDim2.fromOffset(0, -topCornerRadius),
				["Color"] = Color.Button.Blue,
				["CornerRadius"] = cornerRadius,
				["Disabled"] = not shopContext.CanPurchase(props.ProductId, PurchaseType.Robux, props.PrimedCosmeticId),
				["Activated"] = function()
					return shopContext.Purchase(props.ProductId, PurchaseType.Robux, props.PrimedCosmeticId)
				end,
			}, robuxIcon, React.createElement(Text, robuxPriceTextProps))
		)
		local gemIcon = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 10 + (rightWidth - gemRowWidth) / 2, 0.5, topCornerRadius / 2),
			["Image"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256,
			["Size"] = UDim2.fromOffset(textSize, textSize),
			["ZIndex"] = zIndex + 2,
		})
		local gemPriceTextProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(
				0,
				10 + (rightWidth - gemRowWidth) / 2 + textSize + textPadding,
				0.5,
				topCornerRadius / 2
			),
			["ZIndex"] = zIndex + 2,
		}
		for key, value in gemTextProps do
			gemPriceTextProps[key] = value
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(width, height),
				["ZIndex"] = zIndex,
			},
			robuxButton,
			React.createElement(
				Grid,
				{
					["key"] = "GemsClipping",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ClipsDescendants"] = true,
					["AnchorPoint"] = Vector2.new(1, 0),
					["Position"] = UDim2.fromScale(1, 0),
					["Size"] = UDim2.fromOffset(rightWidth, height),
				},
				React.createElement(Button, {
					["Size"] = { rightWidth + 10, height + topCornerRadius },
					["Position"] = UDim2.fromOffset(-10, -topCornerRadius),
					["Color"] = Color.Button.Green,
					["CornerRadius"] = cornerRadius,
					["Disabled"] = not shopContext.CanPurchase(
						props.ProductId,
						PurchaseType.Gems,
						props.PrimedCosmeticId
					),
					["Activated"] = function()
						return shopContext.Purchase(props.ProductId, PurchaseType.Gems, props.PrimedCosmeticId)
					end,
				}, gemIcon, React.createElement(Text, gemPriceTextProps))
			)
		)
	end,
}
