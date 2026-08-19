-- LobbyWorldController

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
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local Workspace: Workspace = Services.Workspace
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local globalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store")
local GlobalStore = globalStoreModule.GlobalStore
local GlobalStoreChanged = globalStoreModule.GlobalStoreChanged

type LobbyWorldController = {
	world: Instance?,
	LobbyWorldLoaded: any,
	setWorld: (self: LobbyWorldController, world: Instance) -> (),
	getWorld: (self: LobbyWorldController) -> Instance?,
	bindWorldLoaded: (self: LobbyWorldController, callback: (world: Instance, lobbyType: string) -> ()) -> any,
	handleLobbyVisibility: (self: LobbyWorldController) -> (),
	isInLobby: (self: LobbyWorldController, player: Player?) -> boolean,
}

local LobbyWorldController = setmetatable({}, {
	["__tostring"] = function()
		return "LobbyWorldController"
	end,
})
LobbyWorldController.__index = LobbyWorldController

function LobbyWorldController.new(...)
	local class = LobbyWorldController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function LobbyWorldController.constructor(self: LobbyWorldController)
	self.LobbyWorldLoaded = AsyncEvent.new()
end

function LobbyWorldController.onStart(self: LobbyWorldController)
	local lobby: Instance? = Workspace:WaitForChild("Lobby", 5)
	if lobby then
		self:setWorld(lobby)
	end
	Events.JoinWorld:connect(function(world)
		self:setWorld(world)
	end)
	self:bindWorldLoaded(function()
		return self:handleLobbyVisibility()
	end)
	Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Alive):Connect(function()
		return self:handleLobbyVisibility()
	end)
	Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Spectating):Connect(function()
		return self:handleLobbyVisibility()
	end)
	GlobalStoreChanged("GameState", function()
		return self:handleLobbyVisibility()
	end)
end

function LobbyWorldController.setWorld(self: LobbyWorldController, world: Instance)
	local lobbyType = world:GetAttribute(Attribute.LobbyType)
	self.world = world
	self.LobbyWorldLoaded:fire({
		["World"] = world,
		["LobbyType"] = lobbyType or "Lobby",
	})
end

function LobbyWorldController.getWorld(self: LobbyWorldController): Instance?
	return self.world
end

function LobbyWorldController.bindWorldLoaded(
	self: LobbyWorldController,
	callback: (world: Instance, lobbyType: string) -> ()
)
	if self.world then
		local lobbyType = self.world:GetAttribute(Attribute.LobbyType)
		callback(self.world, lobbyType or "Lobby")
	end
	return self.LobbyWorldLoaded:bind(function(worldData)
		callback(worldData.World, worldData.LobbyType)
	end)
end

function LobbyWorldController.handleLobbyVisibility(self: LobbyWorldController)
	if not self.world then
		return nil
	end
	if self:isInLobby() then
		if self.world.Parent then
			self.world.Parent = Workspace
			return
		end
	elseif self.world.Parent then
		self.world.Parent = ReplicatedStorage
	end
end

function LobbyWorldController.isInLobby(_, player: Player?): boolean
	if player == nil then
		player = Players.LocalPlayer
	end
	local gameState = GlobalStore:getState().GameState
	local isAlive = player:GetAttribute(Attribute.Alive) == true
	local isSpectating = player:GetAttribute(Attribute.Spectating) == true
	if gameState == GameState.Pregame or gameState == GameState.Ended then
		return true
	end
	local inLobby = not isAlive
	if inLobby then
		inLobby = not isSpectating
	end
	return inLobby
end

Reflect.defineMetadata(LobbyWorldController, "identifier", "Jj")
Reflect.defineMetadata(LobbyWorldController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(LobbyWorldController, "$:flamework@Controller", Controller, {})
return {
	["LobbyWorldController"] = LobbyWorldController,
}
