-- ReportScreen

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
local ReportGui = RuntimeLib.import(script, script.Parent, "report-gui").ReportGui
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local ReportScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ReportScreen"
	end,
	["__index"] = Screen,
})
ReportScreen.__index = ReportScreen

type ReportScreen = typeof(ReportScreen)

function ReportScreen.new(...): ReportScreen
	local class = ReportScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ReportScreen.constructor(self: ReportScreen, ...)
	Screen.constructor(self, ...)
	function self.Component(props: { Player: Player })
		return React.createElement(ReportGui, {
			["Player"] = props.Player,
		})
	end
end

Reflect.defineMetadata(ReportScreen, "identifier", "4V5")
Reflect.decorate(ReportScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Report",
	},
})

return {
	["ReportScreen"] = ReportScreen,
}
