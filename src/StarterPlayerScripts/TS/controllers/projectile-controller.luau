-- ProjectileController

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Debris: Debris = Services.Debris
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GetCharacter: (player: Player?) -> Model? =
	RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetCharacter
local FastCast = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"fastcast",
	"src"
).default
local WorldConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "world", "world-constants").WorldConstants
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local drawProjectileTrajectory = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"util",
	"projectile-util"
).drawProjectileTrajectory
local QueryUtilModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "query-util")
local CombatRaycastType = QueryUtilModule.CombatRaycastType
local QueryUtil = QueryUtilModule.QueryUtil
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local CameraUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "camera-util").CameraUtil
local ProjectileConstants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"projectile",
	"projectile-constants"
).ProjectileConstants
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute

type ProjectileController = {
	sprintingController: any,
	fovController: any,
	inventoryController: any,
	humanoidController: any,
	cosmeticDecoratorModule: any,
	caster: any,
	maid: any,
	maidTwo: any,
	activeProjectiles: { [string]: any },
}

local ProjectileController = setmetatable({}, {
	["__tostring"] = function()
		return "ProjectileController"
	end,
})
ProjectileController.__index = ProjectileController

function ProjectileController.new(...): ProjectileController
	local class = ProjectileController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ProjectileController.constructor(
	self: ProjectileController,
	sprintingController,
	fovController,
	inventoryController,
	humanoidController,
	cosmeticDecoratorModule
)
	self.sprintingController = sprintingController
	self.fovController = fovController
	self.inventoryController = inventoryController
	self.humanoidController = humanoidController
	self.cosmeticDecoratorModule = cosmeticDecoratorModule
	self.caster = FastCast.new()
	self.maid = Maid.new()
	self.maidTwo = Maid.new()
	self.activeProjectiles = {}
end

function ProjectileController.onStart(self: ProjectileController)
	Events.ProjectileFired:connect(
		function(
			shooter: Player?,
			itemName: string,
			origin: Vector3,
			direction: Vector3,
			velocity: number,
			identifier: string,
			bulletTemplate: BasePart?,
			trailName: string?
		)
			self:projectileFired(shooter, itemName, origin, direction, velocity, identifier, bulletTemplate, trailName)
		end
	)
	Events.ProjectileTerminated:connect(function(identifier: string, finishSimulation: boolean)
		local activeProjectile = self.activeProjectiles[identifier]
		if not activeProjectile then
			return nil
		end
		self.activeProjectiles[identifier] = nil
		local cosmeticBullet = activeProjectile.RayInfo.CosmeticBulletObject
		if cosmeticBullet then
			local projectileData = Items[cosmeticBullet.Name].Projectile
			if projectileData.WeldOnCollide and finishSimulation then
				print("Allowing client to complete projectile simulation!")
				return nil
			end
			cosmeticBullet:SetAttribute(Attribute.Simulating, false)
			local impactSound = projectileData.ImpactSound
			if impactSound ~= "" and impactSound then
				Flamework.resolveDependency("jL9")
					:playSoundAtPosition(projectileData.ImpactSound, cosmeticBullet.Position, {
						["Volume"] = 0.8,
					})
			end
		end
		activeProjectile:Terminate()
	end)
	self.caster.RayHit:Connect(function(castRay, rayHit)
		local userData = castRay.UserData
		self.activeProjectiles[userData.Identifier] = nil
		local cosmeticBullet = castRay.RayInfo.CosmeticBulletObject
		if not cosmeticBullet then
			return nil
		end
		cosmeticBullet:SetAttribute(Attribute.Simulating, false)
		castRay.RayInfo.CosmeticBulletObject = nil
		local hitInstance = rayHit.Instance
		local projectileData = Items[cosmeticBullet.Name].Projectile
		local impactSound = projectileData.ImpactSound
		if impactSound ~= "" and impactSound then
			Flamework.resolveDependency("jL9"):playSoundAtPosition(projectileData.ImpactSound, rayHit.Position, {
				["Volume"] = 0.8,
			})
		end
		local weldOnCollide = userData.WeldOnCollide
		if weldOnCollide == nil then
			local defaultWeldOnCollide = projectileData.WeldOnCollide
			weldOnCollide = defaultWeldOnCollide == nil and true or defaultWeldOnCollide
		end
		if not weldOnCollide then
			cosmeticBullet:Destroy()
			return nil
		end
		local character = hitInstance:FindFirstAncestorWhichIsA("Model")
		if character and (character.PrimaryPart and Players:GetPlayerFromCharacter(character)) then
			cosmeticBullet:Destroy()
			return nil
		end
		local terminatedLifetime = userData.TerminatedBulletLifetime
		Debris:AddItem(cosmeticBullet, terminatedLifetime == nil and 30 or terminatedLifetime)
		local destroyConnection = nil
		destroyConnection = hitInstance.Destroying:Connect(function()
			destroyConnection:Disconnect()
			cosmeticBullet:Destroy()
		end)
	end)
	self.caster.CastTerminating:Connect(function(castRay)
		local userData = castRay.UserData
		self.activeProjectiles[userData.Identifier] = nil
		local cosmeticBullet = castRay.RayInfo.CosmeticBulletObject
		if cosmeticBullet ~= nil then
			cosmeticBullet:Destroy()
		end
	end)
	self.caster.LengthChanged:Connect(
		function(
			_,
			segmentOrigin: Vector3,
			segmentDirection: Vector3,
			segmentLength: number,
			_,
			lookPosition: BasePart?
		)
			if not (lookPosition and lookPosition:IsA("BasePart")) then
				return nil
			end
			local halfLength = lookPosition.Size.Z / 2
			local offset = CFrame.new(0, 0, -(segmentLength - halfLength))
			lookPosition.CFrame = CFrame.lookAt(segmentOrigin, segmentOrigin + segmentDirection):ToWorldSpace(offset)
				* CFrame.Angles(0, 3.141592653589793, 0)
		end
	)
	UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isPcInteract(inputObject) then
			return nil
		end
		self:chargeBow(inputObject)
	end)
