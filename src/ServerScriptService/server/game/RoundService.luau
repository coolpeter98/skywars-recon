--!strict

local Players = game:GetService("Players")

local ModeRegistry = require(script.Parent.Parent.modes.ModeRegistry)
local MapService = require(script.Parent.MapService)
local PregameService = require(script.Parent.PregameService)
local RoundConfig = require(script.Parent.RoundConfig)

export type RoundSession = {
	Id: string,
	Kind: "Custom" | "Public",
	GameMode: string,
	MapName: string,
	MinimumPlayers: number,
	AllowTeamSelection: boolean,
	ParticipantUserIds: { [string]: boolean },
	TeamAssignments: { [string]: string },
	AutoStart: boolean,
	Repeatable: boolean,
	OnReset: (() -> ())?,
	OnFinished: (({ Player }) -> ())?,
}

type RespawningPlayer = {
	RoundId: number,
	TeamId: string,
}

local RoundService = {}
RoundService.__index = RoundService

local REPLICATION_RETRY_DELAYS = { 0.5, 1, 2, 4, 8, 16 }

local function countDictionary(dictionary: { [string]: any }): number
	local count = 0
	for _ in dictionary do
		count += 1
	end
	return count
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

function RoundService.new(context)
	return setmetatable({
		context = context,
		mapService = MapService.new(),
		pregameService = PregameService.new(context),
		session = nil :: RoundSession?,
		loadedMap = nil :: MapService.LoadedMap?,
		connections = {} :: { RBXScriptConnection },
		characterConnections = {} :: { [Player]: RBXScriptConnection },
		humanoidConnections = {} :: { [Player]: RBXScriptConnection },
		initializedPlayers = {} :: { [Player]: boolean },
		eliminatedPlayers = {} :: { Player },
		respawningPlayers = {} :: { [Player]: RespawningPlayer },
		roundId = 0,
		roundState = "Pregame",
		gameStateChangeTime = os.time(),
		roundActive = false,
		running = false,
	}, RoundService)
end

function RoundService.getAdapter(self)
	local session = self.session
	return if session ~= nil then ModeRegistry.get(session.GameMode) else nil
end

function RoundService.getModeSession(self)
	local session = self.session
	if session == nil then
		return nil
	end
	return {
		Settings = {
			GameMode = session.GameMode,
			MapName = session.MapName,
			AllowTeamSelection = session.AllowTeamSelection,
			MinimumPlayers = session.MinimumPlayers,
		},
		TeamAssignments = session.TeamAssignments,
	}
end

function RoundService.configure(self, session: RoundSession): boolean
	local adapter = ModeRegistry.get(session.GameMode)
	if adapter == nil then
		warn(("[RoundService] No runtime adapter is registered for %s."):format(session.GameMode))
		return false
	end
	if self.session ~= nil and self.session.Id ~= session.Id then
		self:clearSession()
	end
	self.session = session
	self.roundState = "Pregame"
	self.gameStateChangeTime = os.time()
	self.roundActive = false
	self.context.lobbyWorldService:setPregame()
	self:replicateAll()
	if session.AutoStart then
		local configuredRoundId = self.roundId
		task.delay(RoundConfig.PublicArrivalTimeout, function()
			if self.running and self.roundId == configuredRoundId and self.session == session then
				self:tryAutoStart(true)
			end
		end)
	end
	return true
end

function RoundService.updateConfiguration(
	self,
	gameMode: string,
	mapName: string,
	minimumPlayers: number,
	allowTeamSelection: boolean,
	teamAssignments: { [string]: string }
)
	local session = self.session
	if session == nil or self.roundState ~= "Pregame" or self.roundActive then
		return
	end
	session.GameMode = gameMode
	session.MapName = mapName
	session.MinimumPlayers = minimumPlayers
	session.AllowTeamSelection = allowTeamSelection
	session.TeamAssignments = teamAssignments
	self:replicateAll()
end

function RoundService.getBuildConstraints(self): { MapService.BuildConstraint }
	local session = self.session
	local loadedMap = self.loadedMap
	if session == nil or loadedMap == nil or self.roundState ~= "InGame" then
		return {}
	end
	return loadedMap.BuildConstraints
end

function RoundService.isBlockPlacementAllowed(self, player: Player, position: Vector3): boolean
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

function RoundService.isInRound(self): boolean
	return self.session ~= nil and self.roundState == "InGame"
