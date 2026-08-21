--!strict

local Validation = require(script.Parent.Parent.Validation)

local LegacyHandlers = {}
LegacyHandlers.__index = LegacyHandlers

function LegacyHandlers.new(context)
	return setmetatable({ context = context }, LegacyHandlers)
end

function LegacyHandlers.legacyUnusedEvent(self, player: Player, arguments: { any }) end

function LegacyHandlers.getRoutes(self)
	return {
		{
			Name = "LegacyUnusedEvent",
			Validate = Validation.tuple({}),
			Handle = function(player, arguments)
				self:legacyUnusedEvent(player, arguments)
			end,
		},
	}
end

return LegacyHandlers
