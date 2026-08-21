--!strict

local Validation = require(script.Parent.Parent.Validation)

local PartyHandlers = {}
PartyHandlers.__index = PartyHandlers

function PartyHandlers.new(context)
	return setmetatable({ context = context }, PartyHandlers)
end

function PartyHandlers.invitePlayer(self, player: Player, invitedPlayer: Player, isOffline: boolean) end
function PartyHandlers.promotePlayer(self, player: Player, promotedPlayer: Player) end
function PartyHandlers.removePlayer(self, player: Player, userId: number) end
function PartyHandlers.leaveParty(self, player: Player) end
function PartyHandlers.respondToInvite(self, player: Player, inviteId: string, partyId: string, accepted: boolean) end

function PartyHandlers.getRoutes(self)
	return {
		{
			Name = "InvitePlayerToParty",
			Validate = Validation.tuple({ Validation.instance("Player"), Validation.boolean }),
			Handle = function(player, arguments)
				self:invitePlayer(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "PartyPromote",
			Validate = Validation.tuple({ Validation.instance("Player") }),
			Handle = function(player, arguments)
				self:promotePlayer(player, arguments[1])
			end,
		},
		{
			Name = "PartyRemove",
			Validate = Validation.tuple({ Validation.integer }),
			Handle = function(player, arguments)
				self:removePlayer(player, arguments[1])
			end,
		},
		{
			Name = "PartyLeave",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:leaveParty(player)
			end,
		},
		{
			Name = "PartyInviteResponse",
			Validate = Validation.tuple({ Validation.string, Validation.string, Validation.boolean }),
			Handle = function(player, arguments)
				self:respondToInvite(player, arguments[1], arguments[2], arguments[3])
			end,
		},
	}
end

return PartyHandlers
