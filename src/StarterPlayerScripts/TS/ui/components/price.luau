-- Price

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ROBUX_ICON_SIZE = Vector2.new(24, 24)
local GEM_ICON_SIZE = Vector2.new(28, 24)

type PriceProps = {
	PriceInRobux: number?,
	PriceInGems: number?,
	AnchorPoint: Vector2,
	Position: UDim2,
	ZIndex: number?,
	Price: unknown?,
}

return {
	["Price"] = function(props: PriceProps)
		local robuxText
		if props.PriceInRobux == nil then
			robuxText = nil
		else
			robuxText = getTextProps({
				["Text"] = nil,
				["TextSize"] = 24,
				["Bold"] = true,
				["Text"] = StringUtil.formatNumber(props.PriceInRobux),
			})
		end

		local gemsText
		if props.PriceInGems == nil then
			gemsText = nil
		else
			gemsText = getTextProps({
				["Text"] = nil,
				["TextSize"] = 24,
				["Bold"] = true,
				["Text"] = StringUtil.formatNumber(props.PriceInGems),
			})
		end

		local orText = getTextProps({
			["Text"] = "OR",
			["TextSize"] = 12,
			["Bold"] = true,
		})

		local robuxWidth = robuxText == nil and 0 or ROBUX_ICON_SIZE.X + 4 + robuxText.Size.X.Offset
		local gemsWidth = gemsText == nil and 0 or GEM_ICON_SIZE.X + 4 + gemsText.Size.X.Offset
		local orWidth = (props.PriceInRobux == nil or props.PriceInGems == nil) and 0 or 20 + orText.Size.X.Offset
		local gemsX = not (robuxText and gemsText) and 0 or robuxWidth + orWidth
		local zIndex = props.ZIndex
		local resolvedZIndex = zIndex == nil and 1 or zIndex
		local gridProps = table.clone(props)
		setmetatable(gridProps, nil)
		gridProps.Price = nil

		local robuxElement
		if robuxText then
			local robuxIcon = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Image"] = RobloxImage.Icon.ROBUX,
				["Size"] = UDim2.fromOffset(ROBUX_ICON_SIZE.X, ROBUX_ICON_SIZE.Y),
				["ZIndex"] = resolvedZIndex,
			})
			local robuxTextProps = {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, ROBUX_ICON_SIZE.X + 4, 0.5, 0),
				["ZIndex"] = resolvedZIndex,
			}
			for key, value in robuxText do
				robuxTextProps[key] = value
			end
			robuxElement =
				React.createElement(React.Fragment, nil, robuxIcon, React.createElement(Text, robuxTextProps))
		else
			robuxElement = nil
		end

		local orElement
		if robuxText and gemsText then
			local orTextProps = {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, robuxWidth + 10, 0.5, 0),
				["ZIndex"] = resolvedZIndex,
			}
			for key, value in orText do
				orTextProps[key] = value
			end
			orElement = React.createElement(Text, orTextProps)
		else
			orElement = nil
		end

		local gemsElement
		if gemsText then
			local gemIcon = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, gemsX, 0.5, 0),
				["Image"] = RobloxImage.Icon.GEM_GREEN_256,
				["Size"] = UDim2.fromOffset(GEM_ICON_SIZE.X, GEM_ICON_SIZE.Y),
				["ZIndex"] = resolvedZIndex,
			})
			local gemsTextProps = {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, gemsX + GEM_ICON_SIZE.X + 4, 0.5, 0),
				["ZIndex"] = resolvedZIndex,
			}
			for key, value in gemsText do
				gemsTextProps[key] = value
			end
			gemsElement = React.createElement(React.Fragment, nil, gemIcon, React.createElement(Text, gemsTextProps))
		else
			gemsElement = nil
		end

		return React.createElement(Grid, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(robuxWidth + gemsWidth + orWidth, 24),
		}, robuxElement, orElement, gemsElement)
	end,
}
