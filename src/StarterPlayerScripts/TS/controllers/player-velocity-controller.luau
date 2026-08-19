-- PlayerVelocityController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local util = RuntimeLib.import(script, script.Parent.Parent, "util", "util")
local GetCharacter = util.GetCharacter
local GetHumanoid = util.GetHumanoid
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants

local PlayerVelocityController = setmetatable({}, {
	["__tostring"] = function()
		return "PlayerVelocityController"
	end,
})
PlayerVelocityController.__index = PlayerVelocityController

function PlayerVelocityController.new(...)
	local self = setmetatable({}, PlayerVelocityController)
	return self:constructor(...) or self
end

function PlayerVelocityController.constructor(self)
	self.lastVelocityTime = 0
end

function PlayerVelocityController.onStart(self)
	Events.DamageImpulse:connect(function(damage)
		local humanoid: Humanoid? = GetHumanoid()
		local primaryPart = GetCharacter()
		if primaryPart ~= nil then
			primaryPart = primaryPart.PrimaryPart
		end
		if not (humanoid and primaryPart) then
			return
		end
		if os.clock() - self.lastVelocityTime < HealthConstants.DAMAGE_COOLDOWN * 0.8 then
			return
		end
		self.lastVelocityTime = os.clock()
		local mass = primaryPart.AssemblyMass
		local massScale = mass / 14.332
		humanoid.PlatformStand = true
		print("mass: " .. tostring(mass))
		local currentVelocity = primaryPart:GetVelocityAtPosition(primaryPart.Position)
		print("current velocity: " .. tostring(currentVelocity))
		local appliedImpulse = damage * massScale
		print("applied: " .. tostring(appliedImpulse))
		local assemblyCenterOfMass = primaryPart.AssemblyCenterOfMass
		print("acom: " .. tostring(assemblyCenterOfMass))
		local impulse = damage * massScale
		if humanoid.FloorMaterial == Enum.Material.Air or (currentVelocity.Y > 5 or currentVelocity.Y < -5) then
			print(
				(
					("scaling velocity due to in-air state, platform mat %* y component: %*"):format(
						humanoid.FloorMaterial,
						currentVelocity.Y
					)
				)
			)
			impulse = impulse * Vector3.new(1, 0.3, 1)
		end
		primaryPart:ApplyImpulse(impulse)
		local newPosition = primaryPart.Position
		print("new: " .. tostring(primaryPart:GetVelocityAtPosition(newPosition)))
		local heartbeatElapsed = 0
		local initialTotal = 0
		while heartbeatElapsed < 0.015 do
			heartbeatElapsed = heartbeatElapsed + RunService.Heartbeat:Wait()
		end
		print(("Waited %* on Heartbeat"):format(heartbeatElapsed))
		local heartbeatTotal = initialTotal + heartbeatElapsed
		local steppedElapsed = 0
		while steppedElapsed < 0.03 do
			steppedElapsed = steppedElapsed + select(2, RunService.Stepped:Wait())
		end
		print(("Waited %* on Stepped"):format(steppedElapsed))
		local totalWait = heartbeatTotal + steppedElapsed
		print(("Waited %* before disabling platform stand!"):format(totalWait))
		humanoid.PlatformStand = false
		local postHeartbeatPosition = primaryPart.Position
		print("post-hb: " .. tostring(primaryPart:GetVelocityAtPosition(postHeartbeatPosition)))
	end)
end

Reflect.defineMetadata(PlayerVelocityController, "identifier", "8kG")
Reflect.defineMetadata(PlayerVelocityController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PlayerVelocityController, "$:flamework@Controller", Controller, {})
return {
	["PlayerVelocityController"] = PlayerVelocityController,
}
