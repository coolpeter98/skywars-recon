-- HealthConstants

export type HealthConstants = {
	MIN_HEALTH: number,
	MAX_HEALTH: number,
	DAMAGE_COOLDOWN: number,
	MAX_SHIELD: number,
	EGG_DEFAULT_HEALTH: number,
	ADRENALINE_SHIELD: number,
	HEALTH_PER_SEGMENT: number,
}

export type DamageType = "Melee" | "Bow" | "Fall" | "Void"

export type RegenerationType = "Passive" | "LifeSteal" | "Triumph" | "Adrenaline"

return {
	["HealthConstants"] = {
		["MIN_HEALTH"] = 0,
		["MAX_HEALTH"] = 100,
		["DAMAGE_COOLDOWN"] = 0.4,
		["MAX_SHIELD"] = 50,
		["EGG_DEFAULT_HEALTH"] = 100,
		["ADRENALINE_SHIELD"] = 30,
		["HEALTH_PER_SEGMENT"] = 10,
	},
	["DamageType"] = {
		["Melee"] = "Melee",
		["Bow"] = "Bow",
		["Fall"] = "Fall",
		["Void"] = "Void",
	},
	["RegenerationType"] = {
		["Passive"] = "Passive",
		["LifeSteal"] = "LifeSteal",
		["Triumph"] = "Triumph",
		["Adrenaline"] = "Adrenaline",
	},
}
