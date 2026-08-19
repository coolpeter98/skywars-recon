-- Key

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Outline = RuntimeLib.import(script, script.Parent, "outline").Outline
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type KeyProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Text: string?,
}

return {
	["Key"] = function(props: KeyProps)
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(24, 24),
			["BackgroundColor3"] = Color3.fromRGB(215, 215, 215)
		}, React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(4, 4),
			["Size"] = UDim2.fromOffset(16, 15),
			["BackgroundColor3"] = Color3.fromRGB(245, 245, 245)
		}, React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 14,
			["TextColor3"] = nil,
			["TextTransparency"] = 0.6,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0),
			["Text"] = props.Text,
			["TextColor3"] = Color.Black
		}), React.createElement(CornerRadius, {
			["Radius"] = 2
		}), React.createElement(Outline, {
			["Thickness"] = 2,
			["Color"] = nil,
			["Transparency"] = 0.6,
			["Color"] = Color.White
		})), React.createElement(CornerRadius, {
			["Radius"] = 2
		}), React.createElement(Outline, {
			["Thickness"] = 2,
			["Color"] = nil,
			["Transparency"] = 0.6,
			["Color"] = Color.Black
		}))
	end
}
