--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedDataProfileTemplate = require(ReplicatedStorage.TS.profile["data-profile"]).SharedDataProfileTemplate

export type PlayerSession = {
	player: Player,
	profile: { [string]: any },
	party: { [string]: any },
	friends: { any },
	friendIds: { number },
	showVerify: boolean,
	inventory: {
		Size: number,
		Contents: { [number]: { Slot: number, Type: string, Quantity: number } },
	},
	activeSlot: number,
	gameCurrency: { Quantities: { [string]: number } },
	equippedArmour: { [string]: string },
	heldItemType: string?,
	openChest: Model?,
	pendingInventoryPredictions: {
		[string]: { itemType: string, quantity: number, createdAt: number },
	},
}

local BOOTSTRAP_RETRY_DELAYS = { 0, 0.5, 1, 2, 4, 8 }
local INVENTORY_SIZE = 23

local PlayerSessions = {}
PlayerSessions.__index = PlayerSessions

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[deepCopy(key)] = deepCopy(child)
	end
	return copy
end

local function createParty(player: Player): { [string]: any }
	return {
		Id = "",
		Owner = {
			UserId = player.UserId,
			UserName = player.Name,
			DisplayName = player.DisplayName,
		},
		Players = { player.UserId },
		Invites = {},
	}
end

export type DataServiceLike = {
	onPlayerRemoving: (self: DataServiceLike, player: Player) -> (),
}

function PlayerSessions.new(outbound)
	return setmetatable({
		outbound = outbound,
		sessions = {} :: { [Player]: PlayerSession },
		connections = {} :: { RBXScriptConnection },
		dataService = nil :: DataServiceLike?,
		started = false,
	}, PlayerSessions)
end

-- Injected after construction (the data service itself reads sessions).
function PlayerSessions.setDataService(self, dataService: DataServiceLike)
	self.dataService = dataService
end

function PlayerSessions.get(self, player: Player): PlayerSession?
	return self.sessions[player]
end

function PlayerSessions.require(self, player: Player): PlayerSession
	local session = self.sessions[player]
	if session == nil then
		error(("No active session for %s"):format(player.Name))
	end
	return session
end

function PlayerSessions.bootstrap(self, player: Player)
	if self.sessions[player] ~= nil then
		return
	end
	local session: PlayerSession = {
		player = player,
		profile = deepCopy(SharedDataProfileTemplate),
		party = createParty(player),
		friends = {},
		friendIds = {},
		showVerify = false,
		inventory = {
			Size = INVENTORY_SIZE,
			Contents = {},
		},
		activeSlot = 0,
		gameCurrency = {
			Quantities = {
				TierOne = 0,
				TierTwo = 0,
				TierThree = 0,
				TierFour = 0,
			},
		},
		equippedArmour = {},
		heldItemType = nil,
		openChest = nil,
		pendingInventoryPredictions = {},
	}
	self.sessions[player] = session

	task.spawn(function()
		for attemptIndex, delaySeconds in BOOTSTRAP_RETRY_DELAYS do
			if delaySeconds > 0 then
				task.wait(delaySeconds)
			end
			local currentSession = self.sessions[player]
			if currentSession == nil or player.Parent ~= Players then
				return
			end
			self.outbound:sendBootstrap(player, currentSession, attemptIndex == 1, attemptIndex == 1)
		end
	end)

	task.spawn(function()
		local success, message = pcall(function()
			player:LoadCharacter()
		end)
		if not success then
			warn(
				("[Server] Character load failed for %s (%d): %s"):format(player.Name, player.UserId, tostring(message))
			)
		end
	end)
end

function PlayerSessions.remove(self, player: Player)
	self.sessions[player] = nil
end

function PlayerSessions.start(self)
	if self.started then
		return
	end
	self.started = true
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			self:bootstrap(player)
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			-- Persist before the session is dropped; the data service's own
			-- PlayerRemoving hook would otherwise run after the removal.
			if self.dataService ~= nil then
				self.dataService:onPlayerRemoving(player)
			end
			self:remove(player)
		end)
	)
	for _, player in Players:GetPlayers() do
		self:bootstrap(player)
	end
end

function PlayerSessions.stop(self)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.sessions)
	self.started = false
end

return PlayerSessions
