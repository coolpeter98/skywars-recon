-- AnimationController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local AnimationUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "animation", "animation-util").AnimationUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local PowerUpEffect =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "effect", "power-up-effect").PowerUpEffect
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type AnimationController = {
	playAnimationTrack: (character: Model, animationId: string, looped: boolean?, speed: number?) -> AnimationTrack,
	playHumanoidAnimation: (
		animationId: string,
		looped: boolean?,
		speed: number?,
		character: Model?,
		pauseOnKeyframe: boolean?
	) -> AnimationTrack?,
	stopAnimations: (character: Model?, exceptions: { AnimationTrack }?) -> (),
}

local AnimationController = setmetatable({}, {
	["__tostring"] = function()
		return "AnimationController"
	end,
})
AnimationController.__index = AnimationController

function AnimationController.new(...): AnimationController
	local self = setmetatable({}, AnimationController)
	return self:constructor(...) or self
end

function AnimationController.constructor(_) end

function AnimationController.onStart(_)
	Events["3670fe8e-dc2d-4c11-be18-421c83b38745"]:connect(function(character: Model)
		PowerUpEffect.new(character):start()
	end)
end

function AnimationController.playAnimationTrack(
	_,
	character: Model,
	animationId: string,
	looped: boolean?,
	speed: number?
): AnimationTrack
	if looped == nil then
		looped = false
	end
	local effectiveSpeed = speed == nil and 1 or speed
	local animator = character.AnimationController:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = character.AnimationController
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Looped = looped
	track:Play()
	if effectiveSpeed ~= 1 then
		track:AdjustSpeed(effectiveSpeed)
	end
	AnimationUtil.keyframeReached(track, "Pause", function()
		track:AdjustSpeed(0)
		return true
	end)
	return track
end

function AnimationController.playHumanoidAnimation(
	_,
	animationId: string,
	looped: boolean?,
	speed: number?,
	character: Model?,
	pauseOnKeyframe: boolean?
): AnimationTrack?
	if looped == nil then
		looped = false
	end
	local effectiveSpeed = speed == nil and 1 or speed
	if character == nil then
		character = Players.LocalPlayer.Character
	end
	if not character then
		return nil
	end
	local track = AnimationUtil.findCharacterAnimation(character, animationId)
	if track then
		track:Stop()
	else
		track = AnimationUtil.createCharacterAnimation(character, animationId)
	end
	track:Play()
	if effectiveSpeed ~= 1 then
		track:AdjustSpeed(effectiveSpeed)
	end
	if not looped then
		track.Stopped:Connect(function()
			track:Destroy()
		end)
	end
	if pauseOnKeyframe then
		local connection: RBXScriptConnection? = nil
		connection = track.KeyframeReached:Connect(function(keyframe: string)
			if keyframe == "Pause" then
				track:AdjustSpeed(0)
				connection:Disconnect()
			end
		end)
	end
	return track
end

function AnimationController.stopAnimations(_, character: Model?, exceptions: { AnimationTrack }?)
	if character == nil then
		character = Players.LocalPlayer.Character
	end
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return nil
	end
	local animator = humanoid:FindFirstChild("Animator")
	if not animator then
		return nil
	end
	for _, track in animator:GetPlayingAnimationTracks() do
		if track.Animation then
			local animationIds = ObjectUtils.values(RobloxAnimation)
			local animationId = track.Animation.AnimationId
			if
				table.find(animationIds, animationId) ~= nil
				and (not exceptions or table.find(exceptions, track) == nil)
			then
				track:Stop()
				track:Destroy()
			end
		end
	end
end

Reflect.defineMetadata(AnimationController, "identifier", "Kp")
Reflect.defineMetadata(AnimationController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(AnimationController, "$:flamework@Controller", Controller, {})

return {
	["AnimationController"] = AnimationController,
}