end

function ProjectileController.projectileFired(
	self: ProjectileController,
	shooter: Player?,
	itemName: string,
	origin: Vector3,
	direction: Vector3,
	velocity: number,
	identifier: string,
	bulletTemplate: BasePart?,
	trailName: string?
)
	local projectileData = Items[itemName].Projectile
	local collidePlayers = projectileData.CollidePlayers
	local shouldCollidePlayers = collidePlayers == nil and true or collidePlayers
	local bullet = (bulletTemplate or projectileData.Ref):Clone()
	bullet.Name = projectileData.Ref.Name
	bullet.Size = bullet.Size * 1
	if projectileData.ParticleTrail then
		Flamework.resolveDependency("dm"):attachParticleEmitter(bullet, projectileData.ParticleTrail)
	end
	local flyingSound = projectileData.FlyingSound
	if flyingSound ~= "" and flyingSound then
		Flamework.resolveDependency("jL9"):playSoundAttachedToPart(projectileData.FlyingSound, bullet, {
			["Looped"] = true,
		})
	end
	local castBehavior = FastCast:newBehavior()
	castBehavior.RaycastParams =
		QueryUtil.getCombatRaycastParams(CombatRaycastType.RANGED, shooter, true, shouldCollidePlayers, false)
	castBehavior.Acceleration = projectileData.Acceleration or WorldConstants.WORLD_ACCELERATION
	castBehavior.AutoIgnoreContainer = false
	castBehavior.CosmeticBulletContainer = Workspace
	castBehavior.CosmeticBulletTemplate = bullet
	local castRay = self.caster:Fire(origin, direction.Unit, velocity, castBehavior)
	castRay.UserData = {
		["Identifier"] = identifier,
	}
	local cosmeticBullet = castRay.RayInfo.CosmeticBulletObject
	if cosmeticBullet then
		if shooter then
			cosmeticBullet:SetAttribute(Attribute.Shooter, shooter.UserId)
		end
		if trailName ~= "" and trailName then
			self:playTrailEffect(cosmeticBullet, trailName)
		end
		cosmeticBullet:SetAttribute(Attribute.Simulating, true)
	end
	self.activeProjectiles[identifier] = castRay
	return castRay
end

function ProjectileController.playTrailEffect(self: ProjectileController, bullet: BasePart, trailName: string)
	local arrowTrail = self.cosmeticDecoratorModule:resolveArrowTrail(trailName)
	local trailMaid = Maid.new()
	arrowTrail:playEffect(bullet, trailMaid)
	trailMaid:GiveTask(bullet:GetAttributeChangedSignal(Attribute.Simulating):Connect(function()
		if not bullet:GetAttribute(Attribute.Simulating) then
			trailMaid:DoCleaning()
		end
	end))
	trailMaid:GiveTask(bullet.Destroying:Connect(function()
		return trailMaid:DoCleaning()
	end))
