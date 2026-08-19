-- VerifyScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local VerifyGui = RuntimeLib.import(script, script.Parent, "verify-gui").VerifyGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local VerifyScreen = setmetatable({}, {
	["__tostring"] = function()
		return "VerifyScreen"
	end,
	["__index"] = Screen,
})
VerifyScreen.__index = VerifyScreen

function VerifyScreen.new(...)
	local selfClass = VerifyScreen
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function VerifyScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component()
		return React.createElement(VerifyGui)
	end
end

Reflect.defineMetadata(VerifyScreen, "identifier", "V0k")
Reflect.decorate(VerifyScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Verify",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["VerifyScreen"] = VerifyScreen,
}
