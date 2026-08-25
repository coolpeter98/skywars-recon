--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local CustomGameConfig = require(script.Parent.CustomGameConfig)
local CustomGameStore = require(script.Parent.CustomGameStore)
local LocalCustomGameStore = require(script.Parent.LocalCustomGameStore)
local ModeRegistry = require(script.Parent.Parent.modes.ModeRegistry)

type CustomGameRecord = CustomGameStore.CustomGameRecord

local CustomGameService = {}
CustomGameService.__index = CustomGameService

-- CustomGame is what makes a private-server client cross the lobby -> game
-- lifecycle boundary. Repeat the snapshot while the client boots so a
-- one-shot SetValue sent before RoduxController connects cannot strand the
-- player on the lobby UI.
local REPLICATION_RETRY_DELAYS = { 0.5, 1, 2, 4 }

local function cloneDictionary<T>(source: { [string]: T }): { [string]: T }
	local result = {}
	for key, value in source do
		result[key] = value
	end
	return result
end

local function trim(text: string): string
	return string.match(text, "^%s*(.-)%s*$") or ""
end

local function containsUserId(players: { Player }, userId: number): boolean
	for _, player in players do
		if player.UserId == userId then
			return true
		end
	end
	return false
end

local function countDictionary(dictionary: { [string]: any }): number
	local count = 0
	for _ in dictionary do
		count += 1
	end
	return count
end

function CustomGameService.new(context)
	local store
	if RunService:IsStudio() then
		store = LocalCustomGameStore.new()
	else
		store = CustomGameStore.new()
	end
	return setmetatable({
		context = context,
		store = store,
		record = nil :: CustomGameRecord?,
		connections = {} :: { RBXScriptConnection },
		leavingPlayers = {} :: { [Player]: boolean },
		running = false,
	}, CustomGameService)
end

function CustomGameService.notify(_, player: Player, message: string, _: boolean?)
	-- Custom-game actions do not use the global client Alert surface. Keep
	-- rejected requests visible to server operators without pushing a toast.
	warn(("[CustomGame] %s (%d): %s"):format(player.Name, player.UserId, message))
end

function CustomGameService.toServerData(self, record: CustomGameRecord)
	return {
		OwnerId = record.OwnerId,
		OwnerDisplayName = record.OwnerDisplayName,
		ServerName = record.ServerName,
		ServerKey = record.ServerKey,
		ServerAccessCode = "",
		PlayersOnline = record.PlayersOnline,
		SpectatorsOnline = record.SpectatorsOnline,
		Privacy = record.Privacy,
		Settings = {
			GameMode = record.Settings.GameMode,
			MapName = record.Settings.MapName,
			AllowTeamSelection = record.Settings.AllowTeamSelection,
		},
		InGame = record.InGame,
		BannedPlayers = record.BannedPlayers,
	}
end

function CustomGameService.getAdapter(self, record: CustomGameRecord?)
	local currentRecord = record or self.record
	return if currentRecord then ModeRegistry.getCustom(currentRecord.Settings.GameMode) else nil
end

function CustomGameService.getOnlineCounts(self, record: CustomGameRecord): (number, number)
	local playerCount = 0
	local spectatorCount = 0
	for _, player in Players:GetPlayers() do
		if record.InGame and player:GetAttribute("Alive") ~= true then
			spectatorCount += 1
		else
			playerCount += 1
		end
	end
	return playerCount, spectatorCount
end

function CustomGameService.updateLocalRecord(self, update: (CustomGameRecord) -> ())
	local record = self.record
	if record == nil then
		return nil
	end
	local updated = self.store:updateRecord(record.Id, function(currentRecord)
		if currentRecord == nil then
			return nil
		end
		update(currentRecord)
		currentRecord.UpdatedAt = os.time()
		return currentRecord
	end)
	if updated ~= nil then
		self.record = updated
	end
	return updated
end

function CustomGameService.persistPresence(self)
	local record = self.record
	if record == nil then
		return
	end
	local playersOnline, spectatorsOnline = self:getOnlineCounts(record)
	self:updateLocalRecord(function(currentRecord)
		currentRecord.PlayersOnline = playersOnline
		currentRecord.SpectatorsOnline = spectatorsOnline
	end)
end

function CustomGameService.getParticipantUserIds(self): { number }
	local userIds = {}
	for _, player in Players:GetPlayers() do
		table.insert(userIds, player.UserId)
	end
	table.sort(userIds)
	return userIds
end

