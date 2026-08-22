--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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

-- The recovered lobby's SpawnLocation parts are all Neutral (the original
-- server spawned players by script, never through Roblox's spawn system),
-- so Player:LoadCharacter() has no eligible spawn and places the character
-- at the workspace origin — the endless void in this terrain-less place.
-- The original server's own spawn data survives in the lobby world: the
-- WorldData.RandomSpawn CFrameValues (falling back to WorldData.Spawn and
-- then to the build's bounding box). Returns a CFrame to stand the
-- character at.
local function getLobbySpawnCFrame(): CFrame
	local lobby = Workspace:FindFirstChild("Lobby")
	if lobby ~= nil and lobby:IsA("Model") then
		local worldData = lobby:FindFirstChild("WorldData")
		if worldData ~= nil then
			local randomSpawn = worldData:FindFirstChild("RandomSpawn")
			if randomSpawn ~= nil then
				local candidates = {}
				for _, child in randomSpawn:GetChildren() do
					if child:IsA("CFrameValue") then
						table.insert(candidates, child.Value)
					end
				end
				if #candidates > 0 then
					return lobby:GetPivot():ToWorldSpace(candidates[math.random(#candidates)])
				end
			end
			local spawn = worldData:FindFirstChild("Spawn")
			if spawn ~= nil and spawn:IsA("CFrameValue") then
				return lobby:GetPivot():ToWorldSpace(spawn.Value)
			end
		end
		local boundingCFrame, boundingSize = lobby:GetBoundingBox()
		return CFrame.new(boundingCFrame.X, boundingCFrame.Y + boundingSize.Y / 2 + 4, boundingCFrame.Z)
	end
	return CFrame.new(0, 300, 0)
end

local PlayerSessions = {}
PlayerSessions.__index = PlayerSessions

-- Loads (or reloads) a character and stands it at a real lobby spawn point.
-- See getLobbySpawnCFrame for why the pivot is required.
function PlayerSessions.spawnCharacterAtLobby(self, player: Player): boolean
	local success, message = pcall(function()
		player:LoadCharacter()
	end)
	if not success then
		warn(("[Server] Character load failed for %s (%d): %s"):format(player.Name, player.UserId, tostring(message)))
		return false
	end
	local character = player.Character or player.CharacterAdded:Wait()
	character:PivotTo(getLobbySpawnCFrame())
	return true
end

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

function PlayerSessions.new(outbound)
	return setmetatable({
		outbound = outbound,
		sessions = {} :: { [Player]: PlayerSession },
		connections = {} :: { RBXScriptConnection },
		started = false,
	}, PlayerSessions)
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
			self.outbound:sendBootstrap(player, currentSession, attemptIndex == 1)
		end
	end)

	task.spawn(function()
		-- Stand the fresh character at a real lobby spawn point: the
		-- recovered spawn parts are all Neutral, so a bare LoadCharacter
		-- leaves the character at the workspace origin — the void.
		self:spawnCharacterAtLobby(player)
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
