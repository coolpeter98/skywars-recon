-- WinEffectController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local CollectionService: CollectionService = Services.CollectionService
local RunService: RunService = Services.RunService
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local LobbyScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "lobby", "lobby-screen").LobbyScreen
local SidebarScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "sidebar", "sidebar-screen").SidebarScreen
local HealthBarScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "health-bar", "health-bar-screen").HealthBarScreen
local HotbarScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "hotbar", "hotbar-screen").HotbarScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local WinEffectTrophies =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "win-effect-util").WinEffectTrophies
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "character-util").CharacterUtil
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

local KEYFRAME_SOUNDS = {
	["BronzePlatformIn"] = RobloxSound.WinEffect.WIN_EFFECT_BRONZE_PLATFORM_IN,
	["SilverPlatformIn"] = RobloxSound.WinEffect.WIN_EFFECT_SILVER_PLATFORM_IN,
	["GoldPlatformIn"] = RobloxSound.WinEffect.WIN_EFFECT_GOLD_PLATFORM_IN,
	["BronzeTrophyIn"] = RobloxSound.WinEffect.WIN_EFFECT_BRONZE_TROPHY_IN,
	["SilverTrophyIn"] = RobloxSound.WinEffect.WIN_EFFECT_SILVER_TROPHY_IN,
	["GoldTrophyIn"] = RobloxSound.WinEffect.WIN_EFFECT_GOLD_TROPHY_IN,
}

type ParticleEmitterData = {
	Attachment: Attachment,
	Bone: Bone,
	Offset: CFrame,
}

type CharacterData = {
	Player: Player,
	Dummy: Model,
	Bone: Bone,
	Offset: CFrame,
}

type WinEffectController = {
	WinEffectEnded: typeof(AsyncEvent.new()),
	maid: typeof(Maid.new()),
	inWinEffect: boolean,
}

local WinEffectController = setmetatable({}, {
	["__tostring"] = function()
		return "WinEffectController"
	end,
})
WinEffectController.__index = WinEffectController
function WinEffectController.new(...)
	local self = WinEffectController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function WinEffectController.constructor(self: WinEffectController)
	self.WinEffectEnded = AsyncEvent.new()
	self.maid = Maid.new()
	self.inWinEffect = false
end
function WinEffectController.onStart(self: WinEffectController)
	if not GameConstants.NEW_WIN_EFFECT_ENABLED then
		return nil
	end
	Flamework.resolveDependency("rB8").GameEnded:bind(function(result)
		if GameConstants.NEW_WIN_EFFECT_ENABLED then
			self:startWinEffect(result.GameResult)
		end
	end)
	Events.WinEffectStopped:connect(function()
		self:stopWinEffect()
	end)
end
function WinEffectController.startWinEffect(self: WinEffectController, gameResult)
	self:stopWinEffect()
	self.inWinEffect = true
	self.maid:GiveTask(function()
		self.inWinEffect = false
		self.WinEffectEnded:fire()
	end)
	self:closeScreens()
	local world = Flamework.resolveDependency("Jj"):getWorld()
	if world ~= nil then
		world = world:WaitForChild("WinEffect", 5)
	end
	if not world then
		self:stopWinEffect()
		return nil
	end
	self:playAnimation(world)
	self:animateParticles(world)
	self:animateCharacters(world, gameResult)
end
function WinEffectController.stopWinEffect(self: WinEffectController)
	if not self.inWinEffect then
		return nil
	end
	self.maid:DoCleaning()
end
function WinEffectController.isInWinEffect(self: WinEffectController): boolean
	return self.inWinEffect
end
function WinEffectController.closeScreens(_)
	Flamework.resolveDependency("lB5"):close(LobbyScreen)
	Flamework.resolveDependency("lB5"):close(SidebarScreen)
	Flamework.resolveDependency("lB5"):close(HealthBarScreen)
	Flamework.resolveDependency("lB5"):close(HotbarScreen)
	Flamework.resolveDependency("MMv"):tryLeaveQueue()
