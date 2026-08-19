-- CameraAnimationController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
local AnimationUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local AwaitHumanoid = RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitHumanoid

local PauseBehaviour = {
	["Pause"] = "Pause",
	["Cleanup"] = "Cleanup"
}

type CameraAnimationController = {
	maid: any,
}

type CameraAnimation = {
	AnimationTrack: AnimationTrack,
	CameraBone: Bone,
	FieldOfView: number?,
	Rotation: CFrame?,
	PauseBehaviour: string?,
	OnComplete: (() -> ())?,
}

local CameraAnimationController = setmetatable({}, {
	["__tostring"] = function()
		return "CameraAnimationController"
	end
})
CameraAnimationController.__index = CameraAnimationController

function CameraAnimationController.new(...)
	local self = setmetatable({}, CameraAnimationController)
	return self:constructor(...) or self
end

function CameraAnimationController.constructor(self: CameraAnimationController)
	self.maid = Maid.new()
end

function CameraAnimationController.animateCamera(self: CameraAnimationController, animation: CameraAnimation)
	self.maid:DoCleaning()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	local fovController = Flamework.resolveDependency("jE9")
	local fieldOfView = animation.FieldOfView
	fovController:addModifier("CameraAnimation", "Set", fieldOfView == nil and 70 or fieldOfView)
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		camera.CFrame = animation.CameraBone.TransformedWorldCFrame * (animation.Rotation or CFrame.new())
	end))
	self.maid:GiveTask(animation.AnimationTrack.Stopped:Connect(function()
		self.maid:DoCleaning()
	end))
	self.maid:GiveTask(AnimationUtil.keyframeReached(animation.AnimationTrack, "Pause", function()
		local pauseBehaviour = animation.PauseBehaviour or PauseBehaviour.Cleanup
		if pauseBehaviour == PauseBehaviour.Pause then
			animation.AnimationTrack:AdjustSpeed(0)
		elseif pauseBehaviour == PauseBehaviour.Cleanup then
			self.maid:DoCleaning()
		end
		return true
	end))
	self.maid:GiveTask(function()
		if animation.OnComplete then
			animation.OnComplete()
		end
		camera.CameraSubject = AwaitHumanoid()
		Flamework.resolveDependency("jE9"):removeModifier("CameraAnimation")
		camera.CameraType = Enum.CameraType.Custom
	end)
	return self.maid
end

Reflect.defineMetadata(CameraAnimationController, "identifier", "wj1")
Reflect.decorate(CameraAnimationController, "$:flamework@Controller", Controller, {})
return {
	["PauseBehaviour"] = PauseBehaviour,
	["CameraAnimationController"] = CameraAnimationController
}
