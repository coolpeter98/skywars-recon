-- SprintingController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local UserInputService: UserInputService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").UserInputService
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local GetCharacter: () -> Model? = RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetCharacter
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

type HumanoidController = {
	setBaseSpeed: (speed: number) -> (),
	resetBaseSpeed: () -> (),
}

type SprintingController = {
	humanoidController: HumanoidController,
	SprintingUpdated: {
		fire: (payload: { sprinting: boolean }) -> (),
	},
	sprinting: boolean,
	canSprint: boolean,
}

local SprintingController = setmetatable({}, {
	["__tostring"] = function()
		return "SprintingController"
	end
})
SprintingController.__index = SprintingController

function SprintingController.new(...)
	local self = setmetatable({}, SprintingController)
	return self:constructor(...) or self
end

function SprintingController.constructor(self: SprintingController, humanoidController: HumanoidController)
	self.humanoidController = humanoidController
	self.SprintingUpdated = AsyncEvent.new()
	self.sprinting = false
	self.canSprint = true
end

function SprintingController.onStart(self: SprintingController)
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isSprintToggle(input) then
			return nil
		end
		self:toggleSprinting()
	end)
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isSprint(input) then
			return nil
		end
		if not GetCharacter() then
			return nil
		end
		self:enableSprinting()
	end)
	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isSprint(input) then
			return nil
		end
		if not GetCharacter() then
			return nil
		end
		self:disableSprinting()
	end)
end

function SprintingController.isSprinting(self: SprintingController): boolean
	return self.sprinting
end

function SprintingController.getCanSprint(self: SprintingController): boolean
	return self.canSprint
end

function SprintingController.setCanSprint(self: SprintingController, canSprint: boolean)
	self.canSprint = canSprint
	Flamework.resolveDependency("o5O"):setCanSprint(canSprint)
	if not self.canSprint and self.sprinting then
		self:disableSprinting()
	end
end

function SprintingController.toggleSprinting(self: SprintingController)
	if self.sprinting then
		self:disableSprinting()
	else
		self:enableSprinting()
	end
end

function SprintingController.enableSprinting(self: SprintingController)
	if not self.canSprint or self.sprinting then
		return nil
	end
	self.sprinting = true
	self.humanoidController:setBaseSpeed(22)
	Flamework.resolveDependency("jE9"):addModifier("Sprinting", "Sum", 7)
	self.SprintingUpdated:fire({
		["sprinting"] = true
	})
end

function SprintingController.disableSprinting(self: SprintingController)
	if not self.sprinting then
		return nil
	end
	self.sprinting = false
	self.humanoidController:resetBaseSpeed()
	Flamework.resolveDependency("jE9"):removeModifier("Sprinting")
	self.SprintingUpdated:fire({
		["sprinting"] = false
	})
end

Reflect.defineMetadata(SprintingController, "identifier", "a4X")
Reflect.defineMetadata(SprintingController, "flamework:parameters", { "Zw" })
Reflect.defineMetadata(SprintingController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(SprintingController, "$:flamework@Controller", Controller, {})
return {
	["SprintingController"] = SprintingController
}
