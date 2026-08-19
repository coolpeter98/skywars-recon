-- CooldownController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")

type CooldownController = typeof(setmetatable({} :: any, {} :: any))

local CooldownController = setmetatable({}, {
	["__tostring"] = function()
		return "CooldownController"
	end
})
CooldownController.__index = CooldownController

function CooldownController.new(...)
	local class = CooldownController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function CooldownController.constructor(self: CooldownController)
end

function CooldownController.onStart(self: CooldownController)
	Events["837f63c1-1022-43e2-b749-2695f8ae87d1"]:connect(function(key: string, duration: number?)
		local cooldowns = GlobalStore:getState().Cooldowns
		local newCooldowns = {}
		for _, entry in ObjectUtils.entries(cooldowns) do
			newCooldowns[entry[1]] = entry[2]
		end
		if duration == nil then
			newCooldowns[key] = nil
		else
			newCooldowns[key] = {
				["ExpireTime"] = os.clock() + duration,
				["Duration"] = duration
			}
		end
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "Cooldowns",
			["Value"] = nil,
			["Value"] = newCooldowns
		})
	end)
end

function CooldownController.isOnCooldown(self: CooldownController, key: string): boolean
	local cooldown = GlobalStore:getState().Cooldowns[key]
	if cooldown then
		return os.clock() < cooldown.ExpireTime
	else
		return false
	end
end

Reflect.defineMetadata(CooldownController, "identifier", "LKE")
Reflect.defineMetadata(CooldownController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CooldownController, "$:flamework@Controller", Controller, {})
return {
	["CooldownController"] = CooldownController
}
