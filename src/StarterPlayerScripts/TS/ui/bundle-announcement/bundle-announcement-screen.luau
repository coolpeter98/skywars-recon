-- BundleAnnouncementScreen

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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type BundleAnnouncementScreen = typeof(Screen) & {
	Component: (_: any) -> any,
}

local BundleAnnouncementScreen = setmetatable({}, {
	["__tostring"] = function()
		return "BundleAnnouncementScreen"
	end,
	["__index"] = Screen,
})
BundleAnnouncementScreen.__index = BundleAnnouncementScreen

function BundleAnnouncementScreen.new(...)
	local self = setmetatable({}, BundleAnnouncementScreen)
	return self:constructor(...) or self
end

function BundleAnnouncementScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(_: any)
		return React.createElement(React.Fragment)
	end
end

Reflect.defineMetadata(BundleAnnouncementScreen, "identifier", "VxB")
Reflect.decorate(BundleAnnouncementScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "BundleAnnouncement",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["ShowBackground"] = true,
	},
})

return {
	["BundleAnnouncementScreen"] = BundleAnnouncementScreen,
}
