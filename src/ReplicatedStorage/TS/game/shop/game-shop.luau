-- GameShop

type CurrencyType = "TierOne" | "TierTwo" | "TierThree" | "TierFour"

type ShopItem = {
	ItemType: string,
	Quantity: number,
	Price: number,
	CurrencyType: CurrencyType?,
	Limit: number?,
	ArmourTypes: { string }?,
	ItemIndex: number?,
}

type ItemUpgrade = {
	Id: string,
	Items: { ShopItem },
	ItemIndex: number?,
}

type TeamUpgradeTier = {
	Price: number,
	CurrencyType: CurrencyType?,
	Description: string,
}

type TeamUpgrade = {
	Id: string?,
	Name: string,
	Icon: string?,
	Tiers: { TeamUpgradeTier }?,
	ItemIndex: number?,
}

type Shop = {
	Type: string,
	Items: { ShopItem },
	ItemUpgrades: { ItemUpgrade },
	TeamUpgrades: { TeamUpgrade }?,
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CurrencyType: CurrencyType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-currency").CurrencyType
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ShopType = {
	["Blacksmith"] = "Blacksmith",
	["Merchant"] = "Merchant",
	["QuickShop"] = "QuickShop"
}
local ShopItemUpgradeId = {
	["Armour"] = "Armour",
	["Sword"] = "Sword",
	["Pickaxe"] = "Pickaxe"
}
local ShopTeamUpgradeId = {
	["Triumph"] = "Triumph",
	["Lifesteal"] = "Lifesteal",
	["BaseHeal"] = "BaseHeal",
	["LastStand"] = "LastStand",
	["LootingLuck"] = "LootingLuck",
	["Generator"] = "Generator"
}
local ArmourUpgrade: ItemUpgrade = {
	["Id"] = ShopItemUpgradeId.Armour,
	["Items"] = {
		{
			["ItemType"] = "BronzeChestplate",
			["ArmourTypes"] = nil,
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 2,
			["ArmourTypes"] = { "BronzeHelmet", "BronzeChestplate", "BronzeLeggings" },
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "IronChestplate",
			["ArmourTypes"] = nil,
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 25,
			["ArmourTypes"] = { "IronHelmet", "IronChestplate", "IronLeggings" },
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "GoldChestplate",
			["ArmourTypes"] = nil,
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 25,
			["ArmourTypes"] = { "GoldHelmet", "GoldChestplate", "GoldLeggings" },
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "DiamondChestplate",
			["ArmourTypes"] = nil,
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 35,
			["ArmourTypes"] = { "DiamondHelmet", "DiamondChestplate", "DiamondLeggings" },
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "OnyxChestplate",
			["ArmourTypes"] = nil,
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 30,
			["ArmourTypes"] = { "OnyxHelmet", "OnyxChestplate", "OnyxLeggings" },
			["CurrencyType"] = CurrencyType.TierThree
		}
	}
}
local SwordUpgrade: ItemUpgrade = {
	["Id"] = ShopItemUpgradeId.Sword,
	["Items"] = {
		{
			["ItemType"] = "BronzeSword",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 2,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "IronSword",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 15,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "GoldSword",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 15,
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "DiamondSword",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 24,
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "OnyxSword",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 36,
			["CurrencyType"] = CurrencyType.TierTwo
		}
	}
}
local PickaxeUpgrade: ItemUpgrade = {
	["Id"] = ShopItemUpgradeId.Pickaxe,
	["Items"] = {
		{
			["ItemType"] = "BronzePickaxe",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 2,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "IronPickaxe",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 12,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "GoldPickaxe",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 16,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "DiamondPickaxe",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 24,
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "OnyxPickaxe",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 32,
			["CurrencyType"] = CurrencyType.TierTwo
		}
	}
}
local shops: { Shop } = {}
local blacksmithShop: Shop = {
	["Type"] = ShopType.Blacksmith,
	["Items"] = {
		{
			["ItemType"] = "TeamConcrete",
			["Quantity"] = 16,
			["CurrencyType"] = nil,
			["Price"] = 6,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "Planks",
			["Quantity"] = 6,
			["CurrencyType"] = nil,
			["Price"] = 16,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "StoneBricks",
			["Quantity"] = 6,
			["CurrencyType"] = nil,
			["Price"] = 24,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "AquaBricks",
			["Quantity"] = 6,
			["CurrencyType"] = nil,
			["Price"] = 8,
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "Iron",
			["Quantity"] = 6,
			["CurrencyType"] = nil,
			["Price"] = 16,
			["CurrencyType"] = CurrencyType.TierTwo
		},
		{
			["ItemType"] = "Snowball",
			["Quantity"] = 3,
			["CurrencyType"] = nil,
			["Price"] = 12,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "Bow",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 20,
			["Limit"] = 1,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "Arrow",
			["Quantity"] = 3,
			["CurrencyType"] = nil,
			["Price"] = 9,
			["CurrencyType"] = CurrencyType.TierOne
		},
		{
			["ItemType"] = "Teleporter",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 5,
			["CurrencyType"] = CurrencyType.TierThree
		},
		{
			["ItemType"] = "Dynamite",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 6,
			["CurrencyType"] = CurrencyType.TierThree
		},
		{
			["ItemType"] = "Adrenaline",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 8,
			["CurrencyType"] = CurrencyType.TierThree
		},
		{
			["ItemType"] = "Landmine",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 5,
			["CurrencyType"] = CurrencyType.TierThree
		},
		{
			["ItemType"] = "Launchpad",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 5,
			["CurrencyType"] = CurrencyType.TierThree
		},
		{
			["ItemType"] = "FishingRod",
			["Quantity"] = 1,
			["CurrencyType"] = nil,
			["Price"] = 8,
			["CurrencyType"] = CurrencyType.TierThree
		}
	},
	["ItemUpgrades"] = { ArmourUpgrade, SwordUpgrade, PickaxeUpgrade },
	["TeamUpgrades"] = {}
}
local quickShop: Shop = {
	["Type"] = ShopType.QuickShop,
	["Items"] = {
		{
			["ItemType"] = "TeamConcrete",
			["Quantity"] = 16,
			["CurrencyType"] = nil,
			["Price"] = 6,
			["CurrencyType"] = CurrencyType.TierOne
		}
	},
	["ItemUpgrades"] = { ArmourUpgrade, SwordUpgrade, PickaxeUpgrade },
	["TeamUpgrades"] = {}
}
local merchantShop: Shop = {
	["Type"] = ShopType.Merchant,
	["Items"] = {},
	["ItemUpgrades"] = {}
}
local teamUpgrades: { TeamUpgrade } = {}
local triumphUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Triumph",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.Triumph,
	["Icon"] = RobloxImage.EggUpgrade.TRIUMPH,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "Heal 30 health on defeating a player",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "Heal 40 health on defeating a player",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "Heal 50 health on defeating a player",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
local vampyrismUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Vampyrism",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.Lifesteal,
	["Icon"] = RobloxImage.EggUpgrade.VAMPYRISM,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "Heal 4% of damage dealt",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "Heal 8% of damage dealt",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "Heal 12% of damage dealt",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
local healingWizardUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Healing Wizard",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.BaseHeal,
	["Icon"] = RobloxImage.EggUpgrade.HEALING_WIZARD,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "Heal 2.5 health at your base while out of combat",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "Heal 5 health at your base while out of combat",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "Heal 7.5 health at your base while out of combat",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
local lastStandUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Last Stand",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.LastStand,
	["Icon"] = RobloxImage.EggUpgrade.LAST_STAND,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "Deal 5% extra damage when below 30 health",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "Deal 10% extra damage when below 30 health",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "Deal 15% extra damage when below 30 health",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
local lootingLuckUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Looting Luck",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.LootingLuck,
	["Icon"] = RobloxImage.EggUpgrade.LOOTING_LUCK,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "10% chance to double currency when looting",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "20% chance to double currency when looting",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "30% chance to double currency when looting",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
local generatorUpgrade: TeamUpgrade = {
	["Id"] = nil,
	["Name"] = "Generator",
	["Icon"] = nil,
	["Tiers"] = nil,
	["Id"] = ShopTeamUpgradeId.Generator,
	["Icon"] = RobloxImage.EggUpgrade.GENERATOR_UPGRADE,
	["Tiers"] = {
		{
			["Price"] = 5,
			["CurrencyType"] = nil,
			["Description"] = "More bronze drops from your generator",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 10,
			["CurrencyType"] = nil,
			["Description"] = "Iron drops from your generator",
			["CurrencyType"] = CurrencyType.TierFour
		},
		{
			["Price"] = 15,
			["CurrencyType"] = nil,
			["Description"] = "More bronze and iron drops from your generator",
			["CurrencyType"] = CurrencyType.TierFour
		}
	}
}
__set_list(teamUpgrades, 1, {triumphUpgrade, vampyrismUpgrade, healingWizardUpgrade, lastStandUpgrade, lootingLuckUpgrade, generatorUpgrade})
merchantShop.TeamUpgrades = teamUpgrades
__set_list(shops, 1, {blacksmithShop, quickShop, merchantShop})
local shopsByType: { [string]: Shop } = {}
local ShopItemType = {
	["Items"] = "Items",
	["ItemUpgrades"] = "ItemUpgrades",
	["TeamUpgrades"] = "TeamUpgrades"
}
for _, shop in shops do
	shopsByType[shop.Type] = shop
	for itemIndex, item in shop.Items do
		item.ItemIndex = itemIndex - 1
		local _ = item.ItemIndex
	end
	for itemUpgradeIndex, itemUpgrade in shop.ItemUpgrades do
		itemUpgrade.ItemIndex = itemUpgradeIndex - 1
		local _ = itemUpgrade.ItemIndex
	end
	for teamUpgradeIndex, teamUpgrade in shop.TeamUpgrades do
		teamUpgrade.ItemIndex = teamUpgradeIndex - 1
		local _ = teamUpgrade.ItemIndex
	end
end
return {
	["ShopType"] = ShopType,
	["ShopItemType"] = ShopItemType,
	["ShopItemUpgradeId"] = ShopItemUpgradeId,
	["ShopTeamUpgradeId"] = ShopTeamUpgradeId,
	["Shops"] = shopsByType
}
