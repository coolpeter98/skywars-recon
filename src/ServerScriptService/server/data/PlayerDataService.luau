--!strict
-- PlayerDataService
--
-- Owns player persistence through Drop. One Drop session is opened per
-- joining player; reads are applied onto the runtime profile and writes are
-- queued updates that Drop flushes with its own retry/locking (ACID).
--
-- Lifecycle:
--   * PlayerAdded  -> load (session start + read + apply to profile)
--   * PlayerRemoving -> save + session stop (flushes the update queue)
--   * autosave every AUTOSAVE_SECONDS while a session is active
--   * game:BindToClose is handled inside Drop (stops every session)

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Drop = require(ServerStorage.Drop)
local PlayerDataRules = require(script.Parent.PlayerDataRules)
local PlayerDataSchema = require(script.Parent.PlayerDataSchema)

local STORE_NAME = "PlayerData"
local AUTOSAVE_SECONDS = 60
local SESSION_START_RETRY_DELAYS = { 0, 2 }

local PlayerDataService = {}
PlayerDataService.__index = PlayerDataService

function PlayerDataService.new(context)
	return setmetatable({
		context = context,
		store = Drop.store({
			name = STORE_NAME,
			schema = PlayerDataSchema,
		}),
		loading = {} :: { [Player]: boolean },
		connections = {} :: { RBXScriptConnection },
		autosaveThread = nil :: thread?,
		started = false,
	}, PlayerDataService)
end

function PlayerDataService.getKey(_: PlayerDataService, player: Player): string
	return tostring(player.UserId)
end

-- Starts the Drop session for a player and applies the stored document onto
-- their runtime profile. Runs off-thread; the default profile the bootstrap
-- already replicated is replaced once the read completes.
function PlayerDataService.load(self: PlayerDataService, player: Player)
	if self.loading[player] or player.Parent ~= Players then
		return
	end
	self.loading[player] = true
	local key = self:getKey(player)

	task.spawn(function()
		local sessionStarted = false
		for _, delaySeconds in SESSION_START_RETRY_DELAYS do
			if delaySeconds > 0 then
				task.wait(delaySeconds)
			end
			if player.Parent ~= Players then
				self.loading[player] = nil
				return
			end
			local success, message = pcall(function()
				Drop.startsession(self.store, key)
			end)
			if success then
				sessionStarted = true
				break
			else
				warn(
					("[PlayerDataService] Session start for %s failed (attempt): %s"):format(
						player.Name,
						tostring(message)
					)
				)
			end
		end
		if not sessionStarted then
			self.loading[player] = nil
			return
		end

		-- Yields until the session reads (or falls back to the initial
		-- document when the first read fails).
		Drop.waitforsession(self.store, key)

		local session = self.context.playerSessions:get(player)
		if session == nil or player.Parent ~= Players then
			self.loading[player] = nil
			return
		end

		local data = Drop.view(self.store, key)
		PlayerDataRules.applyPlayerData(session.profile, data)
		self.context.outbound:sendProfile(player, session.profile)
		local nametagService = self.context.nametagService
		if nametagService ~= nil then
			nametagService:refreshAttributes(player)
		end
		self.loading[player] = nil
	end)
end

-- Queues a save of the runtime profile. Drop applies the update to the
-- session cache immediately and flushes to the datastore on its own clock,
-- so callers never wait.
function PlayerDataService.save(self: PlayerDataService, player: Player)
	if player.Parent ~= Players then
		return
	end
	local key = self:getKey(player)
	if not Drop.issessionactive(self.store, key) then
		return
	end
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local profile = session.profile

	local success, message = pcall(function()
		Drop.update(self.store, key, function(data)
			return PlayerDataRules.capturePlayerData(profile, data)
		end)
	end)
	if not success then
		warn(("[PlayerDataService] Save for %s failed: %s"):format(player.Name, tostring(message)))
	end
end

-- PlayerRemoving hook: final save, then stop the session (flushes the queue).
-- PlayerSessions calls this before removing the session itself.
function PlayerDataService.onPlayerRemoving(self: PlayerDataService, player: Player)
	self:save(player)
	local key = self:getKey(player)
	if Drop.issessionactive(self.store, key) then
		task.spawn(function()
			local success, message = pcall(function()
				Drop.stopsessionasync(self.store, key)
			end)
			if not success then
				warn(("[PlayerDataService] Session stop for %s failed: %s"):format(player.Name, tostring(message)))
			end
		end)
	end
	self.loading[player] = nil
end

function PlayerDataService.start(self: PlayerDataService)
	if self.started then
		return
	end
	self.started = true

	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			-- PlayerSessions' own PlayerAdded handler bootstraps the session
			-- synchronously; ours runs afterwards, so the session exists.
			self:load(player)
		end)
	)

	self.autosaveThread = task.spawn(function()
		while self.started do
			task.wait(AUTOSAVE_SECONDS)
			if not self.started then
				break
			end
			for _, player in Players:GetPlayers() do
				self:save(player)
			end
		end
	end)

	for _, player in Players:GetPlayers() do
		self:load(player)
	end
end

function PlayerDataService.stop(self: PlayerDataService)
	if not self.started then
		return
	end
	self.started = false
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.loading)
end

return PlayerDataService
