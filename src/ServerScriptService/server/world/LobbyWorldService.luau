--!strict

-- LobbyWorldService — swaps the visible lobby world for custom-match servers.
-- The place ships two lobbies: Workspace/Lobby.rbxm (normal) and
-- ServerStorage/Maps/PregameLobby.rbxm (compact pre-game waiting lobby).
-- Once a server becomes a custom match (Private runtime role), the normal
-- lobby is retired to ServerStorage and the pre-game lobby is cloned into
-- Workspace named "Lobby" with LobbyType "Pregame" — the client's
-- LobbyWorldController finds its world via a Workspace "Lobby" lookup at
-- boot or via the JoinWorld event (guard accepts "Lobby" | "Pregame"), and
-- shows it whenever GameState is Pregame or Ended. Rojo names the cloned
-- asset after its file name, hence the rename.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute

local LOBBY_WORLD_NAME = "Lobby"
local PREGAME_LOBBY_ASSET_NAME = "PregameLobby"

-- No terrain in this place; below the floating builds is endless void.
local VOID_FLOOR_Y = 100
local VOID_CHECK_INTERVAL = 0.5

-- The client's JoinWorld guard (t.children) requires these WorldData folders
-- to exist; a failing payload is silently dropped (the client never switches
-- worlds). Neither recovered world has all of them, and the guard only
-- checks existence — no client code reads their contents.
local REQUIRED_WORLD_DATA_FOLDERS =
	{ "RandomSpawn", "SkyText", "Billboard", "Prefab", "Dog", "ScavengerProp", "DisplayBoard" }

local function completeWorldData(world: Instance)
	local worldData = world:FindFirstChild("WorldData")
	if worldData == nil then
		return
	end
	for _, folderName in REQUIRED_WORLD_DATA_FOLDERS do
		if worldData:FindFirstChild(folderName) == nil then
			local folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = worldData
		end
	end
end

local LobbyWorldService = {}
LobbyWorldService.__index = LobbyWorldService

function LobbyWorldService.new(context)
	return setmetatable({
		context = context,
		mode = "Lobby" :: "Lobby" | "Pregame",
		normalLobby = nil :: Instance?,
		pregameLobby = nil :: Instance?,
		started = false,
	}, LobbyWorldService)
end

-- The clone keeps its authored position (geometry starts ~Y=134, above the
-- arenas at ~Y=0).
function LobbyWorldService.ensurePregameAsset(self): Instance?
	if self.pregameLobby ~= nil then
		return self.pregameLobby
	end
	local maps = ServerStorage:FindFirstChild("Maps")
	local asset = maps and maps:FindFirstChild(PREGAME_LOBBY_ASSET_NAME)
	if asset == nil or not asset:IsA("Model") then
		warn("[LobbyWorld] PregameLobby asset not found under ServerStorage.Maps — re-sync Rojo!")
		return nil
	end
	local pregameLobby = asset:Clone()
	pregameLobby.Name = LOBBY_WORLD_NAME
	pregameLobby:SetAttribute(Attribute.LobbyType, "Pregame")
	completeWorldData(pregameLobby)
	self.pregameLobby = pregameLobby
	return pregameLobby
end

-- Idempotent; called from either private-role transition (reserved-server
-- boot or Studio local-custom creation).
function LobbyWorldService.setPregame(self): boolean
	if self.mode == "Pregame" then
		return true
	end
	local pregameLobby = self:ensurePregameAsset()
	if pregameLobby == nil then
		return false
	end

	local normalLobby = self.normalLobby or Workspace:FindFirstChild(LOBBY_WORLD_NAME)
	if normalLobby ~= nil and normalLobby.Parent == Workspace then
		self.normalLobby = normalLobby
		-- ServerStorage is not replicated, so the retired lobby vanishes for
		-- every client immediately.
		normalLobby.Parent = ServerStorage
	end

	pregameLobby.Parent = Workspace
	self.mode = "Pregame"
	-- Existing clients (Studio local-custom path) switch via JoinWorld; later
	-- boots find the swapped world through their Workspace "Lobby" lookup.
	-- Re-firing per join would rebuild the world's adverts a second time.
	for _, player in Players:GetPlayers() do
		self.context.outbound:fire("JoinWorld", player, pregameLobby, "Pregame")
		-- Players standing in the retired lobby have nothing underfoot once it
		-- moves to ServerStorage (reserved servers: no players yet, no-op).
		-- LoadCharacter can yield for seconds in Studio; don't block the world
		-- switch or custom-state replication behind it.
		task.spawn(function()
			pcall(function()
				player:LoadCharacter()
			end)
		end)
	end
	return true
end

-- Used on server shutdown / emptied Studio custom sessions.
function LobbyWorldService.restoreLobby(self)
	if self.mode ~= "Pregame" then
		return
	end
	if self.pregameLobby ~= nil then
		self.pregameLobby.Parent = ServerStorage
	end
	local normalLobby = self.normalLobby
	if normalLobby ~= nil then
		normalLobby.Parent = Workspace
		normalLobby:SetAttribute(Attribute.LobbyType, "Lobby")
		completeWorldData(normalLobby)
		for _, player in Players:GetPlayers() do
			self.context.outbound:fire("JoinWorld", player, normalLobby, "Lobby")
		end
	end
	self.mode = "Lobby"
