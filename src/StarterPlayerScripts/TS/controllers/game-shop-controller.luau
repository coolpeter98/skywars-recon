-- GameShopController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local ArmourType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").ArmourType
local ShopItemUpgradeId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop").ShopItemUpgradeId

type GameShopController = {
	new: (...any) -> GameShopController,
	constructor: (self: GameShopController, inventoryController: any) -> (),
	purchaseItem: (self: GameShopController, shopType: any, itemIndex: number) -> (),
	purchaseItemUpgrade: (self: GameShopController, shopType: any, itemIndex: number) -> (),
	purchaseTeamUpgrade: (self: GameShopController, shopType: any, itemIndex: number) -> (),
	getNextUpgradeableItem: (self: GameShopController, shopItem: any) -> any?,
}

local GameShopController = setmetatable({}, {
	["__tostring"] = function()
		return "GameShopController"
	end
})
GameShopController.__index = GameShopController
function GameShopController.new(...)
	local self = setmetatable({}, GameShopController)
	return self:constructor(...) or self
end
function GameShopController.constructor(self, inventoryController)
	self.inventoryController = inventoryController
end
function GameShopController.purchaseItem(_, shopType, itemIndex)
	Events.ShopPurchaseItem:fire(shopType, itemIndex)
end
function GameShopController.purchaseItemUpgrade(_, shopType, itemIndex)
	Events.ShopPurchaseUpgrade:fire(shopType, itemIndex)
end
function GameShopController.purchaseTeamUpgrade(_, shopType, itemIndex)
	Events.ShopPurchaseTeamUpgrade:fire(shopType, itemIndex)
end
function GameShopController.getNextUpgradeableItem(self, shopItem)
	local foundIndex = -1
	if shopItem.Id == ShopItemUpgradeId.Armour then
		local chestplateItemInfo = Flamework.resolveDependency("JXb"):getItemInfoFromArmourType(ArmourType.Chestplate)
		if chestplateItemInfo then
			for index, item in ipairs(shopItem.Items) do
				if item.ItemType == chestplateItemInfo.Name then
					foundIndex = index
					break
				end
			end
		end
	else
		for index, item in ipairs(shopItem.Items) do
			if self.inventoryController:hasItem(item.ItemType) then
				foundIndex = index
				break
			end
		end
	end
	if foundIndex == -1 then
		return nil
	elseif foundIndex == #shopItem.Items then
		return nil
	else
		return shopItem.Items[foundIndex + 1]
	end
end
Reflect.defineMetadata(GameShopController, "identifier", "ADv")
Reflect.defineMetadata(GameShopController, "flamework:parameters", { "qOA" })
Reflect.decorate(GameShopController, "$:flamework@Controller", Controller, {})
return {
	["GameShopController"] = GameShopController
}
