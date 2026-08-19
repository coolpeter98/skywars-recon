-- CameraController

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
local Util = RuntimeLib.import(script, script.Parent.Parent, "util", "util")
local AwaitCharacter = Util.AwaitCharacter
local GetCharacter = Util.GetCharacter
local GetHumanoid = Util.GetHumanoid
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local GuiService: GuiService = Services.GuiService
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local CrosshairScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "crosshair", "crosshair-screen").CrosshairScreen
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local UserGameSettings: UserGameSettings = UserSettings():GetService("UserGameSettings")

export type CameraController = {
	screenController: any,
	winEffectController: any,
	maid: any,
	locked: boolean,
	loadedStoreState: boolean,
	savedFrame: CFrame?,
}

local CameraController = setmetatable({}, {
	["__tostring"] = function()
		return "CameraController"
	end,
})
CameraController.__index = CameraController
function CameraController.new(...): CameraController
	local class = CameraController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end
function CameraController.constructor(self: CameraController, screenController, winEffectController)
	self.screenController = screenController
	self.winEffectController = winEffectController
	self.maid = Maid.new()
	self.locked = false
	self.loadedStoreState = false
end
function CameraController.onLobbyStart(self: CameraController, _)
	if InputUtil.isGamepadEnabled() then
		self:lockCamera()
	else
		self:unlockCamera()
	end
end
function CameraController.onGameStart(self: CameraController, task)
	self.loadedStoreState = false
	self:lockCamera()
	task:GiveTask(Events["570664b1-dc2e-44e1-a0e9-0dd4232eaec7"]:connect(function()
		local cameraSubject = Workspace.CurrentCamera.CameraSubject
		if cameraSubject and not cameraSubject:IsDescendantOf(Workspace) then
			print("Patching camera...")
			local humanoid = Players.LocalPlayer.Character
			if humanoid ~= nil then
				humanoid = humanoid:FindFirstChildOfClass("Humanoid")
			end
			Workspace.CurrentCamera.CameraSubject = humanoid
		end
	end))
	task:GiveTask(Events["570664b1-dc2e-44e1-a0e9-0dd4232eaec7"]:connect(function()
		self:handleInitialFirstPerson(true)
	end))
	self:handleInitialFirstPerson(false)
end
function CameraController.handleInitialFirstPerson(self: CameraController, isRespawn: boolean)
	if isRespawn then
		AwaitCharacter()
	end
	Flamework.resolveDependency("zG"):awaitLoadedProfile()
	if GlobalStore:getState().Profile.FirstPerson then
		self:enableFirstPerson()
	end
	self.loadedStoreState = true
end
function CameraController.cleanup(self: CameraController, lock: boolean)
	self.maid:DoCleaning()
	self.savedFrame = nil
	self.locked = lock
	self:bindToShiftLock()
end
function CameraController.bindCameraUpdate(self: CameraController, callback: () -> ()): Humanoid?
	local camera: Camera = Workspace.CurrentCamera
	self.maid:GiveTask(camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		callback()
	end))
	local cameraSubject = camera.CameraSubject
	if not cameraSubject then
		return nil
	end
	if not cameraSubject:IsA("Humanoid") then
		return nil
	end
	if not cameraSubject.Parent then
		self.maid:GiveTask(cameraSubject.AncestryChanged:Connect(function()
			callback()
		end))
		return nil
	end
	if cameraSubject.Parent and not cameraSubject.Parent:FindFirstChild("Head") then
		self.maid:GiveTask(cameraSubject.Parent.ChildAdded:Connect(function(child)
			if child.Name == "Head" then
				callback()
			end
		end))
		return nil
	end
	local head = cameraSubject.Parent:FindFirstChild("Head")
	self.maid:GiveTask(head.AncestryChanged:Connect(function()
		callback()
	end))
	return cameraSubject
end
function CameraController.handleFirstPerson(
	self: CameraController,
	humanoid: Humanoid,
	cameraSubject: Humanoid,
	character: Model,
	head: BasePart,
	callback: () -> ()
)
	self:manageCursorLocking()
	UserInputService.MouseIconEnabled = false
	if humanoid == cameraSubject then
		cameraSubject.AutoRotate = true
	end
	Flamework.resolveDependency("jE9"):addModifier("FirstPersonCamera", "Multiply", 1.28571429)
	self.maid:GiveTask(head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		if head.LocalTransparencyModifier ~= 1 then
			callback()
		end
	end))
	self.maid:GiveTask(character.DescendantAdded:Connect(function(descendant)
		local particle = descendant:IsA("ParticleEmitter")
		if particle then
			particle = descendant:GetAttribute(Attribute.CharacterParticle)
		end
		if particle ~= 0 and (particle == particle and (particle ~= "" and particle)) then
			descendant.Enabled = false
		end
	end))
	self:toggleCharacterParticles(character, false)
