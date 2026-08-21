--!strict

local LocalCustomGameStore = {}
LocalCustomGameStore.__index = LocalCustomGameStore

function LocalCustomGameStore.new()
	return setmetatable({
		records = {} :: { [string]: any },
		serverKeys = {} :: { [string]: string },
		privateServers = {} :: { [string]: string },
	}, LocalCustomGameStore)
end

function LocalCustomGameStore.claimKey(self, serverKey: string, recordId: string): boolean
	if self.serverKeys[serverKey] ~= nil then
		return false
	end
	self.serverKeys[serverKey] = recordId
	return true
end

function LocalCustomGameStore.setRecord(self, record): boolean
	self.records[record.Id] = record
	self.serverKeys[record.ServerKey] = record.Id
	self.privateServers[record.PrivateServerId] = record.Id
	return true
end

function LocalCustomGameStore.getRecord(self, recordId: string)
	return self.records[recordId]
end

function LocalCustomGameStore.getByKey(self, serverKey: string)
	local recordId = self.serverKeys[serverKey]
	return if recordId then self.records[recordId] else nil
end

function LocalCustomGameStore.getByPrivateServerId(self, privateServerId: string)
	local recordId = self.privateServers[privateServerId]
	return if recordId then self.records[recordId] else nil
end

function LocalCustomGameStore.updateRecord(self, recordId: string, transform)
	local record = transform(self.records[recordId])
	if record ~= nil then
		self:setRecord(record)
	end
	return record
end

function LocalCustomGameStore.listPublic(self, maximumCount: number): { any }
	local records = {}
	for _, record in self.records do
		if record.Privacy == "Public" then
			table.insert(records, record)
		end
	end
	table.sort(records, function(left, right)
		return left.UpdatedAt > right.UpdatedAt
	end)
	local result = {}
	for index = 1, math.min(maximumCount, #records) do
		result[index] = records[index]
	end
	return result
end

function LocalCustomGameStore.removeRecord(self, recordId: string)
	local record = self.records[recordId]
	if record == nil then
		return
	end
	self.records[recordId] = nil
	if self.serverKeys[record.ServerKey] == recordId then
		self.serverKeys[record.ServerKey] = nil
	end
	if self.privateServers[record.PrivateServerId] == recordId then
		self.privateServers[record.PrivateServerId] = nil
	end
end

return LocalCustomGameStore
