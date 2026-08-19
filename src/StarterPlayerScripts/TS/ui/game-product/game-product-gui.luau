-- GameProductGui

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
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local PurchaseType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").PurchaseType
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Robux = RuntimeLib.import(script, script.Parent.Parent, "components", "robux").Robux
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local useState = React.useState
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen
local getAdvertTimeColor =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "lobby", "adverts").getAdvertTimeColor

type OwnedProduct = {
	Type: number,
}

type GameProductGuiProps = {
	ProductId: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["GameProductGui"] = function(props: GameProductGuiProps)
		local screenController: { Close: () -> () } = useScreen()
		local profile: { OwnedProducts: { OwnedProduct } } = useProfile()
		useRef()
		local gameProduct = Flamework.resolveDependency("1EA"):getGameProduct(props.ProductId)
		local seed = useState(math.random() * os.clock())
		local bundle = gameProduct.Bundle or {}
		local canvasWidth = #bundle * 224 + (#bundle - 1) * 20
		local buttonProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Buy",
			["TextSize"] = 48,
			["Icon"] = nil,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.new(0, 20, 1, -20),
			["Size"] = { 250, 100 },
			["Icon"] = RobloxImage.Icon.PLAY,
		}
		local ownedProduct = nil
		for index, product in profile.OwnedProducts do
			local _ = index - 1
			if product.Type == props.ProductId == true then
				ownedProduct = product
				break
			end
		end
		buttonProps.Disabled = ownedProduct ~= nil
		function buttonProps.Activated()
			screenController.Close()
			Flamework.resolveDependency("YOK"):promptPurchase(props.ProductId, PurchaseType.Robux)
		end
		buttonProps.Color = Color.Button.Green
		local gamepassInfo = React.createElement(
			Grid,
			{
				["key"] = "GamepassInfo",
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["Position"] = UDim2.fromOffset(20, 64),
				["Size"] = UDim2.fromOffset(1200, 356),
			},
			React.createElement(Button, buttonProps),
			React.createElement(Robux, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Price"] = 399,
				["TextSize"] = 32,
				["SubTextSize"] = 14,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 290, 1, -72.5),
			}),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local cosmeticSlots = table.create(#bundle)
		for index, cosmeticId in bundle do
			local layoutOrder = index - 1
			cosmeticSlots[index] = React.createElement(CosmeticSlot, {
				["key"] = cosmeticId,
				["Size"] = Size.new(224, 224),
				["CosmeticId"] = cosmeticId,
				["Seed"] = seed,
				["LayoutOrder"] = layoutOrder,
			})
		end
		return React.createElement(
			Window,
			{
				["key"] = "Gamepass",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["TitleText"] = "GAMEPASS",
				["TitleImage"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(1240, 710),
				["TitleImage"] = RobloxImage.Icon.SHOPPING_CART,
			},
			gamepassInfo,
			React.createElement(
				"scrollingframe",
				{
					["key"] = "RewardList",
					["Position"] = nil,
					["Size"] = nil,
					["CanvasSize"] = nil,
					["ScrollingDirection"] = nil,
					["ScrollBarThickness"] = 6,
					["ScrollBarImageColor3"] = nil,
					["BackgroundTransparency"] = 1,
					["BorderSizePixel"] = 0,
					["Selectable"] = false,
					["Position"] = UDim2.fromOffset(20, 440),
					["Size"] = UDim2.fromOffset(1200, 250),
					["CanvasSize"] = UDim2.fromOffset(canvasWidth, 250),
					["ScrollingDirection"] = Enum.ScrollingDirection.X,
					["ScrollBarImageColor3"] = Color.White,
				},
				cosmeticSlots,
				React.createElement(List, {
					["Padding"] = UDim.new(0, 20),
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
					["VerticalAlignment"] = Enum.VerticalAlignment.Top,
				})
			)
		)
	end,
}