end

function RoundService.buildGameTeams(self): { [string]: any }
	local adapter = self:getAdapter()
	local modeSession = self:getModeSession()
	if adapter == nil or modeSession == nil then
		return {}
	end
	local gameTeams = adapter.buildGameTeams(modeSession)
	if self.roundState ~= "Pregame" then
		for _, team in gameTeams do
			team.AliveCount = 0
		end
		for _, candidate in Players:GetPlayers() do
			local teamId = candidate:GetAttribute("TeamId")
			local team = if type(teamId) == "string" then gameTeams[teamId] else nil
			if
				team ~= nil
				and (candidate:GetAttribute("Alive") == true or self.respawningPlayers[candidate] ~= nil)
			then
				team.AliveCount += 1
			end
		end
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:applyGameTeams(gameTeams)
	end
	return gameTeams
end

function RoundService.replicatePlayer(self, player: Player)
	local session = self.session
	local adapter = self:getAdapter()
	local modeSession = self:getModeSession()
	if session == nil or adapter == nil or modeSession == nil or player.Parent ~= Players then
		return
	end
	player:SetAttribute("TeamId", session.TeamAssignments[tostring(player.UserId)])
	local settings = adapter.buildSettings(modeSession)
	self.context.outbound:setValue(player, "GameSettings", settings)
	self.context.outbound:setValue(player, "GameTeams", self:buildGameTeams())
	self.context.outbound:setValue(player, "BuildConstraints", self:getBuildConstraints())
	local aliveUserIds = {}
	for _, candidate in Players:GetPlayers() do
		if
			self.roundState == "Pregame"
			or candidate:GetAttribute("Alive") == true
			or self.respawningPlayers[candidate] ~= nil
		then
			table.insert(aliveUserIds, candidate.UserId)
		end
	end
	self.context.outbound:setValue(player, "Players", aliveUserIds)
	self.context.outbound:setValue(player, "GameState", self.roundState)
	self.context.outbound:setValue(player, "GameStateChangeTime", self.gameStateChangeTime)
	-- Inventory rearrangement is client-local; sendGameCurrency only. Starter
	-- inventory is sent once in spawnPlayer, so a full snapshot here would
	-- overwrite the player's chosen slot layout.
	local playerSession = self.context.playerSessions:get(player)
	if playerSession ~= nil then
		self.context.outbound:sendGameCurrency(player, playerSession.gameCurrency)
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:replicatePlayer(player)
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil then
		bridgeService:replicatePlayer(player)
	end
end

function RoundService.replicateAll(self)
	for _, player in Players:GetPlayers() do
		if self.initializedPlayers[player] or self.session and self.session.Kind == "Custom" then
			self:replicatePlayer(player)
		end
	end
end

function RoundService.bindHumanoid(self, player: Player)
	local existing = self.humanoidConnections[player]
	if existing ~= nil then
		existing:Disconnect()
		self.humanoidConnections[player] = nil
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		self.humanoidConnections[player] = humanoid.Died:Connect(function()
			if self.roundState == "InGame" then
				self:eliminatePlayer(player, "Fall")
			end
		end)
	end
end

function RoundService.bindPlayer(self, player: Player)
	if self.characterConnections[player] ~= nil then
		return
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.defer(function()
			if self.session ~= nil and player:GetAttribute("Alive") == true then
				self:bindHumanoid(player)
			end
		end)
	end)
end

