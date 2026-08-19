-- AnimationUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService

local AnimationUtil  = nil

AnimationUtil = {
	["createHumanoidAnimation"] = function(humanoid: Humanoid, animationId: string): AnimationTrack
		local animator = humanoid:WaitForChild("Animator") :: Animator
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		return animator:LoadAnimation(animation)
	end,
	["createCharacterAnimation"] = function(character: Model, animationId: string): AnimationTrack
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
		return AnimationUtil.createHumanoidAnimation(humanoid, animationId)
	end,
	["findCharacterAnimation"] = function(character: Model, animationId: string): AnimationTrack?
		local animator = (character:FindFirstChild("Humanoid") :: Humanoid):FindFirstChild("Animator") :: Animator?
		if not animator then
			return nil
		end
		for _, track in animator:GetPlayingAnimationTracks() do
			local isPlaying = track.IsPlaying
			if isPlaying then
				local loadedAnimation: any = track.Animation
				if loadedAnimation ~= nil then
					loadedAnimation = loadedAnimation.AnimationId
				end
				isPlaying = loadedAnimation == animationId
			end
			if isPlaying then
				return track
			end
		end
		return nil
	end,
	["waitForAnimation"] = function(animation: Animation)
		local startTime = os.clock()
		while animation.Length == 0 and not TimeUtil.elapsed(startTime, 5) do
			RunService.Heartbeat:Wait()
		end
	end,
	["keyframeReached"] = function(
		animation: Animation,
		keyframeName: string,
		callback: () -> boolean
	): RBXScriptConnection?
		AnimationUtil.waitForAnimation(animation)
		local connection: RBXScriptConnection? = nil
		connection = animation.KeyframeReached:Connect(function(reachedKeyframe: string)
			if reachedKeyframe ~= keyframeName then
				return nil
			end
			if callback() then
				connection:Disconnect()
			end
		end)
		return connection
	end,
}

return {
	["AnimationUtil"] = AnimationUtil,
}
