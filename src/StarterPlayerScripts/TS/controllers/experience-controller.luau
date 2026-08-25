-- ExperienceController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local GlobalStoreChanged =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStoreChanged
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local LevelUpScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "level-up", "level-up-screen").LevelUpScreen

type ExperienceController = {
	new: (...any) -> ExperienceController,
	constructor: (self: ExperienceController, ...any) -> (),
	onStart: (self: ExperienceController) -> (),
	getExperience: (self: ExperienceController) -> any,
	getLevel: (self: ExperienceController) -> any,
}

local ExperienceController = setmetatable({}, {
	["__tostring"] = function()
		return "ExperienceController"
	end,
})
ExperienceController.__index = ExperienceController

function ExperienceController.new(...)
	local class = ExperienceController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ExperienceController.constructor(self) end

-- Reconstructed trigger: the decompiled client lost the code that opened the
-- level-up popup, only its closer survived. Watch the replicated profile and
-- celebrate every level gained (the first replication is a join, not a gain).
function ExperienceController.onStart(self)
	local previousLevel: number? = nil
	GlobalStoreChanged("Profile", function(_, newProfile)
		local experience: number = if newProfile ~= nil and type(newProfile.Experience) == "number"
			then newProfile.Experience
			else 0
		local level = ExperienceUtil.getLevel(experience)
		if previousLevel ~= nil and level > previousLevel then
			Flamework.resolveDependency("lB5"):open(LevelUpScreen)
			Flamework.resolveDependency("qmA"):playLevelUp()
		end
		previousLevel = level
	end)
end

function ExperienceController.getExperience(self)
	return GlobalStore:getState().Profile.Experience
end

function ExperienceController.getLevel(self)
	return ExperienceUtil.getLevel(self:getExperience())
end

Reflect.defineMetadata(ExperienceController, "identifier", "3dX")
Reflect.defineMetadata(ExperienceController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ExperienceController, "$:flamework@Controller", Controller, {})

return {
	["ExperienceController"] = ExperienceController,
}
