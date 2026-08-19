-- LobbyButton

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type LobbyButtonProps = {
	Enabled: boolean,
	Color: Color3,
	Text: string,
	Activated: () -> (),
}

return {
	["LobbyButton"] = function(props: LobbyButtonProps)
		local createElement = React.createElement
		local elementType = "textbutton"
		local buttonProps = {
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["AutoButtonColor"] = nil,
			["Font"] = nil,
			["Text"] = nil,
			["TextColor3"] = nil,
			["RichText"] = true,
			["TextSize"] = 48,
			["BorderSizePixel"] = 0,
			["Event"] = nil,
			["Size"] = UDim2.fromOffset(220, 80),
		}
		local backgroundColor: Color3
		if props.Enabled then
			backgroundColor = props.Color
		else
			backgroundColor = Color.Grey
		end
		buttonProps.BackgroundColor3 = backgroundColor
		buttonProps.AutoButtonColor = props.Enabled
		buttonProps.Font = Enum.Font.Roboto
		buttonProps.Text = ("<b>%*</b>"):format(props.Text)
		buttonProps.TextColor3 = Color.White
		buttonProps.Event = {
			["Activated"] = function()
				if props.Enabled then
					props.Activated()
				end
			end,
		}
		return createElement(
			elementType,
			buttonProps,
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
