--!strict

local Validation = require(script.Parent.Parent.Validation)

local EconomyHandlers = {}
EconomyHandlers.__index = EconomyHandlers

function EconomyHandlers.new(context)
	return setmetatable({ context = context }, EconomyHandlers)
end

function EconomyHandlers.purchaseProduct(self, player: Player, productId: string) end
function EconomyHandlers.primeCosmeticPurchase(self, player: Player, cosmeticId: string) end
function EconomyHandlers.equipCosmetic(self, player: Player, cosmeticId: string) end
function EconomyHandlers.claimSeasonPassTier(self, player: Player, tierId: number) end
function EconomyHandlers.claimScavengerProp(self, player: Player, propId: number) end
function EconomyHandlers.shopPurchaseItem(self, player: Player, shopType: string, itemIndex: number)
	self.context.inventoryService:purchaseItem(player, shopType, itemIndex)
end

function EconomyHandlers.shopPurchaseUpgrade(self, player: Player, shopType: string, itemIndex: number)
	self.context.inventoryService:purchaseUpgrade(player, shopType, itemIndex)
end
function EconomyHandlers.shopPurchaseTeamUpgrade(self, player: Player, shopType: string, itemIndex: number) end

function EconomyHandlers.getRoutes(self)
	local shopArguments = {
		Validation.literal({ "Blacksmith", "Merchant", "QuickShop" }),
		Validation.integer,
	}
	return {
		{
			Name = "PurchaseProduct",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:purchaseProduct(player, arguments[1])
			end,
		},
		{
			Name = "PrimeCosmeticPurchase",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:primeCosmeticPurchase(player, arguments[1])
			end,
		},
		{
			Name = "EquipCosmetic",
			Validate = Validation.tuple({ Validation.string }),
			Handle = function(player, arguments)
				self:equipCosmetic(player, arguments[1])
			end,
		},
		{
			Name = "ClaimSeasonPassTier",
			Validate = Validation.tuple({ Validation.integer }),
			Handle = function(player, arguments)
				self:claimSeasonPassTier(player, arguments[1])
			end,
		},
		{
			Name = "ClaimScavengerProp",
			Validate = Validation.tuple({ Validation.integer }),
			Handle = function(player, arguments)
				self:claimScavengerProp(player, arguments[1])
			end,
		},
		{
			Name = "ShopPurchaseItem",
			Validate = Validation.tuple(shopArguments),
			Handle = function(player, arguments)
				self:shopPurchaseItem(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "ShopPurchaseUpgrade",
			Validate = Validation.tuple(shopArguments),
			Handle = function(player, arguments)
				self:shopPurchaseUpgrade(player, arguments[1], arguments[2])
			end,
		},
		{
			Name = "ShopPurchaseTeamUpgrade",
			Validate = Validation.tuple(shopArguments),
			Handle = function(player, arguments)
				self:shopPurchaseTeamUpgrade(player, arguments[1], arguments[2])
			end,
		},
	}
end

return EconomyHandlers
