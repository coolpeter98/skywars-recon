--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local CustomGameConfig = require(script.Parent.CustomGameConfig)
local CustomGameStore = require(script.Parent.CustomGameStore)
local LocalCustomGameStore = require(script.Parent.LocalCustomGameStore)
local ModeRegistry = require(script.Parent.modes.ModeRegistry)
local MapService = require(script.Parent.MapService)
local PregameService = require(script.Parent.PregameService)

type CustomGameRecord = CustomGameStore.CustomGameRecord

local CustomGameService = {}
CustomGameService.__index = CustomGameService

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
		mapService = MapService.new(),
		pregameService = PregameService.new(context),
		record = nil :: CustomGameRecord?,
		loadedMap = nil :: MapService.LoadedMap?,
		connections = {} :: { RBXScriptConnection },
		characterConnections = {} :: { [Player]: RBXScriptConnection },
		humanoidConnections = {} :: { [Player]: RBXScriptConnection },
		eliminatedPlayers = {} :: { Player },
		roundId = 0,
		roundState = "Pregame",
		running = false,
	}, CustomGameService)
end

function CustomGameService.notify(self, player: Player, message: string, success: boolean?)
	local color = if success then Color3.fromRGB(102, 255, 99) else Color3.fromRGB(255, 92, 92)
	self.context.outbound:fire("Alert", player, "Custom Game", message, color, 3.5)
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
	return if currentRecord then ModeRegistry.get(currentRecord.Settings.GameMode) else nil
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

function CustomGameService.buildGameTeams(self, record: CustomGameRecord, adapter)
	local gameTeams = adapter.buildGameTeams(record)
	if record.InGame then
		for _, team in gameTeams do
			team.AliveCount = 0
		end
		for _, candidate in Players:GetPlayers() do
			local teamId = candidate:GetAttribute("TeamId")
			local team = if type(teamId) == "string" then gameTeams[teamId] else nil
			if team ~= nil and candidate:GetAttribute("Alive") == true then
				team.AliveCount += 1
			end
		end
	end
	return gameTeams
end

local function isInBuildConstraint(position: Vector3, constraint: MapService.BuildConstraint): boolean
	local minimum = constraint.Minimum
	local maximum = constraint.Maximum
	return position.X >= minimum.X
		and position.X <= maximum.X
		and position.Y >= minimum.Y
		and position.Y <= maximum.Y
		and position.Z >= minimum.Z
		and position.Z <= maximum.Z
end

function CustomGameService.getBuildConstraints(self): { MapService.BuildConstraint }
	local record = self.record
	local loadedMap = self.loadedMap
	if record == nil or not record.InGame or loadedMap == nil or self.roundState ~= "InGame" then
		return {}
	end
	return loadedMap.BuildConstraints
end

function CustomGameService.isBlockPlacementAllowed(self, player: Player, position: Vector3): boolean
	if player:GetAttribute("Alive") ~= true or player:GetAttribute("Spectating") == true then
		return false
	end
	for _, constraint in self:getBuildConstraints() do
		if constraint.Whitelist and isInBuildConstraint(position, constraint) then
			return true
		end
	end
	return false
end

function CustomGameService.replicatePlayer(self, player: Player)
	local record = self.record
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil or player.Parent ~= Players then
		return
	end
	local settings = adapter.buildSettings(record)
	self.context.outbound:setValue(player, "CustomGame", {
		ServerData = self:toServerData(record),
		Settings = settings,
	})
	self.context.outbound:setValue(player, "GameSettings", settings)
	self.context.outbound:setValue(player, "GameTeams", self:buildGameTeams(record, adapter))
	self.context.outbound:setValue(player, "BuildConstraints", self:getBuildConstraints())
	local aliveUserIds = {}
	for _, candidate in Players:GetPlayers() do
		if not record.InGame or candidate:GetAttribute("Alive") == true then
			table.insert(aliveUserIds, candidate.UserId)
		end
	end
	self.context.outbound:setValue(player, "Players", aliveUserIds)
	self.context.outbound:setValue(player, "GameState", self.roundState)
	local teamId = record.TeamAssignments[tostring(player.UserId)]
	player:SetAttribute("TeamId", teamId)
