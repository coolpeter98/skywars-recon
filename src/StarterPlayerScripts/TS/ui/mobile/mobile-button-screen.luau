-- MobileButtonScreen

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
local MobileButtonGui = RuntimeLib.import(script, script.Parent, "mobile-button-gui").MobileButtonGui
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

export type MobileButtonScreenProps = {
	MobileButtonId: string,
	DefaultActive: boolean,
}

export type MobileButtonScreen = {
	new: (...any) -> MobileButtonScreen,
	constructor: (self: MobileButtonScreen, ...any) -> (),
	Component: (self: MobileButtonScreen, props: MobileButtonScreenProps) -> any,
}

local MobileButtonScreen: MobileButtonScreen = setmetatable({}, {
	["__tostring"] = function()
		return "MobileButtonScreen"
	end,
	["__index"] = Screen,
})
MobileButtonScreen.__index = MobileButtonScreen

function MobileButtonScreen.new(...: any): MobileButtonScreen
	local self = setmetatable({}, MobileButtonScreen)
	return self:constructor(...) or self
end

function MobileButtonScreen.constructor(self: MobileButtonScreen, ...: any)
	Screen.constructor(self, ...)

	function self.Component(props: MobileButtonScreenProps)
		local isSmallScreen: boolean = ScreenUtil.isSmallScreen()
		local buttonSize: number = isSmallScreen and 70 or 120
		local position: UDim2
		if isSmallScreen then
			position = UDim2.new(1, -(buttonSize * 1.5 - 10) - buttonSize - 10, 1, -buttonSize - 20 - buttonSize - 10)
		else
			position = UDim2.new(1, -(buttonSize * 1.5 - 10) - buttonSize - 20, 1, -buttonSize * 1.75 - buttonSize - 20)
		end
		local alternatePosition: UDim2
		if isSmallScreen then
			alternatePosition = UDim2.new(1, -(buttonSize * 1.5 - 10), 1, -buttonSize - 20 - buttonSize - 10)
		else
			alternatePosition = UDim2.new(1, -(buttonSize * 1.5 - 10), 1, -buttonSize * 1.75 - buttonSize - 20)
		end
		local createElement = React.createElement
		local mobileButtonGui = MobileButtonGui
		local elementProps = {}
		if props.MobileButtonId == "Sprint" then
			position = alternatePosition
		end
		elementProps.Position = position
		elementProps.MobileButtonId = props.MobileButtonId
		elementProps.DefaultActive = props.DefaultActive
		return createElement(mobileButtonGui, elementProps)
	end
end

Reflect.defineMetadata(MobileButtonScreen, "identifier", "kmp")
Reflect.decorate(MobileButtonScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "MobileButton",
		["AllowMultiple"] = true,
		["DisableScaling"] = true,
	},
})

return {
	["MobileButtonScreen"] = MobileButtonScreen,
}