function RoundService.spawnPlayer(self, player: Player, teamId: string, reloadCharacter: boolean?): CFrame?
	local loadedMap = self.loadedMap
	local adapter = self:getAdapter()
	local session = self.session
	if loadedMap == nil or adapter == nil or session == nil then
		return nil
	end
	local spawnCFrame = loadedMap.SpawnPositions[teamId]
	if spawnCFrame == nil then
		return nil
	end
	local character = player.Character
	if character == nil or reloadCharacter == true then
		local previousCharacter = character
		local success = pcall(function()
			player:LoadCharacter()
		end)
		if not success then
			return nil
		end
		character = player.Character
		if character == nil or character == previousCharacter then
			character = player.CharacterAdded:Wait()
		end
	end
	character:PivotTo(spawnCFrame)
	player:SetAttribute("Alive", true)
	player:SetAttribute("Spectating", false)
	player:SetAttribute("TeamId", teamId)
	player:SetAttribute("Health", 100)
	player:SetAttribute("Shield", 0)
	if self.context.regenerationService ~= nil then
		self.context.regenerationService:resetPlayer(player)
	end
	if self.context.fallDamageService ~= nil then
		self.context.fallDamageService:resetPlayer(player)
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.Health = humanoid.MaxHealth
	end
	self.context.inventoryService:clear(player)
	local starterItems, heldItem = adapter.getStarterInventory(session.GameMode)
	local spawnArmour = {} :: { string }
	if type(adapter.getStarterArmour) == "function" then
		spawnArmour = adapter.getStarterArmour(session.GameMode)
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil and eggWarsService:isActive() then
		starterItems, heldItem, spawnArmour = eggWarsService:getSpawnInventory(player)
	end
	for _, item in starterItems do
		self.context.inventoryService:changeItem(player, item.Type, item.Quantity)
	end
	for _, itemType in spawnArmour do
		self.context.inventoryService:equipArmour(player, itemType)
	end
	-- One authoritative snapshot after starter items/armour settle; later
	-- changes go as deltas so client-local slot ordering survives the round.
	local playerSession = self.context.playerSessions:require(player)
	self.context.outbound:sendInventory(player, playerSession.inventory)
	self.context.outbound:sendActiveSlot(player, playerSession.activeSlot)
	if heldItem ~= nil then
		self.context.inventoryService:setHeldItem(player, heldItem)
	end
	self:bindHumanoid(player)
	if self.context.experienceService ~= nil then
		self.context.experienceService:onPlayerSpawned(player)
	end
	return spawnCFrame
end

function RoundService.spawnSpectator(self, player: Player)
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

function RoundService.initializePlayer(self, player: Player)
	local deadline = os.clock() + 10
	while self.context.playerSessions:get(player) == nil and player.Parent == Players and os.clock() < deadline do
		task.wait()
	end
	local session = self.session
	if player.Parent ~= Players or self.context.playerSessions:get(player) == nil or session == nil then
		return
	end
	-- PlayerSessions fires its first bootstrap (@@INIT) as soon as the session
	-- exists; yield once so it can't erase the values replicated below.
	task.wait()
	if player.Parent ~= Players or self.session ~= session then
		return
	end
	if session.Kind == "Public" and not session.ParticipantUserIds[tostring(player.UserId)] then
		return
	end
	self.initializedPlayers[player] = true
	self:bindPlayer(player)
	player:SetAttribute("TeamId", session.TeamAssignments[tostring(player.UserId)])
	if self.roundState ~= "Pregame" then
		self:spawnSpectator(player)
	end
	self:replicatePlayer(player)
	self.pregameService:syncPlayer(player)
	self:tryAutoStart(false)
	local initializedSession = session
	task.spawn(function()
		for _, delaySeconds in REPLICATION_RETRY_DELAYS do
			task.wait(delaySeconds)
			if not self.running or player.Parent ~= Players or self.session ~= initializedSession then
				return
			end
			self:replicatePlayer(player)
		end
	end)
end

function RoundService.getReadyParticipantCount(self): number
	local session = self.session
	if session == nil then
		return 0
	end
	local count = 0
	for player in self.initializedPlayers do
		if player.Parent == Players and session.ParticipantUserIds[tostring(player.UserId)] then
			count += 1
		end
	end
	return count
end

function RoundService.tryAutoStart(self, force: boolean)
	local session = self.session
	if session == nil or not session.AutoStart or self.roundState ~= "Pregame" or self.roundActive then
		return
	end
	local readyCount = self:getReadyParticipantCount()
	local expectedCount = countDictionary(session.ParticipantUserIds)
	if readyCount == expectedCount and readyCount >= session.MinimumPlayers then
		self:startRound()
	elseif force then
		if readyCount >= session.MinimumPlayers then
			self:startRound()
		else
			warn(
				("[RoundService] Match %s did not receive enough players; returning arrivals to the lobby."):format(
					session.Id
				)
			)
			self:completePublicRound()
		end
	end
end

