-- party-instance

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

local SocialStatusNames = {}
local SocialStatus = setmetatable({}, {
	["__index"] = SocialStatusNames,
})
SocialStatus.InGame = 0
SocialStatusNames[0] = "InGame"
SocialStatus.Online = 1
SocialStatusNames[1] = "Online"
SocialStatus.Offline = 2
SocialStatusNames[2] = "Offline"

type ReplicatedPlayer = {
	UserId: number,
	UserName: string,
	DisplayName: string,
}

type Party = {
	Id: string,
	Owner: ReplicatedPlayer,
	Players: { number },
	Invites: { [string]: unknown },
}

type PartyMember = ReplicatedPlayer & {
	Status: number,
	GameId: string,
	PlaceId: number,
}

return {
	["PARTY_INVITE_TIMEOUT"] = 30,
	["PARTY_INVITE_OFFLINE_TIMEOUT"] = 120,
	["PARTY_MAX_PLAYERS"] = 4,
	["PARTY_MAX_INVITES"] = 4,
	["SocialStatus"] = nil,
	["PartyUtil"] = nil,
	["SocialStatus"] = SocialStatus,
	["PartyUtil"] = {
		["isOwnerId"] = function(userId: number, party: Party): boolean
			return party.Owner.UserId == userId
		end,
		["isOwner"] = function(player: ReplicatedPlayer, party: Party): boolean
			return player.UserId == party.Owner.UserId
		end,
		["isInParty"] = function(player: ReplicatedPlayer, party: Party): boolean
			local playerIds = party.Players
			local userId = player.UserId
			return table.find(playerIds, userId) ~= nil
		end,
		["isInvited"] = function(player: ReplicatedPlayer, party: Party): boolean
			local invites = party.Invites
			local userId = player.UserId
			return invites[tostring(userId)] ~= nil
		end,
		["getPlayers"] = function(party: Party): { Player }
			return PlayerUtil.getPlayers(party.Players)
		end,
		["getInvitedPlayers"] = function(party: Party): { Player }
			local inviteKeys = ObjectUtils.keys(party.Invites)
			local playerIds = table.create(#inviteKeys)
			for index, userId in inviteKeys do
				local _ = index - 1
				playerIds[index] = tonumber(userId)
			end
			return PlayerUtil.getPlayers(playerIds)
		end,
		["canQueue"] = function(player: ReplicatedPlayer, party: Party?): boolean
			return not party or player.UserId == party.Owner.UserId
		end,
		["isHostingMultiplayerParty"] = function(player: ReplicatedPlayer, party: Party?): boolean
			local isHostingMultiplayer = party ~= nil and player.UserId == party.Owner.UserId
			if isHostingMultiplayer then
				isHostingMultiplayer = #party.Players > 1
			end
			return isHostingMultiplayer
		end,
		["isFull"] = function(party: Party, includeInvites: boolean?): boolean
			local countInvites = includeInvites == nil and true or includeInvites
			local playerCount = #party.Players
			local inviteCount
			if countInvites then
				inviteCount = 0
				for _ in party.Invites do
					inviteCount = inviteCount + 1
				end
			else
				inviteCount = 0
			end
			local total = playerCount + inviteCount
			local PARTY_MAX_PLAYERS = 4
			return PARTY_MAX_PLAYERS <= total
		end,
		["getDefaultParty"] = function(player: ReplicatedPlayer?): Party
			local owner = player == nil
					and {
						["UserId"] = 1800687521,
						["UserName"] = "Sobkiv2",
						["DisplayName"] = "Jay",
					}
				or PlayerUtil.toReplicated(player)
			return {
				["Id"] = "",
				["Owner"] = nil,
				["Players"] = nil,
				["Invites"] = nil,
				["Owner"] = owner,
				["Players"] = { owner.UserId },
				["Invites"] = {},
			}
		end,
		["getMembers"] = function(party: Party): { PartyMember }
			local playerIds = party.Players
			local function addMember(members: { PartyMember }, userId: number): { PartyMember }
				if userId == party.Owner.UserId then
					return members
				end
				local player: Player = Players:GetPlayerByUserId(userId)
				if not player then
					return members
				end
				local member = table.clone(PlayerUtil.toReplicated(player))
				setmetatable(member, nil)
				member.Status = SocialStatus.InGame
				member.GameId = game.JobId
				member.PlaceId = game.PlaceId
				table.insert(members, member)
				return members
			end
			local members: { PartyMember } = {}
			for index = 1, #playerIds do
				members = addMember(members, playerIds[index], index - 1, playerIds)
			end
			return members
		end,
	},
}
