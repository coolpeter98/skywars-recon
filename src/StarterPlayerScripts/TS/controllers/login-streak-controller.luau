-- LoginStreakController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

export type LoginStreakController = {}

local LoginStreakController = setmetatable({}, {
	["__tostring"] = function()
		return "LoginStreakController"
	end
})
LoginStreakController.__index = LoginStreakController
function LoginStreakController.new(...)
	local class = LoginStreakController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function LoginStreakController.constructor(self: LoginStreakController)
end
function LoginStreakController.onStart(self: LoginStreakController)
	Events.LoginStreak:fire(self:convertTzStringToOffset(os.date("%z")))
end
function LoginStreakController.convertTzStringToOffset(self: LoginStreakController, tzString: string): number
	local sign = string.sub(tzString, 1, 1) == "-" and -1 or 1
	local hoursString = string.sub(tzString, 2, 3)
	local hours = tonumber(hoursString)
	local minutesString = string.sub(tzString, 4, 5)
	local minutes = tonumber(minutesString)
	return (hours * 3600 + minutes * 60) * sign
end
Reflect.defineMetadata(LoginStreakController, "identifier", "bKg")
Reflect.defineMetadata(LoginStreakController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(LoginStreakController, "$:flamework@Controller", Controller, {})
return {
	["LoginStreakController"] = LoginStreakController
}
