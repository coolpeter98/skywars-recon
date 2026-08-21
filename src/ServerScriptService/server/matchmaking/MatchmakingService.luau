--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalMatchmakingStore = require(script.Parent.LocalMatchmakingStore)
local MatchmakingConfig = require(script.Parent.MatchmakingConfig)
local MatchmakingStore = require(script.Parent.MatchmakingStore)

type QueueTicket = MatchmakingStore.QueueTicket
type MatchRecord = MatchmakingStore.MatchRecord
type ModeConfig = MatchmakingConfig.ModeConfig

type LocalTicket = {
	Id: string,
	GameMode: string,
	Players: { Player },
	UserIds: { number },
	MatchNotified: boolean,
	Teleporting: boolean,
}

local MatchmakingService = {}
MatchmakingService.__index = MatchmakingService

local function appendUnique(destination: { number }, seen: { [number]: boolean }, values: { number })
	for _, value in values do
		if not seen[value] then
			seen[value] = true
			table.insert(destination, value)
		end
	end
end

local function getTicketPlayerCount(ticket: QueueTicket): number
	return #ticket.UserIds
end

function MatchmakingService.new(context)
	local originJobId = game.JobId
	if originJobId == "" then
		originJobId = "studio:" .. HttpService:GenerateGUID(false)
	end
	local storeSuccess, store = pcall(MatchmakingStore.new)
	if not storeSuccess then
		if not RunService:IsStudio() then
			error(store)
		end
		warn("[Matchmaking] MemoryStoreService is unavailable; using the Studio-only in-memory queue.")
		store = LocalMatchmakingStore.new()
	end
	return setmetatable({
		context = context,
		store = store,
		originJobId = originJobId,
		localTickets = {} :: { [string]: LocalTicket },
		playerTicketIds = {} :: { [Player]: string },
		connections = {} :: { RBXScriptConnection },
		running = false,
	}, MatchmakingService)
end

function MatchmakingService.getPartyPlayers(self, player: Player, modeConfig: ModeConfig): ({ Player }?, string?)
	local session = self.context.playerSessions:require(player)
	local party = session.party
	if party.Owner.UserId ~= player.UserId then
		return nil, "Only the party owner can enter matchmaking."
	end
	if #party.Players > modeConfig.TeamSize then
		return nil, "This party is too large for the selected mode."
	end

	local partyPlayers: { Player } = {}
	for _, userId in party.Players do
		local partyPlayer = Players:GetPlayerByUserId(userId)
		if partyPlayer == nil or self.context.playerSessions:get(partyPlayer) == nil then
			return nil, "Every party member must be in the same server before queueing."
		end
		if self.playerTicketIds[partyPlayer] ~= nil then
			return nil, "A party member is already in a queue."
		end
		table.insert(partyPlayers, partyPlayer)
	end
	return partyPlayers, nil
end

function MatchmakingService.joinQueue(self, player: Player, joining: boolean, gameMode: string?)
	if not joining then
		self:cancelForPlayer(player)
		return
	end
	if gameMode == nil then
		gameMode = self.context.runtimeContext:get().GameMode
	end
	local modeConfig = gameMode and MatchmakingConfig.getMode(gameMode) or nil
	if modeConfig == nil then
		self.context.outbound:fire("QueueStarted", player, false)
		return
	end
	if self.playerTicketIds[player] ~= nil then
		self.context.outbound:fire("QueueStarted", player, true)
		return
	end

	local partyPlayers, partyError = self:getPartyPlayers(player, modeConfig)
	if partyPlayers == nil then
		warn(
			("[Matchmaking] %s (%d) could not queue: %s"):format(
				player.Name,
				player.UserId,
				partyError or "unknown error"
			)
		)
		self.context.outbound:fire("QueueStarted", player, false)
		return
	end

	local currentTime = os.time()
	local ticketId = HttpService:GenerateGUID(false)
	local userIds: { number } = {}
	for _, partyPlayer in partyPlayers do
		table.insert(userIds, partyPlayer.UserId)
	end
	table.sort(userIds)
	local ticket: QueueTicket = {
		Id = ticketId,
		GameMode = modeConfig.GameMode,
		OriginJobId = self.originJobId,
		UserIds = userIds,
		QueuedAt = currentTime,
		ExpiresAt = currentTime + MatchmakingConfig.TicketLifetime,
		Status = "Queued",
	}
	if not self.store:setTicket(ticket) or not self.store:enqueue(ticketId, modeConfig.GameMode) then
		self.store:updateTicket(ticketId, function(currentTicket)
			if currentTicket == nil then
				return nil
			end
			currentTicket.Status = "Cancelled"
			return currentTicket
		end)
		for _, partyPlayer in partyPlayers do
			self.context.outbound:fire("QueueStarted", partyPlayer, false)
		end
		return
	end

	local localTicket: LocalTicket = {
		Id = ticketId,
		GameMode = modeConfig.GameMode,
		Players = partyPlayers,
		UserIds = userIds,
		MatchNotified = false,
		Teleporting = false,
	}
	self.localTickets[ticketId] = localTicket
	for _, partyPlayer in partyPlayers do
		self.playerTicketIds[partyPlayer] = ticketId
		self.context.outbound:fire("QueueStarted", partyPlayer, true)
	end