function CustomGameService.replicatePlayer(self, player: Player)
	local record = self.record
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil or player.Parent ~= Players then
		return
	end
	self.context.outbound:setValue(player, "CustomGame", {
		ServerData = self:toServerData(record),
		Settings = adapter.buildSettings(record),
	})
	self.context.roundService:replicatePlayer(player)
end

function CustomGameService.replicateAll(self)
	for _, player in Players:GetPlayers() do
		self:replicatePlayer(player)
	end
end

function CustomGameService.configureRoundSession(self, participantUserIds: { [string]: boolean }?)
	local record = self.record
	if record == nil then
		return false
	end
	local participants = participantUserIds or {}
	if participantUserIds == nil then
		for _, player in Players:GetPlayers() do
			participants[tostring(player.UserId)] = true
		end
	end
	return self.context.roundService:configure({
		Id = record.Id,
		Kind = "Custom",
		GameMode = record.Settings.GameMode,
		MapName = record.Settings.MapName,
		MinimumPlayers = 0,
		AllowTeamSelection = record.Settings.AllowTeamSelection,
		ParticipantUserIds = participants,
		TeamAssignments = record.TeamAssignments,
		AutoStart = false,
		Repeatable = true,
		OnReset = function()
			self:updateLocalRecord(function(currentRecord)
				currentRecord.InGame = false
			end)
			self:replicateAll()
		end,
	})
end

function CustomGameService.syncRoundConfiguration(self)
	local record = self.record
	if record == nil then
		return
	end
	self.context.roundService:updateConfiguration(
		record.Settings.GameMode,
		record.Settings.MapName,
		0,
		record.Settings.AllowTeamSelection,
		record.TeamAssignments
	)
end

function CustomGameService.allocateServerKey(self, recordId: string): string?
	for _ = 1, 20 do
		local key = string.upper(
			string.sub(
				string.gsub(HttpService:GenerateGUID(false), "%-", ""),
				1,
				CustomGameConfig.PrivateServerKeyLength
			)
		)
		if self.store:claimKey(key, recordId) then
			return key
		end
	end
	return nil
end

function CustomGameService.reserveServer(self): (string?, string?)
	if RunService:IsStudio() then
		return "studio-access", "studio:" .. HttpService:GenerateGUID(false)
	end
	local lastMessage: any = nil
	for _, delaySeconds in CustomGameConfig.TeleportRetryDelays do
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
	warn("[CustomGame] Failed to reserve a server: " .. tostring(lastMessage))
	return nil, nil
end

function CustomGameService.teleportParty(self, owner: Player, partyPlayers: { Player }, record: CustomGameRecord)
	if RunService:IsStudio() then
		self.record = record
		-- Publish the custom snapshot before the replicated role exposes the
		-- custom dock. The pre-game world transition reloads characters and can
		-- take several seconds in Studio; without this ordering the Settings
		-- button renders against a nil CustomGame store during that whole gap.
		self:replicateAll()
		self.context.runtimeContext:setPrivate(record.Settings.GameMode, record.Id)
		self:configureRoundSession()
		self:replicateAll()
		for _, member in partyPlayers do
			task.spawn(function()
				self:initializePlayer(member)
			end)
		end
		self:notify(owner, "Studio created a local custom game with code " .. record.ServerKey, true)
		return
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = record.AccessCode
	teleportOptions:SetTeleportData(
		self.context.runtimeContext:createPrivateTeleportData(record.Settings.GameMode, record.Id)
	)
	local success, message = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, partyPlayers, teleportOptions)
	end)
	if not success then
		warn(("[CustomGame] Teleport failed for %s: %s"):format(owner.Name, tostring(message)))
		for _, member in partyPlayers do
			self.context.outbound:fire("TeleportFinished", member)
		end
		self:notify(
			owner,
			"The custom server was created, but the party teleport failed. Try joining code " .. record.ServerKey .. "."
		)
	end
end

