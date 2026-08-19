-- PrivateMatchBrowserScreen

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
local PrivateMatch = RuntimeLib.import(script, script.Parent.Parent, "private-match").PrivateMatch
local PrivateMatchBrowserSidebar =
	RuntimeLib.import(script, script.Parent, "private-match-browser-sidebar").PrivateMatchBrowserSidebar
local PrivateMatchBrowserPage =
	RuntimeLib.import(script, script.Parent, "private-match-browser-page").PrivateMatchBrowserPage
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen").Screen

export type PrivateMatchBrowserScreen = {}

local PrivateMatchBrowserScreen = setmetatable({}, {
	["__tostring"] = function()
		return "PrivateMatchBrowserScreen"
	end,
	["__index"] = Screen,
})
PrivateMatchBrowserScreen.__index = PrivateMatchBrowserScreen

function PrivateMatchBrowserScreen.new(...): PrivateMatchBrowserScreen
	local self = setmetatable({}, PrivateMatchBrowserScreen)
	return self:constructor(...) or self
end

function PrivateMatchBrowserScreen.constructor(self: PrivateMatchBrowserScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(PrivateMatch, {
			["Sidebar"] = React.createElement(PrivateMatchBrowserSidebar),
			["Page"] = React.createElement(PrivateMatchBrowserPage),
		})
	end
end

Reflect.defineMetadata(PrivateMatchBrowserScreen, "identifier", "Bx1")
Reflect.decorate(PrivateMatchBrowserScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "PrivateMatchBrowser",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["PrivateMatchBrowserScreen"] = PrivateMatchBrowserScreen,
}