function RoundService.startRound(self): boolean
	local session = self.session
	if session == nil or self.roundState ~= "Pregame" or self.roundActive then
		return false
	end
	self.roundActive = true
	self.roundId += 1
	local roundId = self.roundId
	table.clear(self.eliminatedPlayers)
	table.clear(self.respawningPlayers)
	if self.context.experienceService ~= nil then
		self.context.experienceService:onRoundStarted()
	end
	self.loadedMap = self.mapService:load(session.GameMode, session.MapName)
	if self.loadedMap == nil then
		warn(("[RoundService] Could not load a map for %s."):format(session.GameMode))
		self.roundActive = false
		if session.Kind == "Public" then
			self:completePublicRound()
		end
		return false
	end
	self.context.blockWorldService:rebuild(self.loadedMap.Model)
	self.gameStateChangeTime = os.time()
	self:replicateAll()
	-- Map load/rebuild is synchronous; yield so clients receive the ready
	-- Pregame snapshot and mount the game UI before the countdown events fire.
	task.wait()
	if not self.running or self.roundId ~= roundId or self.session ~= session or self.roundState ~= "Pregame" then
		self.roundActive = false
		return false
	end
	local lobbyCountdown = self.pregameService:startLobbyCountdown()
	task.delay(lobbyCountdown, function()
		if not self.running or self.roundId ~= roundId or self.session ~= session or self.roundState ~= "Pregame" then
			return
		end
		local eggWarsService = self.context.eggWarsService
		local bridgeService = self.context.bridgeService
		local loadedMap = self.loadedMap
		local eggWarsPrepared = eggWarsService == nil
			or loadedMap == nil
			or eggWarsService:prepareRound(session.GameMode, loadedMap.Model)
		local bridgePrepared = bridgeService == nil
			or loadedMap == nil
			or bridgeService:prepareRound(session.GameMode, loadedMap.Model)
		if not eggWarsPrepared or not bridgePrepared then
			local selectedMapName = self.loadedMap.Model:GetAttribute("SelectedMapName")
			warn(
				("[RoundService] Could not populate runtime map %s for %s."):format(
					if type(selectedMapName) == "string" then selectedMapName else self.loadedMap.Model.Name,
					session.GameMode
				)
			)
			self.roundActive = false
			if session.Kind == "Public" then
				self:completePublicRound()
			else
				self:resetRound()
			end
			return
		end
		local cagedPlayers = {}
		local cagedSpawns = {}
		for _, participant in Players:GetPlayers() do
			local userIdKey = tostring(participant.UserId)
			local teamId = session.TeamAssignments[userIdKey]
			if session.ParticipantUserIds[userIdKey] and teamId ~= nil then
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
		self.gameStateChangeTime = os.time()
		self.context.lobbyWorldService:hideWorld()
		self:replicateAll()
		-- Client Flamework may still be attaching after the large arena arrives.
		-- Retry the complete cage snapshot without another @@INIT reset.
		task.spawn(function()
			for _, delaySeconds in REPLICATION_RETRY_DELAYS do
				task.wait(delaySeconds)
				if not self.running or self.roundId ~= roundId or self.session ~= session then
					return
				end
				for _, participant in cagedPlayers do
					self:replicatePlayer(participant)
				end
			end
		end)
		self.pregameService:begin(cagedPlayers, cagedSpawns, RoundConfig.CountdownDuration)
		task.delay(RoundConfig.CountdownDuration, function()
			if
				not self.running
				or self.roundId ~= roundId
				or self.session ~= session
				or self.roundState ~= "Countdown"
			then
				return
			end
			self.pregameService:finish()
			self.roundState = "InGame"
			self.gameStateChangeTime = os.time()
			if bridgeService ~= nil then
				bridgeService:onCagesReleased()
			end
			self:replicateAll()
			for _, participant in Players:GetPlayers() do
				self.context.outbound:fire("GameStateChangeTime", participant, 0)
				self.context.outbound:fire("GameStarted", participant)
			end
		end)
	end)
	return true
end

