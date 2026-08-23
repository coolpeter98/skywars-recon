--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

type PendingInvite = {
	Id: string,
	PartyId: string,
	InviterUserId: number,
	InvitedUserId: number,
	ExpiresAt: number,
	IsOffline: boolean,
}

type ReplicatedPlayer = {
	UserId: number,
	UserName: string,
	DisplayName: string,
}

local PARTY_MAX_PLAYERS = 4
local PARTY_INVITE_TIMEOUT = 30
local PARTY_OFFLINE_INVITE_TIMEOUT = 120

local PartyService = {}
PartyService.__index = PartyService

local function toReplicatedPlayer(player: Player)
	return {
		UserId = player.UserId,
		UserName = player.Name,
		DisplayName = player.DisplayName,
	}
end

local function createSoloParty(player: Player)
	return {
		Id = "",
		Owner = toReplicatedPlayer(player),
		Players = { player.UserId },
		Invites = {},
	}
end

function PartyService.new(context)
	return setmetatable({
		context = context,
		parties = {} :: { [string]: any },
		pendingInvites = {} :: { [string]: PendingInvite },
		connections = {} :: { RBXScriptConnection },
		started = false,
	}, PartyService)
end

function PartyService.notify(self, player: Player, message: string)
	self.context.outbound:fire("Alert", player, "Party", message, Color3.fromRGB(255, 205, 76), 3)
end

function PartyService.publish(self, party)
	for _, userId in party.Players do
		local member = Players:GetPlayerByUserId(userId)
		local session = member and self.context.playerSessions:get(member)
		if member and session then
			session.party = party
			self.context.outbound:fire("PartyUpdated", member, party)
		end
	end
end

function PartyService.ensureParty(self, player: Player)
	local session = self.context.playerSessions:require(player)
	local party = session.party
	if party.Id == "" then
		party.Id = HttpService:GenerateGUID(false)
		self.parties[party.Id] = party
	elseif self.parties[party.Id] == nil then
		self.parties[party.Id] = party
	end
	return party
end

function PartyService.resetPlayer(self, player: Player)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local party = createSoloParty(player)
	session.party = party
	self.context.outbound:fire("PartyUpdated", player, party)
end

function PartyService.removeFromCurrentParty(self, player: Player)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local party = session.party
	if party.Id == "" then
		return
	end
	local memberIndex = table.find(party.Players, player.UserId)
	if memberIndex == nil then
		return
	end
	table.remove(party.Players, memberIndex)
	if #party.Players == 0 then
		self.parties[party.Id] = nil
	elseif party.Owner.UserId == player.UserId then
		local newOwner = Players:GetPlayerByUserId(party.Players[1])
		if newOwner ~= nil then
			party.Owner = toReplicatedPlayer(newOwner)
		end
		self:publish(party)
	else
		self:publish(party)
	end
	self:resetPlayer(player)
end

function PartyService.expireInvite(self, partyId: string, invitedUserId: number, inviteId: string)
	local pending = self.pendingInvites[inviteId]
	if pending == nil or pending.PartyId ~= partyId or pending.InvitedUserId ~= invitedUserId then
		return
	end
	local party = self.parties[partyId]
	if party == nil then
		self.pendingInvites[inviteId] = nil
		return
	end
	local invitedKey = tostring(invitedUserId)
	if party.Invites[invitedKey] == nil then
		self.pendingInvites[inviteId] = nil
		return
	end
	party.Invites[invitedKey] = nil
	self.pendingInvites[inviteId] = nil
	local invitedPlayer = not pending.IsOffline and Players:GetPlayerByUserId(invitedUserId) or nil
	if invitedPlayer ~= nil and invitedPlayer.Parent == Players then
		self.context.outbound:fire("PartyInviteCancelled", invitedPlayer, inviteId)
	end
	self:publish(party)
end

function PartyService.invite(self, player: Player, invitedPlayerData: ReplicatedPlayer, isOffline: boolean)
	if invitedPlayerData.UserId == player.UserId then
		return
	end
	local party = self:ensureParty(player)
	if party.Owner.UserId ~= player.UserId then
		self:notify(player, "Only the party owner can invite players.")
		return
	end
	local inviteCount = 0
	for _ in party.Invites do
		inviteCount += 1
	end
	if #party.Players + inviteCount >= PARTY_MAX_PLAYERS then
		self:notify(player, "Your party is full.")
		return
	end
	local invitedUserId = invitedPlayerData.UserId
	local invitedKey = tostring(invitedUserId)
	if party.Invites[invitedKey] ~= nil or table.find(party.Players, invitedUserId) ~= nil then
		return
	end
	local invitedPlayer = Players:GetPlayerByUserId(invitedUserId)
	if not isOffline and (invitedPlayer == nil or self.context.playerSessions:get(invitedPlayer) == nil) then
		self:notify(player, "That player is no longer in this server.")
		return
	end

	local inviteId = HttpService:GenerateGUID(false)
	local inviteTimeout = isOffline and PARTY_OFFLINE_INVITE_TIMEOUT or PARTY_INVITE_TIMEOUT
	local expiresAt = os.time() + inviteTimeout
	local resolvedInvitee = if invitedPlayer == nil then invitedPlayerData else toReplicatedPlayer(invitedPlayer)
	local inviteeData = {
		UserId = resolvedInvitee.UserId,
		UserName = resolvedInvitee.UserName,
		DisplayName = resolvedInvitee.DisplayName,
		InviteTime = os.time(),
	}
	party.Invites[invitedKey] = inviteeData
	self.pendingInvites[inviteId] = {
		Id = inviteId,
		PartyId = party.Id,
		InviterUserId = player.UserId,
		InvitedUserId = invitedUserId,
		ExpiresAt = expiresAt,
		IsOffline = isOffline,
	}
	self:publish(party)

	if not isOffline and invitedPlayer ~= nil then
		self.context.outbound:fire("PartyInvite", invitedPlayer, inviteId, toReplicatedPlayer(player), party.Id)
	end

	task.delay(inviteTimeout, function()
		local pending = self.pendingInvites[inviteId]
		if pending ~= nil and pending.ExpiresAt <= os.time() then
			self:expireInvite(pending.PartyId, pending.InvitedUserId, inviteId)
		end
	end)