end
function CameraController.handleCrosshairVisibility(self: CameraController, isFirstPerson: boolean)
	local character = isFirstPerson
		and (not ScreenUtil.isMobile() and (not GuiService:IsTenFootInterface() and (Workspace.CurrentCamera.CameraSubject and Workspace.CurrentCamera.CameraSubject:IsA(
			"Humanoid"
		))))
		and Workspace.CurrentCamera.CameraSubject.Parent
	if character then
		self.maid:GiveTask(character.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") and not descendant:FindFirstAncestorWhichIsA("Tool") then
				descendant.LocalTransparencyModifier = 1
			end
		end))
	end
	self.maid:GiveTask(RunService.Heartbeat:Connect(function()
		local cursorLocked = self.screenController:isCursorLocked()
		local cameraOverride = self.screenController:isFocused() and not cursorLocked
			or self.winEffectController:isInWinEffect()
		if not cameraOverride then
			local primaryPart = Players.LocalPlayer.Character
			if primaryPart ~= nil then
				primaryPart = primaryPart.PrimaryPart
			end
			cameraOverride = not primaryPart
		end
		local isCameraUnlocked = not (self.locked or isFirstPerson)
		if isCameraUnlocked then
			isCameraUnlocked = not cursorLocked
		end
		if not (ScreenUtil.isMobile() or GuiService:IsTenFootInterface()) then
			if cameraOverride and isFirstPerson then
				Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				local cameraSubject = Workspace.CurrentCamera.CameraSubject
				if cameraSubject and (cameraSubject:IsA("Humanoid") and cameraSubject.RootPart) then
					local rootPart = cameraSubject.RootPart
					local heightOffset = (rootPart.Size.Y - 2) / 2
					local offset = Vector3.new(0, 1.5, 0) + Vector3.new(0, heightOffset, 0)
					local rotation = Workspace.CurrentCamera.CFrame - Workspace.CurrentCamera.CFrame.Position
					local lookOffset = Workspace.CurrentCamera.CFrame.LookVector * -0.5
					Workspace.CurrentCamera.CFrame = CFrame.new(rootPart.Position + offset) * rotation + lookOffset
				end
			else
				Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end
		end
		if cameraOverride then
			local userInputService = UserInputService
			local mouseBehavior
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
				mouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			else
				mouseBehavior = Enum.MouseBehavior.Default
			end
			userInputService.MouseBehavior = mouseBehavior
			UserInputService.MouseIconEnabled = not GuiService:IsTenFootInterface()
		elseif isCameraUnlocked then
			local userInputService = UserInputService
			local mouseBehavior
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
				mouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			else
				mouseBehavior = Enum.MouseBehavior.Default
			end
			userInputService.MouseBehavior = mouseBehavior
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
		if self.screenController:shouldHideCrosshair() or isCameraUnlocked then
			self:disableCrosshair()
		else
			self:enableCrosshair()
		end
	end))
end
function CameraController.lockCamera(self: CameraController)
	self:cleanup(true)
	local cameraSubject = self:bindCameraUpdate(function()
		return self:lockCamera()
	end)
	if not cameraSubject then
		self:disableCrosshair()
		self:handleCrosshairVisibility(false)
		return nil
	end
	local humanoid = GetHumanoid()
	local camera: Camera = Workspace.CurrentCamera
	local character = cameraSubject.Parent
	local head = character:FindFirstChild("Head")
	local firstPerson = head.LocalTransparencyModifier == 1
	if humanoid == cameraSubject and self.loadedStoreState then
		Events["f5483027-b2fd-46cc-8a19-14a5048ab33f"]:fire(firstPerson)
	end
	self:handleCrosshairVisibility(firstPerson)
	self:enableCrosshair()
	if firstPerson then
		self:handleFirstPerson(humanoid, cameraSubject, character, head, function()
			return self:lockCamera()
		end)
		return nil
	end
	self.maid:GiveTask(head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		if head.LocalTransparencyModifier == 1 then
			self:lockCamera()
		end
	end))
	self:toggleCharacterParticles(character, true)
	Flamework.resolveDependency("jE9"):removeModifier("FirstPersonCamera")
	UserGameSettings.RotationType = Enum.RotationType.CameraRelative
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	cameraSubject.AutoRotate = false
	self.maid:GiveTask(function()
		RunService:UnbindFromRenderStep("PreCamera")
		RunService:UnbindFromRenderStep("PostCamera")
	end)
	RunService:BindToRenderStep("PreCamera", Enum.RenderPriority.Camera.Value - 1, function()
		if self.savedFrame then
			camera.CFrame = self.savedFrame
		end
	end)
	RunService:BindToRenderStep("PostCamera", Enum.RenderPriority.Camera.Value + 1, function()
		if self.screenController:isCursorLocked() and self.savedFrame then
			camera.CFrame = self.savedFrame * CFrame.new(Vector3.new(2, 0, 0))
			return nil
		end
		self.savedFrame = camera.CFrame
		if humanoid == cameraSubject then
			local rootPart = humanoid.RootPart
			if not rootPart then
				return nil
			end
			local rootPartCFrame = rootPart.CFrame
			local _, _, _ = rootPartCFrame:ToOrientation()
			local _, yaw = camera.CFrame:ToOrientation()
			rootPart.CFrame = CFrame.new(rootPartCFrame.Position) * CFrame.Angles(0, yaw, 0)
		end
		camera.CFrame = camera.CFrame * CFrame.new(Vector3.new(2, 0, 0))
	end)
