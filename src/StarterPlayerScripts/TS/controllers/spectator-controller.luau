-- SpectatorController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local StarterPlayer: StarterPlayer = Services.StarterPlayer
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local GetHumanoid = RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetHumanoid
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
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
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute

type SpectatorController = {
	SetSpectating: any,
	spectatingMaid: any,
	spectating: boolean,
	spectateTarget: Player?,
}

local SpectatorController = setmetatable({}, {
	["__tostring"] = function()
		return "SpectatorController"
	end,
})
SpectatorController.__index = SpectatorController
function SpectatorController.new(...)
	local self: SpectatorController = setmetatable({}, SpectatorController)
	return self:constructor(...) or self
end
function SpectatorController.constructor(self: SpectatorController)
	self.SetSpectating = AsyncEvent.new()
	self.spectatingMaid = Maid.new()
	self.spectating = false
end
function SpectatorController.onStart(self: SpectatorController)
	Events["b9b935e9-55ee-43ad-be87-84a7ef56cad9"]:connect(function(target, position, respawnTime)
		self:setSpectating(target, position)
		self.SetSpectating:fire({
			["spectating"] = true,
		})
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "RespawnTime",
			["Value"] = nil,
			["Value"] = respawnTime ~= nil and {
				["Time"] = os.clock() + respawnTime,
				["Delay"] = respawnTime,
			} or nil,
		})
	end)
	Events["98d1d5c5-45be-4173-9e49-0abd7cd7efb2"]:connect(function()
		self:stopSpectating()
	end)
	Flamework.resolveDependency("rB8").GameEnded:bind(function()
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "RespawnTime",
			["Value"] = nil,
		})
	end)
	Flamework.resolveDependency("rB8").PlayerEliminated:bind(function(playerEliminated)
		if Players.LocalPlayer == playerEliminated.Player then
			GlobalStore:dispatch({
				["type"] = "SetValue",
				["Key"] = "RespawnTime",
				["Value"] = nil,
			})
		end
	end)
	self.SetSpectating:bind(function(data)
		if data.spectating then
			Flamework.resolveDependency("lw"):disableProximityPrompts()
		else
			Flamework.resolveDependency("lw"):enableProximityPrompts()
		end
	end)
	RunService.Heartbeat:Connect(function()
		if not self.spectating then
			return nil
		end
		if self.spectateTarget then
			return nil
		end
		self:setSpectating(nil, Vector3.new())
	end)
	UserInputService.TouchTapInWorld:Connect(function(_, gameProcessed)
		if gameProcessed then
			return nil
		end
		self:handleSpectateInput()
	end)
	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed then
			return nil
		end
		if not (InputUtil.isWorldInteract(inputObject) and InputUtil.isPcInteract(inputObject)) then
			return nil
		end
		self:handleSpectateInput()
	end)
