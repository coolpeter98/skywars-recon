-- TextInput

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

export type TextInputProps = {
	Value: string,
	SetValue: (value: string) -> (),
	OnChange: ((text: string) -> string?)?,
	FocusLost: (() -> ())?,
	Ref: { current: TextBox? }?,
}

local function TextInput(props: TextInputProps)
	local textBoxRef = useRef()
	local restProps = table.clone(props)
	setmetatable(restProps, nil)
	restProps.Value = nil
	restProps.SetValue = nil
	restProps.OnChange = nil
	restProps.FocusLost = nil
	restProps.Ref = nil
	useEffect(function()
		local textBox = textBoxRef.current
		if not textBox then
			return nil
		end
		local value = props.Value
		textBox.Text = value
		local textConnection = textBox:GetPropertyChangedSignal("Text"):Connect(function()
			local result
			if props.OnChange then
				result = props.OnChange(textBox.Text)
			else
				result = textBox.Text
			end
			if result == nil then
				textBox.Text = value
				return nil
			end
			if result == value then
				return nil
			end
			props.SetValue(result)
			value = result
			textBox.Text = result
		end)
		return function()
			return textConnection:Disconnect()
		end
	end, { textBoxRef.current })
	local textBoxProps = {
		["Text"] = "",
		["PlaceholderColor3"] = nil,
		["Font"] = nil,
		["TextColor3"] = nil,
		["TextSize"] = 24,
		["ClearTextOnFocus"] = false,
		["TextXAlignment"] = nil,
		["BackgroundColor3"] = nil,
		["BorderSizePixel"] = 0,
		["ref"] = nil,
		["Event"] = nil,
		["PlaceholderColor3"] = Color.PlaceholderGrey,
		["Font"] = Enum.Font.GothamBlack,
		["TextColor3"] = Color.Black,
		["TextXAlignment"] = Enum.TextXAlignment.Left,
		["BackgroundColor3"] = Color.White,
		["ref"] = props.Ref or textBoxRef,
		["Event"] = {
			["FocusLost"] = props.FocusLost,
		},
	}
	for key, value in restProps do
		textBoxProps[key] = value
	end
	return React.createElement(
		"textbox",
		textBoxProps,
		React.createElement("uipadding", {
			["PaddingLeft"] = UDim.new(0, 20),
		}),
		React.createElement(CornerRadius, {
			["Radius"] = 10,
		})
	)
end

return {
	["TextInput"] = TextInput,
}