end

function CustomGameService.replicateAll(self)
	for _, player in Players:GetPlayers() do
		self:replicatePlayer(player)
	end
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
		self.context.runtimeContext:setPrivate(record.Settings.GameMode, record.Id)
		-- The server is now a custom match: swap the visible lobby world for
		-- the pre-game lobby (see LobbyWorldService).
		self.context.lobbyWorldService:setPregame()
		self:replicateAll()
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
	local adapter = ModeRegistry.getDefault()
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
		ServerName = player.DisplayName .. "'s SkyWars",
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
		local adapter = ModeRegistry.get(currentRecord.Settings.GameMode)
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
		normalizedName = player.DisplayName .. "'s SkyWars"
	end
	self:updateLocalRecord(function(record)
		record.ServerName = normalizedName
	end)
	self:replicateAll()
end

function CustomGameService.setGameMode(self, player: Player, gameMode: string)
	local record = self:requireOwner(player)
	local adapter = ModeRegistry.get(gameMode)
	if record == nil or adapter == nil then
		if record ~= nil then
			self:notify(player, "Only SkyWars custom modes are implemented.")
		end
		return
	end
	local userIds = self:getParticipantUserIds()
	self:updateLocalRecord(function(currentRecord)
		currentRecord.Settings.GameMode = gameMode
		if currentRecord.Settings.AllowTeamSelection then
			currentRecord.TeamAssignments =
				adapter.sanitizeTeamAssignments(gameMode, userIds, currentRecord.TeamAssignments)
		else
			currentRecord.TeamAssignments =
				adapter.assignBalancedTeams(gameMode, userIds, currentRecord.TeamAssignments)
		end
	end)
	self.context.runtimeContext:setPrivate(gameMode, record.Id)
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
	local record = self:requireOwner(player)
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil or not adapter.isMapNameValid(mapName) then
		if record ~= nil then
			self:notify(player, "That map is not available for SkyWars.")
		end
		return
	end
	self:updateLocalRecord(function(currentRecord)
		currentRecord.Settings.MapName = mapName
	end)
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

-- Places an assigned participant at their team's spawn and arms their starter
-- inventory. Returns the spawn CFrame used (nil when the map or spawn is
-- missing) so the caller can cage the player there during the countdown.
function CustomGameService.spawnPlayer(self, player: Player, teamId: string): CFrame?
	local loadedMap = self.loadedMap
	if loadedMap == nil then
		return nil
	end
	local spawnCFrame = loadedMap.SpawnPositions[teamId]
	if spawnCFrame == nil then
		return nil
	end
	local character = player.Character
	if character == nil then
		local success = pcall(function()
			player:LoadCharacter()
		end)
		if not success then
			return nil
		end
		character = player.Character or player.CharacterAdded:Wait()
	end
	character:PivotTo(spawnCFrame)
	player:SetAttribute("Alive", true)
	player:SetAttribute("Spectating", false)
	player:SetAttribute("TeamId", teamId)
	player:SetAttribute("Health", 100)
	player:SetAttribute("Shield", 0)
	-- The natural-regeneration tick clock starts at zero for every spawned
	-- player: regen only begins a full tick group after the last hit.
	local regenerationService = self.context.regenerationService
	if regenerationService ~= nil then
		regenerationService:resetPlayer(player)
	end
	-- Fall state restarts too: the first landing after a spawn is always
	-- free (spawn points sit above their islands).
	local fallDamageService = self.context.fallDamageService
	if fallDamageService ~= nil then
		fallDamageService:resetPlayer(player)
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = humanoid.MaxHealth
	end
	self.context.inventoryService:clear(player)
	self.context.inventoryService:changeItem(player, "BronzeSword", 1)
	self.context.inventoryService:changeItem(player, "TeamConcrete", 32)
	self.context.inventoryService:setHeldItem(player, "BronzeSword")
	self:bindHumanoid(player)
	return spawnCFrame
