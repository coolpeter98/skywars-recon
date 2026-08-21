--!strict

local Validation = require(script.Parent.Parent.Validation)

local PrivateSessionHandlers = {}
PrivateSessionHandlers.__index = PrivateSessionHandlers

function PrivateSessionHandlers.new(context)
	return setmetatable({ context = context }, PrivateSessionHandlers)
end

function PrivateSessionHandlers.createPrivateServer(self, player: Player, privacy: string)
	self.context.customGameService:createServer(player, privacy)
end
function PrivateSessionHandlers.joinPrivateServer(self, player: Player, joinCode: string)
	self.context.customGameService:joinServer(player, joinCode)
end
function PrivateSessionHandlers.startPrivateMatch(self, player: Player)
	self.context.customGameService:startMatch(player)
end
function PrivateSessionHandlers.setServerName(self, player: Player, serverName: string)
	self.context.customGameService:setServerName(player, serverName)
end
function PrivateSessionHandlers.setGameMode(self, player: Player, gameMode: string)
	self.context.customGameService:setGameMode(player, gameMode)
end
function PrivateSessionHandlers.setAllowTeamSelection(self, player: Player, allowTeamSelection: boolean)
	self.context.customGameService:setAllowTeamSelection(player, allowTeamSelection)
end
function PrivateSessionHandlers.setPrivacy(self, player: Player, privacy: string)
	self.context.customGameService:setPrivacy(player, privacy)
end
function PrivateSessionHandlers.setMap(self, player: Player, mapName: string)
	self.context.customGameService:setMap(player, mapName)
end
function PrivateSessionHandlers.setPlayerBan(self, player: Player, userId: number, displayName: string, banned: boolean)
	self.context.customGameService:setPlayerBan(player, userId, displayName, banned)
end
function PrivateSessionHandlers.setPlayerTeam(self, player: Player, userId: number, teamId: string?)
	self.context.customGameService:setPlayerTeam(player, userId, teamId)
end

function PrivateSessionHandlers.getRoutes(self)
	local privacy = Validation.literal({ "Public", "Private" })
	return {
		{
			Name = "CreatePrivateServer",
			Validate = Validation.tuple({ privacy }),
			Handle = function(player, arguments)
				self:createPrivateServer(player, arguments[1])
			end,
		},
		{
			Name = "JoinPrivateServer",
			Validate = Validation.tuple({ Validation.nonEmptyString }),
			Handle = function(player, arguments)
				self:joinPrivateServer(player, arguments[1])
			end,
		},
		{
			Name = "StartPrivateMatch",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:startPrivateMatch(player)
			end,
		},
		{
			Name = "SetPrivateServerName",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:setServerName(player, arguments[1])
			end,
		},
		{
			Name = "SetPrivateGameMode",
			Validate = Validation.tuple({ Validation.nonEmptyString }),
			Handle = function(player, arguments)
				self:setGameMode(player, arguments[1])
			end,
		},
		{
			Name = "SetPrivateAllowTeamSelection",
			Validate = Validation.tuple({ Validation.boolean }),
			Handle = function(player, arguments)
				self:setAllowTeamSelection(player, arguments[1])
			end,
		},
		{
			Name = "SetPrivatePrivacy",
			Validate = Validation.tuple({ privacy }),
			Handle = function(player, arguments)
				self:setPrivacy(player, arguments[1])
			end,
		},
		{
			Name = "SetPrivateMap",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:setMap(player, arguments[1])
			end,
		},
		{
			Name = "SetPlayerBan",
			Validate = Validation.tuple({ Validation.integer, Validation.string, Validation.boolean }),
			Handle = function(player, arguments)
				self:setPlayerBan(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "SetPlayerTeam",
			Validate = Validation.tuple({ Validation.integer, Validation.optional(Validation.string) }, 1),
			Handle = function(player, arguments)
				self:setPlayerTeam(player, arguments[1], arguments[2])
			end,
		},
	}
end

return PrivateSessionHandlers