end

function MatchmakingService.cancelForPlayer(self, player: Player)
	local ticketId = self.playerTicketIds[player]
	if ticketId == nil then
		self.context.outbound:fire("QueueStarted", player, false)
		return
	end
	self:cancelLocalTicket(ticketId)
end

function MatchmakingService.cancelLocalTicket(self, ticketId: string)
	local localTicket = self.localTickets[ticketId]
	if localTicket == nil or localTicket.Teleporting then
		return
	end
	self.store:updateTicket(ticketId, function(ticket)
		if ticket == nil or ticket.Status == "Matched" then
			return nil
		end
		ticket.Status = "Cancelled"
		ticket.ClaimId = nil
		ticket.ClaimExpiresAt = nil
		return ticket
	end)
	self:forgetLocalTicket(localTicket, true)
end

function MatchmakingService.forgetLocalTicket(self, localTicket: LocalTicket, notifyCancellation: boolean)
	self.localTickets[localTicket.Id] = nil
	for _, partyPlayer in localTicket.Players do
		if self.playerTicketIds[partyPlayer] == localTicket.Id then
			self.playerTicketIds[partyPlayer] = nil
		end
		if notifyCancellation and partyPlayer.Parent == Players then
			self.context.outbound:fire("QueueStarted", partyPlayer, false)
		end
	end
end

function MatchmakingService.requeueTickets(self, tickets: { QueueTicket })
	for _, ticket in tickets do
		self.store:enqueue(ticket.Id, ticket.GameMode)
	end
end

function MatchmakingService.tryClaimTicket(self, ticket: QueueTicket, claimId: string): QueueTicket?
	local currentTime = os.time()
	return self.store:updateTicket(ticket.Id, function(currentTicket)
		if currentTicket == nil or currentTicket.ExpiresAt <= currentTime then
			return nil
		end
		local claimExpired = currentTicket.Status == "Claimed"
			and (currentTicket.ClaimExpiresAt == nil or currentTicket.ClaimExpiresAt <= currentTime)
		if currentTicket.Status ~= "Queued" and not claimExpired then
			return nil
		end
		currentTicket.Status = "Claimed"
		currentTicket.ClaimId = claimId
		currentTicket.ClaimExpiresAt = currentTime + MatchmakingConfig.CoordinatorLeaseDuration
		return currentTicket
	end)
end

function MatchmakingService.releaseClaims(self, tickets: { QueueTicket }, claimId: string)
	for _, ticket in tickets do
		self.store:updateTicket(ticket.Id, function(currentTicket)
			if currentTicket == nil or currentTicket.Status ~= "Claimed" or currentTicket.ClaimId ~= claimId then
				return nil
			end
			currentTicket.Status = "Queued"
			currentTicket.ClaimId = nil
			currentTicket.ClaimExpiresAt = nil
			return currentTicket
		end)
	end
	self:requeueTickets(tickets)
end

function MatchmakingService.selectTickets(
	self,
	modeConfig: ModeConfig,
	candidates: { QueueTicket }
): ({ QueueTicket }, { QueueTicket }, number)
	local selected: { QueueTicket } = {}
	local deferred: { QueueTicket } = {}
	local selectedPlayers = 0
	for _, ticket in candidates do
		local ticketPlayers = getTicketPlayerCount(ticket)
		if selectedPlayers + ticketPlayers <= modeConfig.MaximumPlayers then
			table.insert(selected, ticket)
			selectedPlayers += ticketPlayers
		else
			table.insert(deferred, ticket)
		end
	end
	return selected, deferred, selectedPlayers
end

function MatchmakingService.shouldCreateMatch(
	self,
	modeConfig: ModeConfig,
	selected: { QueueTicket },
	selectedPlayers: number
): boolean
	if selectedPlayers >= modeConfig.MaximumPlayers then
		return true
	end
	if selectedPlayers < modeConfig.MinimumPlayers or #selected == 0 then
		return false
	end
	local oldestQueuedAt = selected[1].QueuedAt
	for index = 2, #selected do
		oldestQueuedAt = math.min(oldestQueuedAt, selected[index].QueuedAt)
	end
	return os.time() - oldestQueuedAt >= MatchmakingConfig.MaximumWaitTime
