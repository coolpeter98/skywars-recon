-- TextImage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local List = RuntimeLib.import(script, script.Parent, "list").List
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RoactUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "roact-util").RoactUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type TextImageProps = {
	Image: any,
	ImageSize: number?,
	Text: string?,
	TextColor: Color3?,
	SubText: string?,
	TextSize: number?,
	SubTextSize: number?,
	SubTextColor: Color3?,
	Padding: number?,
	TextLabelRef: any?,
	ZIndex: any?,
}

return {
	["TextImage"] = function(props: TextImageProps)
		local frameProps = table.clone(props)
		setmetatable(frameProps, nil)
		frameProps.Image = nil
		frameProps.ImageSize = nil
		frameProps.Text = nil
		frameProps.TextColor = nil
		frameProps.SubText = nil
		frameProps.TextSize = nil
		frameProps.SubTextSize = nil
		frameProps.SubTextColor = nil
		frameProps.Padding = nil
		frameProps.TextLabelRef = nil

		local textSize = props.TextSize
		local resolvedTextSize = textSize == nil and 24 or textSize

		local zIndexBinding = RoactUtil.getBinding(props.ZIndex)
		local zIndex = zIndexBinding == nil and 1 or zIndexBinding

		local gridProps = {
			["AutomaticSize"] = nil,
			["LayoutOrder"] = 2,
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}
		for key, value in frameProps do
			gridProps[key] = value
		end

		local imageProps = {
			["key"] = "Image",
			["Image"] = nil,
			["Image"] = props.Image,
		}
		local imageWidth = props.ImageSize
		if imageWidth == nil then
			imageWidth = resolvedTextSize
		end
		local imageHeight = props.ImageSize
		if imageHeight == nil then
			imageHeight = resolvedTextSize
		end
		imageProps.Size = UDim2.fromOffset(imageWidth, imageHeight)
		imageProps.LayoutOrder = 1
		imageProps.ZIndex = zIndex

		local imageElement = React.createElement(Image, imageProps)
		local textElement = React.createElement(Text, {
			["key"] = "Text",
			["Text"] = nil,
			["TextSize"] = nil,
			["TextColor3"] = nil,
			["LayoutOrder"] = 1,
			["Bold"] = true,
			["FixSize"] = true,
			["Ref"] = nil,
			["ZIndex"] = nil,
			["Text"] = props.Text,
			["TextSize"] = resolvedTextSize,
			["TextColor3"] = props.TextColor or Color.White,
			["Ref"] = props.TextLabelRef,
			["ZIndex"] = zIndex,
		})

		local subText = props.SubText
		local subTextElement
		if subText == "" or not subText then
			subTextElement = nil
		else
			local subTextProps = {
				["key"] = "SubText",
				["Text"] = nil,
				["TextColor3"] = nil,
				["Text"] = props.SubText,
				["TextColor3"] = props.SubTextColor or Color.LightGrey,
			}
			local subTextSize = props.SubTextSize
			subTextProps.TextSize = subTextSize == nil and 14 or subTextSize
			subTextProps.LayoutOrder = 2
			subTextProps.Bold = true
			subTextProps.FixSize = true
			subTextProps.ZIndex = zIndex
			subTextElement = React.createElement(Text, subTextProps)
		end

		local textGridElement = React.createElement(
			Grid,
			{
				["key"] = "Text",
				["AutomaticSize"] = nil,
				["LayoutOrder"] = 2,
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			textElement,
			subTextElement,
			React.createElement(List, {
				["Vertical"] = true,
				["Padding"] = nil,
				["HorizontalAlignment"] = nil,
				["Padding"] = UDim.new(0, 0),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			})
		)

		local paddingListProps = {}
		local padding = props.Padding
		local resolvedPadding = padding == nil and 10 or padding
		paddingListProps.Padding = UDim.new(0, resolvedPadding)

		return React.createElement(
			Grid,
			gridProps,
			imageElement,
			textGridElement,
			React.createElement(List, paddingListProps)
		)
	end,
}
