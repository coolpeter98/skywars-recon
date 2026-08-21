--!strict

local Validation = require(script.Parent.Parent.Validation)

local PrivateSessionHandlers = {}
PrivateSessionHandlers.__index = PrivateSessionHandlers

function PrivateSessionHandlers.new(context)
	return setmetatable({ context = context }, PrivateSessionHandlers)
end

function PrivateSessionHandlers.createPrivateServer(self, player: Player, privacy: string) end
function PrivateSessionHandlers.joinPrivateServer(self, player: Player, joinCode: string) end
function PrivateSessionHandlers.startPrivateMatch(self, player: Player) end
function PrivateSessionHandlers.setServerName(self, player: Player, serverName: string) end
function PrivateSessionHandlers.setGameMode(self, player: Player, gameMode: string) end
function PrivateSessionHandlers.setAllowTeamSelection(self, player: Player, allowTeamSelection: boolean) end
function PrivateSessionHandlers.setPrivacy(self, player: Player, privacy: string) end
function PrivateSessionHandlers.setMap(self, player: Player, mapName: string) end
function PrivateSessionHandlers.setPlayerBan(
	self,
	player: Player,
	userId: number,
	displayName: string,
	banned: boolean
)
end
function PrivateSessionHandlers.setPlayerTeam(self, player: Player, userId: number, teamId: string?) end

function PrivateSessionHandlers.getRoutes(self)
	local privacy = Validation.literal({ "Public", "Private" })
	local gameMode = Validation.literal({
		"SkyWarsSolo",
		"SkyWarsDuos",
		"SkyWarsTrios",
		"SkyWarsQuads",
		"SkyWarsOctos",
		"DuelsSolo",
		"DuelsDuos",
		"EggWarsQuads",
	})
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
			Validate = Validation.tuple({ gameMode }),
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