end

function ProjectileController.chargeBow(self: ProjectileController, inputObject: InputObject)
	if not InputUtil.isWorldInteract(inputObject) then
		return nil
	end
	local heldItemInfo = Flamework.resolveDependency("Dqk"):getHeldItemInfo()
	local ranged
	if heldItemInfo == nil then
		ranged = heldItemInfo
	else
		ranged = heldItemInfo.Ranged
	end
	if not ranged then
		return nil
	end
	local itemName = heldItemInfo.Name
	local activeSkin
	if itemName == "" or not itemName then
		activeSkin = nil
	else
		activeSkin = Flamework.resolveDependency("Ggz"):getActiveSkinFromItem(heldItemInfo.Name)
	end
	local projectileAnimation = Flamework.resolveDependency("Ggz"):getProjectileAnimation(heldItemInfo, activeSkin)
	if not projectileAnimation then
		return nil
	end
	if Flamework.resolveDependency("LKE"):isOnCooldown(heldItemInfo.Name) then
		return nil
	end
	local requiresAmmo = heldItemInfo.Ranged.RequiresAmmo == nil and true or heldItemInfo.Ranged.RequiresAmmo
	local projectileType = heldItemInfo.Ranged.ProjectileType
	local projectileData = Items[projectileType].Projectile
	if requiresAmmo and not self.inventoryController:hasItem(projectileType) then
		return nil
	end
	local drawStartTime = os.clock()
	local drawTime = heldItemInfo.Ranged.DrawTime
	local drawDuration = drawTime == nil and 0.5 or drawTime
	local drawAnimationTrack = Flamework.resolveDependency("Kp")
		:playHumanoidAnimation(projectileAnimation.DrawAnimation, true)
	local currentTool = Players.LocalPlayer.Character
	if currentTool ~= nil then
		currentTool = currentTool:FindFirstChildOfClass("Tool")
	end
	local drawAnimationTool = projectileAnimation.DrawAnimationTool
	if drawAnimationTool ~= "" and drawAnimationTool then
		if currentTool then
			drawAnimationTool = currentTool.Name == heldItemInfo.Name
		else
			drawAnimationTool = currentTool
		end
	end
	if drawAnimationTool ~= "" and drawAnimationTool then
		local toolDrawTrack = Flamework.resolveDependency("Kp")
			:playAnimationTrack(currentTool, projectileAnimation.DrawAnimationTool, true)
		self.maid:GiveTask(function()
			toolDrawTrack:Stop()
			toolDrawTrack:Destroy()
		end)
	end
	local drawSound = projectileAnimation.DrawSound
	if drawSound ~= "" and drawSound then
		Flamework.resolveDependency("jL9"):playSound(projectileAnimation.DrawSound, {
			["Volume"] = 0.8,
		})
	end
	local releaseConnection = nil
	releaseConnection = inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
		if
			inputObject.UserInputState ~= Enum.UserInputState.End
			and inputObject.UserInputState ~= Enum.UserInputState.Cancel
		then
			return nil
		end
		releaseConnection:Disconnect()
		self.maid:DoCleaning()
		self.maidTwo:DoCleaning()
		self.sprintingController:setCanSprint(true)
		self.humanoidController:removeSpeedModifier("Projectile")
		self.fovController:removeModifier("ProjectileDraw", 0.05)
		if not GetCharacter() then
			return nil
		end
		local strength = ProjectileController:getStrength(drawStartTime, drawDuration)
		if strength < heldItemInfo.Ranged.MinimumDrawTime then
			return nil
		end
		local currentTool = Players.LocalPlayer.Character
		if currentTool ~= nil then
			currentTool = currentTool:FindFirstChildOfClass("Tool")
		end
		local animationUtil = Flamework.resolveDependency("Kp")
		local fireAnimation = projectileAnimation.FireAnimation
		local fireAnimationSpeed = projectileAnimation.FireAnimationSpeed
		animationUtil:playHumanoidAnimation(fireAnimation, false, fireAnimationSpeed == nil and 1 or fireAnimationSpeed)
		local fireAnimationTool = projectileAnimation.FireAnimationTool
		if fireAnimationTool ~= "" and fireAnimationTool then
			if currentTool then
				fireAnimationTool = currentTool.Name == heldItemInfo.Name
			else
				fireAnimationTool = currentTool
			end
		end
		if fireAnimationTool ~= "" and fireAnimationTool then
			Flamework.resolveDependency("Kp"):playAnimationTrack(currentTool, projectileAnimation.FireAnimationTool)
		end
		local direction
		if UserInputService.TouchEnabled then
			direction = CameraUtil.getDirection()
		else
			direction = CameraUtil.getCursorDirection()
		end
		local fireSound = projectileAnimation.FireSound
		if fireSound ~= "" and fireSound then
			Flamework.resolveDependency("jL9"):playSound(projectileAnimation.FireSound, {
				["Volume"] = 0.8,
			})
		end
		Events.FireProjectile:fire(direction, strength)
	end)
	self.maid:GiveTask(Flamework.resolveDependency("Dqk").ActiveItemUpdated:bind(function(activeItemUpdate)
		local heldItemInfo = activeItemUpdate.heldItemInfo
		if heldItemInfo and heldItemInfo.Ranged then
			return nil
		end
		releaseConnection:Disconnect()
		self.maid:DoCleaning()
		self.maidTwo:DoCleaning()
		self.sprintingController:setCanSprint(true)
		self.humanoidController:removeSpeedModifier("Projectile")
		self.fovController:removeModifier("ProjectileDraw", 0.05)
	end))
	if drawAnimationTrack then
		self.maid:GiveTask(function()
			drawAnimationTrack:Stop()
			drawAnimationTrack:Destroy()
		end)
	end
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		self.maidTwo:DoCleaning()
		local character = GetCharacter()
		if not character then
			return nil
		end
		local primaryPart = character.PrimaryPart
		if primaryPart ~= nil then
			primaryPart = primaryPart.CFrame
		end
		if not primaryPart then
			return nil
		end
		local direction
		if UserInputService.TouchEnabled then
			direction = CameraUtil.getDirection()
		else
			direction = CameraUtil.getCursorDirection()
		end
		local velocity = projectileData.Velocity
		local bulletSpeed = (velocity == nil and 200 or velocity)
			* ProjectileController:getStrength(drawStartTime, drawDuration)
		local origin = primaryPart * ProjectileConstants.ORIGIN_OFFSET
		for _, trailSegment in
			drawProjectileTrajectory(
				origin.Position,
				self:getPositionAtTime(
					2,
					origin.Position,
					direction * bulletSpeed,
					projectileData.Acceleration or WorldConstants.WORLD_ACCELERATION
				),
				self:getPositionAtTime(
					1,
					origin.Position,
					direction * bulletSpeed,
					projectileData.Acceleration or WorldConstants.WORLD_ACCELERATION
				)
			)
		do
			self.maidTwo:GiveTask(trailSegment)
		end
	end))
	self.sprintingController:setCanSprint(false)
	self.humanoidController:addSpeedModifier("Projectile", 0.5)
	self.fovController:addModifier("ProjectileDraw", "Sum", -25, 0.6, Enum.EasingStyle.Quad)
end

function ProjectileController.getStrength(_, drawStartTime: number, drawDuration: number): number
	local strength = (os.clock() - drawStartTime) / drawDuration
	return math.min(strength, 1)
end

function ProjectileController.getPositionAtTime(
	_,
	time: number,
	origin: Vector3,
	velocity: Vector3,
	acceleration: Vector3
): Vector3
	local offsetX = acceleration.X * math.pow(time, 2) / 2
	local offsetY = acceleration.Y * math.pow(time, 2) / 2
	local offsetZ = acceleration.Z * math.pow(time, 2) / 2
	local accelOffset = Vector3.new(offsetX, offsetY, offsetZ)
	return origin + velocity * time + accelOffset
end

Reflect.defineMetadata(ProjectileController, "identifier", "vmD")
Reflect.defineMetadata(ProjectileController, "flamework:parameters", {
	"a4X",
	"jE9",
	"qOA",
	"Zw",
	"Jkb",
})
Reflect.defineMetadata(ProjectileController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ProjectileController, "$:flamework@Controller", Controller, {})

return {
	["ProjectileController"] = ProjectileController,
}
