-- LeaveGameScreen

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
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Confirmation = RuntimeLib.import(script, script.Parent.Parent, "confirmation", "confirmation").Confirmation
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

type LeaveGameScreen = {
	new: (...any) -> LeaveGameScreen,
	constructor: (self: LeaveGameScreen, ...any) -> (),
	Component: () -> any,
}

local LeaveGameScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LeaveGameScreen"
	end,
	["__index"] = Screen,
})
LeaveGameScreen.__index = LeaveGameScreen

function LeaveGameScreen.new(...)
	local self = LeaveGameScreen
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function LeaveGameScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local screenContext = useScreen()
		local props = {
			["Text"] = "Would you like to return to the lobby?",
			["OnConfirm"] = nil,
			["IsOpen"] = nil,
			["Close"] = nil,
			["OnConfirm"] = function()
				return Flamework.resolveDependency("mPW"):teleportToHub()
			end,
			["IsOpen"] = function()
				return screenContext.IsOpen()
			end,
			["Close"] = function()
				return screenContext.Close()
			end,
		}
		return React.createElement(Confirmation, props)
	end
end

Reflect.defineMetadata(LeaveGameScreen, "identifier", "lj5")
Reflect.decorate(LeaveGameScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "LeaveGame",
		["Focused"] = true,
	},
})

return {
	["LeaveGameScreen"] = LeaveGameScreen,
}