end

function MatchmakingService.reserveServer(self): (string?, string?)
	local lastMessage: any = nil
	for _, delaySeconds in MatchmakingConfig.RetryDelays do
		if delaySeconds > 0 then
			task.wait(delaySeconds)
		end
		local success, reservation = pcall(function()
			return table.pack(TeleportService:ReserveServerAsync(game.PlaceId))
		end)
		if success then
			return reservation[1], reservation[2]
		end
		lastMessage = reservation
	end
	warn(("[Matchmaking] Failed to reserve a server: %s"):format(tostring(lastMessage)))
	return nil, nil
end

function MatchmakingService.createMatch(self, modeConfig: ModeConfig, tickets: { QueueTicket }): boolean
	local matchId = HttpService:GenerateGUID(false)
	local claimed: { QueueTicket } = {}
	for _, ticket in tickets do
		local claimedTicket = self:tryClaimTicket(ticket, matchId)
		if claimedTicket == nil then
			self:releaseClaims(claimed, matchId)
			return false
		end
		table.insert(claimed, claimedTicket)
	end

	local accessCode, privateServerId = self:reserveServer()
	if accessCode == nil or privateServerId == nil then
		self:releaseClaims(claimed, matchId)
		return false
	end

	local ticketIds: { string } = {}
	local userIds: { number } = {}
	local seenUserIds: { [number]: boolean } = {}
	for _, ticket in claimed do
		table.insert(ticketIds, ticket.Id)
		appendUnique(userIds, seenUserIds, ticket.UserIds)
	end
	local matchRecord: MatchRecord = {
		Id = matchId,
		GameMode = modeConfig.GameMode,
		QueueId = modeConfig.QueueId,
		AccessCode = accessCode,
		PrivateServerId = privateServerId,
		TicketIds = ticketIds,
		UserIds = userIds,
		CreatedAt = os.time(),
	}
	if not self.store:setMatch(matchRecord) then
		self:releaseClaims(claimed, matchId)
		return false
	end

	local finalized = true
	for _, ticket in claimed do
		local matchedTicket = self.store:updateTicket(ticket.Id, function(currentTicket)
			if currentTicket == nil or currentTicket.Status ~= "Claimed" or currentTicket.ClaimId ~= matchId then
				return nil
			end
			currentTicket.Status = "Matched"
			currentTicket.MatchId = matchId
			currentTicket.ClaimId = nil
			currentTicket.ClaimExpiresAt = nil
			return currentTicket
		end)
		if matchedTicket == nil then
			finalized = false
		end
	end
	return finalized
end

function MatchmakingService.configureReservedServer(self)
	if game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then
		return
	end
	local matchRecord = self.store:getMatchForPrivateServer(game.PrivateServerId)
	if matchRecord == nil then
		warn(("[Matchmaking] Reserved server %s has no active match record."):format(game.PrivateServerId))
		return
	end
	self.context.runtimeContext:setGame(matchRecord.GameMode, matchRecord.QueueId, matchRecord.Id)
end

function MatchmakingService.validateAdmission(self, player: Player)
	-- Studio game-context overrides have no reserved-server match record.
	if RunService:IsStudio() then
		return
	end
	local runtimeContext = self.context.runtimeContext:get()
	if runtimeContext.Role ~= "Game" or runtimeContext.MatchId == nil then
		return
	end
	local matchRecord = self.store:getMatch(runtimeContext.MatchId)
	if
		matchRecord == nil
		or matchRecord.GameMode ~= runtimeContext.GameMode
		or table.find(matchRecord.UserIds, player.UserId) == nil
	then
		player:Kick("You are not a member of this match.")
	end
end

function MatchmakingService.processMode(self, gameMode: string)
	local modeConfig = MatchmakingConfig.getMode(gameMode)
	if modeConfig == nil or not self.store:acquireCoordinatorLease(gameMode, self.originJobId) then
		return
	end
	local success, queueItems, readId = self.store:read(gameMode, modeConfig.MaximumPlayers)
	if not success or #queueItems == 0 then
		return
	end

	local candidates: { QueueTicket } = {}
	local seenTicketIds: { [string]: boolean } = {}
	local currentTime = os.time()
	for _, queueItem in queueItems do
		local ticketId = type(queueItem) == "table" and queueItem.TicketId or nil
		if type(ticketId) == "string" and not seenTicketIds[ticketId] then
			seenTicketIds[ticketId] = true
			local ticket = self.store:getTicket(ticketId)
			if
				ticket ~= nil
				and ticket.GameMode == gameMode
				and ticket.ExpiresAt > currentTime
				and (
					ticket.Status == "Queued"
					or ticket.Status == "Claimed" and (ticket.ClaimExpiresAt or 0) <= currentTime
				)
			then
				table.insert(candidates, ticket)
			end
		end
	end

	local selected, deferred, selectedPlayers = self:selectTickets(modeConfig, candidates)
	if self:shouldCreateMatch(modeConfig, selected, selectedPlayers) then
		local created = self:createMatch(modeConfig, selected)
		if not created then
			self:requeueTickets(selected)
		end
	else
		self:requeueTickets(selected)
	end
	self:requeueTickets(deferred)
	self.store:acknowledge(gameMode, readId)
