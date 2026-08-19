-- MatchmakingController

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
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local GlobalStoreChanged =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStoreChanged
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local AwaitPlayerRoot = RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitPlayerRoot
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local MatchmakingScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "matchmaking", "matchmaking-screen").MatchmakingScreen
local AbTestType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "ab-test", "ab-test-type").AbTestType
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local eggWarsQuads = GameMode.EggWarsQuads

type MatchmakingController = {
	new: (...any) -> MatchmakingController,
	constructor: (self: MatchmakingController, ...any) -> (),
	onStart: (self: MatchmakingController) -> (),
	inTest: (self: MatchmakingController) -> boolean,
	isInQueue: (self: MatchmakingController) -> boolean,
	canQueue: (self: MatchmakingController) -> boolean,
	joinQueueIn: (self: MatchmakingController, seconds: number) -> (),
	joinQueue: (self: MatchmakingController, gameMode) -> (),
	tryLeaveQueue: (self: MatchmakingController) -> (),
	leaveQueue: (self: MatchmakingController) -> (),
}

local MatchmakingController = setmetatable({}, {
	["__tostring"] = function()
		return "MatchmakingController"
	end,
})

MatchmakingController.__index = MatchmakingController

function MatchmakingController.new(...)
	local self = setmetatable({}, MatchmakingController)
	return self:constructor(...) or self
end

function MatchmakingController.constructor(_) end

function MatchmakingController.onStart(self)
	Flamework.resolveDependency("lB5"):open(MatchmakingScreen, {})
	Events["ae0850b0-3bd0-425e-81f9-6596cc0e07dd"]:connect(function(queueStarted)
		if queueStarted then
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Matchmaking.START)
			Flamework.resolveDependency("zG"):updateQueue(os.time(), true)
		else
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Matchmaking.CANCEL)
			Flamework.resolveDependency("zG"):updateQueue(nil, false)
		end
	end)
	if PlaceUtil.isLobbyServer() then
		task.spawn(function()
			if not Flamework.resolveDependency("Xlg"):didUseLoadingScreen() then
				AwaitPlayerRoot()
				if Players.LocalPlayer.GameplayPaused then
					Players.LocalPlayer:GetPropertyChangedSignal("GameplayPaused"):Wait()
				end
				if not Workspace.CurrentCamera.CameraSubject then
					Workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Wait()
				end
				Flamework.resolveDependency("zG"):awaitLoadedProfile()
				if self:inTest() then
					return nil
				end
				if Flamework.resolveDependency("7xl"):getSetting("AutoQueue") then
					self:joinQueueIn(10)
				end
			end
		end)
	end
	Events["9f5c434e-fb42-4611-ac9a-54862ba240e4"]:connect(function(matchFound)
		if matchFound then
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Matchmaking.SUCCESSFUL, {
				["SoundGroup"] = SoundGroupType.Ui,
			})
		end
	end)
	local isPartyOwner: boolean = PartyUtil.isOwnerId(Players.LocalPlayer.UserId, GlobalStore:getState().Party)
	GlobalStoreChanged("Party", function(_)
		if
			self:isInQueue()
			and (isPartyOwner and not PartyUtil.isOwnerId(Players.LocalPlayer.UserId, GlobalStore:getState().Party))
		then
			self:leaveQueue()
		end
		isPartyOwner = PartyUtil.isOwnerId(Players.LocalPlayer.UserId, GlobalStore:getState().Party)
	end)
	if not PlaceUtil.isGameServer() then
		return nil
	end
	Events["9a400992-3100-43ed-a02f-eb79f17bdd59"]:connect(function()
		self:joinQueueIn(6)
	end)
	Events["771c4840-8c4d-44dd-80fc-192c72e9b8a1"]:connect(function(players)
		local party = GlobalStore:getState().Party
		local localPlayer: Player = Players.LocalPlayer
		local shouldRequeue: boolean = table.find(players, localPlayer) ~= nil
		if shouldRequeue then
			shouldRequeue = #party.Players > 1 and Flamework.resolveDependency("7xl"):getSetting("AutoQueue")
			if shouldRequeue then
				shouldRequeue = not self:inTest()
			end
		end
		if shouldRequeue then
			self:joinQueueIn(6)
		end
	end)
	Flamework.resolveDependency("rB8").PlayerEliminated:bind(function(data)
		if data.Player ~= Players.LocalPlayer or GameConstants.NEW_WIN_EFFECT_ENABLED and data.GameEnding then
			return nil
		end
		if
			#GlobalStore:getState().Party.Players <= 1
			and (Flamework.resolveDependency("7xl"):getSetting("AutoQueue") and not self:inTest())
		then
			self:joinQueueIn(6)
		end
	end)
	if GameConstants.NEW_WIN_EFFECT_ENABLED then
		Flamework.resolveDependency("XNg").WinEffectEnded:bind(function()
			if Flamework.resolveDependency("7xl"):getSetting("AutoQueue") and not self:inTest() then
				self:joinQueueIn(6)
			end
		end)
	else
		Events["909525d9-f05b-422c-aec2-bc5caf93fea2"]:connect(function()
			if Flamework.resolveDependency("7xl"):getSetting("AutoQueue") and not self:inTest() then
				self:joinQueueIn(6)
			end
		end)
	end
