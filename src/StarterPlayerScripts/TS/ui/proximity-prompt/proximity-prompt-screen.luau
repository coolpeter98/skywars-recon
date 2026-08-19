-- ProximityPromptScreen

type ProximityPromptScreen = {
	new: (...any) -> ProximityPromptScreen,
	constructor: (ProximityPromptScreen, ...any) -> (),
	Component: (any) -> any,
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
local ScreenDecorator =
	RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local ProximityPromptGui =
	RuntimeLib.import(script, script.Parent, "proximity-prompt-gui").ProximityPromptGui
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local ProximityPromptScreen = setmetatable({}, {
	["__tostring"] = function()
		return "ProximityPromptScreen"
	end,
	["__index"] = Screen,
})
ProximityPromptScreen.__index = ProximityPromptScreen

function ProximityPromptScreen.new(...)
	local self = ProximityPromptScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function ProximityPromptScreen.constructor(self: ProximityPromptScreen, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(ProximityPromptGui, {
			["ProximityPrompt"] = props.ProximityPrompt,
			["InputType"] = props.InputType,
		})
	end
end

Reflect.defineMetadata(ProximityPromptScreen, "identifier", "px0")
Reflect.decorate(ProximityPromptScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "ProximityPrompt",
		["AllowMultiple"] = true,
	},
})

return {
	["ProximityPromptScreen"] = ProximityPromptScreen,
}
