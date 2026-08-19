-- CrosshairScreen

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
local Crosshair = RuntimeLib.import(script, script.Parent, "crosshair").Crosshair
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local CrosshairScreen = setmetatable({}, {
	["__tostring"] = function()
		return "CrosshairScreen"
	end,
	["__index"] = Screen,
})

type CrosshairScreen = typeof(CrosshairScreen) & {
	new: (...unknown) -> CrosshairScreen,
	constructor: (...unknown) -> CrosshairScreen,
}

CrosshairScreen.__index = CrosshairScreen
function CrosshairScreen.new(...): CrosshairScreen
	local CrosshairScreen = CrosshairScreen
	local self = setmetatable({}, CrosshairScreen)
	return self:constructor(...) or self
end
function CrosshairScreen.constructor(self: CrosshairScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(Crosshair)
	end
end
Reflect.defineMetadata(CrosshairScreen, "identifier", "bo")
Reflect.decorate(CrosshairScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Crosshair",
	},
})
return {
	["CrosshairScreen"] = CrosshairScreen,
}
