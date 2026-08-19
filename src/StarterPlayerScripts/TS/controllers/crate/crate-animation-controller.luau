-- CrateAnimationController

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
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local TweenService: TweenService = Services.TweenService
local Workspace: Workspace = Services.Workspace
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local CrateUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crate-util").CrateUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "character-util").CharacterUtil
local PauseBehaviour = RuntimeLib.import(script, script.Parent.Parent, "camera-animation-controller").PauseBehaviour

type CrateAnimationController = {
	maid: any,
	CrateAnimationCompleted: any,
	CrateAnimationCleanUp: any,
	isAnimationCompleted: boolean,
}

local CrateAnimationController = setmetatable({}, {
	["__tostring"] = function()
		return "CrateAnimationController"
	end,
})
CrateAnimationController.__index = CrateAnimationController

function CrateAnimationController.new(...)
	local self = setmetatable({}, CrateAnimationController)
	return self:constructor(...) or self
end

function CrateAnimationController.constructor(self: CrateAnimationController)
	self.CrateAnimationCompleted = AsyncEvent.new()
	self.CrateAnimationCleanUp = AsyncEvent.new()
	self.maid = Maid.new()
	self.isAnimationCompleted = false
end

function CrateAnimationController.playAnimation(self: CrateAnimationController, crateId: string)
	if self:isInAnimation() then
		return nil
	end
	local crateScene = self:createCrateScene(Vector3.new(588.5, 187, 582.5))
	self.maid:GiveTask(crateScene)
	local animationCharacter = self:createAnimationCharacter(crateScene)
	self.maid:GiveTask(animationCharacter)
	self:completeAnimation()
	self.crateModel = self:createCrateModel(crateId, crateScene)
	self.maid:GiveTask(self.crateModel)
	self:playCharacterAnimation(animationCharacter)
	self:animateCamera(self:playCrateAnimation(self.crateModel), self.crateModel)
end

function CrateAnimationController.stopAnimation(self: CrateAnimationController)
	self.maid:DoCleaning()
	self.crateModel = nil
	self.isAnimationCompleted = false
	self.CrateAnimationCleanUp:fire({})
end

function CrateAnimationController.completeAnimation(self: CrateAnimationController)
	if not self.crateModel or self.isAnimationCompleted then
		return nil
	end
	self.isAnimationCompleted = true
	local position = self.crateModel.RootPart.Bn_Root.Bn_Plate.TransformedWorldCFrame.Position
	self.CrateAnimationCompleted:fire({
		["CrateModel"] = self.crateModel,
		["Position"] = position,
	})
end

function CrateAnimationController.createCrateScene(self: CrateAnimationController, position: Vector3): Model
	local scenes = ReplicatedStorage.Crate.Scenes:GetChildren()
	local crateScene = ArrayUtil.random(scenes):Clone()
	crateScene:TranslateBy(position)
	for _, descendant in crateScene.WorldData:GetDescendants() do
		if descendant:IsA("CFrameValue") then
			descendant.Value = descendant.Value + position
		end
	end
	crateScene.Parent = Workspace
	self.maid:GiveTask(crateScene)
	return crateScene
end

function CrateAnimationController.createCrateModel(_, crateId: string, crateScene): Model
	local crateModel = CrateUtil.createCrateModel(crateId)
	crateModel:SetPrimaryPartCFrame(crateScene.WorldData.Crate.Value)
	crateModel.Parent = crateScene
	return crateModel
end

function CrateAnimationController.playCrateAnimation(self: CrateAnimationController, crateModel: Model): AnimationTrack
	local animationTrack = Flamework.resolveDependency("Kp"):playAnimationTrack(crateModel, RobloxAnimation.CRATE_OPEN)
	AnimationUtil.waitForAnimation(animationTrack)
	self.maid:GiveTask(function()
		return animationTrack:Stop()
	end)
	self.maid:GiveTask(AnimationUtil.keyframeReached(animationTrack, "CrateStart", function()
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.Crate.CRATE_OPEN, {
			["SoundGroup"] = SoundGroupType.World,
		})
		return true
	end))
	self.maid:GiveTask(AnimationUtil.keyframeReached(animationTrack, "CrateOpened", function()
		local attachment = crateModel.PrimaryPart
		if attachment ~= nil then
			attachment = attachment:FindFirstChildOfClass("Attachment")
		end
		if not attachment then
			return true
		end
		TweenService:Create(attachment, TweenInfo.new(0.5), {
			["Position"] = Vector3.new(0, 1.5, 0),
		}):Play()
		return true
	end))
	self.maid:GiveTask(AnimationUtil.keyframeReached(animationTrack, "CrateLanded", function()
		ScheduleUtil.runTask(function()
			self:completeAnimation()
		end, 1)
		return true
	end))
	return animationTrack
end

function CrateAnimationController.createAnimationCharacter(self: CrateAnimationController, crateScene): Model
	local character = CharacterUtil.createCharacter()
	if character.PrimaryPart then
		character.PrimaryPart.Anchored = true
	end
	character.Parent = crateScene
	local halfHeight = character:GetExtentsSize().Y / 2
	local offset = Vector3.new(0, halfHeight)
	local rotation = CFrame.Angles(0, 3.7524578917878086, 0)
	character:SetPrimaryPartCFrame((crateScene.WorldData.Crate.Value + offset) * rotation)
	Flamework.resolveDependency("Z6E"):enableFocus(false, true)
	Flamework.resolveDependency("a4X"):setCanSprint(false)
	self.maid:GiveTask(function()
		character:Destroy()
		Flamework.resolveDependency("Z6E"):disableFocus()
		Flamework.resolveDependency("a4X"):setCanSprint(true)
	end)
	return character
end

function CrateAnimationController.playCharacterAnimation(self: CrateAnimationController, character: Model)
	local animationTrack = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.CRATE_OPEN_PLAYER, false, 1, character)
	AnimationUtil.waitForAnimation(animationTrack)
	self.maid:GiveTask(function()
		return animationTrack:Stop()
	end)
	local delay = animationTrack.Length - 1
	ScheduleUtil.runTask(function()
		if self:isInAnimation() then
			TweenUtil.fadeOutSync(character, 1)
			character:Destroy()
		end
	end, delay)
end

function CrateAnimationController.animateCamera(
	self: CrateAnimationController,
	animationTrack: AnimationTrack,
	crateModel
)
	local cameraMaid = Flamework.resolveDependency("wj1"):animateCamera({
		["AnimationTrack"] = animationTrack,
		["CameraBone"] = crateModel.RootPart.Bn_Root.Bn_Camera_Dummy,
		["Rotation"] = CFrame.Angles(1.5707963267948966, 0, 0),
		["PauseBehaviour"] = PauseBehaviour.Pause,
	})
	self.maid:GiveTask(self.CrateAnimationCompleted:bind(function()
		TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(0.5), {
			["FieldOfView"] = 50,
		}):Play()
	end))
	self.maid:GiveTask(self.CrateAnimationCleanUp:bind(function()
		cameraMaid:DoCleaning()
	end))
end

function CrateAnimationController.isInAnimation(self: CrateAnimationController)
	return self.crateModel ~= nil
end

Reflect.defineMetadata(CrateAnimationController, "identifier", "dyD")
Reflect.decorate(CrateAnimationController, "$:flamework@Controller", Controller, {})
return {
	["CrateAnimationController"] = CrateAnimationController,
}
