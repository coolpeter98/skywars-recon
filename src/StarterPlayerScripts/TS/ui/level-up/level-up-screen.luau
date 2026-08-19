-- LevelUpScreen

type LevelUpScreen = {
	new: (...any) -> LevelUpScreen,
	constructor: (LevelUpScreen, ...any) -> (),
	Component: (LevelUpScreen) -> any,
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
local LevelUpGui = RuntimeLib.import(script, script.Parent, "level-up-gui").LevelUpGui
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

local LevelUpScreen: LevelUpScreen = setmetatable({}, {
	["__tostring"] = function()
		return "LevelUpScreen"
	end,
	["__index"] = Screen,
})
LevelUpScreen.__index = LevelUpScreen

function LevelUpScreen.new(...)
	local class = LevelUpScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function LevelUpScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local screen = useScreen()
		local frameRef = useRef()
		useEffect(function()
			if not frameRef.current then
				return nil
			end
			task.spawn(function()
				task.wait(5)
				if screen.IsOpen() then
					if frameRef.current then
						TweenUtil.fadeOutSync(frameRef.current, 1)
					end
					screen.Close()
				end
			end)
		end, { frameRef.current })
		return React.createElement(LevelUpGui, {
			["FrameRef"] = frameRef,
		})
	end
end

Reflect.defineMetadata(LevelUpScreen, "identifier", "L4o")
Reflect.decorate(LevelUpScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "LevelUp",
	},
})

return {
	["LevelUpScreen"] = LevelUpScreen,
}
