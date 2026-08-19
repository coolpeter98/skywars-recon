-- PlayGameScreen

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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local PlayGameGui = RuntimeLib.import(script, script.Parent, "play-game-gui").PlayGameGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil

export type PlayGameScreen = typeof(PlayGameScreen)

local PlayGameScreen = setmetatable({}, {
	["__tostring"] = function()
		return "PlayGameScreen"
	end,
	["__index"] = Screen,
})
PlayGameScreen.__index = PlayGameScreen

function PlayGameScreen.new(...)
	local self = setmetatable({}, PlayGameScreen)
	return self:constructor(...) or self
end

function PlayGameScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(PlayGameGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
		})
	end
end

Reflect.defineMetadata(PlayGameScreen, "identifier", "o0O")
Reflect.decorate(PlayGameScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "PlayGame",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["ZIndexBehavior"] = nil,
		["ShowBackground"] = true,
		["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling,
	},
})

return {
	["PlayGameScreen"] = PlayGameScreen,
}
