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
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute

local LOBBY_WORLD_NAME = "Lobby"
local PREGAME_LOBBY_ASSET_NAME = "PregameLobby"

local LobbyWorldService = {}
LobbyWorldService.__index = LobbyWorldService

function LobbyWorldService.new(context)
	return setmetatable({
		context = context,
		mode = "Lobby" :: "Lobby" | "Pregame",
		normalLobby = nil :: Instance?,
		pregameLobby = nil :: Instance?,
	}, LobbyWorldService)
end

-- Retires the normal lobby and puts the pre-game lobby in its place. Safe to
-- call repeatedly and from either private-role transition (reserved-server
-- boot or the Studio local-custom creation): the second call is a no-op.
function LobbyWorldService.setPregame(self): boolean
	if self.mode == "Pregame" then
		return true
	end
	local pregameLobby = self.pregameLobby
	if pregameLobby == nil then
		local maps = ServerStorage:FindFirstChild("Maps")
		local asset = maps and maps:FindFirstChild(PREGAME_LOBBY_ASSET_NAME)
		if asset == nil or not asset:IsA("Model") then
			warn("[LobbyWorld] PregameLobby asset not found under ServerStorage.Maps")
			return false
		end
		pregameLobby = asset:Clone()
		pregameLobby.Name = LOBBY_WORLD_NAME
		pregameLobby:SetAttribute(Attribute.LobbyType, "Pregame")
		self.pregameLobby = pregameLobby
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
		for _, player in Players:GetPlayers() do
			self.context.outbound:fire("JoinWorld", player, normalLobby, "Lobby")
		end
	end
	self.mode = "Lobby"
end

function LobbyWorldService.start(_) end

function LobbyWorldService.stop(self)
	self:restoreLobby()
end

return LobbyWorldService
