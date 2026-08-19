-- TitleScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local TitleGui = RuntimeLib.import(script, script.Parent, "title-gui").TitleGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type TitleScreen = typeof(TitleScreen)

local TitleScreen = setmetatable({}, {
	["__tostring"] = function()
		return "TitleScreen"
	end,
	["__index"] = Screen,
})
TitleScreen.__index = TitleScreen

function TitleScreen.new(...)
	local self = setmetatable({}, TitleScreen)
	return self:constructor(...) or self
end

function TitleScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component(props)
		return React.createElement(TitleGui, {
			["Title"] = props.Title,
			["Color"] = props.Color,
			["Styled"] = props.Styled,
		})
	end
end

Reflect.defineMetadata(TitleScreen, "identifier", "w48")
Reflect.decorate(TitleScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Title",
		["DisableCrosshair"] = true,
	},
})

return {
	["TitleScreen"] = TitleScreen,
}
