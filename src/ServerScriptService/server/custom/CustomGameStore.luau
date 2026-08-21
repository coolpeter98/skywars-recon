--!strict

local MemoryStoreService = game:GetService("MemoryStoreService")

local CustomGameConfig = require(script.Parent.CustomGameConfig)

export type CustomGameRecord = {
	Id: string,
	OwnerId: number,
	OwnerDisplayName: string,
	ServerName: string,
	ServerKey: string,
	AccessCode: string,
	PrivateServerId: string,
	Privacy: "Public" | "Private",
	Settings: {
		GameMode: string,
		MapName: string,
		AllowTeamSelection: boolean,
	},
	InGame: boolean,
	BannedPlayers: { { UserId: number, DisplayName: string } },
	BannedUserIds: { [string]: boolean },
	AdmittedUserIds: { [string]: boolean },
	TeamAssignments: { [string]: string },
	PlayersOnline: number,
	SpectatorsOnline: number,
	CreatedAt: number,
	UpdatedAt: number,
}

local CustomGameStore = {}
CustomGameStore.__index = CustomGameStore

local function warnFailure(operation: string, message: any)
	warn(("[CustomGameStore] %s failed: %s"):format(operation, tostring(message)))
end

function CustomGameStore.new()
	return setmetatable({
		records = MemoryStoreService:GetHashMap(CustomGameConfig.StoreNamespace .. ":records"),
		publicServers = MemoryStoreService:GetSortedMap(CustomGameConfig.StoreNamespace .. ":public"),
	}, CustomGameStore)
end

function CustomGameStore.retry(self, operation: string, callback: () -> any): (boolean, any)
	local lastMessage: any = nil
	for _, delaySeconds in CustomGameConfig.TeleportRetryDelays do
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

function CustomGameStore.claimKey(self, serverKey: string, recordId: string): boolean
	local success, claimedRecordId = self:retry("claim server key " .. serverKey, function()
		return self.records:UpdateAsync("key:" .. serverKey, function(currentRecordId)
			if currentRecordId ~= nil and currentRecordId ~= recordId then
				return nil
			end
			return recordId
		end, CustomGameConfig.RecordLifetime)
	end)
	return success and claimedRecordId == recordId
end

function CustomGameStore.publishRecord(self, record: CustomGameRecord)
	if record.Privacy ~= "Public" then
		self:retry("remove private server from browser", function()
			self.publicServers:RemoveAsync(record.Id)
		end)
		return
	end
	local browserRecord = table.clone(record)
	setmetatable(browserRecord, nil)
	browserRecord.AccessCode = ""
	browserRecord.AdmittedUserIds = {}
	browserRecord.TeamAssignments = {}
	self:retry("publish custom server " .. record.Id, function()
		self.publicServers:SetAsync(record.Id, browserRecord, CustomGameConfig.RecordLifetime, record.UpdatedAt)
	end)
end

function CustomGameStore.setRecord(self, record: CustomGameRecord): boolean
	local success = self:retry("write custom server " .. record.Id, function()
		self.records:SetAsync("server:" .. record.Id, record, CustomGameConfig.RecordLifetime)
		self.records:SetAsync("private-server:" .. record.PrivateServerId, record.Id, CustomGameConfig.RecordLifetime)
	end)
	if success then
		self:publishRecord(record)
	end
	return success
end

function CustomGameStore.getRecord(self, recordId: string): CustomGameRecord?
	local success, record = self:retry("read custom server " .. recordId, function()
		return self.records:GetAsync("server:" .. recordId)
	end)
	return if success then record else nil
end

function CustomGameStore.getByKey(self, serverKey: string): CustomGameRecord?
	local success, recordId = self:retry("resolve server key " .. serverKey, function()
		return self.records:GetAsync("key:" .. serverKey)
	end)
	return if success and type(recordId) == "string" then self:getRecord(recordId) else nil
end

function CustomGameStore.getByPrivateServerId(self, privateServerId: string): CustomGameRecord?
	local success, recordId = self:retry("resolve private server " .. privateServerId, function()
		return self.records:GetAsync("private-server:" .. privateServerId)
	end)
	return if success and type(recordId) == "string" then self:getRecord(recordId) else nil
end

function CustomGameStore.updateRecord(
	self,
	recordId: string,
	transform: (CustomGameRecord?) -> CustomGameRecord?
): CustomGameRecord?
	local success, record = self:retry("update custom server " .. recordId, function()
		return self.records:UpdateAsync("server:" .. recordId, transform, CustomGameConfig.RecordLifetime)
	end)
	if success and record ~= nil then
		self:publishRecord(record)
		return record
	end
	return nil
end

function CustomGameStore.listPublic(self, maximumCount: number): { CustomGameRecord }
	local success, entries = self:retry("list public custom servers", function()
		return self.publicServers:GetRangeAsync(Enum.SortDirection.Descending, maximumCount)
	end)
	if not success or type(entries) ~= "table" then
		return {}
	end
	local records = {}
	for _, entry in entries do
		local record = entry.value or entry.Value
		if type(record) == "table" and record.Privacy == "Public" then
			table.insert(records, record)
		end
	end
	return records
end

function CustomGameStore.removeRecord(self, recordId: string)
	local record = self:getRecord(recordId)
	if record == nil then
		return
	end
	self:retry("remove custom server " .. recordId, function()
		self.records:RemoveAsync("server:" .. recordId)
		self.records:RemoveAsync("private-server:" .. record.PrivateServerId)
		self.records:RemoveAsync("key:" .. record.ServerKey)
		self.publicServers:RemoveAsync(recordId)
	end)
end

return CustomGameStore
