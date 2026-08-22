--!strict

local Validation = require(script.Parent.Parent.Validation)

local CombatHandlers = {}
CombatHandlers.__index = CombatHandlers

function CombatHandlers.new(context)
	return setmetatable({ context = context }, CombatHandlers)
end

function CombatHandlers.meleeStrike(self, player: Player, target: Player?)
	self.context.combatService:meleeStrike(player, target)
end

function CombatHandlers.meleeStrikeEntity(self, player: Player, target: Model)
	self.context.combatService:meleeStrikeEntity(player, target)
end

function CombatHandlers.fireProjectile(
	self,
	player: Player,
	direction: Vector3,
	strength: number,
	predictionId: string?
)
	self.context.projectileService:fireProjectile(player, direction, strength, predictionId)
end

function CombatHandlers.activatePowerUp(self, player: Player)
	local powerUpService = self.context.powerUpService
	if powerUpService ~= nil then
		powerUpService:activate(player)
	end
end

function CombatHandlers.getRoutes(self)
	return {
		{
			Name = "MeleeStrike",
			Validate = Validation.tuple({ Validation.optional(Validation.instance("Player")) }, 0),
			Handle = function(player, arguments)
				self:meleeStrike(player, arguments[1])
			end,
		},
		{
			Name = "MeleeStrikeEntity",
			Validate = Validation.tuple({ Validation.instance("Model") }),
			Handle = function(player, arguments)
				self:meleeStrikeEntity(player, arguments[1])
			end,
		},
		{
			Name = "FireProjectile",
			Validate = Validation.tuple(
				{ Validation.finiteVector3, Validation.numberRange(0, 1), Validation.optional(Validation.string) },
				2
			),
			Handle = function(player, arguments)
				self:fireProjectile(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "ActivatePowerUp",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:activatePowerUp(player)
			end,
		},
	}
end

return CombatHandlers
