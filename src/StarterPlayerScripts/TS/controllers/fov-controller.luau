-- FovController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local TweenService: TweenService = Services.TweenService
local Workspace: Workspace = Services.Workspace
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

type FovModifier = {
	Type: string,
	Value: number,
}

type FovController = {
	modifiers: { [string]: FovModifier },
	addModifier: (
		self: FovController,
		modifierId: string,
		modifierType: string,
		value: number,
		duration: number?,
		easingStyle: Enum.EasingStyle?
	) -> (),
	removeModifier: (self: FovController, modifierId: string, duration: number?, easingStyle: Enum.EasingStyle?) -> (),
	getFov: (self: FovController) -> number,
	updateFov: (self: FovController, duration: number?, easingStyle: Enum.EasingStyle?) -> (),
	tweenFov: (self: FovController, fov: number, duration: number?, easingStyle: Enum.EasingStyle?) -> (),
	getModifiers: (self: FovController, modifierType: string) -> { number },
	getBaseFov: (self: FovController) -> number,
}

local FovController = setmetatable({}, {
	["__tostring"] = function()
		return "FovController"
	end,
})
FovController.__index = FovController

function FovController.new(...)
	local self = setmetatable({}, FovController)
	return self:constructor(...) or self
end

function FovController.constructor(self: FovController)
	self.modifiers = {}
end

function FovController.onStart(_)
	Flamework.resolveDependency("7xl"):onSettingChanged("FieldOfView", function(newFov)
		Workspace.CurrentCamera.FieldOfView = newFov
	end)
end

function FovController.addModifier(
	self: FovController,
	modifierId: string,
	modifierType: string,
	value: number,
	duration: number?,
	easingStyle: Enum.EasingStyle?
)
	self.modifiers[modifierId] = {
		["Type"] = modifierType,
		["Value"] = value,
	}
	self:updateFov(duration, easingStyle)
end

function FovController.removeModifier(
	self: FovController,
	modifierId: string,
	duration: number?,
	easingStyle: Enum.EasingStyle?
)
	self.modifiers[modifierId] = nil
	self:updateFov(duration, easingStyle)
end

function FovController.getFov(self: FovController): number
	local setModifiers = self:getModifiers("Set")
	if #setModifiers ~= 0 then
		return setModifiers[1]
	end
	local fov = self:getBaseFov()
	for _, multiplier in self:getModifiers("Multiply") do
		fov = fov * multiplier
	end
	return fov + ArrayUtil.sum(self:getModifiers("Sum"))
end

function FovController.updateFov(self: FovController, duration: number?, easingStyle: Enum.EasingStyle?)
	self:tweenFov(self:getFov(), duration, easingStyle)
end

function FovController.tweenFov(_, fov: number, duration: number?, easingStyle: Enum.EasingStyle?)
	local duration = duration == nil and 0.2 or duration
	if easingStyle == nil then
		easingStyle = Enum.EasingStyle.Linear
	end
	TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(duration, easingStyle), {
		["FieldOfView"] = fov,
	}):Play()
end

function FovController.getModifiers(self: FovController, modifierType: string): { number }
	local count = 0
	local modifiers = {}
	for index, modifier in ObjectUtils.values(self.modifiers) do
		local _ = index - 1
		if modifier.Type == modifierType == true then
			count = count + 1
			modifiers[count] = modifier
		end
	end
	local values = table.create(#modifiers)
	for index, modifier in modifiers do
		local _ = index - 1
		values[index] = modifier.Value
	end
	return values
end

function FovController.getBaseFov(_): number
	return Flamework.resolveDependency("7xl"):getSetting("FieldOfView")
end

Reflect.defineMetadata(FovController, "identifier", "jE9")
Reflect.defineMetadata(FovController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(FovController, "$:flamework@Controller", Controller, {})

return {
	["FovController"] = FovController,
}
