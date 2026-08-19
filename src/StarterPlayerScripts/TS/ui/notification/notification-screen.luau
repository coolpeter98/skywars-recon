-- NotificationScreen

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
local NotificationGui = RuntimeLib.import(script, script.Parent, "notification-gui").NotificationGui
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

type NotificationProps = {
	Id: number,
	Notification: any,
	StartTime: number,
}

export type NotificationScreen = typeof(NotificationScreen)

local NotificationScreen = setmetatable({}, {
	["__tostring"] = function()
		return "NotificationScreen"
	end,
	["__index"] = Screen,
})
NotificationScreen.__index = NotificationScreen

function NotificationScreen.new(...)
	local self = setmetatable({}, NotificationScreen)
	return self:constructor(...) or self
end

function NotificationScreen.constructor(self: NotificationScreen, ...)
	Screen.constructor(self, ...)
	function self.Component(props: NotificationProps)
		return React.createElement(NotificationGui, {
			["Id"] = props.Id,
			["Notification"] = props.Notification,
			["StartTime"] = props.StartTime,
		})
	end
end

Reflect.defineMetadata(NotificationScreen, "identifier", "EJ8")
Reflect.decorate(NotificationScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Notification",
		["AllowMultiple"] = true,
	},
})
return {
	["NotificationScreen"] = NotificationScreen,
}
