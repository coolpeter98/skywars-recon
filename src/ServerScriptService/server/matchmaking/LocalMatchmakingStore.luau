--!strict

local MatchmakingConfig = require(script.Parent.MatchmakingConfig)

local LocalMatchmakingStore = {}
LocalMatchmakingStore.__index = LocalMatchmakingStore

function LocalMatchmakingStore.new()
	return setmetatable({
		tickets = {} :: { [string]: any },
		matches = {} :: { [string]: any },
		privateServerMatches = {} :: { [string]: string },
		queues = {} :: { [string]: { any } },
	}, LocalMatchmakingStore)
end

function LocalMatchmakingStore.getQueue(self, gameMode: string): { any }
	local queue = self.queues[gameMode]
	if queue == nil then
		queue = {}
		self.queues[gameMode] = queue
	end
	return queue
end

function LocalMatchmakingStore.enqueue(self, ticketId: string, gameMode: string): boolean
	table.insert(self:getQueue(gameMode), { TicketId = ticketId })
	return true
end

function LocalMatchmakingStore.read(self, gameMode: string, count: number): (boolean, { any }, string?)
	local queue = self:getQueue(gameMode)
	local items = {}
	for _ = 1, math.min(count, #queue) do
		table.insert(items, table.remove(queue, 1))
	end
	return true, items, #items > 0 and "local" or nil
end

function LocalMatchmakingStore.acknowledge(self, _: string, _: string?): boolean
	return true
end

function LocalMatchmakingStore.setTicket(self, ticket): boolean
	self.tickets[ticket.Id] = ticket
	return true
end

function LocalMatchmakingStore.getTicket(self, ticketId: string)
	local ticket = self.tickets[ticketId]
	if ticket ~= nil and ticket.ExpiresAt <= os.time() then
		self.tickets[ticketId] = nil
		return nil
	end
	return ticket
end

function LocalMatchmakingStore.updateTicket(self, ticketId: string, transform)
	local updatedTicket = transform(self:getTicket(ticketId))
	if updatedTicket ~= nil then
		self.tickets[ticketId] = updatedTicket
	end
	return updatedTicket
end

function LocalMatchmakingStore.setMatch(self, matchRecord): boolean
	self.matches[matchRecord.Id] = matchRecord
	self.privateServerMatches[matchRecord.PrivateServerId] = matchRecord.Id
	return true
end

function LocalMatchmakingStore.getMatch(self, matchId: string)
	local matchRecord = self.matches[matchId]
	if matchRecord ~= nil and os.time() - matchRecord.CreatedAt >= MatchmakingConfig.MatchLifetime then
		self.matches[matchId] = nil
		return nil
	end
	return matchRecord
end

function LocalMatchmakingStore.getMatchForPrivateServer(self, privateServerId: string)
	local matchId = self.privateServerMatches[privateServerId]
	return matchId and self:getMatch(matchId) or nil
end

function LocalMatchmakingStore.acquireCoordinatorLease(self, _: string, _: string): boolean
	return true
end

return LocalMatchmakingStore
