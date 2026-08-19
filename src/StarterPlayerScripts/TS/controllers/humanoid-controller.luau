-- HumanoidController

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local StarterPlayer: StarterPlayer = Services.StarterPlayer
local Util = RuntimeLib.import(script, script.Parent.Parent, "util", "util")
local AwaitHumanoid = Util.AwaitHumanoid
local GetHumanoid = Util.GetHumanoid
local RigUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "rig-util").RigUtil

type HumanoidController = {
	speedModifiers: { [string]: number },
	jumpModifiers: { [string]: number },
	baseSpeed: number,
	character: Model?,
	humanoidDescription: HumanoidDescription?,
	new: (...any) -> HumanoidController,
	constructor: (self: HumanoidController) -> (),
	onStart: (self: HumanoidController) -> (),
	getCachedCharacter: (self: HumanoidController) -> Model?,
	getCachedHumanoidDescription: (self: HumanoidController) -> HumanoidDescription?,
	handleHumanoid: (self: HumanoidController) -> (),
	setBaseSpeed: (self: HumanoidController, speed: number) -> (),
	resetBaseSpeed: (self: HumanoidController) -> (),
	addSpeedModifier: (self: HumanoidController, key: string, multiplier: number) -> (),
	removeSpeedModifier: (self: HumanoidController, key: string) -> (),
	updateSpeed: (self: HumanoidController) -> (),
	getSpeed: (self: HumanoidController) -> number,
	addJumpModifier: (self: HumanoidController, key: string, multiplier: number) -> (),
	removeJumpModifier: (self: HumanoidController, key: string) -> (),
	updateJumpPower: (self: HumanoidController) -> (),
	getJumpPower: (self: HumanoidController) -> number,
	__index: HumanoidController,
}

local HumanoidController = setmetatable({}, {
	["__tostring"] = function()
		return "HumanoidController"
	end,
})
HumanoidController.__index = HumanoidController
function HumanoidController.new(...)
	local class = HumanoidController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end
function HumanoidController.constructor(self: HumanoidController)
	self.speedModifiers = {}
	self.jumpModifiers = {}
	self.baseSpeed = StarterPlayer.CharacterWalkSpeed
	self.character = nil
	self.humanoidDescription = nil
end
function HumanoidController.onStart(self: HumanoidController)
	local localPlayer = Players.LocalPlayer
	if localPlayer.Character then
		HumanoidController:handleHumanoid()
	end
	localPlayer.CharacterAdded:Connect(function()
		HumanoidController:handleHumanoid()
	end)
	local humanoidDescription = Instance.new("HumanoidDescription")
	RuntimeLib.try(function()
		humanoidDescription = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId):Clone()
		RigUtil.applyHumanoidDescriptionConfig(humanoidDescription)
	end, function(err)
		print(err)
	end)
	self.character = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	local animate = self.character:FindFirstChild("Animate")
	if animate ~= nil then
		animate:Destroy()
	end
	self.humanoidDescription = humanoidDescription
end
function HumanoidController.getCachedCharacter(self: HumanoidController): Model?
	return self.character
end
function HumanoidController.getCachedHumanoidDescription(self: HumanoidController): HumanoidDescription?
	return self.humanoidDescription
end
function HumanoidController.handleHumanoid(_)
	local humanoid = AwaitHumanoid()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
end
function HumanoidController.setBaseSpeed(self: HumanoidController, speed: number)
	self.baseSpeed = speed
	self:updateSpeed()
end
function HumanoidController.resetBaseSpeed(self: HumanoidController)
	self.baseSpeed = StarterPlayer.CharacterWalkSpeed
	self:updateSpeed()
end
function HumanoidController.addSpeedModifier(self: HumanoidController, key: string, multiplier: number)
	self.speedModifiers[key] = multiplier
	self:updateSpeed()
end
function HumanoidController.removeSpeedModifier(self: HumanoidController, key: string)
	self.speedModifiers[key] = nil
	self:updateSpeed()
end
function HumanoidController.updateSpeed(self: HumanoidController)
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.WalkSpeed = self:getSpeed()
	end
end
function HumanoidController.getSpeed(self: HumanoidController): number
	local speed = self.baseSpeed
	for _, multiplier in self.speedModifiers do
		speed = speed * multiplier
	end
	return speed
end
function HumanoidController.addJumpModifier(self: HumanoidController, key: string, multiplier: number)
	self.jumpModifiers[key] = multiplier
	self:updateJumpPower()
end
function HumanoidController.removeJumpModifier(self: HumanoidController, key: string)
	self.jumpModifiers[key] = nil
	self:updateJumpPower()
end
function HumanoidController.updateJumpPower(self: HumanoidController)
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.JumpPower = self:getJumpPower()
	end
end
function HumanoidController.getJumpPower(self: HumanoidController): number
	local jumpPower = StarterPlayer.CharacterJumpPower
	for _, multiplier in self.jumpModifiers do
		jumpPower = jumpPower * multiplier
	end
	return jumpPower
end
Reflect.defineMetadata(HumanoidController, "identifier", "Zw")
Reflect.defineMetadata(HumanoidController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(HumanoidController, "$:flamework@Controller", Controller, {})
return {
	["HumanoidController"] = HumanoidController,
}
