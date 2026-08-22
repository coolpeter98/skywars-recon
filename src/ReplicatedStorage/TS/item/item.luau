-- Item definitions

type ItemDefinition = {
	Name: string,
	ItemGroup: string?,
	ItemMaterial: string?,
	ToolRef: Tool?,
	DisplayName: string?,
	Skins: { [string]: Tool }?,
	LeftHanded: boolean?,
	Ranged: any?,
	Projectile: any?,
	Melee: any?,
	Pickaxe: any?,
	Armour: any?,
	Block: any?,
	Currency: any?,
	PowerUp: any?,
	Rewrite: any?,
	Animation: any?,
	ViewportOptions: any?,
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local RobloxAnimation = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local ItemUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-util").ItemUtil
local PowerUps = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "power-up", "power-ups").PowerUps
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local WorldConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "world", "world-constants").WorldConstants
local CosmeticsByType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").CosmeticsByType
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local ItemMaterial = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-material").ItemMaterial
local StringUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil

local ArmourType = {
	["Helmet"] = "Helmet",
	["Chestplate"] = "Chestplate",
	["Leggings"] = "Leggings"
}
local itemDefinitions: { ItemDefinition } = {}
local bowDefinition = {
	["Name"] = "Bow",
	["Ranged"] = nil,
	["ViewportOptions"] = nil,
	["Animation"] = nil
}
local bowRanged = {
	["ProjectileType"] = "Arrow",
	["MinimumDrawTime"] = 0.3,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = RobloxAnimation.BOW_DRAW,
		["FireAnimation"] = RobloxAnimation.BOW_FIRE,
		["DrawSound"] = RobloxSound.Bow.DRAW,
		["FireSound"] = RobloxSound.Bow.FIRE
	}
}
bowDefinition.Ranged = bowRanged
bowDefinition.ViewportOptions = {
	["Rotate"] = Vector3.new(90, 0, 0)
}
bowDefinition.Animation = {
	["Idle"] = RobloxAnimation.BOW_IDLE,
	["Equip"] = RobloxAnimation.BOW_EQUIP
}
local bronzeHelmet = {
	["Name"] = "BronzeHelmet",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.03,
		["ArmourType"] = ArmourType.Helmet
	}
}
local bronzeChestplate = {
	["Name"] = "BronzeChestplate",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.06,
		["ArmourType"] = ArmourType.Chestplate
	}
}
local bronzeLeggings = {
	["Name"] = "BronzeLeggings",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.06,
		["ArmourType"] = ArmourType.Leggings
	}
}
local ironHelmet = {
	["Name"] = "IronHelmet",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.0625,
		["ArmourType"] = ArmourType.Helmet
	}
}
-- Decompiler helper (definition was lost during the rename pass; restored for correctness)
local function __set_list(list: { any }, startIndex: number, values: { any })
	for i = 1, #values do
		list[startIndex + i - 1] = values[i]
	end
end

