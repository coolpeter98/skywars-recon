--!strict

local Validation = require(script.Parent.Parent.Validation)

local SessionHandlers = {}
SessionHandlers.__index = SessionHandlers

function SessionHandlers.new(context)
	return setmetatable({ context = context }, SessionHandlers)
end

function SessionHandlers.loginStreak(self, player: Player, timezoneOffset: number)
	local session = self.context.playerSessions:require(player)
	session.profile.LoginStreak.TimezoneOffset = timezoneOffset
end

function SessionHandlers.sendMetrics(self, player: Player, localeId: string, deviceType: string) end
function SessionHandlers.updateSetting(self, player: Player, settingId: string, value: any) end
function SessionHandlers.setFirstPerson(self, player: Player, firstPerson: boolean) end
function SessionHandlers.acknowledgeUpdateLog(self, player: Player, updateIds: { string }) end
function SessionHandlers.setVerificationOpen(self, player: Player, shouldOpen: boolean) end
function SessionHandlers.requestVerification(self, player: Player) end
function SessionHandlers.reportPlayer(self, player: Player, reportedPlayer: Player) end
function SessionHandlers.requestLeaderboard(
	self,
	player: Player,
	leaderboardType: string,
	statId: string,
	granularity: string,
	friendIds: { number }?
)
end
function SessionHandlers.joinGame(self, player: Player, gameId: string) end

function SessionHandlers.getRoutes(self)
	return {
		{
			Name = "LoginStreak",
			Validate = Validation.tuple({ Validation.finiteNumber }),
			Handle = function(player, arguments)
				self:loginStreak(player, arguments[1])
			end,
		},
		{
			Name = "SendMetrics",
			Validate = Validation.tuple({
				Validation.string,
				Validation.literal({ "MOBILE", "CONSOLE", "DESKTOP", "UNKNOWN" }),
			}),
			Handle = function(player, arguments)
				self:sendMetrics(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "UpdateSetting",
			Validate = Validation.settingUpdate,
			Handle = function(player, arguments)
				self:updateSetting(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "SetFirstPerson",
			Validate = Validation.tuple({ Validation.boolean }),
			Handle = function(player, arguments)
				self:setFirstPerson(player, arguments[1])
			end,
		},
		{
			Name = "AcknowledgeUpdateLog",
			Validate = Validation.tuple({ Validation.arrayOf(Validation.string, 100) }),
			Handle = function(player, arguments)
				self:acknowledgeUpdateLog(player, arguments[1])
			end,
		},
		{
			Name = "SetVerificationOpen",
			Validate = Validation.tuple({ Validation.boolean }),
			Handle = function(player, arguments)
				self:setVerificationOpen(player, arguments[1])
			end,
		},
		{
			Name = "RequestVerification",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:requestVerification(player)
			end,
		},
		{
			Name = "ReportPlayer",
			Validate = Validation.tuple({ Validation.instance("Player") }),
			Handle = function(player, arguments)
				self:reportPlayer(player, arguments[1])
			end,
		},
		{
			Name = "RequestLeaderboard",
			Validate = Validation.tuple({
				Validation.literal({ "Global", "Friends", "Personal" }),
				Validation.string,
				Validation.literal({ "ALL", "DAY", "WEEK", "MONTH", "YEAR" }),
				Validation.optional(Validation.arrayOf(Validation.integer, 200)),
			}, 3),
			Handle = function(player, arguments)
				self:requestLeaderboard(player, arguments[1], arguments[2], arguments[3], arguments[4])
			end,
		},
		{
			Name = "JoinGame",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:joinGame(player, arguments[1])
			end,
		},
	}
end

return SessionHandlers
