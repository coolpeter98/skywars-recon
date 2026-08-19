-- BooleanSettingItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type Setting = {
	GetCurrentValue: () -> boolean,
	OnChange: (value: boolean) -> (),
	TrueText: string?,
	FalseText: string?,
}

type Props = {
	Setting: Setting,
}

return {
	["BooleanSettingItem"] = function(props: Props)
		local value, setValue = useState(props.Setting.GetCurrentValue())
		local buttonProps = {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -20, 0.5, 0),
			["Size"] = { 150, 50 },
		}
		local text: string
		if value then
			local trueText = props.Setting.TrueText
			text = trueText == nil and "On" or trueText
		else
			local falseText = props.Setting.FalseText
			text = falseText == nil and "Off" or falseText
		end
		buttonProps.Text = ("%*"):format(text)
		buttonProps.TextSize = 24
		buttonProps.Color = Color.Button.Green
		function buttonProps.Activated()
			local newValue = not value
			setValue(newValue)
			props.Setting.OnChange(newValue)
		end
		return React.createElement(Button, buttonProps)
	end,
}
