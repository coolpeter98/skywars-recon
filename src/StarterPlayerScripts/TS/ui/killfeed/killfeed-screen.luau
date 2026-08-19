-- KillfeedScreen

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
local KillfeedGui = RuntimeLib.import(script, script.Parent, "killfeed-gui").KillfeedGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local KillfeedScreen = setmetatable({}, {
	["__tostring"] = function()
		return "KillfeedScreen"
	end,
	["__index"] = Screen,
})
KillfeedScreen.__index = KillfeedScreen

function KillfeedScreen.new(...)
	local self = setmetatable({}, KillfeedScreen)
	return self:constructor(...) or self
end

function KillfeedScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(KillfeedGui, {
			["Index"] = props.Index,
			["Killed"] = props.Killed,
			["Killer"] = props.Killer,
			["DamageType"] = props.DamageType,
		})
	end
end

Reflect.defineMetadata(KillfeedScreen, "identifier", "mBW")
Reflect.decorate(KillfeedScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Killfeed",
		["AllowMultiple"] = true,
	},
})

return {
	["KillfeedScreen"] = KillfeedScreen,
}
