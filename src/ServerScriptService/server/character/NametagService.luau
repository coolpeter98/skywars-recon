--!strict

-- Recreates the server half of the client's player nametags. The nametag UI
-- itself is built entirely by the client: Flamework's CharacterComponent
-- (StarterPlayerScripts/TS/components/character-component.luau) attaches to
-- every instance carrying the CollectionService tag "character" and portals a
-- React BillboardGui above the HumanoidRootPart (avatar icon, rank/title,
-- display name, level badge, and the health bar or lobby stats row). It skips
-- the local player's own character.
--
-- CollectionService tags replicate server -> client, so the original server
-- must have tagged each spawned character; without the tag the client
-- component is never instantiated and no nametag appears. This service:
--
--   * tags every character with "character" on spawn (and re-tags anything
--     that removes the tag while the character is still the player's active
--     character),
--   * publishes the display attributes the nametag reads:
--       Level     - ExperienceUtil.getLevel(profile.Experience) (shared)
--       Wins      - profile.Stats summed across every per-queue entry
--       Kills     - profile.Stats summed across every per-queue entry
--       WinStreak - profile.Stats summed across every per-queue entry
--       Rank      - the first known rank key found in profile.Ranks
--                   (accepts both list and map forms)
--       Title     - the equipped title cosmetic
--                   (profile.Cosmetics.Active.Title)
--
-- Every one of those client reads is nil-guarded, so a missing value degrades
-- to "?" / zero instead of erroring. TeamId / Health / Shield / Alive /
-- Spectating (team color, health bar, and character visibility) are owned by
-- CustomGameService and CombatService already.
--
-- Call refreshAttributes(player) again whenever the session profile changes
-- (e.g. from the future EquipCosmetic / persistence layers) so the nametag
-- tracks the new Level / stats / rank / title.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local ExperienceUtil = require(ReplicatedStorage.TS.experience["experience-util"]).ExperienceUtil
local Ranks = require(ReplicatedStorage.TS["game-product"].ranks).Ranks

-- The tag the client's CharacterComponent (@Component, tag = "character")
-- watches through CollectionService to mount the nametag.
local CHARACTER_TAG = "character"

type NametagContext = {
	playerSessions: any,
}

local NametagService = {}
NametagService.__index = NametagService

local function sumStats(profile: { [string]: any }): (number, number, number)
	local wins = 0
	local kills = 0
	local winStreak = 0
	local stats = profile.Stats
	if type(stats) ~= "table" then
		return wins, kills, winStreak
	end
	for _, queueStats in stats do
		if type(queueStats) == "table" then
			if type(queueStats.Wins) == "number" then
				wins += queueStats.Wins
			end
			if type(queueStats.Kills) == "number" then
				kills += queueStats.Kills
			end
			if type(queueStats.WinStreak) == "number" then
				winStreak += queueStats.WinStreak
			end
		end
	end
	return wins, kills, winStreak
end

-- profile.Ranks has no surviving reader besides the nametag, so its exact
-- shape is unknown: accept a list of rank keys ({"ADMIN", ...}) or a map
-- ({["ADMIN"] = true, ...}) and return the first key the shared Ranks table
-- knows about.
local function getRankKey(profile: { [string]: any }): string?
	local ranks = profile.Ranks
	if type(ranks) ~= "table" then
		return nil
	end
	for key, value in ranks do
		local rankKey: string?
		if type(key) == "string" and value ~= false and value ~= nil and Ranks[key] ~= nil then
			rankKey = key
		elseif type(value) == "string" and Ranks[value] ~= nil then
			rankKey = value
		end
		if rankKey ~= nil then
			return rankKey
		end
	end
	return nil
end

local function getTitleKey(profile: { [string]: any }): string?
	local cosmetics = profile.Cosmetics
	if type(cosmetics) ~= "table" then
		return nil
	end
	local active = cosmetics.Active
	if type(active) ~= "table" then
		return nil
	end
	local title = active.Title
	if type(title) == "string" and title ~= "" then
		return title
	end
	return nil
end

function NametagService.new(context: NametagContext)
	return setmetatable({
		context = context,
		playerAddedConnection = nil :: RBXScriptConnection?,
		playerRemovingConnection = nil :: RBXScriptConnection?,
		tagRemovedConnection = nil :: RBXScriptConnection?,
		characterConnections = {} :: { [Player]: RBXScriptConnection },
		started = false,
	}, NametagService)
end

-- Recomputes every nametag display attribute from the player's session
-- profile. Safe to call any number of times; missing profile fields leave the
-- corresponding attribute unset (the client renders "?" / zero).
function NametagService:refreshAttributes(player: Player)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local profile = session.profile
	if type(profile) ~= "table" then
		return
	end

	local experience = profile.Experience
	if type(experience) == "number" then
		player:SetAttribute(Attribute.Level, ExperienceUtil.getLevel(experience))
	end

	local wins, kills, winStreak = sumStats(profile)
	player:SetAttribute(Attribute.Wins, wins)
	player:SetAttribute(Attribute.Kills, kills)
	player:SetAttribute(Attribute.WinStreak, winStreak)
	player:SetAttribute(Attribute.Rank, getRankKey(profile))
	player:SetAttribute(Attribute.Title, getTitleKey(profile))
end

function NametagService:ensureCharacterTag(character: Model)
	if not CollectionService:HasTag(character, CHARACTER_TAG) then
		CollectionService:AddTag(character, CHARACTER_TAG)
	end
end

function NametagService:trackPlayer(player: Player)
	if self.characterConnections[player] ~= nil then
		return
	end
	self:refreshAttributes(player)
	local character = player.Character
	if character ~= nil then
		self:ensureCharacterTag(character)
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function(newCharacter)
		self:ensureCharacterTag(newCharacter)
	end)
end

function NametagService:start()
	if self.started then
		return
	end
	self.started = true
	for _, player in Players:GetPlayers() do
		self:trackPlayer(player)
	end
	self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		self:trackPlayer(player)
	end)
	self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		local connection = self.characterConnections[player]
		if connection ~= nil then
			connection:Disconnect()
		end
		self.characterConnections[player] = nil
	end)
	-- Self-heal: only this service tags real player characters, so re-apply
	-- the tag if anything removes it while the model is still the player's
	-- active character. (Client-side tags on cosmetic dummies never reach the
	-- server, so previews are unaffected.)
	self.tagRemovedConnection = CollectionService:GetInstanceRemovedSignal(CHARACTER_TAG):Connect(function(instance)
		local character = instance :: Model
		local player = Players:GetPlayerFromCharacter(character)
		if player ~= nil and player.Character == character then
			task.defer(function()
				if player.Character == character and character.Parent ~= nil then
					CollectionService:AddTag(character, CHARACTER_TAG)
				end
			end)
		end
	end)
end

function NametagService:stop()
	if not self.started then
		return
	end
	if self.tagRemovedConnection ~= nil then
		self.tagRemovedConnection:Disconnect()
		self.tagRemovedConnection = nil
	end
	if self.playerRemovingConnection ~= nil then
		self.playerRemovingConnection:Disconnect()
		self.playerRemovingConnection = nil
	end
	if self.playerAddedConnection ~= nil then
		self.playerAddedConnection:Disconnect()
		self.playerAddedConnection = nil
	end
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)
	self.started = false
end

return NametagService
