-- ChangelogScreen

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
local ChangelogGui = RuntimeLib.import(script, script.Parent, "changelog-gui").ChangelogGui

local ChangelogScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ChangelogScreen"
	end,
	["__index"] = Screen,
})
ChangelogScreen.__index = ChangelogScreen

function ChangelogScreen.new(...)
	local selfClass = ChangelogScreen
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function ChangelogScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(ChangelogGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 176),
		})
	end
end

Reflect.defineMetadata(ChangelogScreen, "identifier", "rqG")
Reflect.decorate(ChangelogScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Changelog",
	},
})

return {
	["ChangelogScreen"] = ChangelogScreen,
}