end

function CustomGameService.spawnSpectator(self, player: Player)
	local loadedMap = self.loadedMap
	if loadedMap == nil then
		return
	end
	local character = player.Character
	if character == nil then
		local success = pcall(function()
			player:LoadCharacter()
		end)
		if not success then
			return
		end
		character = player.Character or player.CharacterAdded:Wait()
	end
	character:PivotTo(loadedMap.SpectatorCFrame)
	player:SetAttribute("Alive", false)
	player:SetAttribute("Spectating", true)
	player:SetAttribute("TeamId", nil)
	self.context.inventoryService:clear(player)
	self.context.outbound:fire("Spectate", player, nil, loadedMap.SpectatorCFrame.Position, nil)
end

function CustomGameService.startMatch(self, player: Player)
	local record = self:requireOwner(player)
	local adapter = self:getAdapter(record)
	if record == nil or adapter == nil then
		return
	end
	local participants = Players:GetPlayers()
	local userIds = self:getParticipantUserIds()
	local assignments = adapter.assignBalancedTeams(record.Settings.GameMode, userIds, record.TeamAssignments)
	local updated = self:updateLocalRecord(function(currentRecord)
		currentRecord.TeamAssignments = assignments
		currentRecord.InGame = true
	end)
	if updated == nil then
		return
	end
	self.roundId += 1
	local roundId = self.roundId
	-- Phase 1 — the pre-game lobby countdown. The round opens in the
	-- Pregame state: the client's scoreboard shows its "Starting in N..."
	-- countdown (it counts GameConstants.PREGAME_DURATION down from the
	-- GameStateChangeTime event) while the players wait in the pre-game
	-- lobby world. Nobody is teleported or caged yet.
	self.roundState = "Pregame"
	table.clear(self.eliminatedPlayers)
	self:replicateAll()
	local lobbyCountdown = self.pregameService:startLobbyCountdown()
	task.delay(lobbyCountdown, function()
		if
			not self.running
			or self.roundId ~= roundId
			or self.record == nil
			or not self.record.InGame
			or self.roundState ~= "Pregame"
		then
			return
		end
		-- Phase 2 — the cages. The scoreboard countdown is over: load the
		-- arena, teleport every participant to their spot, cage the assigned
		-- players, and run the 4-second centre-screen countdown (Title
		-- events: 4, 3, 2, 1 with the recovered voice sounds from "3" on).
		self.loadedMap = self.mapService:load(updated.Settings.GameMode, updated.Settings.MapName)
		if self.loadedMap ~= nil then
			self.context.blockWorldService:rebuild(self.loadedMap.Model)
		end
		local cagedPlayers = {}
		local cagedSpawns = {}
		for _, participant in participants do
			local teamId = assignments[tostring(participant.UserId)]
			if teamId ~= nil then
				local spawnCFrame = self:spawnPlayer(participant, teamId)
				if spawnCFrame ~= nil then
					table.insert(cagedPlayers, participant)
					cagedSpawns[participant] = spawnCFrame
				end
			else
				self:spawnSpectator(participant)
			end
		end
		self.roundState = "Countdown"
		-- The lobby world is only for the Pregame/Ended phases: hide it
		-- server-side (authoritative) the moment the round leaves the lobby,
		-- so it can never linger under the arena during the match.
		self.context.lobbyWorldService:hideWorld()
		self:replicateAll()
		self.pregameService:begin(cagedPlayers, cagedSpawns, CustomGameConfig.CountdownDuration)
		task.delay(CustomGameConfig.CountdownDuration, function()
			if
				not self.running
				or self.roundId ~= roundId
				or self.record == nil
				or not self.record.InGame
				or self.roundState ~= "Countdown"
			then
				return
			end
			-- GO: the release title and its sound play at the exact moment the
			-- cages drop (PregameService.finish), then the round opens.
			self.pregameService:finish()
			self.roundState = "InGame"
			self:replicateAll()
			for _, participant in Players:GetPlayers() do
				-- GameStateChangeTime(0) rebases the scoreboard clock: the
				-- GameTimer counts round time from the moment InGame begins.
				self.context.outbound:fire("GameStateChangeTime", participant, 0)
				self.context.outbound:fire("GameStarted", participant)
			end
		end)
	end)
