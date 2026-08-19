-- OldWinEffectController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Workspace: Workspace = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local GameConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

type OldWinEffectController = {
	focus: CFrame?,
}

local OldWinEffectController = setmetatable({}, {
	["__tostring"] = function()
		return "OldWinEffectController"
	end
})
OldWinEffectController.__index = OldWinEffectController

function OldWinEffectController.new(...)
	local self = setmetatable({}, OldWinEffectController)
	return self:constructor(...) or self
end

function OldWinEffectController.constructor(self: OldWinEffectController)
	self.focus = nil
end

function OldWinEffectController.onStart(self: OldWinEffectController)
	if GameConstants.NEW_WIN_EFFECT_ENABLED then
		return nil
	end
	Events.WinEffectFocus:connect(function(focus)
		self:startWinEffect(focus)
	end)
	Events.WinEffectStopped:connect(function()
		self:stopWinEffect()
	end)
end

function OldWinEffectController.onRender(self: OldWinEffectController, _)
	if GameConstants.NEW_WIN_EFFECT_ENABLED then
		return nil
	end
	if self.focus then
		local camera = Workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CameraSubject = nil
		camera.CFrame = self.focus
	end
end

function OldWinEffectController.startWinEffect(self: OldWinEffectController, focus: CFrame)
	self.focus = focus
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CameraSubject = nil
	camera.CFrame = focus
	Flamework.resolveDependency("jE9"):addModifier("WinEffectFov", "Set", 62, 0.05)
end

function OldWinEffectController.stopWinEffect(self: OldWinEffectController)
	local focus = self.focus
	self.focus = nil
	Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	Flamework.resolveDependency("jE9"):removeModifier("WinEffectFov", 0.05)
	return focus
end

Reflect.defineMetadata(OldWinEffectController, "identifier", "K4o")
Reflect.defineMetadata(OldWinEffectController, "flamework:implements", { "$:flamework@OnStart", "$:flamework@OnRender" })
Reflect.decorate(OldWinEffectController, "$:flamework@Controller", Controller, {})
return {
	["OldWinEffectController"] = OldWinEffectController
}
