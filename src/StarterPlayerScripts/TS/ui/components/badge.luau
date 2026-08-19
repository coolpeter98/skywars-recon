-- Badge

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type BadgeProps = {
	Text: string,
	TextSize: number?,
	Transparency: number?,
	ZIndex: number?,
	TextLabelRef: any?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Color: Color3?,
	Rotation: number?,
	LayoutOrder: number?,
	children: any?,
}

return {
	["Badge"] = function(props: BadgeProps)
		local text = props.Text
		local textSize = props.TextSize
		local textBounds: Vector2 = TextService:GetTextSize(
			text,
			textSize == nil and 14 or textSize,
			Enum.Font.Gotham,
			Vector2.new(210, 20)
		) * 1.05
		local children = props.children
		local textProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(textBounds.X + 10, textBounds.Y + 10),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["Text"] = props.Text,
		}
		local textSize = props.TextSize
		textProps.TextSize = textSize == nil and 14 or textSize
		textProps.TextTransparency = props.Transparency
		textProps.Bold = true
		local zIndex = props.ZIndex
		textProps.ZIndex = (zIndex == nil and 0 or zIndex) + 2
		textProps.Ref = props.TextLabelRef
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(textBounds.X + 20, textBounds.Y + 10),
				["BackgroundColor3"] = props.Color,
				["BackgroundTransparency"] = props.Transparency,
				["Rotation"] = props.Rotation,
				["ZIndex"] = props.ZIndex,
				["LayoutOrder"] = props.LayoutOrder,
			},
			children,
			React.createElement(Text, textProps),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