end

function CustomGameService.getAliveTeams(self): ({ [string]: { Player } }, number)
	local teams = {}
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Alive") == true then
			local teamId = player:GetAttribute("TeamId")
			if type(teamId) == "string" and teamId ~= "" then
				local teamPlayers = teams[teamId]
				if teamPlayers == nil then
					teamPlayers = {}
					teams[teamId] = teamPlayers
				end
				table.insert(teamPlayers, player)
			end
		end
	end
	return teams, countDictionary(teams)
end

-- Round context for out-of-service consumers (the kill log): the current
-- round number plus the game mode and the map actually in play ("Placeholder"
-- when no real map model is loaded).
function CustomGameService.getRoundInfo(self): { RoundId: number?, GameMode: string?, MapName: string? }
	local record = self.record
	if record == nil then
		return {}
	end
	local mapName = record.Settings.MapName
	if (mapName == "" or mapName == nil) and self.loadedMap ~= nil then
		mapName = self.loadedMap.Model.Name
	end
	return {
		RoundId = self.roundId,
		GameMode = record.Settings.GameMode,
		MapName = mapName,
	}
end

function CustomGameService.eliminatePlayer(self, player: Player, damageType: string, killer: Player?)
	local record = self.record
	if record == nil or not record.InGame or player:GetAttribute("Alive") ~= true then
		return
	end
	player:SetAttribute("Alive", false)
	player:SetAttribute("Spectating", true)
	local powerUpService = self.context.powerUpService
	if powerUpService ~= nil then
		powerUpService:clearPlayer(player)
	end
	local regenerationService = self.context.regenerationService
	if regenerationService ~= nil then
		regenerationService:clearPlayer(player)
	end
	local fallDamageService = self.context.fallDamageService
	if fallDamageService ~= nil then
		fallDamageService:clearPlayer(player)
	end
	self.context.inventoryService:clear(player)
	table.insert(self.eliminatedPlayers, 1, player)
	local killCredit = if killer ~= nil and killer.Parent == Players then killer else nil
	-- Environmental eliminations (Fall/Void) arrive with no direct killer;
	-- credit the last attacker instead so a hit that knocks someone into the
	-- void logs — and feeds the kill feed with — the real killer. The tag is
	-- consumed either way: an eliminated player's tag is stale.
	local creditedWeapon: string? = nil
	local combatService = self.context.combatService
	if killCredit == nil and combatService ~= nil and combatService.getLastAttacker ~= nil then
		killCredit, creditedWeapon = combatService:getLastAttacker(player)
	end
	if combatService ~= nil and combatService.clearLastAttacker ~= nil then
		combatService:clearLastAttacker(player)
	end
	local position: Vector3? = nil
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		position = root.Position
	end
	for _, recipient in Players:GetPlayers() do
		self.context.outbound:fire("PlayerEliminated", recipient, player, killCredit, damageType, position)
		self.context.outbound:fire("PlayerKilled", recipient, player, killCredit, damageType, position or Vector3.zero)
	end
	self.context.outbound:fire("Spectate", player, nil, position, nil)
	self:replicateAll()

	-- Kill log: one structured line per elimination, printed to the server
	-- console and kept in the logger's bounded in-memory history.
	local killLog = self.context.killLog
	if killLog ~= nil then
		local killerWeapon: string? = creditedWeapon
		if killerWeapon == nil and killCredit ~= nil and killCredit.Character ~= nil then
			local tool = killCredit.Character:FindFirstChildOfClass("Tool")
			if tool ~= nil then
				killerWeapon = tool.Name
			end
		end
		local survivors = 0
		for _, candidate in Players:GetPlayers() do
			if candidate:GetAttribute("Alive") == true then
				survivors += 1
			end
		end
		local roundInfo = self:getRoundInfo()
		killLog:record({
			Kind = "Player",
			Victim = player.Name,
			VictimUserId = player.UserId,
			Killer = if killCredit ~= nil then killCredit.Name else nil,
			KillerUserId = if killCredit ~= nil then killCredit.UserId else nil,
			DamageType = damageType,
			Weapon = killerWeapon,
			Position = position,
			RoundId = roundInfo.RoundId,
			GameMode = roundInfo.GameMode,
			MapName = roundInfo.MapName,
			Survivors = survivors,
		})
	end

	local aliveTeams, aliveTeamCount = self:getAliveTeams()
	if aliveTeamCount <= 1 then
		local winners = {}
		for _, teamPlayers in aliveTeams do
			for _, winner in teamPlayers do
				table.insert(winners, winner)
			end
		end
		self:finishMatch(winners)
	end
