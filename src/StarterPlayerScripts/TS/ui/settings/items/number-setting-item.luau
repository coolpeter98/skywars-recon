-- NumberSettingItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState

local NumberSlider = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "number-slider").NumberSlider

type Setting = {
	GetCurrentValue: () -> number,
	Min: number,
	Max: number,
	OnChange: (value: number) -> (),
}

type Props = {
	Setting: Setting,
}

local function NumberSettingItem(props: Props)
	local value, setValue = useState(props.Setting.GetCurrentValue())

	return React.createElement(NumberSlider, {
		["AnchorPoint"] = Vector2.new(1, 0.5),
		["Position"] = UDim2.new(1, -20, 0.5, 0),
		["Size"] = UDim2.fromOffset(330, 14),
		["Value"] = value,
		["SetValue"] = function(newValue: number)
			setValue(newValue)
			props.Setting.OnChange(newValue)
		end,
		["Min"] = props.Setting.Min,
		["Max"] = props.Setting.Max,
		["Released"] = props.Setting.OnChange,
	})
end

return {
	["NumberSettingItem"] = NumberSettingItem,
}