end

-- The world active for players (in Workspace, or last known while hidden).
function LobbyWorldService.getActiveWorld(self): Instance?
	for _, world in { self.pregameLobby, self.normalLobby } do
		if world ~= nil and world.Parent == Workspace then
			return world
		end
	end
	if self.pregameLobby ~= nil then
		return self.pregameLobby
	end
	if self.normalLobby ~= nil then
		return self.normalLobby
	end
	return Workspace:FindFirstChild(LOBBY_WORLD_NAME)
end

-- ServerStorage is not replicated, so moving the world there hides it from
-- every client in the same frame. The client's own re-parent of the world is
-- only a local edit on streamed content and gets overridden when parts
-- re-stream, so visibility must be owned server-side.
function LobbyWorldService.hideWorld(self)
	local world = self:getActiveWorld()
	if world ~= nil and world.Parent == Workspace then
		world.Parent = ServerStorage
	end
end

function LobbyWorldService.showWorld(self)
	local world = self:getActiveWorld()
	if world ~= nil and world.Parent ~= Workspace then
		world.Parent = Workspace
	end
end

function LobbyWorldService.start(self)
	-- Studio turns a running public lobby into a local custom server in
	-- place; pre-replicate the completed pre-game world so JoinWorld's strict
	-- t.children guard never sees a newly-parented model before its
	-- descendants arrive. Published lobbies teleport into a fresh reserved
	-- server and don't need this.
	if RunService:IsStudio() then
		local pregameLobby = self:ensurePregameAsset()
		if pregameLobby ~= nil and pregameLobby.Parent == nil then
			pregameLobby.Parent = ReplicatedStorage
		end
	end

	-- A missing/empty lobby world strands players in the void (no terrain);
	-- fall back to the pre-game asset so there is always a floor and spawns.
	local lobby = Workspace:FindFirstChild(LOBBY_WORLD_NAME)
	if lobby == nil or (lobby:IsA("Model") and #lobby:GetChildren() == 0) then
		if lobby ~= nil then
			lobby:Destroy()
		end
		warn(
			"[LobbyWorld] No usable 'Lobby' world in Workspace at boot — placing the PregameLobby asset so players are not left in the void. Re-sync Rojo to restore the normal lobby."
		)
		local fallback = self:ensurePregameAsset()
		if fallback ~= nil then
			fallback.Parent = Workspace
			self.mode = "Pregame"
		end
	else
		self.normalLobby = lobby
		local hasSpawnLocation = false
		for _, descendant in lobby:GetDescendants() do
			if descendant:IsA("SpawnLocation") then
				hasSpawnLocation = true
				break
			end
		end
		if not hasSpawnLocation then
			warn(
				"[LobbyWorld] The 'Lobby' world in Workspace has no SpawnLocations — players may spawn in the void. Re-sync Rojo."
			)
		end
		-- For diagnosing a void-rescue later: what the world looked like at boot.
		if lobby:IsA("Model") then
			local spawnCount = 0
			for _, descendant in lobby:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawnCount += 1
				end
			end
			local boundingCFrame, boundingSize = lobby:GetBoundingBox()
			print(
				("[LobbyWorld] world ready: %q — %d SpawnLocations, bounds (%.0f, %.0f, %.0f) size (%.0f, %.0f, %.0f)"):format(
					lobby.Name,
					spawnCount,
					boundingCFrame.X,
					boundingCFrame.Y,
					boundingCFrame.Z,
					boundingSize.X,
					boundingSize.Y,
					boundingSize.Z
				)
			)
		end
	end

	-- Void watchdog: rescue anyone below every world. In-match falls are
	-- RoundService's job (arena-specific VoidY); this catches everything else.
	self.started = true
	task.spawn(function()
		while self.started do
			for _, player in Players:GetPlayers() do
				-- Match-owned characters (Alive/Spectating) belong to RoundService's
				-- void elimination; rescuing them here races it and can teleport a
				-- live fighter into the lobby mid-round.
				if
					player:GetAttribute(Attribute.Alive) == true
					or player:GetAttribute(Attribute.Spectating) == true
				then
					continue
				end
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root ~= nil and root:IsA("BasePart") and root.Position.Y < VOID_FLOOR_Y then
					warn(
						("[LobbyWorld] %s fell into the void at (%.0f, %.0f, %.0f) — rescuing to the lobby"):format(
							player.Name,
							root.Position.X,
							root.Position.Y,
							root.Position.Z
						)
					)
					local world = self:getActiveWorld()
					if world ~= nil then
						character:PivotTo(CFrame.new(world:GetPivot().Position + Vector3.new(0, 8, 0)))
						root.AssemblyLinearVelocity = Vector3.zero
					else
						pcall(function()
							player:LoadCharacter()
						end)
					end
				end
			end
			task.wait(VOID_CHECK_INTERVAL)
		end
	end)
end

function LobbyWorldService.stop(self)
	self.started = false
	self:restoreLobby()
end

return LobbyWorldService
