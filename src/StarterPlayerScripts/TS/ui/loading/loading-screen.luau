-- LoadingScreen

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
local LoadingGui = RuntimeLib.import(script, script.Parent, "loading-gui").LoadingGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local LoadingScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LoadingScreen"
	end,
	["__index"] = Screen,
})
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(...): LoadingScreen
	local classTable = LoadingScreen
	local self = setmetatable({}, classTable)
	return self:constructor(...) or self
end

function LoadingScreen.constructor(self: LoadingScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(LoadingGui)
	end
end

Reflect.defineMetadata(LoadingScreen, "identifier", "6x8")
Reflect.decorate(LoadingScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "LoadingScreen",
		["Focused"] = true,
		["DisplayOrder"] = 100,
		["DisableScaling"] = true,
		["ZIndexBehavior"] = nil,
		["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling,
	},
})

return {
	["LoadingScreen"] = LoadingScreen,
}
