--!strict

type PlayerSession = {
	profile: { [string]: any },
	party: { [string]: any },
	friends: { any },
	friendIds: { number },
	showVerify: boolean,
}

local Outbound = {}
Outbound.__index = Outbound

function Outbound.new(remoteRegistry)
	return setmetatable({
		setValueRemote = remoteRegistry:getEvent("SetValue"),
		remoteRegistry = remoteRegistry,
	}, Outbound)
end

function Outbound.fire(self, eventName: string, player: Player, ...)
	self.remoteRegistry:getEvent(eventName):FireClient(player, ...)
end

function Outbound.fireAll(self, eventName: string, ...)
	self.remoteRegistry:getEvent(eventName):FireAllClients(...)
end

function Outbound.sendProfile(self, player: Player, profile: { [string]: any })
	self.setValueRemote:FireClient(player, {
		type = "SetValue",
		Key = "Profile",
		Value = profile,
	})
end

function Outbound.sendParty(self, player: Player, party: { [string]: any })
	self.setValueRemote:FireClient(player, {
		type = "SetValue",
		Key = "Party",
		Value = party,
	})
end

function Outbound.sendFriends(self, player: Player, friends: { any }, friendIds: { number })
	self.setValueRemote:FireClient(player, {
		type = "SetValue",
		Key = "Friends",
		Value = friends,
	})
	self.setValueRemote:FireClient(player, {
		type = "SetValue",
		Key = "FriendIds",
		Value = friendIds,
	})
end

function Outbound.sendVerificationState(self, player: Player, showVerify: boolean)
	self.setValueRemote:FireClient(player, {
		type = "SetValue",
		Key = "ShowVerify",
		Value = showVerify,
	})
end

function Outbound.sendBootstrap(self, player: Player, session: PlayerSession)
	self.setValueRemote:FireClient(player, { type = "@@INIT" })
	self:sendProfile(player, session.profile)
	self:sendParty(player, session.party)
	self:sendFriends(player, session.friends, session.friendIds)
	self:sendVerificationState(player, session.showVerify)
end

return Outbound
