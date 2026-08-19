-- ActiveItemAnimationController

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
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound

type AnimationData = {
	IdleAnimationTrack: AnimationTrack?,
	ToolAnimationTrack: AnimationTrack?,
}

type ActiveItemAnimationController = {
	characterAnimationData: { [Model]: AnimationData },
}

local ActiveItemAnimationController = setmetatable({}, {
	["__tostring"] = function()
		return "ActiveItemAnimationController"
	end,
})
ActiveItemAnimationController.__index = ActiveItemAnimationController

function ActiveItemAnimationController.new(...)
	local self = setmetatable({}, ActiveItemAnimationController)
	return self:constructor(...) or self
end

function ActiveItemAnimationController.constructor(self: ActiveItemAnimationController)
	self.characterAnimationData = {}
end

function ActiveItemAnimationController.onStart(self: ActiveItemAnimationController)
	local hotbarController = Flamework.resolveDependency("Dqk")
	local cosmeticsController = Flamework.resolveDependency("Ggz")

	hotbarController.ActiveItemUpdated:bind(function(event)
		local character: Model? = Players.LocalPlayer.Character
		if not character then
			return nil
		end

		local itemName = event.heldItemInfo
		if itemName ~= nil then
			itemName = itemName.Name
		end

		local skinId
		if itemName == "" or not itemName then
			skinId = nil
		else
			skinId = cosmeticsController:getActiveSkinFromItem(event.heldItemInfo.Name)
		end

		self:playIdleAnimation(character, event.heldItemInfo, skinId)
		self:playToolAnimation(character, event.heldItemInfo, skinId)

		local shouldEquip = event.slotId ~= event.lastActiveSlot
		if not shouldEquip then
			shouldEquip = event.heldItemInfo
			if shouldEquip then
				local itemName = event.heldItemInfo.Name
				local lastHeldItemName = event.lastHeldItem
				if lastHeldItemName ~= nil then
					lastHeldItemName = lastHeldItemName.Name
				end
				shouldEquip = itemName ~= lastHeldItemName
			end
		end

		if shouldEquip then
			self:playEquipAnimation(character, event.heldItemInfo, skinId)
		end
	end)

	Flamework.resolveDependency("a4X").SprintingUpdated:bind(function(event)
		local character: Model? = Players.LocalPlayer.Character
		if not character then
			return nil
		end

		local heldItemInfo = hotbarController:getHeldItemInfo()

		local itemName
		if heldItemInfo == nil then
			itemName = heldItemInfo
		else
			itemName = heldItemInfo.Name
		end

		local skinId
		if itemName == "" or not itemName then
			skinId = nil
		else
			skinId = cosmeticsController:getActiveSkinFromItem(heldItemInfo.Name)
		end

		self:playIdleAnimation(character, heldItemInfo, skinId, event.sprinting)
	end)
end

function ActiveItemAnimationController.stopAnimations(self: ActiveItemAnimationController, character: Model)
	local animationData = self:getAnimationData(character)
	local tracks = {}
	if animationData.IdleAnimationTrack then
		local track = animationData.IdleAnimationTrack
		table.insert(tracks, track)
	end
	Flamework.resolveDependency("Kp"):stopAnimations(character, tracks)
end

function ActiveItemAnimationController.playIdleAnimation(
	self: ActiveItemAnimationController,
	character: Model,
	heldItemInfo: any,
	skinId: string?,
	sprinting: boolean?
): AnimationTrack?
	if sprinting == nil then
		if character == Players.LocalPlayer.Character then
			sprinting = Flamework.resolveDependency("a4X"):isSprinting()
		else
			sprinting = false
		end
	end

	local animationData = self:getAnimationData(character)

	if heldItemInfo and not heldItemInfo.Block then
		local animation = Flamework.resolveDependency("Ggz"):getItemAnimation(heldItemInfo, skinId)

		if sprinting then
			if animation ~= nil then
				animation = animation.Sprint
			end
		elseif animation ~= nil then
			animation = animation.Idle
		end

		if animation == nil then
			animation = RobloxAnimation.TOOL_IDLE
		end

		local sameAnimation = animationData.IdleAnimationTrack
		if sameAnimation then
			local currentAnimationId = animationData.IdleAnimationTrack.Animation
			if currentAnimationId ~= nil then
				currentAnimationId = currentAnimationId.AnimationId
			end
			sameAnimation = currentAnimationId == animation
		end

		if sameAnimation then
			return nil
		end

		local track = Flamework.resolveDependency("Kp"):playHumanoidAnimation(animation, true, 1, character)

		local oldTrack = animationData.IdleAnimationTrack
		if oldTrack ~= nil then
			oldTrack:Stop()
		end

		local oldTrack = animationData.IdleAnimationTrack
		if oldTrack ~= nil then
			oldTrack:Destroy()
		end

		animationData.IdleAnimationTrack = track
		return track
	end

	local oldTrack = animationData.IdleAnimationTrack
	if oldTrack ~= nil then
		oldTrack:Stop()
	end

	local oldTrack = animationData.IdleAnimationTrack
	if oldTrack ~= nil then
		oldTrack:Destroy()
	end

	animationData.IdleAnimationTrack = nil
