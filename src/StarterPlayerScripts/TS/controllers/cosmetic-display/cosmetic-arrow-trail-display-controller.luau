-- CosmeticArrowTrailDisplayController

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
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local CosmeticDisplayDecorator =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local ProjectileConstants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"projectile",
	"projectile-constants"
).ProjectileConstants
local HttpService: HttpService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).HttpService

type Maid = typeof(Maid.new())

local CosmeticArrowTrailDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticKillEffectDisplayController"
	end,
})
CosmeticArrowTrailDisplayController.__index = CosmeticArrowTrailDisplayController

function CosmeticArrowTrailDisplayController.new(...)
	local self = setmetatable({}, CosmeticArrowTrailDisplayController)
	return self:constructor(...) or self
end

function CosmeticArrowTrailDisplayController.constructor(_) end

function CosmeticArrowTrailDisplayController.equip(self, player: Player, cosmetic: string): Maid
	local maid = Maid.new()
	if Cosmetics[cosmetic].Type ~= "ArrowTrailEffect" or not player.Character then
		return maid
	end
	Flamework.resolveDependency("XbN"):equipTool(maid, player, Items.Bow, nil)
	self:createFireBowSchedule(maid, player, cosmetic)
	return maid
end

function CosmeticArrowTrailDisplayController.createFireBowSchedule(self, maid: Maid, player: Player, cosmetic: string)
	maid:GiveTask(ScheduleUtil.createSchedule(5, function()
		self:drawBow(player)
		if player.Character.Parent then
			self:fireBow(player, cosmetic)
		end
	end))
end

function CosmeticArrowTrailDisplayController.drawBow(self, player: Player)
	local itemData = Items.Bow.Ranged
	local animationTrack = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(itemData.Animation.DrawAnimation, true, 1, player.Character)
	local drawSound = itemData.Animation.DrawSound
	if drawSound ~= "" and drawSound then
		Flamework.resolveDependency("jL9"):playSound(itemData.Animation.DrawSound, {
			["Volume"] = 0.8,
		})
	end
	task.wait(2)
	if animationTrack then
		animationTrack:Stop()
		animationTrack:Destroy()
	end
end

function CosmeticArrowTrailDisplayController.fireBow(self, player: Player, cosmetic: string)
	local itemData = Items.Bow.Ranged
	local projectileType = itemData.ProjectileType
	local projectileData = Items[projectileType]
	if projectileData ~= nil then
		projectileData = projectileData.Projectile
	end
	local animationController = Flamework.resolveDependency("Kp")
	local fireAnimation = itemData.Animation.FireAnimation
	local fireAnimationSpeed = itemData.Animation.FireAnimationSpeed
	animationController:playHumanoidAnimation(
		fireAnimation,
		false,
		fireAnimationSpeed == nil and 1 or fireAnimationSpeed,
		player.Character
	)
	if not cosmetic then
		return nil
	end
	local bulletId = ("COSMETIC_DISPLAY_%*"):format((HttpService:GenerateGUID()))
	local originCframe = player.Character.PrimaryPart.CFrame * ProjectileConstants.ORIGIN_OFFSET
	local projectileVelocity = projectileData.Velocity
	local velocity = (projectileVelocity == nil and 200 or projectileVelocity) * 0.8
	local bullet = Flamework.resolveDependency("vmD"):projectileFired(
		nil,
		projectileType,
		originCframe.Position,
		Vector3.new(0, 2.5, -10),
		velocity,
		bulletId,
		nil,
		cosmetic
	)
	local userData = {}
	local existingUserData = bullet.UserData
	if existingUserData then
		for key, value in existingUserData do
			userData[key] = value
		end
	end
	userData.TerminatedBulletLifetime = 1
	bullet.UserData = userData
end

Reflect.defineMetadata(CosmeticArrowTrailDisplayController, "identifier", "Elz")
Reflect.defineMetadata(CosmeticArrowTrailDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticArrowTrailDisplayController, "MJo", CosmeticDisplayDecorator, { "ArrowTrailEffect" })
Reflect.decorate(CosmeticArrowTrailDisplayController, "$:flamework@Controller", Controller, {})

return {
	["CosmeticKillEffectDisplayController"] = CosmeticArrowTrailDisplayController,
}
