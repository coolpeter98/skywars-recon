-- GameCurrencyItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ItemViewport = RuntimeLib.import(script, script.Parent.Parent, "viewport", "item-viewport").ItemViewport
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Currencies =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-currency").Currencies
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type GameCurrencyItemProps = {
	Quantity: number,
	CurrencyType: string,
	Size: UDim2?,
	ZIndex: number?,
	TextSize: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	BackgroundTransparency: number?,
	LayoutOrder: number?,
}

return {
	["GameCurrencyItem"] = function(props: GameCurrencyItemProps)
		local gridRef = useRef()
		local previousQuantityRef = useRef(props.Quantity)
		local function bumpItem()
			local grid = gridRef.current
			if not grid then
				return nil
			end
			local tween: Tween =
				TweenService:Create(grid, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					["Position"] = UDim2.fromOffset(0, -8),
				})
			tween:Play()
			tween.Completed:Connect(function()
				return TweenService:Create(grid, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					["Position"] = UDim2.new(),
				}):Play()
			end)
		end
		useEffect(function()
			local previousQuantity = previousQuantityRef.current
			previousQuantityRef.current = props.Quantity
			if previousQuantity < props.Quantity then
				bumpItem()
			end
		end, { props.Quantity })
		local currency = Currencies[props.CurrencyType]
		local size: UDim2 = props.Size or UDim2.fromOffset(110, 110)
		local textPadding = 0.09090909090909091 * size.Y.Offset
		local viewportProps = {
			["Frontal"] = true,
			["ItemType"] = nil,
			["Zoom"] = 1.5,
			["ItemType"] = currency.ItemType,
		}
		local zIndex = props.ZIndex
		local viewportZIndex
		if zIndex == 0 or (zIndex ~= zIndex or not zIndex) then
			viewportZIndex = nil
		else
			viewportZIndex = props.ZIndex + 1
		end
		viewportProps.ZIndex = viewportZIndex
		local gridElement = React.createElement(Grid, {
			["Size"] = UDim2.fromScale(1, 1),
			["Ref"] = gridRef,
		}, React.createElement(ItemViewport, viewportProps))
		local textProps = {
			["key"] = "Quantity",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["AnchorPoint"] = Vector2.new(1, 1),
			["Position"] = UDim2.new(1, -textPadding, 1, -textPadding),
		}
		local quantity = props.Quantity
		textProps.Text = tostring(quantity)
		local textSize = props.TextSize
		textProps.TextSize = textSize == nil and 32 or textSize
		textProps.Bold = true
		textProps.DropShadow = Vector2.new(0, 2)
		local baseZIndex = props.ZIndex
		local textZIndex
		if baseZIndex == 0 or (baseZIndex ~= baseZIndex or not baseZIndex) then
			textZIndex = nil
		else
			textZIndex = props.ZIndex + 2
		end
		textProps.ZIndex = textZIndex
		return React.createElement(
			Grid,
			{
				["key"] = currency.ItemType,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = size,
				["BackgroundTransparency"] = props.BackgroundTransparency,
				["LayoutOrder"] = props.LayoutOrder,
				["ZIndex"] = props.ZIndex,
			},
			gridElement,
			React.createElement(Text, textProps),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
