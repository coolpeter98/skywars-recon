-- Coins

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local List = RuntimeLib.import(script, script.Parent, "list").List
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CoinsProps = {
	Value: number,
	ImageSize: number?,
	TextSize: number?,
	Padding: number?,
}

return {
	["Coins"] = function(props: CoinsProps)
		local imageProps = {}
		local imageWidthInput = props.ImageSize
		local imageWidth = imageWidthInput == nil and 16 or imageWidthInput
		local imageHeightInput = props.ImageSize
		local imageHeight = imageHeightInput == nil and 16 or imageHeightInput
		imageProps.Size = UDim2.fromOffset(imageWidth, imageHeight)
		imageProps.Image = RobloxImage.COIN
		local imageElement = React.createElement(Image, imageProps)
		local textProps = {
			["AnchorPoint"] = Vector2.new(),
			["Text"] = ("%*"):format((StringUtil.formatNumber(props.Value))),
			["Font"] = Enum.Font.GothamBlack,
		}
		local textSizeInput = props.TextSize
		textProps.TextSize = textSizeInput == nil and 20 or textSizeInput
		textProps.FixSize = true
		local textElement = React.createElement(Text, textProps)
		local listProps = {}
		local paddingInput = props.Padding
		local padding = paddingInput == nil and 4 or paddingInput
		listProps.Padding = UDim.new(0, padding)
		return React.createElement(Grid, {
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}, imageElement, textElement, React.createElement(List, listProps))
	end,
}
