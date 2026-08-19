-- LobbyScreen

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
local LobbyGui = RuntimeLib.import(script, script.Parent, "lobby-gui").LobbyGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local LobbyScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LobbyScreen"
	end,
	["__index"] = Screen,
})
type LobbyScreen = typeof(LobbyScreen)

LobbyScreen.__index = LobbyScreen

function LobbyScreen.new(...)
	local self = setmetatable({}, LobbyScreen)
	return self:constructor(...) or self
end

function LobbyScreen.constructor(self: LobbyScreen, ...)
	Screen.constructor(self, ...)

	function self.Component(props: { InLobby: boolean })
		return React.createElement(LobbyGui, {
			["InLobby"] = props.InLobby,
		})
	end
end

Reflect.defineMetadata(LobbyScreen, "identifier", "OPx")
Reflect.decorate(LobbyScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Lobby",
	},
})

return {
	["LobbyScreen"] = LobbyScreen,
}