end
function WinEffectController.playAnimation(self: WinEffectController, model: Model)
	local animationTrack: AnimationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(model, RobloxAnimation.WIN_EFFECT_ANIMATION, false, 0.5)
	self.maid:GiveTask(Flamework.resolveDependency("jL9"):playSound(RobloxSound.WinEffect.WIN_EFFECT_AMBIENT, {
		["Looped"] = true,
		["SoundGroup"] = nil,
		["SoundGroup"] = SoundGroupType.World,
	}))
	self.maid:GiveTask(
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.WinEffect.WIN_EFFECT_PLATFORM_HOVER_LOOP, {
			["Looped"] = true,
			["SoundGroup"] = nil,
			["SoundGroup"] = SoundGroupType.World,
		})
	)
	for keyframeName, sound in KEYFRAME_SOUNDS do
		self.maid:GiveTask(AnimationUtil.keyframeReached(animationTrack, keyframeName, function()
			Flamework.resolveDependency("jL9"):playSound(sound, {
				["SoundGroup"] = SoundGroupType.World,
			})
			return true
		end))
	end
	self.maid:GiveTask(Flamework.resolveDependency("wj1"):animateCamera({
		["AnimationTrack"] = animationTrack,
		["CameraBone"] = model.RootPart.Bn_Root.Bn_Camera,
		["Rotation"] = CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966),
		["OnComplete"] = function()
			self:stopWinEffect()
		end,
	}))
end
function WinEffectController.animateParticles(self: WinEffectController, model: Model)
	local particleEmitters = self:createParticleEmitters(model)
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		for _, emitter in particleEmitters do
			emitter.Attachment.WorldCFrame = emitter.Bone.TransformedWorldCFrame:ToWorldSpace(emitter.Offset)
		end
	end))
end
function WinEffectController.animateCharacters(self: WinEffectController, model: Model, gameResult)
	local characters = self:createCharacters(model, gameResult)
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		for _, character in characters do
			character.Dummy:PivotTo(character.Bone.TransformedWorldCFrame:ToWorldSpace(character.Offset))
		end
	end))
end
function WinEffectController.createParticleEmitters(self: WinEffectController, model: Model): { ParticleEmitterData }
	local emitters = {}
	for _, descendant in model:GetDescendants() do
		local skip = not descendant:IsA("BasePart")
		if not skip then
			local parentIsModel = descendant.Parent
			if parentIsModel ~= nil then
				parentIsModel = parentIsModel:IsA("Model")
			end
			skip = not (parentIsModel and self:isParticlePart(descendant))
		end
		if not skip then
			local trophyType = self:getTrophyType(descendant)
			local platformCFrame = model[trophyType].CFrame
			local attachment = Instance.new("Attachment")
			attachment.Parent = descendant
			attachment.WorldCFrame = (CFrame.new(
				attachment.WorldPosition,
				platformCFrame:ToWorldSpace(CFrame.new(0, 60, 0)).Position
			) * CFrame.Angles(0, 3.141592653589793, 0)):ToWorldSpace(CFrame.new(0, 0, 2))
			self:createParticleEmitter(attachment)
			local emitter = {
				["Attachment"] = attachment,
				["Bone"] = self:getPlatformBone(model, trophyType),
				["Offset"] = platformCFrame:ToObjectSpace(attachment.WorldCFrame),
			}
			table.insert(emitters, emitter)
		end
	end
	return emitters