end

function CustomGameService.finishMatch(self, winners: { Player })
	local record = self.record
	if record == nil or not record.InGame or self.roundState == "Ended" then
		return
	end
	self.roundState = "Ended"
	-- A round can end while the pre-game countdown is still running (players
	-- leaving mid-countdown); the cages must not survive into the post-game.
	self.pregameService:clear()
	-- Post-game is a lobby phase: bring the lobby world back.
	self.context.lobbyWorldService:showWorld()
	local placements = { winners }
	if #self.eliminatedPlayers > 0 then
		table.insert(placements, table.clone(self.eliminatedPlayers))
	end
	local gameResult = {
		winners = winners,
		placements = placements,
	}
	local playersPresent = Players:GetPlayers()
	self:replicateAll()
	for _, recipient in playersPresent do
		self.context.outbound:fire("GameResult", recipient, gameResult)
		self.context.outbound:fire("PlayersPresent", recipient, playersPresent)
	end
	local roundId = self.roundId
	task.delay(CustomGameConfig.PostGameDuration, function()
		if self.running and self.roundId == roundId then
			self:resetMatch()
		end
	end)
end

function CustomGameService.resetMatch(self)
	if self.record == nil then
		return
	end
	self.roundId += 1
	self.roundState = "Pregame"
	self.pregameService:clear()
	-- Back to a lobby phase: show the lobby world again BEFORE the respawn
	-- loop below, so LoadCharacter lands players on its SpawnLocations.
	self.context.lobbyWorldService:showWorld()
	self.mapService:unload()
	self.context.blockWorldService:clear()
	local combatService = self.context.combatService
	if combatService ~= nil and combatService.clearLastAttackers ~= nil then
		combatService:clearLastAttackers()
	end
	local powerUpService = self.context.powerUpService
	if powerUpService ~= nil then
		powerUpService:clearAll()
	end
	local regenerationService = self.context.regenerationService
	if regenerationService ~= nil then
		regenerationService:clearAll()
	end
	local fallDamageService = self.context.fallDamageService
	if fallDamageService ~= nil then
		fallDamageService:clearAll()
	end
	self.loadedMap = nil
	self:updateLocalRecord(function(record)
		record.InGame = false
	end)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("Alive", nil)
		player:SetAttribute("Spectating", false)
		self.context.outbound:fire("StopSpectating", player)
		pcall(function()
			player:LoadCharacter()
		end)
	end
	self:replicateAll()
end

function CustomGameService.bindHumanoid(self, player: Player)
	local existing = self.humanoidConnections[player]
	if existing ~= nil then
		existing:Disconnect()
		self.humanoidConnections[player] = nil
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		self.humanoidConnections[player] = humanoid.Died:Connect(function()
			-- Deaths only eliminate during the round proper. A death during
			-- the caged countdown (a player resetting) must not end the
			-- round — PregameService re-cages the respawned character.
			if self.roundState == "InGame" then
				self:eliminatePlayer(player, "Fall")
			end
		end)
	end
end

