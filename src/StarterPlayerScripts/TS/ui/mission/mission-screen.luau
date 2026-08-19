-- MissionScreen

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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local MissionGui = RuntimeLib.import(script, script.Parent, "mission-gui").MissionGui
local MissionScreen = setmetatable({}, {
	["__tostring"] = function()
		return "MissionScreen"
	end,
	["__index"] = Screen,
})
MissionScreen.__index = MissionScreen

function MissionScreen.new(...)
	local self = setmetatable({}, MissionScreen)
	return self:constructor(...) or self
end

function MissionScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component()
		return React.createElement(MissionGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
		})
	end
end

Reflect.defineMetadata(MissionScreen, "identifier", "aDX")
Reflect.decorate(MissionScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Mission",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["MissionScreen"] = MissionScreen,
}
