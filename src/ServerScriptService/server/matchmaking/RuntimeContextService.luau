--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RuntimeContext = require(ReplicatedStorage.TS.place["runtime-context"]).RuntimeContext
local MatchmakingConfig = require(script.Parent.MatchmakingConfig)

export type GameContext = {
	Version: number,
	Role: string,
	GameMode: string?,
	QueueId: string?,
	MatchId: string?,
}

local RuntimeContextService = {}
RuntimeContextService.__index = RuntimeContextService

local function setAttribute(name: string, value: any?)
	ReplicatedStorage:SetAttribute(name, value)
end

function RuntimeContextService.new()
	local self = setmetatable({
		context = nil :: GameContext?,
	}, RuntimeContextService)
	local studioGameMode = if RunService:IsStudio()
		then ReplicatedStorage:GetAttribute(RuntimeContext.Attribute.StudioGameMode)
		else nil
	local studioModeConfig = if type(studioGameMode) == "string" then MatchmakingConfig.getMode(studioGameMode) else nil
	if studioModeConfig ~= nil then
		self:setGame(studioModeConfig.GameMode, studioModeConfig.QueueId, "studio-test")
		return self
	end
	self:setLobby()
	return self
end

function RuntimeContextService.apply(self, context: GameContext)
	self.context = context
	setAttribute(RuntimeContext.Attribute.Role, context.Role)
	setAttribute(RuntimeContext.Attribute.GameMode, context.GameMode)
	setAttribute(RuntimeContext.Attribute.QueueId, context.QueueId)
	setAttribute(RuntimeContext.Attribute.MatchId, context.MatchId)
	setAttribute(RuntimeContext.Attribute.Production, true)
end

function RuntimeContextService.setLobby(self)
	self:apply({
		Version = RuntimeContext.Version,
		Role = RuntimeContext.Role.Lobby,
	})
end

function RuntimeContextService.setGame(self, gameMode: string, queueId: string, matchId: string)
	self:apply({
		Version = RuntimeContext.Version,
		Role = RuntimeContext.Role.Game,
		GameMode = gameMode,
		QueueId = queueId,
		MatchId = matchId,
	})
end

function RuntimeContextService.setPrivate(self, gameMode: string, customGameId: string)
	self:apply({
		Version = RuntimeContext.Version,
		Role = RuntimeContext.Role.Private,
		GameMode = gameMode,
		QueueId = "private",
		MatchId = customGameId,
	})
end

function RuntimeContextService.configurePlayer(self, player: Player)
	local joinData = player:GetJoinData()
	local teleportData = joinData.TeleportData
	local incomingContext = type(teleportData) == "table" and teleportData[RuntimeContext.TeleportDataKey] or nil
	if type(incomingContext) ~= "table" or incomingContext.Version ~= RuntimeContext.Version then
		return
	end
	if incomingContext.Role == RuntimeContext.Role.Lobby then
		return
	end
	local modeConfig = type(incomingContext.GameMode) == "string"
			and MatchmakingConfig.getMode(incomingContext.GameMode)
		or nil
	if modeConfig == nil or type(incomingContext.MatchId) ~= "string" then
		warn(("[RuntimeContext] Rejected invalid teleport context from %s (%d)"):format(player.Name, player.UserId))
		return
	end
	if incomingContext.Role == RuntimeContext.Role.Private then
		if self.context ~= nil and self.context.Role == RuntimeContext.Role.Private then
			if self.context.MatchId ~= incomingContext.MatchId or self.context.GameMode ~= modeConfig.GameMode then
				player:Kick("This private server belongs to a different custom game.")
				return
			end
		end
		self:setPrivate(modeConfig.GameMode, incomingContext.MatchId)
		return
	end
	if incomingContext.Role ~= RuntimeContext.Role.Game then
		warn(("[RuntimeContext] Rejected invalid teleport role from %s (%d)"):format(player.Name, player.UserId))
		return
	end
	local context: GameContext = {
		Version = RuntimeContext.Version,
		Role = RuntimeContext.Role.Game,
		GameMode = modeConfig.GameMode,
		QueueId = modeConfig.QueueId,
		MatchId = incomingContext.MatchId,
	}
	if self.context ~= nil and self.context.Role == RuntimeContext.Role.Game then
		if self.context.MatchId ~= context.MatchId or self.context.GameMode ~= context.GameMode then
			player:Kick("This game server belongs to a different match.")
			return
		end
	end
	self:setGame(context.GameMode :: string, context.QueueId :: string, context.MatchId :: string)
end

function RuntimeContextService.get(self): GameContext
	return self.context :: GameContext
end

function RuntimeContextService.createGameTeleportData(self, gameMode: string, matchId: string): { [string]: any }
	return {
		[RuntimeContext.TeleportDataKey] = {
			Version = RuntimeContext.Version,
			Role = RuntimeContext.Role.Game,
			GameMode = gameMode,
			MatchId = matchId,
		},
	}
end

function RuntimeContextService.createPrivateTeleportData(
	self,
	gameMode: string,
	customGameId: string
): { [string]: any }
	return {
		[RuntimeContext.TeleportDataKey] = {
			Version = RuntimeContext.Version,
			Role = RuntimeContext.Role.Private,
			GameMode = gameMode,
			MatchId = customGameId,
		},
	}
end

function RuntimeContextService.createLobbyTeleportData(self): { [string]: any }
	return {
		[RuntimeContext.TeleportDataKey] = {
			Version = RuntimeContext.Version,
			Role = RuntimeContext.Role.Lobby,
		},
	}
end

return RuntimeContextService
