-- ShopBundleBuyButton

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
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local GameProductModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product")
local GameProducts = GameProductModule.GameProducts
local PurchaseType = GameProductModule.PurchaseType
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext

type ShopBundleBuyButtonProps = {
	ProductId: string,
	PurchaseType: string,
	PrimedCosmeticId: string?,
	Size: UDim2?,
	TextSize: number?,
	TextPadding: number?,
	ZIndex: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Color: Color3?,
}

return {
	["ShopBundleBuyButton"] = function(props: ShopBundleBuyButtonProps)
		local shopController = useContext(NewShopContext)
		local gameProduct
		if RunService:IsRunning() then
			gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		else
			gameProduct = GameProducts[props.ProductId]
		end
		local price
		if props.PurchaseType == PurchaseType.Robux then
			price = gameProduct.PriceInRobux
		else
			price = gameProduct.PriceInGems
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
		local textSize = props.TextSize
		local resolvedTextSize = textSize == nil and 24 or textSize
		local textPadding = props.TextPadding
		local resolvedTextPadding = textPadding == nil and 10 or textPadding
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = nil,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(price),
			["TextSize"] = resolvedTextSize,
		})
		local textWidth = resolvedTextSize + resolvedTextPadding + textProps.Size.X.Offset
		local zIndex = props.ZIndex
		local resolvedZIndex = zIndex == nil and 1 or zIndex
		local createElement = React.createElement
		local imageComponent = Image
		local iconProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (width - textWidth) / 2, 0.5, 0),
		}
		local icon
		if props.PurchaseType == PurchaseType.Robux then
			icon = RobloxImage.Icon.ROBUX
		else
			icon = RobloxImage.Icon.GEM_GREEN_OUTLINE_256
		end
		iconProps.Image = icon
		iconProps.Size = UDim2.fromOffset(resolvedTextSize, resolvedTextSize)
		iconProps.ZIndex = resolvedZIndex + 2
		local iconElement = createElement(imageComponent, iconProps)
		local textElementProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, (width - textWidth) / 2 + resolvedTextSize + resolvedTextPadding, 0.5, 0),
			["ZIndex"] = resolvedZIndex + 2,
		}
		for key, value in textProps do
			textElementProps[key] = value
		end
		return React.createElement(Button, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = { width, height },
			["Color"] = props.Color or Color.Button.Blue,
			["Disabled"] = not shopController.CanPurchase(props.ProductId, props.PurchaseType, props.PrimedCosmeticId),
			["Activated"] = function()
				return shopController.Purchase(props.ProductId, props.PurchaseType, props.PrimedCosmeticId)
			end,
		}, iconElement, React.createElement(Text, textElementProps))
	end,
}
