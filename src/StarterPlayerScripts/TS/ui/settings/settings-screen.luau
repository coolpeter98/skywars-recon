-- SettingsScreen

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local SettingsGui = RuntimeLib.import(script, script.Parent, "settings-gui").SettingsGui
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

export type SettingsScreen = {}

local SettingsScreen = setmetatable({}, {
	["__tostring"] = function()
		return "SettingsScreen"
	end,
	["__index"] = Screen,
})
SettingsScreen.__index = SettingsScreen

function SettingsScreen.new(...): SettingsScreen
	local self = setmetatable({}, SettingsScreen)
	return self:constructor(...) or self
end

function SettingsScreen.constructor(self: SettingsScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(SettingsGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
		})
	end
end

Reflect.defineMetadata(SettingsScreen, "identifier", "04L")
Reflect.decorate(SettingsScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Settings",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["SettingsScreen"] = SettingsScreen,
}
