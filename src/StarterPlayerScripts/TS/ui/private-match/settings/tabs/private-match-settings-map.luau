-- PrivateMatchSettingsMap

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type Props = {
	Map: {
		Image: string,
		DisplayName: string,
	},
	Selected: boolean,
	SelectMap: () -> (),
}

return {
	["PrivateMatchSettingsMap"] = function(props: Props)
		local createElement = React.createElement
		local imageButtonType = "imagebutton"
		local imageButtonProps = {
			["Size"] = nil,
			["Image"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["ZIndex"] = 1,
			["Event"] = nil,
			["Size"] = UDim2.fromOffset(210, 265),
			["Image"] = props.Map.Image,
			["Event"] = {
				["Activated"] = function()
					props.SelectMap()
				end
			}
		}
		local mapLabel = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["ZIndex"] = 3,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.new(0, 10, 1, -10),
			["Text"] = props.Map.DisplayName
		})
		local selectedOverlay
		if props.Selected then
			selectedOverlay = React.createElement(Grid, {
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["ZIndex"] = 2,
				["Size"] = UDim2.fromScale(1, 1),
				["BackgroundColor3"] = Color.Green
			}, React.createElement("uigradient", {
				["Rotation"] = 270,
				["Transparency"] = nil,
				["Transparency"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.5, 1, 0), NumberSequenceKeypoint.new(1, 1, 0) })
			}), React.createElement(CornerRadius, {
				["Radius"] = 10
			}))
		else
			selectedOverlay = nil
		end
		return createElement(imageButtonType, imageButtonProps, mapLabel, selectedOverlay, React.createElement(CornerRadius, {
			["Radius"] = 10
		}))
	end
}
