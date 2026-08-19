-- Card

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CardProps = {
	Padding: number?,
	Image: string?,
	Text: string?,
	TextSize: number?,
	ImageColor: Color3?,
	CornerRadius: UDim?,
	children: { any }?,
	[string]: any,
}

return {
	["Card"] = function(props: CardProps)
		local paddingProp = props.Padding
		local paddingValue = paddingProp == nil and 12.5 or paddingProp
		local padding = UDim.new(0, paddingValue)
		local frameProps = table.clone(props)
		setmetatable(frameProps, nil)
		frameProps.Image = nil
		frameProps.Text = nil
		frameProps.TextSize = nil
		frameProps.ImageColor = nil
		frameProps.CornerRadius = nil
		frameProps.Padding = nil
		frameProps.children = nil
		local frameDefaults = {
			["AutomaticSize"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}
		for key, value in frameProps do
			frameDefaults[key] = value
		end
		local children = props.children
		local image = props.Image
		local imageElement
		if image == "" or not image then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["LayoutOrder"] = 1,
				["Size"] = UDim2.fromOffset(25, 25),
				["Image"] = props.Image,
				["ImageColor3"] = props.ImageColor,
			})
		end
		local text = props.Text
		local createElement = React.createElement
		local grid = Grid
		local textElement
		if text == "" or not text then
			textElement = nil
		else
			textElement = React.createElement(Text, {
				["Text"] = nil,
				["TextSize"] = nil,
				["Bold"] = true,
				["FixSize"] = true,
				["LayoutOrder"] = 2,
				["Text"] = props.Text,
				["TextSize"] = props.TextSize,
			})
		end
		local listLayoutElement = React.createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Horizontal,
			["SortOrder"] = Enum.SortOrder.LayoutOrder,
			["Padding"] = padding,
			["VerticalAlignment"] = Enum.VerticalAlignment.Center,
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
		})
		local paddingElement = React.createElement("uipadding", {
			["PaddingTop"] = padding,
			["PaddingBottom"] = padding,
			["PaddingLeft"] = padding,
			["PaddingRight"] = padding,
		})
		local cornerElement
		if props.CornerRadius then
			cornerElement = React.createElement("uicorner", {
				["CornerRadius"] = props.CornerRadius,
			})
		else
			cornerElement = React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		end
		return createElement(
			grid,
			frameDefaults,
			children,
			imageElement,
			textElement,
			listLayoutElement,
			paddingElement,
			cornerElement
		)
	end,
}