end

function MatchmakingController.inTest(_)
	local isInTest: boolean = Flamework.resolveDependency("yAg"):isInTest(AbTestType.AutoQueue)
	if isInTest then
		isInTest = not GlobalStore:getState().Profile.InitialSession
	end
	return isInTest
end

function MatchmakingController.isInQueue(_)
	local queueStartTime = GlobalStore:getState().QueueStartTime
	if queueStartTime == 0 then
		queueStartTime = false
	elseif queueStartTime ~= queueStartTime then
		queueStartTime = false
	end
	return queueStartTime and true or false
end

function MatchmakingController.canQueue(_)
	local party = GlobalStore:getState().Party
	return PartyUtil.canQueue(PlayerUtil.toReplicated(Players.LocalPlayer), party)
end

function MatchmakingController.joinQueueIn(self, seconds: number)
	if PlaceUtil.getGameMode() == GameMode.DuelsSolo or PlaceUtil.getGameMode() == GameMode.DuelsDuos then
		return nil
	end
	if
		not self:isInQueue()
		and (
			self:canQueue()
			and not (Flamework.resolveDependency("mPW"):isTeleporting() or Flamework.resolveDependency("vbD"):isOpen())
		)
	then
		Flamework.resolveDependency("zG"):updateQueue(os.time() + seconds, false)
	end
end

function MatchmakingController.joinQueue(self, gameMode)
	if Flamework.resolveDependency("vbD"):isOpen() then
		return nil
	end
	if Flamework.resolveDependency("mPW"):isTeleporting() then
		return nil
	end
	if not self:canQueue() then
		return nil
	end
	local queueGameMode = gameMode or PlaceUtil.getGameMode() or eggWarsQuads
	print("Sending packet to join queue...")
	Events["e83ed51a-a6d6-4326-bc3f-c7add422229b"]:fire(true, queueGameMode)
end

function MatchmakingController.tryLeaveQueue(self)
	if not self:canQueue() then
		return nil
	end
	self:leaveQueue()
end

function MatchmakingController.leaveQueue(_)
	local queueStartTime = GlobalStore:getState().QueueStartTime
	local shouldLeaveQueue: boolean
	if queueStartTime == 0 or (queueStartTime ~= queueStartTime or not queueStartTime) then
		shouldLeaveQueue = false
	else
		shouldLeaveQueue = os.time() - queueStartTime >= 0
	end
	if shouldLeaveQueue then
		Events["e83ed51a-a6d6-4326-bc3f-c7add422229b"]:fire(false)
	elseif queueStartTime ~= nil then
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.Matchmaking.CANCEL)
		Flamework.resolveDependency("zG"):updateQueue(nil, false)
	end
end

Reflect.defineMetadata(MatchmakingController, "identifier", "MMv")
Reflect.defineMetadata(MatchmakingController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(MatchmakingController, "$:flamework@Controller", Controller, {})

return {
	["MatchmakingController"] = MatchmakingController,
}