end

function ActiveItemAnimationController.playToolAnimation(
	self: ActiveItemAnimationController,
	character: Model,
	heldItemInfo: any,
	skinId: string?
): AnimationTrack?
	local animationData = self:getAnimationData(character)

	if not heldItemInfo then
		local track = animationData.ToolAnimationTrack
		if track ~= nil then
			track:Stop()
		end

		local track = animationData.ToolAnimationTrack
		if track ~= nil then
			track:Destroy()
		end

		animationData.ToolAnimationTrack = nil
		return nil
	end

	local animation = Flamework.resolveDependency("Ggz"):getItemAnimation(heldItemInfo, skinId)

	local sameAnimation = animationData.ToolAnimationTrack
	if sameAnimation then
		local currentAnimationId = animationData.ToolAnimationTrack.Animation.AnimationId
		local toolAnimation
		if animation == nil then
			toolAnimation = animation
		else
			toolAnimation = animation.Tool
		end
		sameAnimation = currentAnimationId == toolAnimation
	end

	if sameAnimation then
		return nil
	end

	local track = animationData.ToolAnimationTrack
	if track ~= nil then
		track:Stop()
	end

	local track = animationData.ToolAnimationTrack
	if track ~= nil then
		track:Destroy()
	end

	local toolAnimation
	if animation == nil then
		toolAnimation = animation
	else
		toolAnimation = animation.Tool
	end

	if toolAnimation == "" or not toolAnimation then
		animationData.ToolAnimationTrack = nil
		return nil
	end

	local tool = Players.LocalPlayer.Character
	if tool ~= nil then
		tool = tool:FindFirstChildOfClass("Tool")
	end

	if not tool or tool.Name ~= heldItemInfo.Name then
		return nil
	end

	local animator = tool:FindFirstChild("AnimationController")
	if animator ~= nil then
		animator = animator:FindFirstChild("Animator")
	end

	if not animator then
		return nil
	end

	local animationInstance = Instance.new("Animation")
	animationInstance.AnimationId = animation.Tool

	local track = animator:LoadAnimation(animationInstance)
	track.Looped = true
	track:Play()

	animationData.ToolAnimationTrack = track
	return track
end

function ActiveItemAnimationController.playEquipAnimation(
	self: ActiveItemAnimationController,
	character: Model,
	heldItemInfo: any,
	skinId: string?
): AnimationTrack?
	self:stopAnimations(character)

	if heldItemInfo then
		local function playEquipSound(soundId, soundOptions)
			if Players.LocalPlayer.Character == character then
				Flamework.resolveDependency("jL9"):playSound(soundId, soundOptions)
				return nil
			end

			local position = character.PrimaryPart
			if position ~= nil then
				position = position.Position
			end

			if position then
				Flamework.resolveDependency("jL9"):playSoundAtPosition(soundId, position, soundOptions)
			end
		end

		local equipSound = heldItemInfo.Ranged
		if equipSound ~= nil then
			equipSound = equipSound.Animation.EquipSound
		end

		if equipSound == "" or not equipSound then
			if heldItemInfo.Melee or heldItemInfo.Pickaxe then
				playEquipSound(RobloxSound.Sword.EQUIP, {
					["Volume"] = 0.7,
				})
			else
				playEquipSound(RobloxSound.Inventory.MOVE_ITEM, {
					["Volume"] = 0.7,
				})
			end
		else
			playEquipSound(heldItemInfo.Ranged.Animation.EquipSound, {
				["Volume"] = 0.7,
			})
		end

		local animation = Flamework.resolveDependency("Ggz"):getItemAnimation(heldItemInfo, skinId)

		local equipAnimation
		if animation == nil then
			equipAnimation = animation
		else
			equipAnimation = animation.Equip
		end

		if equipAnimation == "" or not equipAnimation then
			if heldItemInfo.Melee or heldItemInfo.Pickaxe then
				return Flamework.resolveDependency("Kp")
					:playHumanoidAnimation(RobloxAnimation.TOOL_EQUIP, false, 1, character)
			else
				return nil
			end
		else
			return Flamework.resolveDependency("Kp"):playHumanoidAnimation(animation.Equip, false, 1, character)
		end
	else
		return nil
	end
end

function ActiveItemAnimationController.getAnimationData(
	self: ActiveItemAnimationController,
	character: Model
): AnimationData
	local animationData = self.characterAnimationData[character]
	if animationData then
		return animationData
	end

	local animationData = {
		["IdleAnimationTrack"] = nil,
		["ToolAnimationTrack"] = nil,
	}

	self.characterAnimationData[character] = animationData
	return animationData
end

Reflect.defineMetadata(ActiveItemAnimationController, "identifier", "jBW")
Reflect.defineMetadata(ActiveItemAnimationController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ActiveItemAnimationController, "$:flamework@Controller", Controller, {})

return {
	["ActiveItemAnimationController"] = ActiveItemAnimationController,
}
