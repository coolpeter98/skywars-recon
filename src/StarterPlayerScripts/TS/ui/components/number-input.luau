-- NumberInput

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local TextInput = RuntimeLib.import(script, script.Parent, "text-input").TextInput
local NumberInputButton = RuntimeLib.import(script, script.Parent, "number-input-button").NumberInputButton
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

type NumberInputProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	DefaultValue: number?,
	MinValue: number?,
	MaxValue: number?,
	ValueChanged: ((value: number) -> ())?,
}

return {
	["NumberInput"] = function(props: NumberInputProps)
		local inputRef = useRef()
		local defaultValue = props.DefaultValue
		local value, setValue = useState(defaultValue == nil and 1 or defaultValue)
		local function setDisplayText(value: number)
			local input = inputRef.current
			if input then
				input.Text = tostring(value)
			end
		end
		useEffect(function()
			if props.MinValue == nil or value >= props.MinValue then
				if props.MaxValue == nil or value <= props.MaxValue then
					if props.ValueChanged then
						props.ValueChanged(value)
					end
				else
					setValue(props.MaxValue)
				end
			else
				setValue(props.MinValue)
			end
			local currentValue = value
			local input = inputRef.current
			if input then
				input.Text = tostring(currentValue)
			end
		end, { value })
		useEffect(function()
			local input = inputRef.current
			if not input then
				return nil
			end
			local connection = input:GetPropertyChangedSignal("Text"):Connect(function()
				local digits = string.gsub(input.Text, "%D+", "")
				local parsed = tonumber(digits)
				if parsed == nil or parsed == value then
					input.Text = digits
				else
					setValue(parsed)
				end
			end)
			return function()
				return connection:Disconnect()
			end
		end, { value })
		local createElement = React.createElement
		local Grid = Grid
		local textInputBackgroundProps = {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(180, 100),
		}
		local textInputElement = React.createElement(
			Grid,
			{
				["key"] = "TextInputBackground",
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = 0.6,
				["CornerRadius"] = nil,
				["Size"] = UDim2.fromOffset(130, 100),
				["BackgroundColor3"] = Color.White,
				["CornerRadius"] = {
					["TopLeft"] = 10,
					["BottomLeft"] = 10,
				},
			},
			React.createElement(TextInput, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 1,
				["Text"] = nil,
				["TextColor3"] = nil,
				["TextSize"] = 40,
				["TextXAlignment"] = nil,
				["TextYAlignment"] = nil,
				["Ref"] = nil,
				["Value"] = "",
				["SetValue"] = nil,
				["FocusLost"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(120, 100),
				["Text"] = tostring(value),
				["TextColor3"] = Color.White,
				["TextXAlignment"] = Enum.TextXAlignment.Center,
				["TextYAlignment"] = Enum.TextYAlignment.Center,
				["Ref"] = inputRef,
				["SetValue"] = function() end,
				["FocusLost"] = function()
					return setDisplayText(value)
				end,
			})
		)
		local createElement = React.createElement
		local Grid = Grid
		local buttonsProps = {
			["key"] = "Buttons",
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["Position"] = UDim2.fromOffset(130, 0),
			["Size"] = UDim2.fromOffset(50, 100),
		}
		local createElement = React.createElement
		local NumberInputButton = NumberInputButton
		local incrementProps = {
			["key"] = "Increment",
			["Color"] = nil,
			["CornerRadius"] = nil,
			["ImageRotation"] = 180,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Color"] = Color.Green,
			["CornerRadius"] = {
				["TopRight"] = 10,
			},
		}
		local incrementDisabled
		if props.MaxValue == nil then
			incrementDisabled = false
		else
			incrementDisabled = props.MaxValue <= value
		end
		incrementProps.Disabled = incrementDisabled
		function incrementProps.Activated()
			return setValue(function(currentValue)
				return currentValue + 1
			end)
		end
		local incrementButton = createElement(NumberInputButton, incrementProps)
		local createElement = React.createElement
		local NumberInputButton = NumberInputButton
		local decrementProps = {
			["key"] = "Decrement",
			["Position"] = nil,
			["Color"] = nil,
			["CornerRadius"] = nil,
			["ImageRotation"] = 0,
			["Disabled"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(0, 50),
			["Color"] = Color.Red,
			["CornerRadius"] = {
				["BottomRight"] = 10,
			},
		}
		local decrementDisabled
		if props.MinValue == nil then
			decrementDisabled = false
		else
			decrementDisabled = value <= props.MinValue
		end
		decrementProps.Disabled = decrementDisabled
		function decrementProps.Activated()
			return setValue(function(currentValue)
				return currentValue - 1
			end)
		end
		return createElement(
			Grid,
			textInputBackgroundProps,
			textInputElement,
			createElement(Grid, buttonsProps, incrementButton, createElement(NumberInputButton, decrementProps))
		)
	end,
}