function CustomGameService.createServer(self, player: Player, privacy: string)
	if self.context.runtimeContext:get().Role ~= "Lobby" then
		self:notify(player, "Custom servers can only be created from the lobby.")
		return
	end
	local partyPlayers, partyError = self.context.partyService:getTravelPlayers(player)
	if partyPlayers == nil then
		self:notify(player, partyError or "Unable to move this party.")
		return
	end
	self.context.matchmakingService:cancelForPlayer(player)
	local adapter = ModeRegistry.getDefaultCustom()
	if adapter == nil then
		self:notify(player, "No custom-game mode is currently available.")
		return
	end
	local gameMode = adapter.getDefaultGameMode()
	local accessCode, privateServerId = self:reserveServer()
	if accessCode == nil or privateServerId == nil then
		self:notify(player, "Roblox could not reserve a custom server. Please try again.")
		return
	end
	local recordId = HttpService:GenerateGUID(false)
	local serverKey = self:allocateServerKey(recordId)
	if serverKey == nil then
		self:notify(player, "A unique join code could not be allocated. Please try again.")
		return
	end
	local admittedUserIds = {}
	for _, member in partyPlayers do
		admittedUserIds[tostring(member.UserId)] = true
	end
	local now = os.time()
	local record: CustomGameRecord = {
		Id = recordId,
		OwnerId = player.UserId,
		OwnerDisplayName = player.DisplayName,
		ServerName = player.DisplayName .. "'s " .. adapter.Id,
		ServerKey = serverKey,
		AccessCode = accessCode,
		PrivateServerId = privateServerId,
		Privacy = privacy :: "Public" | "Private",
		Settings = {
			GameMode = gameMode,
			MapName = "",
			AllowTeamSelection = true,
		},
		InGame = false,
		BannedPlayers = {},
		BannedUserIds = {},
		AdmittedUserIds = admittedUserIds,
		TeamAssignments = {},
		PlayersOnline = #partyPlayers,
		SpectatorsOnline = 0,
		CreatedAt = now,
		UpdatedAt = now,
	}
	if not self.store:setRecord(record) then
		self:notify(player, "The custom server record could not be saved. Please try again.")
		return
	end
	self:teleportParty(player, partyPlayers, record)
end

function CustomGameService.admitParty(
	self,
	player: Player,
	partyPlayers: { Player },
	record: CustomGameRecord
): CustomGameRecord?
	local rejection: string? = nil
	local updated = self.store:updateRecord(record.Id, function(currentRecord)
		if currentRecord == nil then
			rejection = "That custom server has expired."
			return nil
		end
		for _, member in partyPlayers do
			if currentRecord.BannedUserIds[tostring(member.UserId)] then
				rejection = member == player and "You are banned from that custom server."
					or (member.DisplayName .. " is banned from that custom server.")
				return nil
			end
		end
		local adapter = ModeRegistry.getCustom(currentRecord.Settings.GameMode)
		if adapter == nil then
			rejection = "That custom server uses an unavailable mode."
			return nil
		end
		if
			not currentRecord.InGame
			and currentRecord.PlayersOnline + #partyPlayers
				> adapter.getMaximumPlayers(currentRecord.Settings.GameMode)
		then
			rejection = "That custom server does not have room for the whole party."
			return nil
		end
		if
			currentRecord.PlayersOnline + currentRecord.SpectatorsOnline + #partyPlayers
			> CustomGameConfig.MaximumServerPlayers
		then
			rejection = "That custom server is full."
			return nil
		end
		currentRecord.AdmittedUserIds = cloneDictionary(currentRecord.AdmittedUserIds)
		for _, member in partyPlayers do
			currentRecord.AdmittedUserIds[tostring(member.UserId)] = true
		end
		currentRecord.UpdatedAt = os.time()
		return currentRecord
	end)
	if updated == nil and rejection ~= nil then
		self:notify(player, rejection)
	end
	return updated
end

function CustomGameService.joinServer(self, player: Player, joinCode: string)
	if self.context.runtimeContext:get().Role ~= "Lobby" then
		self:notify(player, "Join codes can only be used from the lobby.")
		return
	end
	local normalizedCode = string.upper(trim(joinCode))
	if
		#normalizedCode ~= CustomGameConfig.PrivateServerKeyLength
		or string.match(normalizedCode, "^[%u%d]+$") == nil
	then
		self:notify(player, "Enter a valid six-character custom game code.")
		return
	end
	local partyPlayers, partyError = self.context.partyService:getTravelPlayers(player)
	if partyPlayers == nil then
		self:notify(player, partyError or "Unable to move this party.")
		return
	end
	local record = self.store:getByKey(normalizedCode)
	if record == nil then
		self:notify(player, "No active custom server uses that code.")
		return
	end
	local updated = self:admitParty(player, partyPlayers, record)
	if updated ~= nil then
		self:teleportParty(player, partyPlayers, updated)
	end
end

