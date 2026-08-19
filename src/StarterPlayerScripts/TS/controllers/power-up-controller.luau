-- PowerUpController

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
local UserInputService: UserInputService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).UserInputService
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local PowerUps = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "power-up", "power-ups").PowerUps
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local PowerUpsScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "power-ups", "power-ups-screen").PowerUpsScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

type PowerUpController = {
	new: (...any) -> PowerUpController,
	constructor: (
		self: PowerUpController,
		screenController: any,
		inventoryController: any,
		hotbarController: any
	) -> (),
	screenController: any,
	inventoryController: any,
	hotbarController: any,
	PowerUpActivated: any,
	PowerUpDeactivated: any,
	onStart: (self: PowerUpController) -> (),
	usePowerUp: (self: PowerUpController, input: InputObject) -> (),
	hasPowerUp: (self: PowerUpController, powerUp: string) -> boolean,
}

local PowerUpController: PowerUpController = setmetatable({}, {
	["__tostring"] = function()
		return "PowerUpController"
	end,
})
PowerUpController.__index = PowerUpController

function PowerUpController.new(...)
	local class = PowerUpController
	local instance: PowerUpController = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function PowerUpController.constructor(self: PowerUpController, screenController, inventoryController, hotbarController)
	self.screenController = screenController
	self.inventoryController = inventoryController
	self.hotbarController = hotbarController
	self.PowerUpActivated = AsyncEvent.new()
	self.PowerUpDeactivated = AsyncEvent.new()
end

function PowerUpController.onStart(self: PowerUpController)
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isPcInteract(input) then
			return nil
		end
		self:usePowerUp(input)
	end)

	Events.PowerUpToggled:connect(function(powerUp: string, activated: boolean)
		local newState = {}
		for powerUpKey, activatedAt in GlobalStore:getState().PowerUps do
			newState[powerUpKey] = activatedAt
		end
		if activated then
			newState[powerUp] = os.clock()
		else
			newState[powerUp] = nil
		end
		Flamework.resolveDependency("zG"):setValue("PowerUps", newState)
		if activated then
			self.PowerUpActivated:fire({
				["powerUp"] = powerUp,
			})
		else
			self.PowerUpDeactivated:fire({
				["powerUp"] = powerUp,
			})
		end
	end)

	self.PowerUpActivated:bind(function(data: { powerUp: string })
		local powerUp = data.powerUp
		if powerUp == "SpeedBoost" then
			Flamework.resolveDependency("Zw"):addSpeedModifier("SpeedBoost", 1.2)
			return
		elseif powerUp == "JumpBoost" then
			Flamework.resolveDependency("Zw"):addJumpModifier("JumpBoost", 1.65)
		elseif powerUp == "Adrenaline" then
			Flamework.resolveDependency("Zw"):addSpeedModifier("SpeedBoost", 1.1)
		end
	end)

	self.PowerUpDeactivated:bind(function(data: { powerUp: string })
		local powerUp = data.powerUp
		if powerUp == "SpeedBoost" then
			Flamework.resolveDependency("Zw"):removeSpeedModifier("SpeedBoost")
			return
		elseif powerUp == "JumpBoost" then
			Flamework.resolveDependency("Zw"):removeJumpModifier("JumpBoost")
		elseif powerUp == "Adrenaline" then
			Flamework.resolveDependency("Zw"):removeSpeedModifier("SpeedBoost")
		end
	end)

	self.screenController.ScreenOpenedEvent:bind(function(screenData)
		if screenData.screenHandler.Options.DisableHealthBar then
			self.screenController:close(PowerUpsScreen)
		end
	end)

	self.screenController.ScreenClosedEvent:bind(function(screenData)
		if screenData.screenHandler.Options.DisableHealthBar then
			self.screenController:open(PowerUpsScreen, {})
		end
	end)

	self.screenController:open(PowerUpsScreen, {})
end

function PowerUpController.usePowerUp(self: PowerUpController, input: InputObject)
	if not InputUtil.isWorldInteract(input) then
		return nil
	end

	local heldItemInfo = self.hotbarController:getHeldItemInfo()
	local powerUpInfo
	if heldItemInfo == nil then
		powerUpInfo = heldItemInfo
	else
		powerUpInfo = heldItemInfo.PowerUp
	end
	if not powerUpInfo then
		return nil
	end
	if Flamework.resolveDependency("LKE"):isOnCooldown(heldItemInfo.Name) then
		return nil
	end

	local powerUpConfig = PowerUps[powerUpInfo.Type]
	local maid = Maid.new()

	local animationController = Flamework.resolveDependency("Kp")
	local animationId = powerUpConfig.Animation
	if animationId == nil then
		animationId = RobloxAnimation.POWERUP_USE
	end
	local animationTrack = animationController:playHumanoidAnimation(animationId, false)

	local soundController = Flamework.resolveDependency("jL9")
	local soundId = powerUpConfig.Sound
	if soundId == nil then
		soundId = RobloxSound.Potion.DRINK
	end
	local soundHandle = soundController:playSound(soundId, {
		["Volume"] = 0.8,
	})

	local cancelled = false
	maid:GiveTask(function()
		animationTrack:Stop()
		animationTrack:Destroy()
		soundHandle:Destroy()
	end)
	maid:GiveTask(Flamework.resolveDependency("Dqk").ActiveItemUpdated:bind(function(data)
		local heldItemInfo = data.heldItemInfo
		if heldItemInfo and heldItemInfo.Name == heldItemInfo.Name then
			return nil
		end
		cancelled = true
		maid:DoCleaning()
	end))
	maid:GiveTask(input:GetPropertyChangedSignal("UserInputState"):Connect(function()
		if input.UserInputState ~= Enum.UserInputState.End and input.UserInputState ~= Enum.UserInputState.Cancel then
			return nil
		end
		cancelled = true
		maid:DoCleaning()
	end))
	maid:GiveTask(animationTrack.Stopped:Connect(function()
		if cancelled then
			return nil
		end
		if animationTrack.TimePosition >= animationTrack.Length * 0.9 and not cancelled then
			Events.ActivatePowerUp:fire()
		end
	end))
end

function PowerUpController.hasPowerUp(_, powerUp: string): boolean
	return GlobalStore:getState().PowerUps[powerUp] ~= nil
end

Reflect.defineMetadata(PowerUpController, "identifier", "B51")
Reflect.defineMetadata(PowerUpController, "flamework:parameters", { "lB5", "qOA", "Dqk" })
Reflect.defineMetadata(PowerUpController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PowerUpController, "$:flamework@Controller", Controller, {})
return {
	["PowerUpController"] = PowerUpController,
}
