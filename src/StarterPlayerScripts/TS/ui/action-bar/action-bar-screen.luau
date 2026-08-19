-- ActionBarScreen

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
local ActionBarGui = RuntimeLib.import(script, script.Parent, "action-bar-gui").ActionBarGui
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local ActionBarScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ActionBarScreen"
	end,
	["__index"] = Screen,
})
ActionBarScreen.__index = ActionBarScreen

function ActionBarScreen.new(...)
	local self = setmetatable({}, ActionBarScreen)
	return self:constructor(...) or self
end

function ActionBarScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component()
		return React.createElement(ActionBarGui, {
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(0.5, 0, 1, -187),
		})
	end
end

Reflect.defineMetadata(ActionBarScreen, "identifier", "99l")
Reflect.decorate(ActionBarScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "ActionBar",
	},
})

return {
	["ActionBarScreen"] = ActionBarScreen,
}