end
function SpectatorController.handleSpectateInput(self: SpectatorController)
	if not self.spectateTarget then
		return nil
	end
	local aliveCount = 0
	local alivePlayers = {}
	for index, player in Players:GetPlayers() do
		local _ = index - 1
		if self:isAlive(player) == true then
			aliveCount = aliveCount + 1
			alivePlayers[aliveCount] = player
		end
	end
	local candidateCount = 0
	local candidates = {}
	for index, player in alivePlayers do
		local _ = index - 1
		local hasCharacter
		if player.Character == nil or player.Character.PrimaryPart == nil then
			hasCharacter = false
		else
			hasCharacter = player.Character:FindFirstChildOfClass("Humanoid") ~= nil
		end
		if hasCharacter == true then
			candidateCount = candidateCount + 1
			candidates[candidateCount] = player
		end
	end
	table.sort(candidates, function(a, b)
		return a.UserId > b.UserId
	end)
	local currentTarget = self.spectateTarget
	local nextTarget = candidates[((table.find(candidates, currentTarget) or 0) - 1 + 1) % #candidates + 1]
	if nextTarget then
		self:attachCamera(nextTarget)
	end
end
function SpectatorController.startSpectating(self: SpectatorController)
	self:setSpectating(nil, nil)
end
function SpectatorController.stopSpectating(self: SpectatorController): boolean
	local wasSpectating = self.spectating
	self.spectating = false
	self:detachCamera()
	self.SetSpectating:fire({
		["spectating"] = false,
	})
	return wasSpectating
end
function SpectatorController.setSpectating(self: SpectatorController, target: Player?, position: Vector3?)
	self.spectating = true
	if target and self:attachCamera(target) then
		return nil
	end
	if position == nil then
		position = Vector3.new()
	end
	local aliveCount = 0
	local alivePlayers = {}
	for index, player in Players:GetPlayers() do
		local _ = index - 1
		if self:isAlive(player) == true then
			aliveCount = aliveCount + 1
			alivePlayers[aliveCount] = player
		end
	end
	local nearestPlayer = PlayerUtil.findNearestPlayer(alivePlayers, position, { Players.LocalPlayer })
	if nearestPlayer then
		self:attachCamera(nearestPlayer)
	end
end
function SpectatorController.attachCamera(self: SpectatorController, target: Player): boolean
	self.spectatingMaid:DoCleaning()
	Players.LocalPlayer.CameraMaxZoomDistance = StarterPlayer.CameraMaxZoomDistance * 1.25
	Players.LocalPlayer.CameraMinZoomDistance = Players.LocalPlayer.CameraMaxZoomDistance
	local currentCamera = Workspace.CurrentCamera
	local humanoid = GetHumanoid(target)
	if not self:isAlive(target) then
		return false
	end
	if not (currentCamera and (humanoid and (humanoid.RootPart and humanoid.RootPart.Parent))) then
		return false
	end
	self.spectatingMaid:GiveTask(humanoid.RootPart.Parent:GetPropertyChangedSignal("Parent"):Connect(function()
		self.spectateTarget = nil
		self.spectatingMaid:DoCleaning()
	end))
	self.spectatingMaid:GiveTask(humanoid.RootPart.Destroying:Connect(function()
		self.spectateTarget = nil
		self.spectatingMaid:DoCleaning()
	end))
	self.spectatingMaid:GiveTask(humanoid.Destroying:Connect(function()
		self.spectateTarget = nil
		self.spectatingMaid:DoCleaning()
	end))
	currentCamera.CameraSubject = humanoid
	currentCamera.CameraType = Enum.CameraType.Custom
	Events["365f4042-5ef0-46d4-96f7-154c0ef5f9ec"]:fire(target)
	self.spectateTarget = target
	Flamework.resolveDependency("zG"):setValue("Spectating", {
		["Name"] = target.DisplayName,
		["UserId"] = target.UserId,
	})
	return true
end
function SpectatorController.detachCamera(self: SpectatorController)
	Players.LocalPlayer.CameraMinZoomDistance = StarterPlayer.CameraMinZoomDistance
	Players.LocalPlayer.CameraMaxZoomDistance = StarterPlayer.CameraMaxZoomDistance
	Workspace.CurrentCamera.CameraSubject = GetHumanoid()
	self.spectateTarget = nil
	Flamework.resolveDependency("zG"):setValue("Spectating", nil)
end
function SpectatorController.getSpectating(self: SpectatorController): Player?
	return self.spectateTarget
end
function SpectatorController.isSpectating(self: SpectatorController): boolean
	return self.spectating
end
function SpectatorController.isAlive(_: SpectatorController, player: Player): boolean
	return player:GetAttribute(Attribute.Alive) == true
end
Reflect.defineMetadata(SpectatorController, "identifier", "1LA")
Reflect.defineMetadata(SpectatorController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(SpectatorController, "$:flamework@Controller", Controller, {})
return {
	["SpectatorController"] = SpectatorController,
}
