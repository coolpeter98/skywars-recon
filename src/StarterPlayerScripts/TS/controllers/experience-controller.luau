-- ExperienceController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ExperienceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "experience", "experience-util").ExperienceUtil

type ExperienceController = {
	new: (...any) -> ExperienceController,
	constructor: (self: ExperienceController, ...any) -> (),
	getExperience: (self: ExperienceController) -> any,
	getLevel: (self: ExperienceController) -> any,
}

local ExperienceController = setmetatable({}, {
	["__tostring"] = function()
		return "ExperienceController"
	end
})
ExperienceController.__index = ExperienceController

function ExperienceController.new(...)
	local class = ExperienceController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ExperienceController.constructor(self)
end

function ExperienceController.getExperience(self)
	return GlobalStore:getState().Profile.Experience
end

function ExperienceController.getLevel(self)
	return ExperienceUtil.getLevel(self:getExperience())
end

Reflect.defineMetadata(ExperienceController, "identifier", "3dX")
Reflect.decorate(ExperienceController, "$:flamework@Controller", Controller, {})

return {
	["ExperienceController"] = ExperienceController,
}
