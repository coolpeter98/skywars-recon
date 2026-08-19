-- LeaderboardScreen

type LeaderboardScreen = {
	new: (...any) -> LeaderboardScreen,
	constructor: (LeaderboardScreen, ...any) -> (),
	Component: (LeaderboardScreen) -> any,
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
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local LeaderboardGui = RuntimeLib.import(script, script.Parent, "leaderboard-gui").LeaderboardGui

local LeaderboardScreen: LeaderboardScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LeaderboardScreen"
	end,
	["__index"] = Screen,
})
LeaderboardScreen.__index = LeaderboardScreen

function LeaderboardScreen.new(...)
	local class = LeaderboardScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function LeaderboardScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		return React.createElement(LeaderboardGui)
	end
end

Reflect.defineMetadata(LeaderboardScreen, "identifier", "ZkE")
Reflect.decorate(LeaderboardScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Leaderboard",
		["Focused"] = true,
		["DisableHealthBar"] = true,
		["IsInventoryGroup"] = true,
	},
})

return {
	["LeaderboardScreen"] = LeaderboardScreen,
}
