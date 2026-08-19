-- TeleController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local TeleportService: TeleportService = Services.TeleportService
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local PartyUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local SoundGroupType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local PlayerUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local LoadingScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "loading", "loading-screen").LoadingScreen

type TeleController = {
	screenController: any,
	teleporting: boolean,
}

local TeleController = setmetatable({}, {
	["__tostring"] = function()
		return "TeleController"
	end
})
TeleController.__index = TeleController
function TeleController.new(...)
	local class = TeleController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end
function TeleController.constructor(self: TeleController, screenController: any)
	self.screenController = screenController
	self.teleporting = false
end
function TeleController.onStart(self: TeleController)
	Events["9f5c434e-fb42-4611-ac9a-54862ba240e4"]:connect(function()
		self:setupTeleportGui()
	end)
	Events["278a3433-e8c3-4e94-b450-290da77f88b5"]:connect(function()
		if self.teleporting then
			Flamework.resolveDependency("jL9"):startSound()
			self.teleporting = false
			self.screenController:close(LoadingScreen)
		end
	end)
end
function TeleController.isTeleporting(self: TeleController): boolean
	return self.teleporting
end
function TeleController.teleportToHub(self: TeleController)
	if self.teleporting then
		return nil
	end
	local partyState = GlobalStore:getState().Party
	if not PartyUtil.isHostingMultiplayerParty(PlayerUtil.toReplicated(Players.LocalPlayer), partyState) then
		Flamework.resolveDependency("PrB"):leaveParty()
	end
	Events["b4c1dd39-7e8d-4484-b4e7-c3bb0475d92c"]:fire()
end
function TeleController.teleportToHubInstance(self: TeleController, instanceId: string, customLoadingScreen: Instance?)
	if self.teleporting then
		return nil
	end
	RuntimeLib.try(function()
		self:setupTeleportGui()
		Events["3f765989-4b02-4e6d-b33f-33a90e0a9e63"]:fire()
		TeleportService:TeleportToPlaceInstance(PlaceUtil.getLobbyId(), instanceId, Players.LocalPlayer, nil, customLoadingScreen)
	end, function(err)
		print(err)
	end)
end
function TeleController.setupTeleportGui(self: TeleController)
	Flamework.resolveDependency("jL9"):stopSound(SoundGroupType.World)
	Flamework.resolveDependency("jL9"):stopSound(SoundGroupType.Music)
	self.teleporting = true
	self.screenController:open(LoadingScreen, {})
	local loadingScreen = Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen")
	print((("SetTeleportGui %*"):format(loadingScreen)))
	TeleportService:SetTeleportGui(loadingScreen)
end
Reflect.defineMetadata(TeleController, "identifier", "mPW")
Reflect.defineMetadata(TeleController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(TeleController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(TeleController, "$:flamework@Controller", Controller, {})
return {
	["TeleController"] = TeleController
}