function CustomGameService.requireOwner(self, player: Player, allowInGame: boolean?): CustomGameRecord?
	local record = self.record
	if record == nil or record.OwnerId ~= player.UserId then
		self:notify(player, "Only the custom game owner can change this setting.")
		return nil
	end
	if not allowInGame and record.InGame then
		self:notify(player, "This setting cannot be changed during a round.")
		return nil
	end
	return record
end

function CustomGameService.setServerName(self, player: Player, serverName: string)
	if self:requireOwner(player) == nil then
		return
	end
	local normalizedName = string.sub(trim(serverName), 1, 50)
	if normalizedName == "" then
		local adapter = self:getAdapter(self.record)
		normalizedName = player.DisplayName .. "'s " .. (if adapter ~= nil then adapter.Id else "Game")
	end
	self:updateLocalRecord(function(record)
		record.ServerName = normalizedName
	end)
	self:replicateAll()
end

function CustomGameService.setGameMode(self, player: Player, gameMode: string)
	local record = self:requireOwner(player)
	local adapter = ModeRegistry.getCustom(gameMode)
	if record == nil or adapter == nil then
		if record ~= nil then
			self:notify(player, "That mode is not available for custom games.")
		end
		return
	end
	local userIds = self:getParticipantUserIds()
	self:updateLocalRecord(function(currentRecord)
		currentRecord.Settings.GameMode = gameMode
		if not adapter.isMapNameValid(currentRecord.Settings.MapName) then
			currentRecord.Settings.MapName = ""
		end
		if currentRecord.Settings.AllowTeamSelection then
			currentRecord.TeamAssignments =
				adapter.sanitizeTeamAssignments(gameMode, userIds, currentRecord.TeamAssignments)
		else
			currentRecord.TeamAssignments =
				adapter.assignBalancedTeams(gameMode, userIds, currentRecord.TeamAssignments)
		end
	end)
	self.context.runtimeContext:setPrivate(gameMode, record.Id)
	self:syncRoundConfiguration()
	self:replicateAll()
end

function CustomGameService.setAllowTeamSelection(self, player: Player, allowTeamSelection: boolean)
	local record = self:requireOwner(player)
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil then
		return
	end
	local userIds = self:getParticipantUserIds()
	self:updateLocalRecord(function(currentRecord)
		currentRecord.Settings.AllowTeamSelection = allowTeamSelection
		if not allowTeamSelection then
			currentRecord.TeamAssignments =
				adapter.assignBalancedTeams(currentRecord.Settings.GameMode, userIds, currentRecord.TeamAssignments)
		end
	end)
	self:syncRoundConfiguration()
	self:replicateAll()
end

function CustomGameService.setPrivacy(self, player: Player, privacy: string)
	if self:requireOwner(player, true) == nil then
		return
	end
	self:updateLocalRecord(function(record)
		record.Privacy = privacy :: "Public" | "Private"
	end)
	self:replicateAll()
end

function CustomGameService.setMap(self, player: Player, mapName: string)
	-- Map selection is configuration for the next round. Updating it while a
	-- round is live must not replace the already-loaded arena.
	local record = self:requireOwner(player, true)
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil or not adapter.isMapNameValid(mapName) then
		if record ~= nil then
			self:notify(player, "That map is not available for the selected mode.")
		end
		return
	end
	self:updateLocalRecord(function(currentRecord)
		currentRecord.Settings.MapName = mapName
	end)
	self:syncRoundConfiguration()
	self:replicateAll()
end

function CustomGameService.setPlayerTeam(self, player: Player, userId: number, teamId: string?)
	local record = self.record
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil or record.InGame then
		return
	end
	local isOwner = record.OwnerId == player.UserId
	if not isOwner and (userId ~= player.UserId or not record.Settings.AllowTeamSelection) then
		self:notify(player, "Team selection is disabled.")
		return
	end
	local target = Players:GetPlayerByUserId(userId)
	if target == nil then
		return
	end
	local validTeam = teamId == nil
	if teamId ~= nil then
		validTeam = table.find(adapter.getTeamIds(record.Settings.GameMode), teamId) ~= nil
	end
	if not validTeam then
		return
	end
	if teamId ~= nil then
		local teams = adapter.buildTeams(record.Settings.GameMode, record.TeamAssignments)
		for _, team in teams do
			if
				team.Id == teamId
				and countDictionary(team.Players) >= team.MaxPlayers
				and team.Players[tostring(userId)] == nil
			then
				self:notify(player, "That team is full.")
				return
			end
		end
	end
	self:updateLocalRecord(function(currentRecord)
		currentRecord.TeamAssignments = cloneDictionary(currentRecord.TeamAssignments)
		currentRecord.TeamAssignments[tostring(userId)] = teamId
	end)
	target:SetAttribute("TeamId", teamId)
	self:syncRoundConfiguration()
	self:replicateAll()
