-- CosmeticSwords

type CosmeticDefinition = {
	Id: string?,
	Name: string,
	Description: string?,
	Rarity: string,
	Type: string,
	ItemGroup: string?,
	DualWield: boolean?,
	ItemAnimation: {
		Equip: string?,
		Idle: string?,
		Sprint: string?,
		Tool: string?,
		Melee: { string }?,
	}?,
	Display: {
		Sprinting: boolean?,
		Melee: boolean?,
		MeleeInterval: Vector2?,
	}?,
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local RobloxAnimation = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticSwords: { CosmeticDefinition } = {}
local SupporterSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Supporter Sword",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordSupporter,
	["ItemGroup"] = ItemGroup.Sword
}
local TrainingSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Training Sword",
	["Description"] = "A simple sword, does the trick!",
	["Rarity"] = "Common",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordCommon,
	["ItemGroup"] = ItemGroup.Sword
}
local Cutlass: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Cutlass",
	["Rarity"] = "Common",
	["Description"] = "Yarr!",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordCutlass,
	["ItemGroup"] = ItemGroup.Sword
}
local DoubleAxe: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Double Axe",
	["Description"] = "Demonstrate your strength and wield this double-headed weapon to victory!",
	["Rarity"] = "Legendary",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordDoubleAxe,
	["ItemGroup"] = ItemGroup.Sword
}
local KnightsBlade: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Knight\'s Blade",
	["Description"] = "Become a noble knight and slay your opponents with this finely crafted blade!",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordKnightBlade,
	["ItemGroup"] = ItemGroup.Sword
}
local Rapier: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Rapier",
	["Description"] = "Looks pointy... ouch",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordRapier,
	["ItemGroup"] = ItemGroup.Sword
}
local WarAxe: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "War Axe",
	["Description"] = "Prepare yourself for a war in the sky and destroy your opponents with this hefty axe!",
	["Rarity"] = "Legendary",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordWarAxe,
	["ItemGroup"] = ItemGroup.Sword
}
local Wrench: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Wrench",
	["Description"] = "Whack your opponents with this trusty wrench and bolt your way to victory!",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordWrench,
	["ItemGroup"] = ItemGroup.Sword
}
local WarHammer: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "War Hammer",
	["Description"] = "Wield the mythical War Hammer, a weapon of unparalleled destruction, capable of shattering your enemies\' defenses",
	["Rarity"] = "Mythical",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordWarHammer,
	["ItemGroup"] = ItemGroup.Sword
}
local RingSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Ring Sword",
	["Description"] = "Unleash your inner warrior with this sword featuring a unique ring-shaped hilt, providing both style and grip in battle",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordRing,
	["ItemGroup"] = ItemGroup.Sword
}
local RazorSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Razor Sword",
	["Description"] = "Wield this rare sword with a razor-sharp blade, cleaving through your foes with swift and precise strikes",
	["Rarity"] = "Rare",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordRazor,
	["ItemGroup"] = ItemGroup.Sword
}
local Pan: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Pan",
	["Description"] = "Turn a simple kitchen pan into a formidable weapon, inflicting both culinary and combat skills on your opponents",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordPan,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Melee"] = { RobloxAnimation.PAN_SWING }
	}
}
local NatureAxe: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Nature Axe",
	["Description"] = "Tap into the vitality of nature with this common axe",
	["Rarity"] = "Common",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordNatureAxe,
	["ItemGroup"] = ItemGroup.Sword
}
local NatureSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Nature Sword",
	["Description"] = " Wield the power of nature with this epic sword, channeling the forces of the earth for devastating attacks",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordNature,
	["ItemGroup"] = ItemGroup.Sword
}
local Hatchet: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Hatchet",
	["Description"] = "",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordHatchet,
	["ItemGroup"] = ItemGroup.Sword
}
local Chainsaw: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Chainsaw",
	["Description"] = "",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Display"] = nil,
	["Id"] = CosmeticId.SwordChainsaw,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.CHAINSAW_EQUIP,
		["Idle"] = RobloxAnimation.CHAINSAW_IDLE,
		["Sprint"] = RobloxAnimation.CHAINSAW_SPRINT,
		["Melee"] = { RobloxAnimation.CHAINSAW_MELEE },
		["Tool"] = RobloxAnimation.CHAINSAW_TOOL_IDLE
	},
	["Display"] = {
		["Sprinting"] = true,
		["Melee"] = true,
		["MeleeInterval"] = nil,
		["MeleeInterval"] = Vector2.new(2, 4)
	}
}
-- Decompiler helper (definition was lost during the rename pass; restored for correctness)
local function __set_list(list: { any }, startIndex: number, values: { any })
	for i = 1, #values do
		list[startIndex + i - 1] = values[i]
	end
end

