-- ThunderstormKillEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-decorator"
).CosmeticDecorator
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local ElectricArc = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"eletric-arc",
	"lib"
)
local StringUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"string-utils"
)
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local CLOUD_OFFSET = 2 * BlockConstants.BLOCK_SIZE
local VIEWPORT_CLOUD_OFFSET = 1 * BlockConstants.BLOCK_SIZE
local ThunderstormKillEffect = setmetatable({}, {
	["__tostring"] = function()
		return "ThunderstormKillEffect"
	end,
	["__index"] = KillEffect,
})
ThunderstormKillEffect.__index = ThunderstormKillEffect

function ThunderstormKillEffect.new(...)
	local self = setmetatable({}, ThunderstormKillEffect)
	return self:constructor(...) or self
end

function ThunderstormKillEffect.constructor(self, ...)
	KillEffect.constructor(self, ...)
end

function ThunderstormKillEffect.playEffect(self, character: Model, killEffectArgs)
	self:playCloudsAnimation(self:createClouds(self:getCloudsPosition(killEffectArgs)), killEffectArgs)
	TweenUtil.fadeOutSync(character, 0.4)
end

function ThunderstormKillEffect.getCloudsPosition(_, killEffectArgs): CFrame
	local pivot = killEffectArgs.Character:GetPivot()
	local cloudOffset
	if killEffectArgs.IsInViewportFrame then
		cloudOffset = VIEWPORT_CLOUD_OFFSET
	else
		cloudOffset = CLOUD_OFFSET
	end
	return pivot + Vector3.new(0, cloudOffset, 0)
end

function ThunderstormKillEffect.playCloudsAnimation(self, clouds: Model, killEffectArgs)
	local fadeTween = TweenUtil.fadeOutAsync(clouds, 0)
	clouds.Parent = killEffectArgs.Parent
	if killEffectArgs.AnimationEnded then
		return nil
	end
	local track: AnimationTrack = Flamework.resolveDependency("Kp")
		:playAnimationTrack(clouds, RobloxAnimation.THUNDERSTORM_CLOUDS)
	AnimationUtil.waitForAnimation(track)
	RuntimeLib.Promise.delay(0.4):andThen(function()
		if not killEffectArgs.AnimationEnded then
			TweenUtil.restoreTween(fadeTween, 0.4)
		end
	end)
	RuntimeLib.Promise.delay(track.Length - 0.4):andThen(function()
		if not killEffectArgs.AnimationEnded then
			TweenUtil.fadeOutAsync(clouds, 0.4)
		end
	end)
	local lightningMaid = nil
	local keyframeConnection: RBXScriptConnection = track.KeyframeReached:Connect(function(keyframe: string)
		if keyframe == "LightningStart" then
			lightningMaid = self:playLightningStrikeAnimation(clouds, killEffectArgs.Character)
			killEffectArgs.Maid:GiveTask(lightningMaid)
		elseif keyframe == "LightningStop" and lightningMaid then
			lightningMaid:DoCleaning()
		end
	end)
	track.Stopped:Wait()
	keyframeConnection:Disconnect()
end

function ThunderstormKillEffect.playLightningStrikeAnimation(self, clouds: Model, character: Model)
	local maid = Maid.new()
	Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(RobloxAnimation.THUNDERSTORM_PLAYER_STRIKE, false, 1, character, true)
	task.wait(0.5)
	local largeCloudArc = self:createLightningStrikeArc(clouds, character, "LargeCloud")
	local smallCloud1Arc = self:createLightningStrikeArc(clouds, character, "SmallCloud1")
	local smallCloud2Arc = self:createLightningStrikeArc(clouds, character, "SmallCloud2")
	maid:GiveTask(largeCloudArc)
	maid:GiveTask(smallCloud1Arc)
	maid:GiveTask(smallCloud2Arc)
	Flamework.resolveDependency("Ax3"):playerThunderstormHighlight(character)
	maid:GiveTask(ScheduleUtil.createSchedule(0.5, function()
		return Flamework.resolveDependency("Ax3"):playerThunderstormHighlight(character)
	end))
	return maid
end

function ThunderstormKillEffect.createLightningStrikeArc(self, clouds: Model, character: Model, cloudPartPrefix: string)
	local parts = self:getSubCloudParts(clouds, cloudPartPrefix)
	local positionSum = Vector3.new()
	for i = 1, #parts do
		local part = parts[i]
		local _ = i - 1
		positionSum = positionSum + part.Position
	end
	local averagePosition = positionSum / #parts
	local characterPosition = character:GetPivot().Position
	return ElectricArc.new(averagePosition, characterPosition, Color.White, Color.LightBlue, 2, 2)
end

function ThunderstormKillEffect.getSubCloudParts(_, clouds: Model, namePrefix: string): { BasePart }
	local count = 0
	local result = {}
	for index, descendant in clouds:GetDescendants() do
		local _ = index - 1
		local matches = descendant:IsA("BasePart")
		if matches then
			matches = StringUtils.startsWith(descendant.Name, namePrefix)
		end
		if matches == true then
			count = count + 1
			result[count] = descendant
		end
	end
	return result
end

function ThunderstormKillEffect.createClouds(_, position: CFrame): Model
	local clouds = ReplicatedStorage.Cosmetic.KillEffect.Clouds:Clone()
	for _, descendant in clouds:GetDescendants() do
		if descendant:IsA("BasePart") then
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = clouds.PrimaryPart
			weldConstraint.Part1 = descendant
			weldConstraint.Parent = descendant
		end
	end
	clouds:PivotTo(position)
	return clouds
end

Reflect.defineMetadata(ThunderstormKillEffect, "identifier", "zPo")
Reflect.decorate(ThunderstormKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectThunderstorm })
return {
	["ThunderstormKillEffect"] = ThunderstormKillEffect,
}