end

function PartyService.acceptPlatformInvite(self, player: Player, partyId: string)
	local party = self.parties[partyId]
	if party == nil or party.Invites[tostring(player.UserId)] == nil or #party.Players >= PARTY_MAX_PLAYERS then
		return
	end
	local matchingInviteId: string? = nil
	for inviteId, pending in self.pendingInvites do
		if pending.PartyId == partyId and pending.InvitedUserId == player.UserId and pending.IsOffline then
			if pending.ExpiresAt <= os.time() then
				self:expireInvite(partyId, player.UserId, inviteId)
				return
			end
			matchingInviteId = inviteId
			break
		end
	end
	if matchingInviteId == nil then
		return
	end
	self.pendingInvites[matchingInviteId] = nil
	party.Invites[tostring(player.UserId)] = nil
	self:removeFromCurrentParty(player)
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	table.insert(party.Players, player.UserId)
	session.party = party
	self:publish(party)
end

function PartyService.processJoinData(self, player: Player)
	local session = self.context.playerSessions:get(player)
	for _ = 1, 50 do
		if session ~= nil or player.Parent ~= Players then
			break
		end
		task.wait(0.1)
		session = self.context.playerSessions:get(player)
	end
	if session == nil or player.Parent ~= Players then
		return
	end

	local launchDataJson: string? = nil
	for _ = 1, 10 do
		local joinSuccess, joinData = pcall(function()
			return player:GetJoinData()
		end)
		if joinSuccess and type(joinData) == "table" and type(joinData.LaunchData) == "string" then
			if joinData.LaunchData ~= "" then
				launchDataJson = joinData.LaunchData
				break
			end
		end
		task.wait(1)
		if player.Parent ~= Players then
			return
		end
	end
	if launchDataJson == nil then
		return
	end
	local decodeSuccess, launchData = pcall(function()
		return HttpService:JSONDecode(launchDataJson)
	end)
	if
		not decodeSuccess
		or type(launchData) ~= "table"
		or launchData.Type ~= "PartyAcceptInvite"
		or type(launchData.PartyId) ~= "string"
	then
		return
	end
	self:acceptPlatformInvite(player, launchData.PartyId)
end

function PartyService.respond(self, player: Player, inviteId: string, partyId: string, accepted: boolean)
	local pending = self.pendingInvites[inviteId]
	local party = self.parties[partyId]
	if
		pending == nil
		or pending.PartyId ~= partyId
		or pending.InvitedUserId ~= player.UserId
		or pending.ExpiresAt <= os.time()
		or pending.IsOffline
		or party == nil
	then
		return
	end
	self.pendingInvites[inviteId] = nil
	party.Invites[tostring(player.UserId)] = nil
	if accepted and #party.Players < PARTY_MAX_PLAYERS then
		self:removeFromCurrentParty(player)
		local session = self.context.playerSessions:get(player)
		if session ~= nil then
			table.insert(party.Players, player.UserId)
			session.party = party
		end
	end
	self:publish(party)
end

function PartyService.promote(self, player: Player, promotedUserId: number)
	local party = self.context.playerSessions:require(player).party
	local promotedPlayer = Players:GetPlayerByUserId(promotedUserId)
	if
		party.Id == ""
		or party.Owner.UserId ~= player.UserId
		or promotedPlayer == nil
		or table.find(party.Players, promotedUserId) == nil
	then
		return
	end
	party.Owner = toReplicatedPlayer(promotedPlayer)
	self:publish(party)
end

function PartyService.remove(self, player: Player, userId: number)
	local party = self.context.playerSessions:require(player).party
	if party.Id == "" or party.Owner.UserId ~= player.UserId or userId == player.UserId then
		return
	end
	local removedPlayer = Players:GetPlayerByUserId(userId)
	if removedPlayer == nil or table.find(party.Players, userId) == nil then
		return
	end
	self:removeFromCurrentParty(removedPlayer)
end

function PartyService.leave(self, player: Player)
	self:removeFromCurrentParty(player)
end

function PartyService.getTravelPlayers(self, player: Player): ({ Player }?, string?)
	local party = self.context.playerSessions:require(player).party
	if party.Owner.UserId ~= player.UserId then
		return nil, "Only the party owner can move the party to a custom game."
	end
	local members = {}
	for _, userId in party.Players do
		local member = Players:GetPlayerByUserId(userId)
		if member == nil or self.context.playerSessions:get(member) == nil then
			return nil, "Every party member must be in this server."
		end
		table.insert(members, member)
	end
	return members, nil
end

function PartyService.start(self)
	if self.started then
		return
	end
	self.started = true
	table.insert(
		self.connections,
		Players.PlayerAdded:Connect(function(player)
			task.spawn(function()
				self:processJoinData(player)
			end)
		end)
	)
	table.insert(
		self.connections,
		Players.PlayerRemoving:Connect(function(player)
			self:removeFromCurrentParty(player)
		end)
	)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:processJoinData(player)
		end)
	end
end

function PartyService.stop(self)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	table.clear(self.parties)
	table.clear(self.pendingInvites)
	self.started = false
end

return PartyService