end

function MatchmakingService.hasLocalTicketForMode(self, gameMode: string): boolean
	for _, localTicket in self.localTickets do
		if localTicket.GameMode == gameMode and not localTicket.MatchNotified and not localTicket.Teleporting then
			return true
		end
	end
	return false
end

function MatchmakingService.transferTicket(self, localTicket: LocalTicket, matchRecord: MatchRecord)
	if localTicket.Teleporting then
		return
	end
	localTicket.MatchNotified = true
	local teleportPlayers: { Player } = {}
	for _, partyPlayer in localTicket.Players do
		if partyPlayer.Parent == Players then
			table.insert(teleportPlayers, partyPlayer)
			self.context.outbound:fire("MatchFound", partyPlayer, true)
		end
	end
	if #teleportPlayers == 0 then
		self:forgetLocalTicket(localTicket, false)
		return
	end

	localTicket.Teleporting = true
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = matchRecord.AccessCode
	teleportOptions:SetTeleportData(
		self.context.runtimeContext:createGameTeleportData(localTicket.GameMode, matchRecord.Id)
	)
	local success, message = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, teleportPlayers, teleportOptions)
	end)
	if not success then
		localTicket.Teleporting = false
		localTicket.MatchNotified = false
		warn(("[Matchmaking] Teleport failed for ticket %s: %s"):format(localTicket.Id, tostring(message)))
		for _, partyPlayer in teleportPlayers do
			self.context.outbound:fire("TeleportFinished", partyPlayer)
		end
	end
end

function MatchmakingService.pollAssignments(self)
	for _, localTicket in self.localTickets do
		if not localTicket.Teleporting then
			local ticket = self.store:getTicket(localTicket.Id)
			if ticket == nil or ticket.Status == "Cancelled" or ticket.ExpiresAt <= os.time() then
				self:forgetLocalTicket(localTicket, true)
			elseif ticket.Status == "Matched" and ticket.MatchId ~= nil then
				local matchRecord = self.store:getMatch(ticket.MatchId)
				if matchRecord ~= nil then
					self:transferTicket(localTicket, matchRecord)
				end
			end
		end
	end
end

function MatchmakingService.teleportToLobby(self, player: Player)
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions:SetTeleportData(self.context.runtimeContext:createLobbyTeleportData())
	local success, message = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, { player }, teleportOptions)
	end)
	if not success then
		warn(
			("[Matchmaking] Lobby teleport failed for %s (%d): %s"):format(
				player.Name,
				player.UserId,
				tostring(message)
			)
		)
		self.context.outbound:fire("TeleportFinished", player)
	end
end

function MatchmakingService.onPlayerRemoving(self, player: Player)
	local ticketId = self.playerTicketIds[player]
	if ticketId == nil then
		return
	end
	local localTicket = self.localTickets[ticketId]
	if localTicket ~= nil and not localTicket.Teleporting then
		self:cancelLocalTicket(ticketId)
	end
end

function MatchmakingService.start(self)
	if self.running then
		return
	end
	self.running = true
	self:configureReservedServer()
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			self.context.runtimeContext:configurePlayer(player)
			task.spawn(function()
				self:validateAdmission(player)
			end)
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			self:onPlayerRemoving(player)
		end)
	)
	for _, player in Players:GetPlayers() do
		self.context.runtimeContext:configurePlayer(player)
		task.spawn(function()
			self:validateAdmission(player)
		end)
	end

	task.spawn(function()
		while self.running do
			self:pollAssignments()
			task.wait(MatchmakingConfig.PollInterval)
		end
	end)
	task.spawn(function()
		while self.running do
			for _, gameMode in MatchmakingConfig.ModeOrder do
				if self:hasLocalTicketForMode(gameMode) then
					self:processMode(gameMode)
				end
			end
			task.wait(MatchmakingConfig.WorkerInterval)
		end
	end)
end

function MatchmakingService.stop(self)
	self.running = false
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	for ticketId, localTicket in self.localTickets do
		if not localTicket.Teleporting then
			self:cancelLocalTicket(ticketId)
		end
	end
	table.clear(self.localTickets)
	table.clear(self.playerTicketIds)
end

return MatchmakingService
