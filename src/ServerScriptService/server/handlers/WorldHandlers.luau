--!strict

local Validation = require(script.Parent.Parent.Validation)

local WorldHandlers = {}
WorldHandlers.__index = WorldHandlers

function WorldHandlers.new(context)
	return setmetatable({ context = context }, WorldHandlers)
end

function WorldHandlers.equipItem(self, player: Player, itemType: string) end
function WorldHandlers.equipArmour(self, player: Player, itemType: string) end
function WorldHandlers.heldItemChanged(self, player: Player, previousItemType: string?) end
function WorldHandlers.useHeldItem(self, player: Player) end
function WorldHandlers.itemPickup(self, player: Player, itemType: string, quantity: number, predictionId: string) end
function WorldHandlers.placeBlock(self, player: Player, position: Vector3, rotation: number, predictionId: string) end
function WorldHandlers.hitBlock(self, player: Player, position: Vector3) end
function WorldHandlers.openChest(self, player: Player, chest: Model) end
function WorldHandlers.takeChestItem(self, player: Player, chest: Model, slotId: number, itemType: string) end
function WorldHandlers.closeChest(self, player: Player, chest: Model) end

function WorldHandlers.getRoutes(self)
	return {
		{
			Name = "EquipItem",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:equipItem(player, arguments[1])
			end,
		},
		{
			Name = "EquipArmour",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:equipArmour(player, arguments[1])
			end,
		},
		{
			Name = "HeldItemChanged",
			Validate = Validation.tuple({ Validation.optional(Validation.string) }, 0),
			Handle = function(player, arguments)
				self:heldItemChanged(player, arguments[1])
			end,
		},
		{
			Name = "UseHeldItem",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				self:useHeldItem(player)
			end,
		},
		{
			Name = "ItemPickup",
			Validate = Validation.tuple({ Validation.string, Validation.integer, Validation.string }),
			Handle = function(player, arguments)
				self:itemPickup(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "PlaceBlock",
			Validate = Validation.tuple({ Validation.finiteVector3, Validation.finiteNumber, Validation.string }),
			Handle = function(player, arguments)
				self:placeBlock(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "HitBlock",
			Validate = Validation.tuple({ Validation.finiteVector3 }),
			Handle = function(player, arguments)
				self:hitBlock(player, arguments[1])
			end,
		},
		{
			Name = "OpenChest",
			Validate = Validation.tuple({ Validation.instance("Model") }),
			Handle = function(player, arguments)
				self:openChest(player, arguments[1])
			end,
		},
		{
			Name = "TakeChestItem",
			Validate = Validation.tuple({
				Validation.instance("Model"),
				Validation.integer,
				Validation.string,
			}),
			Handle = function(player, arguments)
				self:takeChestItem(player, arguments[1], arguments[2], arguments[3])
			end,
		},
		{
			Name = "CloseChest",
			Validate = Validation.tuple({ Validation.instance("Model") }),
			Handle = function(player, arguments)
				self:closeChest(player, arguments[1])
			end,
		},
	}
end

return WorldHandlers
