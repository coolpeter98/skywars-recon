-- CosmeticsShopSidebarList

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local GradientCard = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "gradient-card").GradientCard
local Size = RuntimeLib.import(script, script.Parent.Parent.Parent, "size").Size
local CosmeticViewport =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "viewport", "cosmetic-viewport").CosmeticViewport
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local function truncateText(text: string, maxWidth: number): string
	local textProps = getTextProps({
		["Text"] = nil,
		["TextSize"] = 16,
		["Bold"] = true,
		["Text"] = text,
	})
	local truncated = false
	while maxWidth < textProps.Size.X.Offset do
		local newLength = #text - 1
		text = string.sub(text, 0, newLength)
		textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 16,
			["Bold"] = true,
			["Text"] = ("%*..."):format(text),
		})
		truncated = true
	end
	if truncated then
		return ("%*..."):format(text)
	else
		return text
	end
end

export type CosmeticEntry = {
	CosmeticId: string,
	LayoutOrder: number?,
	SubText: string?,
}

export type Props = {
	Cosmetics: { CosmeticEntry },
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

return {
	["CosmeticsShopSidebarList"] = function(props: Props)
		local cosmetics = props.Cosmetics
		local items = table.create(#cosmetics)
		local function renderItem(item: CosmeticEntry)
			local cosmetic = Cosmetics[item.CosmeticId]
			local textSize = Vector2.new(290, 20)
			local title = truncateText(cosmetic.Name, textSize.X)
			local rarity = CosmeticRarities[cosmetic.Rarity]
			local gridItem = {
				["key"] = item.CosmeticId,
				["Size"] = UDim2.fromOffset(374, 64),
			}
			local layoutOrder = item.LayoutOrder
			if layoutOrder == nil then
				layoutOrder = -rarity.Rarity
			end
			gridItem.LayoutOrder = layoutOrder
			local card = React.createElement(
				GradientCard,
				{
					["Size"] = nil,
					["Color"] = nil,
					["FooterHeight"] = 0,
					["StrokeThickness"] = 2,
					["ScalingDisabled"] = true,
					["CornerRadius"] = 4,
					["FooterComponent"] = nil,
					["Size"] = Size.new(64, 64),
					["Color"] = rarity.Color,
					["FooterComponent"] = React.createElement(React.Fragment),
				},
				React.createElement(CosmeticViewport, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["CosmeticId"] = nil,
					["ZIndex"] = 2,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromScale(1, 1),
					["CosmeticId"] = cosmetic.Id,
				})
			)
			local titleProps = {}
			local subText = item.SubText
			titleProps.AnchorPoint = Vector2.new(0, (subText == "" or not subText) and 0.5 or 0)
			local subTextValue = item.SubText
			local titleYScale = (subTextValue == "" or not subTextValue) and 0.5 or 0
			local subTextOffset = item.SubText
			titleProps.Position = UDim2.new(0, 74, titleYScale, (subTextOffset == "" or not subTextOffset) and 0 or 10)
			titleProps.Size = UDim2.fromOffset(textSize.X, textSize.Y)
			titleProps.Text = title
			titleProps.TextSize = 20
			titleProps.Bold = true
			titleProps.TextXAlignment = Enum.TextXAlignment.Left
			local titleElement = React.createElement(Text, titleProps)
			local subTextContent = item.SubText
			local createElement = React.createElement
			local grid = Grid
			local subTextElement
			if subTextContent == "" or not subTextContent then
				subTextElement = nil
			else
				subTextElement = React.createElement(Text, {
					["Position"] = nil,
					["Text"] = nil,
					["TextSize"] = 20,
					["TextTransparency"] = 0.2,
					["Bold"] = true,
					["Size"] = nil,
					["TextXAlignment"] = nil,
					["Position"] = UDim2.fromOffset(74, 30),
					["Text"] = item.SubText,
					["Size"] = UDim2.fromOffset(textSize.X, textSize.Y),
					["TextXAlignment"] = Enum.TextXAlignment.Left,
				})
			end
			return createElement(grid, gridItem, card, titleElement, subTextElement)
		end
		for index, item in cosmetics do
			items[index] = renderItem(item, index - 1, cosmetics)
		end
		return React.createElement(
			"scrollingframe",
			{
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["CanvasSize"] = nil,
				["ScrollingDirection"] = nil,
				["ScrollBarThickness"] = 10,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Selectable"] = false,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = props.Size or UDim2.fromOffset(374, 300),
				["CanvasSize"] = UDim2.fromOffset(0, ScreenUtil.getGridSize(64, 10, #props.Cosmetics)),
				["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			},
			items,
			React.createElement(List, {
				["Vertical"] = true,
				["VerticalAlignment"] = nil,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			})
		)
	end,
}
