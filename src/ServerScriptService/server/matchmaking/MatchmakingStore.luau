--!strict

local MemoryStoreService = game:GetService("MemoryStoreService")

local MatchmakingConfig = require(script.Parent.MatchmakingConfig)

export type QueueTicket = {
	Id: string,
	GameMode: string,
	OriginJobId: string,
	UserIds: { number },
	QueuedAt: number,
	ExpiresAt: number,
	Status: "Queued" | "Claimed" | "Matched" | "Cancelled",
	ClaimId: string?,
	ClaimExpiresAt: number?,
	MatchId: string?,
}

export type MatchRecord = {
	Id: string,
	GameMode: string,
	QueueId: string,
	AccessCode: string,
	PrivateServerId: string,
	TicketIds: { string },
	UserIds: { number },
	CreatedAt: number,
}

type QueueItem = {
	TicketId: string,
}

local MatchmakingStore = {}
MatchmakingStore.__index = MatchmakingStore

local function warnFailure(operation: string, message: any)
	warn(("[MatchmakingStore] %s failed: %s"):format(operation, tostring(message)))
end

function MatchmakingStore.new()
	return setmetatable({
		records = MemoryStoreService:GetHashMap(MatchmakingConfig.StoreNamespace .. ":records"),
		queues = {} :: { [string]: MemoryStoreQueue },
	}, MatchmakingStore)
end

function MatchmakingStore.getQueue(self, gameMode: string): MemoryStoreQueue
	local queue = self.queues[gameMode]
	if queue == nil then
		queue = MemoryStoreService:GetQueue(
			MatchmakingConfig.StoreNamespace .. ":queue:" .. gameMode,
			MatchmakingConfig.QueueInvisibilityTimeout
		)
		self.queues[gameMode] = queue
	end
	return queue
end

function MatchmakingStore.retry(self, operation: string, callback: () -> any): (boolean, any)
	local lastMessage: any = nil
	for _, delaySeconds in MatchmakingConfig.RetryDelays do
		if delaySeconds > 0 then
			task.wait(delaySeconds)
		end
		local result = table.pack(pcall(callback))
		if result[1] then
			return true, result[2]
		end
		lastMessage = result[2]
	end
	warnFailure(operation, lastMessage)
	return false, lastMessage
end

function MatchmakingStore.enqueue(self, ticketId: string, gameMode: string): boolean
	local success = self:retry("enqueue " .. ticketId, function()
		self:getQueue(gameMode):AddAsync({ TicketId = ticketId }, MatchmakingConfig.TicketLifetime, 0)
	end)
	return success
end

function MatchmakingStore.read(self, gameMode: string, count: number): (boolean, { QueueItem }, string?)
	local success, packedResult = self:retry("read " .. gameMode, function()
		return table.pack(self:getQueue(gameMode):ReadAsync(count, false, 0))
	end)
	if not success then
		return false, {}, nil
	end
	return true, packedResult[1] or {}, packedResult[2]
end

function MatchmakingStore.acknowledge(self, gameMode: string, readId: string?): boolean
	if readId == nil then
		return true
	end
	local success = self:retry("acknowledge " .. gameMode, function()
		self:getQueue(gameMode):RemoveAsync(readId)
	end)
	return success
end

function MatchmakingStore.setTicket(self, ticket: QueueTicket): boolean
	local success = self:retry("write ticket " .. ticket.Id, function()
		self.records:SetAsync("ticket:" .. ticket.Id, ticket, MatchmakingConfig.TicketLifetime)
	end)
	return success
end

function MatchmakingStore.getTicket(self, ticketId: string): QueueTicket?
	local success, ticket = self:retry("read ticket " .. ticketId, function()
		return self.records:GetAsync("ticket:" .. ticketId)
	end)
	return success and ticket or nil
end

function MatchmakingStore.updateTicket(self, ticketId: string, transform: (QueueTicket?) -> QueueTicket?): QueueTicket?
	local success, ticket = self:retry("update ticket " .. ticketId, function()
		return self.records:UpdateAsync("ticket:" .. ticketId, transform, MatchmakingConfig.TicketLifetime)
	end)
	return success and ticket or nil
end

function MatchmakingStore.setMatch(self, matchRecord: MatchRecord): boolean
	local matchSuccess = self:retry("write match " .. matchRecord.Id, function()
		self.records:SetAsync("match:" .. matchRecord.Id, matchRecord, MatchmakingConfig.MatchLifetime)
	end)
	if not matchSuccess then
		return false
	end
	local indexSuccess = self:retry("index private server " .. matchRecord.PrivateServerId, function()
		self.records:SetAsync(
			"private-server:" .. matchRecord.PrivateServerId,
			matchRecord.Id,
			MatchmakingConfig.MatchLifetime
		)
	end)
	return indexSuccess
end

function MatchmakingStore.getMatch(self, matchId: string): MatchRecord?
	local success, matchRecord = self:retry("read match " .. matchId, function()
		return self.records:GetAsync("match:" .. matchId)
	end)
	return success and matchRecord or nil
end

function MatchmakingStore.getMatchForPrivateServer(self, privateServerId: string): MatchRecord?
	local success, matchId = self:retry("read private server " .. privateServerId, function()
		return self.records:GetAsync("private-server:" .. privateServerId)
	end)
	if not success or type(matchId) ~= "string" then
		return nil
	end
	return self:getMatch(matchId)
end

function MatchmakingStore.acquireCoordinatorLease(self, gameMode: string, ownerId: string): boolean
	local currentTime = os.time()
	local success, lease = self:retry("acquire coordinator lease " .. gameMode, function()
		return self.records:UpdateAsync("lease:" .. gameMode, function(currentLease)
			if currentLease ~= nil and currentLease.OwnerId ~= ownerId and currentLease.ExpiresAt > currentTime then
				return nil
			end
			return {
				OwnerId = ownerId,
				ExpiresAt = currentTime + MatchmakingConfig.CoordinatorLeaseDuration,
			}
		end, MatchmakingConfig.CoordinatorLeaseDuration)
	end)
	return success and lease ~= nil and lease.OwnerId == ownerId
end

return MatchmakingStore