__set_list(CosmeticSwords, 1, {SupporterSword, TrainingSword, Cutlass, DoubleAxe, KnightsBlade, Rapier, WarAxe, Wrench, WarHammer, RingSword, RazorSword, Pan, NatureAxe, NatureSword, Hatchet, Chainsaw})
local Claws: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Claws",
	["Description"] = "",
	["Rarity"] = "Rare",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Display"] = nil,
	["Id"] = CosmeticId.SwordClaws,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.CLAWS_MELEE_EQUIP,
		["Idle"] = RobloxAnimation.CLAWS_MELEE_IDLE,
		["Sprint"] = RobloxAnimation.CLAWS_MELEE_SPRINT,
		["Melee"] = { RobloxAnimation.CLAWS_MELEE_RIGHT, RobloxAnimation.CLAWS_MELEE_LEFT }
	},
	["Display"] = {
		["Sprinting"] = true
	}
}
local KnockyaOut3310: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Knockya Out 3310",
	["Description"] = "",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordKnockyaOut3310,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.LONG_AXE_IDLE,
		["Sprint"] = RobloxAnimation.LONG_AXE_RUN,
		["Melee"] = { RobloxAnimation.LONG_AXE_SLASH }
	}
}
local BoxingGloves: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Boxing Gloves",
	["Description"] = "",
	["Rarity"] = "Rare",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Display"] = nil,
	["Id"] = CosmeticId.SwordBoxingGloves,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.BOXING_GLOVES_EQUIP,
		["Idle"] = RobloxAnimation.BOXING_GLOVES_IDLE,
		["Sprint"] = RobloxAnimation.BOXING_GLOVES_SPRINT,
		["Melee"] = { RobloxAnimation.BOXING_GLOVES_MELEE_RIGHT, RobloxAnimation.BOXING_GLOVES_MELEE_LEFT }
	},
	["Display"] = {
		["Melee"] = true,
		["MeleeInterval"] = nil,
		["MeleeInterval"] = Vector2.new(0.4, 0.6)
	}
}
local PlasmaSword: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Plasma Sword",
	["Description"] = "",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordPlasma,
	["ItemGroup"] = ItemGroup.Sword
}
local BaseballBat: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Baseball Bat",
	["Description"] = "",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordBaseballBat,
	["ItemGroup"] = ItemGroup.Sword
}
local GolfClub: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Golf Club",
	["Description"] = "",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordGolfClub,
	["ItemGroup"] = ItemGroup.Sword
}
local HeavyHammers: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Heavy Hammers",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordHeavyHammers,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.GENERIC_DAGGER_EQUIP,
		["Idle"] = RobloxAnimation.GENERIC_DAGGER_IDLE,
		["Sprint"] = RobloxAnimation.GENERIC_DAGGER_SPRINT,
		["Melee"] = { RobloxAnimation.HEAVY_HAMMERS_MELEE }
	}
}
local DualDaggers: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Dual Daggers",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordDualDaggers,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.GENERIC_DAGGER_EQUIP,
		["Idle"] = RobloxAnimation.GENERIC_DAGGER_IDLE,
		["Sprint"] = RobloxAnimation.GENERIC_DAGGER_SPRINT,
		["Melee"] = { RobloxAnimation.DUAL_DAGGERS_MELEE }
	}
}
local SaiDaggers: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Sai Daggers",
	["Rarity"] = "Rare",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Display"] = nil,
	["Id"] = CosmeticId.SwordSaiDagger,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.GENERIC_DAGGER_EQUIP,
		["Idle"] = RobloxAnimation.GENERIC_DAGGER_IDLE,
		["Sprint"] = RobloxAnimation.GENERIC_DAGGER_SPRINT,
		["Melee"] = { RobloxAnimation.SAI_DAGGER_MELEE }
	},
	["Display"] = {
		["Melee"] = true,
		["MeleeInterval"] = nil,
		["MeleeInterval"] = Vector2.new(1.2, 2.5)
	}
}
local Okatana: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Okatana",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordOkatana,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.OKATANA_EQUIP,
		["Idle"] = RobloxAnimation.OKATANA_IDLE,
		["Sprint"] = RobloxAnimation.OKATANA_SPRINT
	}
}
local ConstructionHammer: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Construction Hammer",
	["Rarity"] = "Common",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordConstructionHammer,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Melee"] = { RobloxAnimation.PAN_SWING }
	}
}
local WavyDagger: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Wavy Dagger",
	["Rarity"] = "Uncommon",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["DualWield"] = true,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordWavyDagger,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Equip"] = RobloxAnimation.GENERIC_DAGGER_EQUIP,
		["Idle"] = RobloxAnimation.GENERIC_DAGGER_IDLE,
		["Sprint"] = RobloxAnimation.GENERIC_DAGGER_SPRINT,
		["Melee"] = { RobloxAnimation.DUAL_DAGGERS_MELEE }
	}
}
local RazorBaton: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Razor Baton",
	["Rarity"] = "Rare",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordRazorBaton,
	["ItemGroup"] = ItemGroup.Sword
}
local ForestBlade: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Forest Blade",
	["Rarity"] = "Epic",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordForestBlade,
	["ItemGroup"] = ItemGroup.Sword
}
local Mace: CosmeticDefinition = {
	["Id"] = nil,
	["Name"] = "Mace",
	["Rarity"] = "Legendary",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["ItemAnimation"] = nil,
	["Id"] = CosmeticId.SwordMace,
	["ItemGroup"] = ItemGroup.Sword,
	["ItemAnimation"] = {
		["Idle"] = RobloxAnimation.LONG_AXE_IDLE,
		["Sprint"] = RobloxAnimation.LONG_AXE_RUN,
		["Melee"] = { RobloxAnimation.LONG_AXE_SLASH }
	}
}
__set_list(CosmeticSwords, 17, {Claws, KnockyaOut3310, BoxingGloves, PlasmaSword, BaseballBat, GolfClub, HeavyHammers, DualDaggers, SaiDaggers, Okatana, ConstructionHammer, WavyDagger, RazorBaton, ForestBlade, Mace, {
	["Id"] = nil,
	["Name"] = "Royal Blade",
	["Rarity"] = "Mythical",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordRoyalBlade,
	["ItemGroup"] = ItemGroup.Sword
}})
__set_list(CosmeticSwords, 33, {{
	["Id"] = nil,
	["Name"] = "Brute Sawblade",
	["Rarity"] = "Mythical",
	["Type"] = "Skin",
	["ItemGroup"] = nil,
	["Id"] = CosmeticId.SwordBruteSawblade,
	["ItemGroup"] = ItemGroup.Sword
}})
return {
	["CosmeticSwords"] = CosmeticSwords
}
