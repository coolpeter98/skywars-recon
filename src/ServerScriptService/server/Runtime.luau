--!strict

local RemoteRegistry = require(script.Parent.RemoteRegistry)
local Outbound = require(script.Parent.Outbound)
local PlayerSessions = require(script.Parent.PlayerSessions)
local EventRouter = require(script.Parent.EventRouter)
local FunctionRouter = require(script.Parent.FunctionRouter)
local MatchmakingService = require(script.Parent.matchmaking.MatchmakingService)
local RuntimeContextService = require(script.Parent.matchmaking.RuntimeContextService)

local SessionHandlers = require(script.Parent.handlers.SessionHandlers)
local MatchmakingHandlers = require(script.Parent.handlers.MatchmakingHandlers)
local PartyHandlers = require(script.Parent.handlers.PartyHandlers)
local PrivateSessionHandlers = require(script.Parent.handlers.PrivateSessionHandlers)
local WorldHandlers = require(script.Parent.handlers.WorldHandlers)
local CombatHandlers = require(script.Parent.handlers.CombatHandlers)
local EconomyHandlers = require(script.Parent.handlers.EconomyHandlers)
local LegacyHandlers = require(script.Parent.handlers.LegacyHandlers)
local CustomServersService = require(script.Parent.functions.CustomServersService)

local Runtime = {}
Runtime.__index = Runtime

local function appendRoutes(destination, source)
	for _, route in source do
		table.insert(destination, route)
	end
end

function Runtime.new()
	local remoteRegistry = RemoteRegistry.new()
	local outbound = Outbound.new(remoteRegistry)
	local playerSessions = PlayerSessions.new(outbound)
	local runtimeContext = RuntimeContextService.new()
	local context = {
		outbound = outbound,
		playerSessions = playerSessions,
		runtimeContext = runtimeContext,
	}
	local matchmakingService = MatchmakingService.new(context)
	context.matchmakingService = matchmakingService
	local eventRoutes = {}
	appendRoutes(eventRoutes, SessionHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, MatchmakingHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, PartyHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, PrivateSessionHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, WorldHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, CombatHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, EconomyHandlers.new(context):getRoutes())
	appendRoutes(eventRoutes, LegacyHandlers.new(context):getRoutes())

	local functionRoutes = CustomServersService.new(context):getRoutes()
	return setmetatable({
		playerSessions = playerSessions,
		matchmakingService = matchmakingService,
		eventRouter = EventRouter.new(remoteRegistry, playerSessions, eventRoutes),
		functionRouter = FunctionRouter.new(remoteRegistry, playerSessions, functionRoutes),
		started = false,
	}, Runtime)
end

function Runtime.start(self)
	if self.started then
		return
	end
	self.matchmakingService:start()
	self.eventRouter:start()
	self.functionRouter:start()
	self.playerSessions:start()
	self.started = true
end

function Runtime.stop(self)
	if not self.started then
		return
	end
	self.matchmakingService:stop()
	self.playerSessions:stop()
	self.functionRouter:stop()
	self.eventRouter:stop()
	self.started = false
end

return Runtime