end

function CustomGameService.setPlayerBan(self, player: Player, userId: number, displayName: string, banned: boolean)
	local record = self:requireOwner(player, true)
	if record == nil or userId == record.OwnerId then
		return
	end
	self:updateLocalRecord(function(currentRecord)
		currentRecord.BannedUserIds = cloneDictionary(currentRecord.BannedUserIds)
		currentRecord.TeamAssignments = cloneDictionary(currentRecord.TeamAssignments)
		currentRecord.AdmittedUserIds = cloneDictionary(currentRecord.AdmittedUserIds)
		currentRecord.BannedUserIds[tostring(userId)] = if banned then true else nil
		if banned then
			currentRecord.TeamAssignments[tostring(userId)] = nil
			currentRecord.AdmittedUserIds[tostring(userId)] = nil
		end
		local bannedPlayers = {}
		for _, entry in currentRecord.BannedPlayers do
			if entry.UserId ~= userId then
				table.insert(bannedPlayers, entry)
			end
		end
		if banned then
			table.insert(bannedPlayers, { UserId = userId, DisplayName = string.sub(displayName, 1, 50) })
		end
		currentRecord.BannedPlayers = bannedPlayers
	end)
	self:replicateAll()
	if banned then
		local target = Players:GetPlayerByUserId(userId)
		if target ~= nil then
			self.context.matchmakingService:teleportToLobby(target)
		end
	end
end

function CustomGameService.startMatch(self, player: Player)
	local record = self:requireOwner(player)
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil then
		return
	end
	local userIds = self:getParticipantUserIds()
	local assignments = adapter.assignBalancedTeams(record.Settings.GameMode, userIds, record.TeamAssignments)
	local updated = self:updateLocalRecord(function(currentRecord)
		currentRecord.TeamAssignments = assignments
		currentRecord.InGame = true
	end)
	if updated == nil then
		return
	end
	local participantUserIds = {}
	for userIdKey in assignments do
		participantUserIds[userIdKey] = true
	end
	if not self:configureRoundSession(participantUserIds) then
		self:updateLocalRecord(function(currentRecord)
			currentRecord.InGame = false
		end)
		self:replicateAll()
		return
	end
	-- The client only tears down LobbyScreen after it observes
	-- CustomGame.ServerData.InGame. Publish that transition before
	-- RoundService emits the pregame countdown, otherwise GameController is
	-- not mounted yet and the countdown event is lost.
	self:replicateAll()
	if not self.context.roundService:startRound() then
		self:updateLocalRecord(function(currentRecord)
			currentRecord.InGame = false
		end)
		self:replicateAll()
	end
end

function CustomGameService.validateAdmission(self, player: Player): boolean
	local cachedRecord = self.record
	if cachedRecord == nil then
		return false
	end
	local userIdKey = tostring(player.UserId)
	local deadline = os.clock() + CustomGameConfig.AdmissionValidationTimeout
	repeat
		-- Lobby servers add admissions after the reserved server has already
		-- cached its startup record. Always validate arrivals against the shared
		-- record so the first join attempt sees that newly committed admission.
		local record = self.store:getRecord(cachedRecord.Id)
		if record ~= nil then
			self.record = record
			if record.BannedUserIds[userIdKey] then
				player:Kick("You are not admitted to this custom game.")
				return false
			end
			if record.OwnerId == player.UserId or record.AdmittedUserIds[userIdKey] then
				return true
			end
		end
		if os.clock() >= deadline then
			break
		end
		task.wait(CustomGameConfig.AdmissionValidationInterval)
	until player.Parent ~= Players
	if player.Parent == Players then
		player:Kick("You are not admitted to this custom game.")
	end
	return false
end

