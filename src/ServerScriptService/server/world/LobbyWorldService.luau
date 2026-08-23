--!strict

-- LobbyWorldService — swaps the visible lobby world for custom-match servers.
--
-- The recovered place ships two lobby worlds:
--   * Workspace/Lobby.rbxm — the normal lobby (adverts, featured cosmetics,
--     display boards, sky text, benches);
--   * ServerStorage/Maps/PregameLobby.rbxm — the compact pre-game waiting
--     lobby (smaller build, its own WorldData spawn/advert/play layout, and
--     its own RandomSpawn SpawnLocations).
--
-- The client's LobbyWorldController finds its world either by waiting for a
-- child named "Lobby" in Workspace at boot (5 s window) or through the
-- JoinWorld event, whose guard accepts (worldModel, "Lobby" | "Pregame").
-- The world carries its type in the LobbyType attribute (the controller
-- defaults a missing attribute to "Lobby").
--
-- This service owns the swap: once a server becomes a custom match
-- (Private runtime role) the normal lobby is retired to ServerStorage and
-- the pre-game lobby is cloned into Workspace under the name "Lobby" with
-- LobbyType "Pregame". Every phase of a custom match then shows the
-- pre-game lobby instead of the normal lobby — waiting between rounds,
-- the Pregame cage countdown, and post-game — because the client's
-- LobbyWorldController shows its world whenever GameState is Pregame or
-- Ended. Clients that boot after the swap find the pre-game lobby through
-- their Workspace "Lobby" lookup; clients that booted before the swap
-- (the Studio local-custom path) are switched over with JoinWorld.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute

local LOBBY_WORLD_NAME = "Lobby"
local PREGAME_LOBBY_ASSET_NAME = "PregameLobby"

-- This place has no terrain: below the floating builds (lobby ~Y130+, maps
-- ~Y170+) there is nothing at all. Anyone found below this floor is falling
-- forever; the watchdog logs where they were and rescues them.
local VOID_FLOOR_Y = 100
local VOID_CHECK_INTERVAL = 0.5

-- The client's JoinWorld guard (t.children) requires these WorldData folders
-- to exist on any world the server pushes. Neither recovered world has all
-- of them (the normal lobby lacks Billboard/Dog/ScavengerProp; the pre-game
-- lobby also lacks SkyText/DisplayBoard), and a failing payload is silently
-- dropped — the client never switches worlds. Complete whichever world is
-- about to be pushed with empty folders (the guard only requires them to
-- exist; no client code reads their contents).
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

-- Loads (and caches) the pre-game lobby clone used by setPregame and by the
-- boot-time fallback. Returns nil (with a warning) when the asset is missing
-- from the built place — usually a Rojo sync that never delivered the file.
-- The clone keeps the asset's authored position. Recovered arenas keep their
-- own authored coordinates around world Y=0, while this asset's geometry
-- starts around Y=134, placing the pre-game lobby safely above the map centre.
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

-- Retires the normal lobby and puts the pre-game lobby in its place. Safe to
-- call repeatedly and from either private-role transition (reserved-server
-- boot or the Studio local-custom creation): the second call is a no-op.
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
	-- Clients already on the server (the Studio local-custom path, where the
	-- swap happens mid-session) switch worlds through JoinWorld; clients that
	-- boot afterwards find the swapped world via their Workspace "Lobby"
	-- lookup, so no per-join firing is needed (and re-firing would rebuild
	-- the world's adverts a second time).
	for _, player in Players:GetPlayers() do
		self.context.outbound:fire("JoinWorld", player, pregameLobby, "Pregame")
		-- Players standing inside the retired lobby have nothing under their
		-- feet once it moves to ServerStorage; respawn them onto the
		-- pre-game lobby's own SpawnLocations. On reserved servers the swap
		-- happens before anyone joins, so this loop is a no-op there.
		pcall(function()
			player:LoadCharacter()
		end)
	end
	return true
end

-- Puts the normal lobby back. Used when a custom-match server returns to
-- plain lobby duty (server shutdown or an emptied Studio custom session).
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

-- The world currently active for players (the one parented in Workspace, or
-- the last known one while it is hidden in ServerStorage).
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

-- Visibility is server-owned. The client's own re-parent of the world (its
-- LobbyWorldController moves it between Workspace and ReplicatedStorage) is a
-- local edit on streamed content, which the streaming engine overrides when
-- parts re-stream — the world visibly "comes back" during a match. Moving it
-- server-side is authoritative and immediate: ServerStorage is not
-- replicated, so the world vanishes for every client in the same frame.
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
	-- Studio changes a running public lobby into a local custom server in
	-- place. Replicate the completed pre-game world before that transition
	-- can happen, so JoinWorld's strict t.children guard never observes a
	-- newly-parented model before its descendants have reached the client.
	-- Published public lobbies do not need this extra replicated copy: they
	-- teleport into a fresh reserved server, where the swap happens before
	-- any player joins.
	if RunService:IsStudio() then
		local pregameLobby = self:ensurePregameAsset()
		if pregameLobby ~= nil and pregameLobby.Parent == nil then
			pregameLobby.Parent = ReplicatedStorage
		end
	end

	-- Boot-time world sanity check. This place has no terrain: everything
	-- below the floating builds is endless void, so a missing or empty lobby
	-- world (a lost/unsynced model, a half-applied Rojo sync, a saved
	-- post-swap place state) strands players falling forever with no error.
	-- Fall back to the pre-game lobby asset so there is always a world,
	-- spawn points, and a floor.
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
		-- One-time world report: when a player ends up in the void, this line
		-- shows exactly what the world looks like from the server's side.
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

	-- Void watchdog: log and rescue anyone below every world. The round's own
	-- void elimination handles in-match falls; this catches the rest (broken
	-- spawns, missing geometry, a half-synced world) so nobody stays stuck.
	self.started = true
	task.spawn(function()
		while self.started do
			for _, player in Players:GetPlayers() do
				-- Match-owned characters are handled by CustomGameService's
				-- arena-specific VoidY elimination. Rescuing them here races that
				-- loop, steals the elimination, and can teleport a live fighter
				-- into the lobby mid-round. Eliminated spectators are match-owned
				-- too and must remain at the arena's spectator position.
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