function RoundService.beginBridgeScoreReset(self, duration: number): boolean
	local session = self.session
	local bridgeService = self.context.bridgeService
	if
		session == nil
		or self.loadedMap == nil
		or self.roundState ~= "InGame"
		or not self.roundActive
		or bridgeService == nil
		or not bridgeService:isActive()
	then
		return false
	end
	local roundId = self.roundId
	bridgeService:onCagesStarted()
	self.roundState = "Countdown"
	self.gameStateChangeTime = os.time()
	table.clear(self.respawningPlayers)
	self.context.combatService:clearLastAttackers()
	self.context.powerUpService:clearAll()
	self.context.regenerationService:clearAll()
	self.context.fallDamageService:clearAll()

	local cagedPlayers = {}
	local cagedSpawns = {}
	for _, participant in Players:GetPlayers() do
		local userIdKey = tostring(participant.UserId)
		local teamId = session.TeamAssignments[userIdKey]
		if session.ParticipantUserIds[userIdKey] and teamId ~= nil then
			local spawnCFrame = self:spawnPlayer(participant, teamId, true)
			if spawnCFrame ~= nil then
				table.insert(cagedPlayers, participant)
				cagedSpawns[participant] = spawnCFrame
			end
		else
			self:spawnSpectator(participant)
		end
	end
	self:replicateAll()
	self.pregameService:begin(cagedPlayers, cagedSpawns, duration, "BridgeReset")
	task.delay(duration, function()
		if
			not self.running
			or self.roundId ~= roundId
			or self.session ~= session
			or self.roundState ~= "Countdown"
			or not bridgeService:isActive()
		then
			return
		end
		self.pregameService:finish()
		self.roundState = "InGame"
		self.gameStateChangeTime = os.time()
		bridgeService:onCagesReleased()
		self:replicateAll()
		for _, participant in Players:GetPlayers() do
			self.context.outbound:fire("GameStateChangeTime", participant, 0)
		end
	end)
	return true
end

function RoundService.getAliveTeams(self): ({ [string]: { Player } }, number)
	local teams = {}
	for _, player in Players:GetPlayers() do
		local respawn = self.respawningPlayers[player]
		if player:GetAttribute("Alive") == true or respawn ~= nil then
			local teamId = if respawn ~= nil then respawn.TeamId else player:GetAttribute("TeamId")
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

function RoundService.checkForWinner(self)
	if self.roundState ~= "Countdown" and self.roundState ~= "InGame" then
		return
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil and bridgeService:isActive() then
		return
	end
	local aliveTeams, aliveTeamCount = self:getAliveTeams()
	if aliveTeamCount > 1 then
		return
	end
	local winners = {}
	for _, teamPlayers in aliveTeams do
		for _, winner in teamPlayers do
			table.insert(winners, winner)
		end
	end
	self:finishRound(winners)
end

function RoundService.getRoundInfo(self): { RoundId: number?, GameMode: string?, MapName: string? }
	local session = self.session
	if session == nil then
		return {}
	end
	local mapName = session.MapName
	if self.loadedMap ~= nil then
		local selectedMapName = self.loadedMap.Model:GetAttribute("SelectedMapName")
		mapName = if type(selectedMapName) == "string" then selectedMapName else self.loadedMap.Model.Name
	end
	return {
		RoundId = self.roundId,
		GameMode = session.GameMode,
		MapName = mapName,
	}
end

