-- SeasonPassScreen

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
local SeasonPassGui = RuntimeLib.import(script, script.Parent, "season-pass-gui").SeasonPassGui
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

type SeasonPassScreen = {
	new: (...any) -> SeasonPassScreen,
	constructor: (self: SeasonPassScreen, ...any) -> (),
	Component: (() -> any)?,
}

local SeasonPassScreen = setmetatable({}, {
	["__tostring"] = function()
		return "SeasonPassScreen"
	end,
	["__index"] = Screen,
})
SeasonPassScreen.__index = SeasonPassScreen

function SeasonPassScreen.new(...)
	local class = SeasonPassScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function SeasonPassScreen.constructor(self: SeasonPassScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(SeasonPassGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
		})
	end
end

Reflect.defineMetadata(SeasonPassScreen, "identifier", "475")
Reflect.decorate(SeasonPassScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "SeasonPass",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})
return {
	["SeasonPassScreen"] = SeasonPassScreen,
}