function CustomGameService.bindPlayer(self, player: Player)
	if self.characterConnections[player] ~= nil then
		return
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.defer(function()
			if self.record and self.record.InGame and player:GetAttribute("Alive") == true then
				self:bindHumanoid(player)
			end
		end)
	end)
end

function CustomGameService.validateAdmission(self, player: Player): boolean
	local record = self.record
	if record == nil then
		return false
	end
	local userIdKey = tostring(player.UserId)
	if
		record.BannedUserIds[userIdKey] or (record.OwnerId ~= player.UserId and not record.AdmittedUserIds[userIdKey])
	then
		player:Kick("You are not admitted to this custom game.")
		return false
	end
	return true
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
	self:bindPlayer(player)
	local record = self.record :: CustomGameRecord
	local teamId = record.TeamAssignments[tostring(player.UserId)]
	player:SetAttribute("TeamId", teamId)
	if record.InGame then
		self:spawnSpectator(player)
	end
	self:persistPresence()
	self:replicateAll()
	-- Mid-countdown arrivals (spectators admitted during the pre-game) get
	-- the remaining time on the countdown display. Fired after replicateAll
	-- so the client's GameStateChangeTime listener (connected when the
	-- scoreboard opens on the CustomGame update) already exists.
	self.pregameService:syncPlayer(player)
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
	-- Reserved custom-match servers swap the lobby world for the pre-game
	-- lobby before any player arrives (see LobbyWorldService).
	self.context.lobbyWorldService:setPregame()
end

function CustomGameService.onPlayerRemoving(self, player: Player)
	local record = self.record
	if record == nil then
		return
	end
	if record.InGame and player:GetAttribute("Alive") == true then
		self:eliminatePlayer(player, "Void")
	end
	local characterConnection = self.characterConnections[player]
	if characterConnection then
		characterConnection:Disconnect()
		self.characterConnections[player] = nil
	end
	local humanoidConnection = self.humanoidConnections[player]
	if humanoidConnection then
		humanoidConnection:Disconnect()
		self.humanoidConnections[player] = nil
	end
	task.defer(function()
		if self.record == nil then
			return
		end
		local remainingPlayers = Players:GetPlayers()
		if #remainingPlayers == 0 then
			self.store:removeRecord(self.record.Id)
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
	if self.record == nil or not self.record.InGame then
		return
	end
	self:spawnSpectator(player)
	self:replicateAll()
end

function CustomGameService.spectateTargetChanged(self, player: Player, target: Player)
	if self.record == nil or player:GetAttribute("Alive") == true or target:GetAttribute("Alive") ~= true then
		return
	end
	self.context.outbound:setValue(player, "Spectating", {
		Name = target.DisplayName,
		UserId = target.UserId,
	})
end

function CustomGameService.start(self)
	if self.running then
		return
	end
	self.running = true
	self:configureReservedServer()
	if self.record == nil then
		return
	end
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			task.spawn(function()
				self:initializePlayer(player)
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
		task.spawn(function()
			self:initializePlayer(player)
		end)
	end
	task.spawn(function()
		while self.running and self.record ~= nil do
			self:persistPresence()
			task.wait(CustomGameConfig.HeartbeatInterval)
		end
	end)
	task.spawn(function()
		while self.running and self.record ~= nil do
			local loadedMap = self.loadedMap
			if loadedMap ~= nil and self.record.InGame then
				for _, player in Players:GetPlayers() do
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if
						player:GetAttribute("Alive") == true
						and root
						and root:IsA("BasePart")
						and root.Position.Y < loadedMap.VoidY
					then
						self:eliminatePlayer(player, "Void")
					end
				end
			end
			task.wait(0.25)
		end
	end)
end

function CustomGameService.stop(self)
	self.running = false
	for _, connection in self.connections do
		connection:Disconnect()
	end
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	for _, connection in self.humanoidConnections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.characterConnections)
	table.clear(self.humanoidConnections)
	self.pregameService:clear()
	self.mapService:unload()
	self.context.blockWorldService:clear()
end

return CustomGameService
