-- SidebarScreen

local RuntimeLib: RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect: Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React: React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator: ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen: Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local SidebarScreen = setmetatable({}, {
	["__tostring"] = function()
		return "SidebarScreen"
	end,
	["__index"] = Screen,
})
type SidebarScreen = typeof(SidebarScreen)

SidebarScreen.__index = SidebarScreen

function SidebarScreen.new(...): SidebarScreen
	local selfClass = SidebarScreen
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function SidebarScreen.constructor(self: SidebarScreen, ...)
	Screen.constructor(self, ...)

	function self.Component(): React.Element
		return React.createElement(React.Fragment)
	end
end

Reflect.defineMetadata(SidebarScreen, "identifier", "pO9")
Reflect.decorate(SidebarScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Sidebar",
	},
})

return {
	["SidebarScreen"] = SidebarScreen,
}