end
function WinEffectController.createParticleEmitter(_, attachment: Attachment)
	Flamework.resolveDependency("dm"):attachParticleEmitter(attachment, {
		["Color"] = nil,
		["Texture"] = "http://www.roblox.com/asset/?id=7249913733",
		["LightEmission"] = 0,
		["LightInfluence"] = 1,
		["Size"] = nil,
		["Transparency"] = nil,
		["EmissionDirection"] = nil,
		["Lifetime"] = nil,
		["Rate"] = 50,
		["Speed"] = nil,
		["SpreadAngle"] = nil,
		["Drag"] = 3.5,
		["TimeScale"] = 0.65,
		["LockedToPart"] = true,
		["Color"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 142, 255)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(58, 194, 253)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(123, 255, 251)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.1, 1.3),
			NumberSequenceKeypoint.new(0.2, 1.9),
			NumberSequenceKeypoint.new(0.35, 1.4),
			NumberSequenceKeypoint.new(0.55, 0.75),
			NumberSequenceKeypoint.new(1, 0),
		}),
		["Transparency"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.3, 0.75),
			NumberSequenceKeypoint.new(1, 1),
		}),
		["EmissionDirection"] = Enum.NormalId.Front,
		["Lifetime"] = NumberRange.new(0.25, 0.5),
		["Speed"] = NumberRange.new(28, 60),
		["SpreadAngle"] = Vector2.new(1, 1),
	})
end
function WinEffectController.createCharacters(self: WinEffectController, model: Model, gameResult): { CharacterData }
	local characters = {}
	for _, trophy in WinEffectTrophies do
		local placement = gameResult.placements[trophy.PlacementIndex + 1]
		if placement then
			local platform = model[trophy.Type]
			local zOffsetMagnitude = #placement > 3 and 6 or 3
			for i = 0, #placement - 1 do
				local player = placement[i + 1]
				local dummy = self:createDummy(player)
				dummy.Name = player.Name
				dummy.Parent = model
				local center, size = dummy:GetBoundingBox()
				local bottomY = (center - size / 2).Y
				local primaryPartY = dummy.PrimaryPart.Position.Y
				dummy:FindFirstChildOfClass("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				local centerXOffset = (#placement - 1) * -4.5
				local indexXOffset = i * 9
				local zOffset
				if #placement > 2 then
					if i == 0 or i == #placement - 1 then
						zOffset = -zOffsetMagnitude
					else
						zOffset = zOffsetMagnitude
					end
				else
					zOffset = 0
				end
				local character = {
					["Player"] = player,
					["Dummy"] = dummy,
					["Bone"] = self:getPlatformBone(model, trophy.Type),
				}
				local newCFrame = CFrame.new
				local xOffset
				if #placement > 3 then
					xOffset = i % 2 == 0 and -6 or 6
				else
					xOffset = -(centerXOffset + indexXOffset)
				end
				character.Offset = newCFrame(xOffset, platform.Size.Y / 2 + (primaryPartY - bottomY), zOffset)
				table.insert(characters, character)
				CollectionService:AddTag(dummy, "character")
				Flamework.resolveDependency("Kp"):playHumanoidAnimation(trophy.Animation, true, 1, dummy)
			end
		end
	end
	return characters
end
function WinEffectController.createDummy(_, player: Player): Model
	local character = CharacterUtil.createCharacter(player.UserId)
	if character.PrimaryPart then
		character.PrimaryPart.Anchored = true
	end
	character:ScaleTo(2.5)
	return character
end
function WinEffectController.isParticlePart(_, part: BasePart): boolean
	return string.match(part.Name, "particles") ~= nil
end
function WinEffectController.getTrophyType(_, part: BasePart): string?
	for trophyType in WinEffectTrophies do
		local partName = part.Name
		local lowerTrophyType = string.lower(trophyType)
		if string.match(partName, lowerTrophyType) ~= nil then
			return trophyType
		end
	end
	return nil
end
function WinEffectController.getPlatformBone(_, model: Model, trophyType: string): Bone?
	if trophyType == "Bronze" then
		return model.RootPart.Bn_Root.Bn_Platform_Bronze
	end
	if trophyType == "Silver" then
		return model.RootPart.Bn_Root.Bn_Platform_Silver
	end
	if trophyType == "Gold" then
		return model.RootPart.Bn_Root.Bn_Platform_Gold
	end
end
Reflect.defineMetadata(WinEffectController, "identifier", "XNg")
Reflect.defineMetadata(WinEffectController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(WinEffectController, "$:flamework@Controller", Controller, {})
return {
	["WinEffectController"] = WinEffectController,
}
