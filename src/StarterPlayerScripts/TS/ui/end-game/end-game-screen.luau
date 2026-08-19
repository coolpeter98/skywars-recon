-- EndGameScreen

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
local EndGameGui = RuntimeLib.import(script, script.Parent, "end-game-gui").EndGameGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type EndGameScreen = {}

local EndGameScreen = setmetatable({}, {
	["__tostring"] = function()
		return "EndGameScreen"
	end,
	["__index"] = Screen,
})
EndGameScreen.__index = EndGameScreen

function EndGameScreen.new(...)
	local class = EndGameScreen
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function EndGameScreen.constructor(self: EndGameScreen, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(EndGameGui, {
			["Winner"] = props.Winner,
			["GameEnded"] = props.GameEnded,
		})
	end
end

Reflect.defineMetadata(EndGameScreen, "identifier", "P4B")
Reflect.decorate(EndGameScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "EndGame",
		["DisableCrosshair"] = true,
		["ShowBackground"] = true,
		["Focused"] = true,
	},
})

return {
	["EndGameScreen"] = EndGameScreen,
}
