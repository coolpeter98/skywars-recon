-- SettingsItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local SettingsModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "settings", "settings")
local Settings = SettingsModule.Settings
local SettingType = SettingsModule.SettingType
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local NumberSettingItem = RuntimeLib.import(script, script.Parent, "items", "number-setting-item").NumberSettingItem
local EnumSettingItem = RuntimeLib.import(script, script.Parent, "items", "enum-setting-item").EnumSettingItem
local BooleanSettingItem = RuntimeLib.import(script, script.Parent, "items", "boolean-setting-item").BooleanSettingItem

return {
	["SettingsItem"] = function(props: { SettingId: string })
		local setting = Settings[props.SettingId]
		local createElement = React.createElement
		local gridProps = {
			["key"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["key"] = props.SettingId,
			["Size"] = UDim2.fromOffset(720, 60),
		}
		local title = createElement(Text, {
			["key"] = "Title",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 20, 0.5, 0),
			["Text"] = setting.Name,
		})
		local numberItem
		if setting.Type == SettingType.Number then
			numberItem = createElement(NumberSettingItem, {
				["Setting"] = setting,
			})
		end
		local enumItem
		if setting.Type == SettingType.Enum then
			enumItem = createElement(EnumSettingItem, {
				["Setting"] = setting,
			})
		end
		local booleanItem
		if setting.Type == SettingType.Boolean then
			booleanItem = createElement(BooleanSettingItem, {
				["Setting"] = setting,
			})
		end
		return createElement(
			Grid,
			gridProps,
			title,
			numberItem,
			enumItem,
			booleanItem,
			createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
