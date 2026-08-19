--!strict
--[[
	MinimalServer — smallest server stub required for local testing.

	The original game's server code was never recoverable (the place was
	saved client-side under FilteringEnabled), so this stub speaks the
	client's existing wire protocol directly to make the lobby fully
	interactable. It:

	- sends @@INIT + the default shared Profile through SetValue, which
	  unblocks every controller awaiting profile replication
	  (Matchmaking, PlayerSettings, Camera, Changelog, Advert, ...),
	- answers the GetCustomServers function with an empty list so the
	  private match browser finishes loading,
	- loads the character (the place sets CharacterAutoLoads = false;
	  the lobby world's spawn locations handle placement).

	It deliberately does NOT implement persistence, purchases, parties,
	or matchmaking — those remain future server work.

	Remotes are found by their `id` attribute (the same discovery
	mechanism Flamework networking uses). The UUID strings are the wire
	protocol (see TS/event/event-ids.luau) and must not change. A real
	server can replace this file wholesale with no client changes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SET_VALUE_EVENT_ID = "4e368d35-2565-4359-97cb-b7714d75fe09"
local LOGIN_STREAK_EVENT_ID = "180fe66b-221f-432f-aa14-5c135cb1255f"
local GET_CUSTOM_SERVERS_FUNCTION_ID = "a8ed47d9-a359-40b4-840b-47fed6373b94"
local REPLICATION_RETRY_INTERVAL = 2

local function findRemote(namespace: string, id: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(namespace)
	for _, remote in folder:GetChildren() do
		if remote:GetAttribute("id") == id then
			return remote :: RemoteEvent
		end
	end
	error("[MinimalServer] Remote not found: " .. namespace .. "/" .. id)
end

local function getSharedDataProfile(): { [string]: any }
	return require(ReplicatedStorage.TS.profile["data-profile"]).SharedDataProfileTemplate
end

-- Private-server browser: answer with an empty server list.
local function onCustomServersRequest(player: Player, requestId: number)
	-- Flamework function protocol: respond on the same remote with
	-- (requestId, processResult, result).
	local customServers = findRemote("dYE", GET_CUSTOM_SERVERS_FUNCTION_ID)
	customServers:FireClient(player, requestId, true, {})
end

local function onPlayerAdded(player: Player)
	player:LoadCharacter()

	local setValue = findRemote("aYZ", SET_VALUE_EVENT_ID)
	local profile = getSharedDataProfile()
	local profileReceived = false

	-- The client fires LoginStreak once it has applied the replicated
	-- profile; treat that as the acknowledgement.
	local loginStreak = findRemote("aYZ", LOGIN_STREAK_EVENT_ID)
	loginStreak.OnServerEvent:Connect(function(sender)
		if sender == player then
			profileReceived = true
		end
	end)

	local function sendInitialReplication()
		if profileReceived then
			return nil
		end
		setValue:FireClient(player, { ["type"] = "@@INIT" })
		setValue:FireClient(player, {
			["type"] = "SetValue",
			["Key"] = "Profile",
			["Value"] = profile,
		})
	end

	sendInitialReplication()

	-- The client may not have connected its SetValue listener yet when a
	-- player joins, so re-send until acknowledged (or the player leaves).
	task.spawn(function()
		while player.Parent and not profileReceived do
			task.wait(REPLICATION_RETRY_INTERVAL)
			sendInitialReplication()
		end
	end)
end

local customServersRemote = findRemote("dYE", GET_CUSTOM_SERVERS_FUNCTION_ID)
customServersRemote.OnServerEvent:Connect(onCustomServersRequest)

Players.PlayerAdded:Connect(onPlayerAdded)
