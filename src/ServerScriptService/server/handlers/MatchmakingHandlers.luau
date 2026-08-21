--!strict

local Validation = require(script.Parent.Parent.Validation)

local MatchmakingHandlers = {}
MatchmakingHandlers.__index = MatchmakingHandlers

function MatchmakingHandlers.new(context)
	return setmetatable({ context = context }, MatchmakingHandlers)
end

function MatchmakingHandlers.joinQueue(self, player: Player, joining: boolean, gameMode: string?) end
function MatchmakingHandlers.requestSpectate(self, player: Player) end
function MatchmakingHandlers.spectateTargetChanged(self, player: Player, target: Player) end
function MatchmakingHandlers.teleportToHub(self, player: Player) end
function MatchmakingHandlers.teleportToHubInstance(self, player: Player) end

function MatchmakingHandlers.getRoutes(self)
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
			Name = "JoinQueue",
			Validate = Validation.tuple({ Validation.boolean, Validation.optional(gameMode) }, 1),
			Handle = function(player, arguments)
				self:joinQueue(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "RequestSpectate",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:requestSpectate(player)
			end,
		},
		{
			Name = "SpectateTargetChanged",
			Validate = Validation.tuple({ Validation.instance("Player") }),
			Handle = function(player, arguments)
				self:spectateTargetChanged(player, arguments[1])
			end,
		},
		{
			Name = "TeleportToHub",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:teleportToHub(player)
			end,
		},
		{
			Name = "TeleportToHubInstance",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:teleportToHubInstance(player)
			end,
		},
	}
end

return MatchmakingHandlers