function CustomGameService.initializePlayer(self, player: Player)
	local deadline = os.clock() + 10
	while self.context.playerSessions:get(player) == nil and player.Parent == Players and os.clock() < deadline do
		task.wait()
	end
	if
		player.Parent ~= Players
		or self.context.playerSessions:get(player) == nil
		or not self:validateAdmission(player)
	then
		return
	end
	-- Let PlayerSessions deliver its one reset-style bootstrap before mounting
	-- the CustomGame-dependent scoreboard listeners and syncing pregame time.
	task.wait()
	if player.Parent ~= Players or self.record == nil then
		return
	end
	local record = self.record :: CustomGameRecord
	local teamId = record.TeamAssignments[tostring(player.UserId)]
	player:SetAttribute("TeamId", teamId)
	-- Replicate CustomGame first: the client mounts the private-game
	-- scoreboard listeners from this value before RoundService synchronizes a
	-- countdown already in progress.
	self:replicatePlayer(player)
	self.context.roundService:initializePlayer(player)
	self:persistPresence()
	self:replicateAll()
	local initializedRecordId = record.Id
	task.spawn(function()
		for _, delaySeconds in REPLICATION_RETRY_DELAYS do
			task.wait(delaySeconds)
			if
				not self.running
				or player.Parent ~= Players
				or self.record == nil
				or self.record.Id ~= initializedRecordId
			then
				return
			end
			self:replicatePlayer(player)
		end
	end)
end

function CustomGameService.configureReservedServer(self)
	if game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then
		return
	end
	local record = self.store:getByPrivateServerId(game.PrivateServerId)
	if record == nil then
		return
	end
	self.record = record
	self.context.runtimeContext:setPrivate(record.Settings.GameMode, record.Id)
	self:configureRoundSession()
end

function CustomGameService.onPlayerRemoving(self, player: Player)
	self.leavingPlayers[player] = true
	local record = self.record
	if record == nil then
		return
	end
	task.defer(function()
		if self.record == nil then
			return
		end
		local remainingPlayers = {}
		for _, candidate in Players:GetPlayers() do
			-- PlayerRemoving may run before Roblox removes departing Players from
			-- Players. Exclude every removal already in flight so simultaneous
			-- departures still tear down the browser record.
			if candidate ~= player and not self.leavingPlayers[candidate] and candidate.Parent == Players then
				table.insert(remainingPlayers, candidate)
			end
		end
		if #remainingPlayers == 0 then
			local recordToRemove = self.record
			self.record = nil
			self.store:removeRecord(recordToRemove.Id, recordToRemove)
			local roundSession = self.context.roundService.session
			if roundSession ~= nil and roundSession.Kind == "Custom" and roundSession.Id == recordToRemove.Id then
				self.context.roundService:clearSession()
			end
			return
		end
		if self.record.OwnerId == player.UserId then
			local newOwner = remainingPlayers[1]
			self:updateLocalRecord(function(currentRecord)
				currentRecord.OwnerId = newOwner.UserId
				currentRecord.OwnerDisplayName = newOwner.DisplayName
			end)
		end
		self:persistPresence()
		self:replicateAll()
	end)
end

function CustomGameService.listPublicServers(self, player: Player): { any }
	local servers = {}
	for _, record in self.store:listPublic(CustomGameConfig.ServerListLimit) do
		if not record.BannedUserIds[tostring(player.UserId)] then
			table.insert(servers, self:toServerData(record))
		end
	end
	table.sort(servers, function(left, right)
		if left.PlayersOnline == right.PlayersOnline then
			return left.ServerName < right.ServerName
		end
		return left.PlayersOnline > right.PlayersOnline
	end)
	return servers
end

function CustomGameService.requestSpectate(self, player: Player)
	self.context.roundService:requestSpectate(player)
end

function CustomGameService.spectateTargetChanged(self, player: Player, target: Player)
	self.context.roundService:spectateTargetChanged(player, target)
end

function CustomGameService.start(self)
	if self.running then
		return
	end
	self.running = true
	self:configureReservedServer()
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			if self.record ~= nil then
				task.spawn(function()
					self:initializePlayer(player)
				end)
			end
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			self:onPlayerRemoving(player)
		end)
	)
	for _, player in Players:GetPlayers() do
		if self.record ~= nil then
			task.spawn(function()
				self:initializePlayer(player)
			end)
		end
	end
	task.spawn(function()
		while self.running do
			if self.record ~= nil then
				self:persistPresence()
			end
			task.wait(CustomGameConfig.HeartbeatInterval)
		end
	end)
end

function CustomGameService.stop(self)
	self.running = false
	local recordToRemove = self.record
	self.record = nil
	if recordToRemove ~= nil then
		-- BindToClose reaches this path even when PlayerRemoving cleanup never
		-- ran (crash/migration/forced shutdown). Do not leave its public lease.
		self.store:removeRecord(recordToRemove.Id, recordToRemove)
	end
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.leavingPlayers)
end

return CustomGameService
