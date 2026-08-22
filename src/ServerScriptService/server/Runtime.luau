--!strict

local RemoteRegistry = require(script.Parent.RemoteRegistry)
local Outbound = require(script.Parent.Outbound)
local PlayerSessions = require(script.Parent.PlayerSessions)
local EventRouter = require(script.Parent.EventRouter)
local FunctionRouter = require(script.Parent.FunctionRouter)
local InventoryService = require(script.Parent.inventory.InventoryService)
local CombatService = require(script.Parent.combat.CombatService)
local RegenerationService = require(script.Parent.combat.RegenerationService)
local ProjectileService = require(script.Parent.projectile.ProjectileService)
local PowerUpService = require(script.Parent.powerup.PowerUpService)
local MatchmakingService = require(script.Parent.matchmaking.MatchmakingService)
local RuntimeContextService = require(script.Parent.matchmaking.RuntimeContextService)
local PartyService = require(script.Parent.party.PartyService)
local CustomGameService = require(script.Parent.custom.CustomGameService)
local BlockWorldService = require(script.Parent.world.BlockWorldService)
local KillLog = require(script.Parent.logging.KillLog)
local NametagService = require(script.Parent.character.NametagService)

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
		killLog = KillLog.new(),
	}
	local partyService = PartyService.new(context)
	context.partyService = partyService
	local customGameService = CustomGameService.new(context)
	context.customGameService = customGameService
	local matchmakingService = MatchmakingService.new(context)
	context.matchmakingService = matchmakingService
	local inventoryService = InventoryService.new(context)
	context.inventoryService = inventoryService
	local combatService = CombatService.new(context)
	context.combatService = combatService
	local projectileService = ProjectileService.new(context)
	context.projectileService = projectileService
	local powerUpService = PowerUpService.new(context)
	context.powerUpService = powerUpService
	local regenerationService = RegenerationService.new(context)
	context.regenerationService = regenerationService
	local blockWorldService = BlockWorldService.new(context)
	context.blockWorldService = blockWorldService
	local nametagService = NametagService.new(context)
	context.nametagService = nametagService
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
		partyService = partyService,
		customGameService = customGameService,
		inventoryService = inventoryService,
		combatService = combatService,
		projectileService = projectileService,
		powerUpService = powerUpService,
		regenerationService = regenerationService,
		blockWorldService = blockWorldService,
		nametagService = nametagService,
		matchmakingService = matchmakingService,
		killLog = context.killLog,
		eventRouter = EventRouter.new(remoteRegistry, playerSessions, eventRoutes),
		functionRouter = FunctionRouter.new(remoteRegistry, playerSessions, functionRoutes),
		started = false,
	}, Runtime)
end

function Runtime.start(self)
	if self.started then
		return
	end
	self.partyService:start()
	self.customGameService:start()
	self.matchmakingService:start()
	self.inventoryService:start()
	self.combatService:start()
	self.projectileService:start()
	self.powerUpService:start()
	self.regenerationService:start()
	self.blockWorldService:start()
	self.eventRouter:start()
	self.functionRouter:start()
	self.playerSessions:start()
	self.nametagService:start()
	self.started = true
end

function Runtime.stop(self)
	if not self.started then
		return
	end
	self.customGameService:stop()
	self.partyService:stop()
	self.matchmakingService:stop()
	self.projectileService:stop()
	self.powerUpService:stop()
	self.regenerationService:stop()
	self.combatService:stop()
	self.blockWorldService:stop()
	self.inventoryService:stop()
	self.playerSessions:stop()
	self.nametagService:stop()
	self.functionRouter:stop()
	self.eventRouter:stop()
	self.started = false
end

return Runtime