end
function CameraController.unlockCamera(self: CameraController)
	self:cleanup(false)
	local cameraSubject = self:bindCameraUpdate(function()
		return self:unlockCamera()
	end)
	if not cameraSubject then
		self:disableCrosshair()
		self:handleCrosshairVisibility(false)
		return nil
	end
	local humanoid = GetHumanoid()
	local _ = Workspace.CurrentCamera
	local character = cameraSubject.Parent
	local head = character:FindFirstChild("Head")
	local firstPerson = head.LocalTransparencyModifier == 1
	if humanoid == cameraSubject and self.loadedStoreState then
		Events["f5483027-b2fd-46cc-8a19-14a5048ab33f"]:fire(firstPerson)
	end
	self:handleCrosshairVisibility(firstPerson)
	self:enableCrosshair()
	if firstPerson then
		self:handleFirstPerson(humanoid, cameraSubject, character, head, function()
			return self:unlockCamera()
		end)
		return nil
	end
	UserInputService.MouseIconEnabled = true
	self.maid:GiveTask(head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		if head.LocalTransparencyModifier == 1 then
			self:unlockCamera()
		end
	end))
	self:toggleCharacterParticles(character, true)
	Flamework.resolveDependency("jE9"):removeModifier("FirstPersonCamera")
	UserGameSettings.RotationType = Enum.RotationType.MovementRelative
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	cameraSubject.AutoRotate = true
	self:manageCursorLocking()
end
function CameraController.manageCursorLocking(self: CameraController)
	local camera: Camera = Workspace.CurrentCamera
	self.maid:GiveTask(function()
		RunService:UnbindFromRenderStep("PostCamera")
	end)
	RunService:BindToRenderStep("PostCamera", Enum.RenderPriority.Camera.Value + 1, function()
		if self.screenController:isCursorLocked() and self.savedFrame then
			camera.CFrame = self.savedFrame
			return nil
		end
		self.savedFrame = camera.CFrame
	end)
end
function CameraController.bindToShiftLock(self: CameraController)
	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
		if gameProcessedEvent then
			return nil
		end
		if not InputUtil.isShiftLock(inputObject) then
			return nil
		end
		if self.screenController:isCursorLocked() then
			return nil
		end
		if Flamework.resolveDependency("dyD"):isInAnimation() then
			return nil
		end
		self:invertCameraLock()
	end))
end
function CameraController.invertCameraLock(self: CameraController)
	if self.locked then
		self:unlockCamera()
	else
		self:lockCamera()
	end
end
function CameraController.isCameraLocked(self: CameraController): boolean
	return self.locked
end
function CameraController.enableCrosshair(self: CameraController)
	if self.screenController:isOpen("Crosshair") then
		return nil
	end
	self.screenController:open(CrosshairScreen, {})
end
function CameraController.disableCrosshair(self: CameraController)
	if not self.screenController:isOpen("Crosshair") then
		return nil
	end
	self.screenController:close(CrosshairScreen)
end
function CameraController.enableFirstPerson(_)
	Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	task.defer(function()
		Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
	end)
end
function CameraController.enableThirdPerson(_)
	Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
	local cameraMinZoomDistance = Players.LocalPlayer.CameraMinZoomDistance
	Players.LocalPlayer.CameraMinZoomDistance = Players.LocalPlayer.CameraMaxZoomDistance
	task.defer(function()
		Players.LocalPlayer.CameraMinZoomDistance = cameraMinZoomDistance
	end)
end
function CameraController.toggleZoom(self: CameraController)
	local humanoid = GetHumanoid()
	if humanoid then
		local _ = Workspace.CurrentCamera
		local head = humanoid.Parent:FindFirstChild("Head")
		if head then
			if head.LocalTransparencyModifier == 1 then
				self:enableThirdPerson()
			else
				self:enableFirstPerson()
			end
		else
			return nil
		end
	else
		return nil
	end
end
function CameraController.toggleCharacterParticles(_, character: Model, enabled: boolean)
	local count = 0
	local particles = {}
	for index, descendant in character:GetDescendants() do
		local _ = index - 1
		local particle = descendant:IsA("ParticleEmitter")
		if particle then
			particle = descendant:GetAttribute(Attribute.CharacterParticle)
		end
		if particle == true then
			count = count + 1
			particles[count] = descendant
		end
	end
	for _, particleEmitter in particles do
		particleEmitter.Enabled = enabled
	end
end
function CameraController.isFirstPerson(_): boolean
	local character = GetCharacter()
	if character then
		local head = character:FindFirstChild("Head")
		if head then
			return head.LocalTransparencyModifier == 1
		else
			return false
		end
	else
		return false
	end
end
Reflect.defineMetadata(CameraController, "identifier", "VJk")
Reflect.defineMetadata(CameraController, "flamework:parameters", { "lB5", "XNg" })
Reflect.defineMetadata(CameraController, "flamework:implements", { "VNB", "09p" })
Reflect.decorate(CameraController, "$:flamework@Controller", Controller, {})
return {
	["CameraController"] = CameraController,
}
