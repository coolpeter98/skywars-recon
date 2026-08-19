-- LockerScreen

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
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local LockerGui = RuntimeLib.import(script, script.Parent, "locker-gui").LockerGui

local LockerScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LockerScreen"
	end,
	["__index"] = Screen,
})

LockerScreen.__index = LockerScreen

function LockerScreen.new(...)
	local self = setmetatable({}, LockerScreen)
	return self:constructor(...) or self
end

function LockerScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component()
		return React.createElement(LockerGui)
	end
end

Reflect.defineMetadata(LockerScreen, "identifier", "dMD")
Reflect.decorate(LockerScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Locker",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["DisableDock"] = true,
		["ShowBackground"] = true,
		["MobileScale"] = 1,
	},
})

return {
	["LockerScreen"] = LockerScreen,
}
