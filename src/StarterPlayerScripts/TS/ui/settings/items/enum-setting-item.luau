-- EnumSettingItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

return {
	["EnumSettingItem"] = function(props)
		local enumEntries = ObjectUtils.entries(props.Setting.Enum)
		local currentIndex = -1
		for i, entry in enumEntries do
			local _ = i - 1
			if entry[2] == props.Setting.GetCurrentValue() == true then
				currentIndex = i - 1
				break
			end
		end
		local selectedIndex, setSelectedIndex = useState(currentIndex)
		local createElement = React.createElement
		local buttonProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Color"] = nil,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -20, 0.5, 0),
			["Size"] = { 150, 50 },
		}
		local enumName = enumEntries[selectedIndex + 1][1]
		buttonProps.Text = ("%*"):format((tostring(enumName)))
		buttonProps.Color = Color.Button.Green
		function buttonProps.Activated()
			local nextIndex = selectedIndex + 1 >= #enumEntries and 0 or selectedIndex + 1
			local nextValue = enumEntries[nextIndex + 1][2]
			setSelectedIndex(nextIndex)
			props.Setting.OnChange(nextValue)
		end
		return createElement(Button, buttonProps)
	end,
}
