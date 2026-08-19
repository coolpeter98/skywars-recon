-- SimpleButton

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type SimpleButtonProps = {
	Text: string?,
	Activated: (() -> ())?,
	Color: Color3?,
	[string]: any,
}

return {
	["SimpleButton"] = function(props: SimpleButtonProps)
		local propsToMerge = table.clone(props)
		setmetatable(propsToMerge, nil)
		propsToMerge.Text = nil
		propsToMerge.Activated = nil
		propsToMerge.Color = nil
		local buttonProps = {
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["Font"] = nil,
			["TextColor3"] = nil,
			["RichText"] = true,
			["TextSize"] = 24,
			["BorderSizePixel"] = 0,
			["Event"] = nil,
			["Size"] = UDim2.fromOffset(160, 50),
			["BackgroundColor3"] = props.Color or Color.Black,
			["Font"] = Enum.Font.Roboto,
			["TextColor3"] = Color.White,
			["Event"] = {
				["Activated"] = props.Activated
			}
		}
		for key, value in propsToMerge do
			buttonProps[key] = value
		end
		buttonProps.Text = ("<b>%*</b>"):format(props.Text)
		return React.createElement("textbutton", buttonProps, React.createElement(CornerRadius, {
			["Radius"] = 10
		}))
	end
}