function RoundService.eliminatePlayer(self, player: Player, damageType: string, killer: Player?)
	if (self.roundState ~= "Countdown" and self.roundState ~= "InGame") or player:GetAttribute("Alive") ~= true then
		return
	end
	local killCredit = if killer ~= nil and killer.Parent == Players then killer else nil
	local creditedWeapon: string? = nil
	local combatService = self.context.combatService
	if killCredit == nil and combatService ~= nil then
		killCredit, creditedWeapon = combatService:getLastAttacker(player)
	end
	if combatService ~= nil then
		combatService:clearLastAttacker(player)
	end
	local teamId = player:GetAttribute("TeamId")
	local eggWarsService = self.context.eggWarsService
	local eggWarsRespawn = eggWarsService ~= nil
		and eggWarsService:isActive()
		and type(teamId) == "string"
		and eggWarsService:canRespawn(player)
	local bridgeService = self.context.bridgeService
	local bridgeRespawn = bridgeService ~= nil
		and bridgeService:isActive()
		and type(teamId) == "string"
		and bridgeService:canRespawn(player)
	local willRespawn = eggWarsRespawn or bridgeRespawn
	if eggWarsService ~= nil then
		eggWarsService:onPlayerDefeated(player, killCredit)
	end
	local experienceService = self.context.experienceService
	if experienceService ~= nil then
		experienceService:onElimination(player, killCredit)
	end

	local position: Vector3? = nil
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		position = root.Position
	end
	player:SetAttribute("Alive", false)
	player:SetAttribute("Spectating", true)
	if self.context.powerUpService ~= nil then
		self.context.powerUpService:clearPlayer(player)
	end
	if self.context.regenerationService ~= nil then
		self.context.regenerationService:clearPlayer(player)
	end
	if self.context.fallDamageService ~= nil then
		self.context.fallDamageService:clearPlayer(player)
	end
	self.context.inventoryService:clear(player)
	if willRespawn then
		self.respawningPlayers[player] = {
			RoundId = self.roundId,
			TeamId = teamId :: string,
		}
	else
		table.insert(self.eliminatedPlayers, 1, player)
	end
	for _, recipient in Players:GetPlayers() do
		self.context.outbound:fire("PlayerKilled", recipient, player, killCredit, damageType, position or Vector3.zero)
		if not willRespawn then
			self.context.outbound:fire("PlayerEliminated", recipient, player, killCredit, damageType, position)
		end
	end
	local respawnDelay: number? = nil
	if bridgeRespawn and bridgeService ~= nil then
		respawnDelay = bridgeService:getRespawnDelay()
	elseif eggWarsRespawn and eggWarsService ~= nil then
		respawnDelay = eggWarsService:getRespawnDelay()
	end
	self.context.outbound:fire("Spectate", player, nil, position, respawnDelay)
	self:replicateAll()
	local killLog = self.context.killLog
	if killLog ~= nil then
		local killerWeapon = creditedWeapon
		if killerWeapon == nil and killCredit ~= nil and killCredit.Character ~= nil then
			local tool = killCredit.Character:FindFirstChildOfClass("Tool")
			killerWeapon = if tool ~= nil then tool.Name else nil
		end
		local aliveTeams = self:getAliveTeams()
		local survivors = 0
		for _, teamPlayers in aliveTeams do
			survivors += #teamPlayers
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
	if willRespawn and respawnDelay ~= nil then
		local respawnRoundId = self.roundId
		task.delay(respawnDelay, function()
			local respawn = self.respawningPlayers[player]
			if
				respawn == nil
				or respawn.RoundId ~= respawnRoundId
				or self.roundId ~= respawnRoundId
				or (self.roundState ~= "Countdown" and self.roundState ~= "InGame")
				or player.Parent ~= Players
			then
				return
			end
			self.respawningPlayers[player] = nil
			if self:spawnPlayer(player, respawn.TeamId, true) == nil then
				self:checkForWinner()
				return
			end
			self.context.outbound:setValue(player, "RespawnTime", nil)
			self.context.outbound:fire("StopSpectating", player)
			self.context.outbound:fire("Respawn", player)
			self:replicateAll()
		end)
	end
	-- Respawn-awaiting players keep their team alive; checking the winner
	-- here would end a one-team round before the respawn lands.
	if not willRespawn then
		self:checkForWinner()
	end
end

function RoundService.finishRound(self, winners: { Player })
	local session = self.session
	if session == nil or self.roundState == "Ended" then
		return
	end
	self.roundState = "Ended"
	self.gameStateChangeTime = os.time()
	table.clear(self.respawningPlayers)
	self.pregameService:clear()
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:endRound()
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil then
		bridgeService:endRound()
	end
	self.context.lobbyWorldService:showWorld()
	local placements = { winners }
	if #self.eliminatedPlayers > 0 then
		table.insert(placements, table.clone(self.eliminatedPlayers))
	end
	-- Award XP and replicate before GameResult so GameStats/Profile land first.
	local experienceService = self.context.experienceService
	if experienceService ~= nil then
		experienceService:onRoundEnded(winners, placements)
	end
	local playersPresent = Players:GetPlayers()
	self:replicateAll()
	for _, recipient in playersPresent do
		self.context.outbound:fire("GameResult", recipient, { winners = winners, placements = placements })
		self.context.outbound:fire("PlayersPresent", recipient, playersPresent)
	end
	if session.OnFinished ~= nil then
		session.OnFinished(winners)
	end
	local roundId = self.roundId
	task.delay(RoundConfig.PostGameDuration, function()
		if not self.running or self.roundId ~= roundId or self.session ~= session then
			return
		end
		if session.Repeatable then
			self:resetRound()
		else
			self:completePublicRound()
		end
	end)
end

