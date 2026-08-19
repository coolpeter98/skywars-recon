-- PowerUpsScreen

type PowerUpsScreen = {
	new: (...any) -> PowerUpsScreen,
	constructor: (PowerUpsScreen, ...any) -> (),
	Component: (PowerUpsScreen) -> any,
}

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
local PowerUpsGui = RuntimeLib.import(script, script.Parent, "power-ups-gui").PowerUpsGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local PowerUpsScreen: PowerUpsScreen = setmetatable({}, {
	["__tostring"] = function()
		return "PowerUpsScreen"
	end,
	["__index"] = Screen,
})
PowerUpsScreen.__index = PowerUpsScreen

function PowerUpsScreen.new(...)
	local class = PowerUpsScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function PowerUpsScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(PowerUpsGui)
	end
end

Reflect.defineMetadata(PowerUpsScreen, "identifier", "3xD")
Reflect.decorate(PowerUpsScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "PowerUps",
		["CloseOnDeath"] = true,
	},
})

return {
	["PowerUpsScreen"] = PowerUpsScreen,
}