__set_list(itemDefinitions, 1, {{
	["Name"] = "BronzePickaxe",
	["Pickaxe"] = nil,
	["Pickaxe"] = {
		["TimeMultiplier"] = 1
	}
}, {
	["Name"] = "IronPickaxe",
	["Pickaxe"] = nil,
	["Pickaxe"] = {
		["TimeMultiplier"] = 0.7
	}
}, {
	["Name"] = "GoldPickaxe",
	["Pickaxe"] = nil,
	["Pickaxe"] = {
		["TimeMultiplier"] = 0.6
	}
}, {
	["Name"] = "DiamondPickaxe",
	["Pickaxe"] = nil,
	["Pickaxe"] = {
		["TimeMultiplier"] = 0.4
	}
}, {
	["Name"] = "OnyxPickaxe",
	["Pickaxe"] = nil,
	["Pickaxe"] = {
		["TimeMultiplier"] = 0.3
	}
}, {
	["Name"] = "BronzeSword",
	["Melee"] = nil,
	["Melee"] = {
		["Damage"] = 18
	}
}, {
	["Name"] = "IronSword",
	["Melee"] = nil,
	["Melee"] = {
		["Damage"] = 23
	}
}, {
	["Name"] = "GoldSword",
	["Melee"] = nil,
	["Melee"] = {
		["Damage"] = 25
	}
}, {
	["Name"] = "DiamondSword",
	["Melee"] = nil,
	["Melee"] = {
		["Damage"] = 29
	}
}, {
	["Name"] = "OnyxSword",
	["Melee"] = nil,
	["Melee"] = {
		["Damage"] = 32
	}
}, bowDefinition, {
	["Name"] = "Arrow",
	["Projectile"] = nil,
	["ViewportOptions"] = nil,
	["Projectile"] = {
		["Damage"] = 18,
		["WeldOnCollide"] = true
	},
	["ViewportOptions"] = {
		["Zoom"] = 0.45
	}
}, bronzeHelmet, bronzeChestplate, bronzeLeggings, ironHelmet})
local ironChestplate = {
	["Name"] = "IronChestplate",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.09375,
		["ArmourType"] = ArmourType.Chestplate
	}
}
local ironLeggings = {
	["Name"] = "IronLeggings",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.09375,
		["ArmourType"] = ArmourType.Leggings
	}
}
local goldHelmet = {
	["Name"] = "GoldHelmet",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.09375,
		["ArmourType"] = ArmourType.Helmet
	}
}
local goldChestplate = {
	["Name"] = "GoldChestplate",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.125,
		["ArmourType"] = ArmourType.Chestplate
	}
}
local goldLeggings = {
	["Name"] = "GoldLeggings",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.125,
		["ArmourType"] = ArmourType.Leggings
	}
}
local diamondHelmet = {
	["Name"] = "DiamondHelmet",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.12,
		["ArmourType"] = ArmourType.Helmet
	}
}
local diamondChestplate = {
	["Name"] = "DiamondChestplate",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.165,
		["ArmourType"] = ArmourType.Chestplate
	}
}
local diamondLeggings = {
	["Name"] = "DiamondLeggings",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.165,
		["ArmourType"] = ArmourType.Leggings
	}
}
local onyxHelmet = {
	["Name"] = "OnyxHelmet",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.165,
		["ArmourType"] = ArmourType.Helmet
	}
}
local onyxChestplate = {
	["Name"] = "OnyxChestplate",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.18,
		["ArmourType"] = ArmourType.Chestplate
	}
}
local onyxLeggings = {
	["Name"] = "OnyxLeggings",
	["Armour"] = nil,
	["Armour"] = {
		["ArmourType"] = nil,
		["DamageMitigation"] = 0.18,
		["ArmourType"] = ArmourType.Leggings
	}
}
local teleporterDefinition = {
	["Name"] = "Teleporter",
	["Ranged"] = nil,
	["Projectile"] = nil,
	["ViewportOptions"] = nil,
	["LeftHanded"] = true
}
local teleporterRanged = {
	["ProjectileType"] = "Teleporter",
	["MinimumDrawTime"] = 0.05,
	["DrawTime"] = 0.3,
	["Cooldown"] = 15,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = nil,
		["FireAnimation"] = nil,
		["FireSound"] = nil,
		["FireAnimationSpeed"] = 2,
		["DrawAnimation"] = RobloxAnimation.PROJECTILE_DRAW,
		["FireAnimation"] = RobloxAnimation.PROJECTILE_FIRE,
		["FireSound"] = RobloxSound.Teleporter.FIRE
	}
}
teleporterDefinition.Ranged = teleporterRanged
local teleporterProjectile = {
	["Damage"] = 0,
	["CollidePlayers"] = true,
	["WeldOnCollide"] = false,
	["ImpactSound"] = nil,
	["ParticleTrail"] = nil,
	["ExplosionParticles"] = nil,
	["ImpactSound"] = RobloxSound.Teleporter.IMPACT,
	["ParticleTrail"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 60,
		["Speed"] = 3,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 53, 164)), ColorSequenceKeypoint.new(1, Color3.fromRGB(183, 89, 201)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(2, 3),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(0, 180)
	},
	["ExplosionParticles"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 5,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 20,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(37, 143, 107)), ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 125, 130)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(0.5, 0.5),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(0, 180)
	}
}
teleporterDefinition.Projectile = teleporterProjectile
teleporterDefinition.ViewportOptions = {
	["Zoom"] = 0.5
}
local snowballDefinition = {
	["Name"] = "Snowball",
	["Ranged"] = nil,
	["Projectile"] = nil,
	["ViewportOptions"] = nil,
	["LeftHanded"] = true
}
local snowballRanged = {
	["ProjectileType"] = "Snowball",
	["MinimumDrawTime"] = 0.01,
	["DrawTime"] = 0.05,
	["Cooldown"] = 0.5,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = nil,
		["FireAnimation"] = nil,
		["FireSound"] = nil,
		["FireAnimationSpeed"] = 2,
		["DrawAnimation"] = RobloxAnimation.PROJECTILE_DRAW,
		["FireAnimation"] = RobloxAnimation.PROJECTILE_FIRE,
		["FireSound"] = RobloxSound.Snowball.FIRE
	}
}
snowballDefinition.Ranged = snowballRanged
local snowballProjectile = {
	["Damage"] = 0,
	["WeldOnCollide"] = false,
	["ImpactSound"] = nil,
	["ParticleTrail"] = nil,
	["ExplosionParticles"] = nil,
	["ImpactSound"] = RobloxSound.Snowball.IMPACT,
	["ParticleTrail"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 60,
		["Speed"] = 3,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(202, 231, 252)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(2, 3),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180)
	},
	["ExplosionParticles"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 5,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 20,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(202, 231, 252)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(0.5, 0.5),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180)
	}
}
snowballDefinition.Projectile = snowballProjectile
snowballDefinition.ViewportOptions = {
	["Zoom"] = 0.5
}
local capybaraDefinition = {
	["Name"] = "Capybara",
	["Ranged"] = nil,
	["Projectile"] = nil,
	["ViewportOptions"] = nil,
	["LeftHanded"] = true
}
local capybaraRanged = {
	["ProjectileType"] = "Capybara",
	["MinimumDrawTime"] = 0.05,
	["DrawTime"] = 0.3,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = nil,
		["FireAnimation"] = nil,
		["FireSound"] = nil,
		["EquipSound"] = nil,
		["FireAnimationSpeed"] = 2,
		["DrawAnimation"] = RobloxAnimation.PROJECTILE_DRAW,
		["FireAnimation"] = RobloxAnimation.PROJECTILE_FIRE,
		["FireSound"] = RobloxSound.Snowball.FIRE,
		["EquipSound"] = RobloxSound.Capybara.EQUIP
	}
}
capybaraDefinition.Ranged = capybaraRanged
local capybaraProjectile = {
	["Damage"] = 42,
	["WeldOnCollide"] = false,
	["FlyingSound"] = nil,
	["ExplosionSound"] = nil,
	["ExplosionRadius"] = 3,
	["KnockbackRadius"] = 5,
	["Velocity"] = 150,
	["Acceleration"] = nil,
	["ParticleTrail"] = nil,
	["ExplosionParticles"] = nil,
	["FlyingSound"] = RobloxSound.Capybara.FLYING,
	["ExplosionSound"] = RobloxSound.Capybara.IMPACT,
	["Acceleration"] = WorldConstants.WORLD_ACCELERATION * 0.5,
	["ParticleTrail"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 60,
		["Speed"] = 3,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(3, 5),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(0, 180)
	},
	["ExplosionParticles"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 30,
		["Acceleration"] = nil,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 100,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.25, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Acceleration"] = WorldConstants.WORLD_ACCELERATION * 0.5,
		["Lifetime"] = NumberRange.new(0.5, 1),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180)
	}
}
capybaraDefinition.Projectile = capybaraProjectile
capybaraDefinition.ViewportOptions = {
	["Zoom"] = 0.5
}
__set_list(itemDefinitions, 17, {ironChestplate, ironLeggings, goldHelmet, goldChestplate, goldLeggings, diamondHelmet, diamondChestplate, diamondLeggings, onyxHelmet, onyxChestplate, onyxLeggings, teleporterDefinition, snowballDefinition, capybaraDefinition, {
	["Name"] = "BronzeCoin",
	["Currency"] = nil,
	["ViewportOptions"] = nil,
	["Currency"] = {},
	["ViewportOptions"] = {
		["Rotate"] = Vector3.new(0, 45, 0)
	}
}, {
	["Name"] = "IronCoin",
	["Currency"] = nil,
	["ViewportOptions"] = nil,
	["Currency"] = {},
	["ViewportOptions"] = {
		["Rotate"] = Vector3.new(0, 45, 0)
	}
}})
local dynamiteDefinition = {
	["Name"] = "Dynamite",
	["Ranged"] = nil,
	["Projectile"] = nil,
	["ViewportOptions"] = nil,
	["LeftHanded"] = true
}
local dynamiteRanged = {
	["ProjectileType"] = "Dynamite",
	["MinimumDrawTime"] = 0.05,
	["DrawTime"] = 0.3,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = nil,
		["FireAnimation"] = nil,
		["FireSound"] = nil,
		["FireAnimationSpeed"] = 2,
		["DrawAnimation"] = RobloxAnimation.PROJECTILE_DRAW,
		["FireAnimation"] = RobloxAnimation.PROJECTILE_FIRE,
		["FireSound"] = RobloxSound.Snowball.FIRE
	}
}
dynamiteDefinition.Ranged = dynamiteRanged
local dynamiteProjectile = {
	["Damage"] = 0,
	["WeldOnCollide"] = false,
	["FlyingSound"] = nil,
	["ExplosionSound"] = nil,
	["ExplosionRadius"] = 3,
	["KnockbackRadius"] = 5,
	["Velocity"] = 80,
	["Acceleration"] = nil,
	["ParticleTrail"] = nil,
	["ExplosionParticles"] = nil,
	["FlyingSound"] = RobloxSound.Explosion.FLYING,
	["ExplosionSound"] = RobloxSound.Explosion.IMPACT,
	["Acceleration"] = WorldConstants.WORLD_ACCELERATION,
	["ParticleTrail"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Rate"] = 60,
		["Speed"] = 3,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.25, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Lifetime"] = NumberRange.new(3, 5),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(0, 180)
	},
	["ExplosionParticles"] = {
		["Color"] = nil,
		["Size"] = nil,
		["Speed"] = 30,
		["Acceleration"] = nil,
		["Lifetime"] = nil,
		["Rotation"] = nil,
		["LightInfluence"] = 1,
		["LightEmission"] = 0.7,
		["SpreadAngle"] = nil,
		["Count"] = 100,
		["Color"] = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)) }),
		["Size"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.25, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.01)
		}),
		["Acceleration"] = WorldConstants.WORLD_ACCELERATION * 0.5,
		["Lifetime"] = NumberRange.new(0.5, 1),
		["Rotation"] = NumberRange.new(0, 360),
		["SpreadAngle"] = Vector2.new(180, 180)
	}
}
dynamiteDefinition.Projectile = dynamiteProjectile
dynamiteDefinition.ViewportOptions = {
	["Zoom"] = 0.5
}
local fishingRodDefinition = {
	["Name"] = "FishingRod",
	["Ranged"] = nil,
	["Animation"] = nil
}
local fishingRodRanged = {
	["ProjectileType"] = "Fish",
	["MinimumDrawTime"] = 0.05,
	["Cooldown"] = 1,
	["RequiresAmmo"] = false,
	["DrawTime"] = 0.05,
	["Animation"] = nil,
	["Animation"] = {
		["DrawAnimation"] = RobloxAnimation.FISHING_WIND,
		["FireAnimation"] = RobloxAnimation.FISHING_CAST,
		["DrawSound"] = RobloxSound.Bow.DRAW,
		["FireSound"] = RobloxSound.Bow.FIRE
	}
}
fishingRodDefinition.Ranged = fishingRodRanged
fishingRodDefinition.Animation = {
	["Idle"] = RobloxAnimation.FISHING_IDLE
}
local fishDefinition = {
	["Name"] = "Fish",
	["Projectile"] = nil,
	["Projectile"] = {
		["Damage"] = 0,
		["WeldOnCollide"] = false,
		["KnockbackScalar"] = Vector3.new(-1.5, 1, -1.5),
		["Velocity"] = 75,
		["Acceleration"] = nil,
		["Acceleration"] = WorldConstants.WORLD_ACCELERATION
	}
}
__set_list(itemDefinitions, 33, {{
	["Name"] = "GoldCoin",
	["Currency"] = nil,
	["ViewportOptions"] = nil,
	["Currency"] = {},
	["ViewportOptions"] = {
		["Rotate"] = Vector3.new(0, 45, 0)
	}
}, {
	["Name"] = "Shard",
	["Currency"] = nil,
	["ViewportOptions"] = nil,
	["Currency"] = {},
	["ViewportOptions"] = {
		["Rotate"] = Vector3.new(0, 45, 0)
	}
}, {
	["Name"] = "TeamConcrete",
	["Rewrite"] = nil,
	["Rewrite"] = {
		["Type"] = "ConcreteSmooth{TeamId}"
	}
}, {
	["Name"] = "Planks",
	["Block"] = nil,
	["Block"] = {
		["BreakTime"] = 1
	}
}, {
	["Name"] = "StoneBricks",
	["Block"] = nil,
	["Block"] = {
		["BreakTime"] = 1.75
	}
}, {
	["Name"] = "AquaBricks",
	["Block"] = nil,
	["Block"] = {
		["BreakTime"] = 2.5
	}
}, {
	["Name"] = "Iron",
	["Block"] = nil,
	["Block"] = {
		["BreakTime"] = 3
	}
}, {
	["Name"] = "ShimBlock",
	["Block"] = nil,
	["Block"] = {
		["BreakTime"] = (1 / 0)
	}
}, dynamiteDefinition, {
	["Name"] = "EasterIslandHead"
}, {
	["Name"] = "Landmine",
	["Block"] = nil,
	["Block"] = {
		["NoAssist"] = true,
		["BreakTime"] = 1,
		["CollectionTag"] = "block:landmine"
	}
}, {
	["Name"] = "Launchpad",
	["Block"] = nil,
	["Block"] = {
		["NoAssist"] = true,
		["Rotation"] = true,
		["BreakTime"] = 1,
		["CollectionTag"] = "block:launchpad"
	}
}, {
	["Name"] = "SmokeGrenade"
}, {
	["Name"] = "Tornado"
}, fishingRodDefinition, fishDefinition})
__set_list(itemDefinitions, 49, {{
	["Name"] = "Ice",
	["Block"] = {
		["BreakTime"] = 0.5
	}
}})
local initialItemCount = #itemDefinitions
local powerUpValues = ObjectUtils.values(PowerUps)
local powerUpItems: { ItemDefinition } = table.create(#powerUpValues)
local function powerUpToItem(powerUp: { Type: string }): ItemDefinition
	local item: ItemDefinition = {
		["Name"] = powerUp.Type,
		["PowerUp"] = {
			["Type"] = powerUp.Type,
			["Cooldown"] = powerUp.Type == "Adrenaline" and 15 or nil
		},
		["ViewportOptions"] = {
			["Zoom"] = nil,
			["Rotate"] = Vector3.new(0, 90, 0),
			["Zoom"] = powerUp.Type == "Adrenaline" and 0.65 or 0.5
		}
	}
	return item
end
for index, powerUp: { Type: string } in powerUpValues do
	powerUpItems[index] = powerUpToItem(powerUp, index - 1, powerUpValues)
end
local powerUpCount = #powerUpItems
table.move(powerUpItems, 1, powerUpCount, initialItemCount + 1, itemDefinitions)
local itemCountWithPowerUps = initialItemCount + powerUpCount
local blockInstances = ReplicatedStorage.Blocks:GetChildren()
local blockItems: { ItemDefinition } = table.create(#blockInstances)
for index, blockInstance: Instance in blockInstances do
	local _ = index - 1
	blockItems[index] = {
		["Name"] = blockInstance.Name,
		["Block"] = {
			["BreakTime"] = 0.5
		}
	}
end
table.move(blockItems, 1, #blockItems, itemCountWithPowerUps + 1, itemDefinitions)
local blocksSerialized: { [number]: ItemDefinition } = {}
local itemsByGroup: { [string]: { ItemDefinition } } = {}
local items: { [string]: ItemDefinition } = {}
local function loadToolRef(item: ItemDefinition): Tool
	local name: string = item.Name
	local tool
	if item.Block then
		tool = ReplicatedStorage.Blocks:FindFirstChild(name)
		if tool ~= nil then
			tool = tool:Clone()
		end
	else
		tool = ReplicatedStorage.Items:FindFirstChild(name)
		if tool ~= nil then
			tool = tool:Clone()
		end
	end
	if not tool and item.PowerUp then
		tool = ReplicatedStorage.Items:FindFirstChild("Potion" .. name)
		if tool ~= nil then
			tool = tool:Clone()
		end
	end
	if not tool and item.Rewrite then
		tool = Instance.new("Part")
	end
	if not tool then
		error((("Missing item asset for %*!"):format(name)))
	end
	if tool:IsA("BasePart") then
		tool = ItemUtil.createToolFromBasePart(tool)
	end
	if tool:IsA("Accessory") then
		tool = ItemUtil.createToolFromAccessory(tool)
	end
	tool.Name = name
	for _, descendant in tool:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end
	tool.CanBeDropped = false
	return tool
end
local function applyItemGroup(item: ItemDefinition)
	if item.Armour then
		local armourType = item.Armour.ArmourType
		if armourType == ArmourType.Helmet then
			item.ItemGroup = ItemGroup.Helmet
			return nil
		end
		if armourType == ArmourType.Chestplate then
			item.ItemGroup = ItemGroup.Chestplate
			return nil
		end
		if armourType == ArmourType.Leggings then
			item.ItemGroup = ItemGroup.Leggings
			return nil
		end
	end
	if item.Melee then
		item.ItemGroup = ItemGroup.Sword
		return nil
	end
	if item.Name == "Bow" then
		item.ItemGroup = ItemGroup.Bow
		return nil
	end
	if item.Name == "Snowball" then
		item.ItemGroup = ItemGroup.Snowball
		return nil
	end
	if item.Pickaxe then
		item.ItemGroup = ItemGroup.Pickaxe
	end
end
local function applyItemMaterial(item: ItemDefinition)
	if not item.ItemGroup then
		return nil
	end
	for _, material in ObjectUtils.values(ItemMaterial) do
		if #{ string.find(item.Name, material) } > 0 then
			item.ItemMaterial = material
			return nil
		end
	end
end
local function loadSkinToolRef(_, skinTool: Tool): Tool
	if skinTool:IsA("Accessory") then
		skinTool = ItemUtil.createToolFromAccessory(skinTool)
	end
	for _, descendant in skinTool:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end
	skinTool.CanBeDropped = false
	return skinTool
end
for _, item: ItemDefinition in itemDefinitions do
	if items[item.Name] == nil then
		item.ToolRef = loadToolRef(item)
		item.DisplayName = StringUtil.formatDisplayName(item.Name)
		applyItemGroup(item)
		applyItemMaterial(item)
		if item.Projectile then
			item.Projectile.Ref = ReplicatedStorage.Projectiles:FindFirstChild(item.Name)
		end
		if item.Armour then
			item.Armour.Ref = ReplicatedStorage.Items:FindFirstChild(item.Name)
		end
		if item.Block then
			local serializeId = 0
			for _ in blocksSerialized do
				serializeId = serializeId + 1
			end
			item.Block.SerializeId = serializeId
			item.Block.Ref = ReplicatedStorage.Blocks:FindFirstChild(item.Name)
			item.Block.PrimaryColor = item.Block.Ref.Color
			blocksSerialized[item.Block.SerializeId] = item
		end
		items[item.Name] = item
		if item.ItemGroup then
			if itemsByGroup[item.ItemGroup] == nil then
				itemsByGroup[item.ItemGroup] = {}
			end
			local groupItems = itemsByGroup[item.ItemGroup]
			table.insert(groupItems, item)
		end
	end
end
for _, cosmetic in CosmeticsByType.Skin do
	if cosmetic.Type == "Skin" then
		local skinFolder = ReplicatedStorage.Skins:FindFirstChild(cosmetic.Id)
		if not skinFolder then
			error("Skin cosmetic folder does not exist! " .. cosmetic.Id)
		end
		for _, item in itemsByGroup[cosmetic.ItemGroup] do
			local skinInstance = skinFolder:FindFirstChild(item.Name)
			if not skinInstance then
				error((("Missing item skin for cosmetic %*, type: %*!"):format(cosmetic.Id, item.Name)))
			end
			local skinTool = loadSkinToolRef(item, skinInstance:Clone())
			if not item.Skins then
				item.Skins = {}
			end
			item.Skins[cosmetic.Id] = skinTool
			if item.Armour then
				if not item.Armour.Skins then
					item.Armour.Skins = {}
				end
				item.Armour.Skins[cosmetic.Id] = skinInstance
			end
		end
	end
end
return {
	["ArmourType"] = ArmourType,
	["Items"] = items,
	["ItemsByGroup"] = itemsByGroup,
	["BlocksSerialized"] = blocksSerialized
}