function RoundService.resetRound(self)
	local session = self.session
	if session == nil then
		return
	end
	self.roundId += 1
	self.roundState = "Pregame"
	self.gameStateChangeTime = os.time()
	self.roundActive = false
	self.pregameService:clear()
	table.clear(self.respawningPlayers)
	if self.context.experienceService ~= nil then
		self.context.experienceService:clearRound()
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:clearRound()
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil then
		bridgeService:clearRound()
	end
	self.context.lobbyWorldService:showWorld()
	self.mapService:unload()
	self.context.blockWorldService:clear()
	self.context.combatService:clearLastAttackers()
	self.context.powerUpService:clearAll()
	self.context.regenerationService:clearAll()
	self.context.fallDamageService:clearAll()
	self.loadedMap = nil
	for _, player in Players:GetPlayers() do
		player:SetAttribute("Alive", nil)
		player:SetAttribute("Spectating", false)
		self.context.outbound:fire("StopSpectating", player)
		pcall(function()
			player:LoadCharacter()
		end)
	end
	if session.OnReset ~= nil then
		session.OnReset()
	end
	self:replicateAll()
end

function RoundService.completePublicRound(self)
	local session = self.session
	if session == nil or session.Kind ~= "Public" then
		return
	end
	self.roundActive = true
	table.clear(self.respawningPlayers)
	local experienceService = self.context.experienceService
	if experienceService ~= nil then
		experienceService:clearRound()
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:clearRound()
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil then
		bridgeService:clearRound()
	end
	if self.roundState ~= "Ended" then
		self.roundState = "Ended"
		self.gameStateChangeTime = os.time()
		self.context.lobbyWorldService:showWorld()
		self:replicateAll()
	end
	for _, player in Players:GetPlayers() do
		self.context.matchmakingService:teleportToLobby(player)
	end
end

function RoundService.requestSpectate(self, player: Player)
	if self.session == nil or self.roundState == "Pregame" or self.respawningPlayers[player] ~= nil then
		return
	end
	self:spawnSpectator(player)
	self:replicateAll()
end

function RoundService.spectateTargetChanged(self, player: Player, target: Player)
	if self.session == nil or player:GetAttribute("Alive") == true or target:GetAttribute("Alive") ~= true then
		return
	end
	self.context.outbound:setValue(player, "Spectating", {
		Name = target.DisplayName,
		UserId = target.UserId,
	})
end

function RoundService.onPlayerRemoving(self, player: Player)
	if (self.roundState == "Countdown" or self.roundState == "InGame") and player:GetAttribute("Alive") == true then
		self:eliminatePlayer(player, "Void")
	end
	if self.respawningPlayers[player] ~= nil then
		self.respawningPlayers[player] = nil
		self:checkForWinner()
	end
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:onPlayerRemoving(player)
	end
	self.initializedPlayers[player] = nil
	local characterConnection = self.characterConnections[player]
	if characterConnection ~= nil then
		characterConnection:Disconnect()
		self.characterConnections[player] = nil
	end
	local humanoidConnection = self.humanoidConnections[player]
	if humanoidConnection ~= nil then
		humanoidConnection:Disconnect()
		self.humanoidConnections[player] = nil
	end
end

function RoundService.clearSession(self)
	self.roundId += 1
	self.pregameService:clear()
	local eggWarsService = self.context.eggWarsService
	if eggWarsService ~= nil then
		eggWarsService:clearRound()
	end
	local bridgeService = self.context.bridgeService
	if bridgeService ~= nil then
		bridgeService:clearRound()
	end
	self.mapService:unload()
	self.context.blockWorldService:clear()
	self.loadedMap = nil
	self.session = nil
	self.roundState = "Pregame"
	self.gameStateChangeTime = os.time()
	self.roundActive = false
	table.clear(self.initializedPlayers)
	table.clear(self.eliminatedPlayers)
	table.clear(self.respawningPlayers)
	if self.context.experienceService ~= nil then
		self.context.experienceService:clearRound()
	end
end

function RoundService.start(self)
	if self.running then
		return
	end
	self.running = true
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			local session = self.session
			if session ~= nil and session.Kind == "Public" then
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
		local session = self.session
		if session ~= nil and session.Kind == "Public" then
			task.spawn(function()
				self:initializePlayer(player)
			end)
		end
	end
	task.spawn(function()
		while self.running do
			local loadedMap = self.loadedMap
			if loadedMap ~= nil and self.roundState == "InGame" then
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

function RoundService.stop(self)
	self.running = false
	self:clearSession()
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
end

return RoundService
