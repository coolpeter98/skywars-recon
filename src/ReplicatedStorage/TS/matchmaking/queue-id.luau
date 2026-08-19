-- QueueId

type QueueId =
	| "solo"
	| "duos"
	| "trios"
	| "quads"
	| "testing_solo"
	| "testing_duos"
	| "testing_trios"
	| "testing_quads"
	| "private"
	| "testing_private"
	| "duels_solo"
	| "duels_duos"
	| "testing_duels_solo"
	| "testing_duels_duos"
	| "eggwars_quads"
	| "testing_eggwars_quads"

return {
	["QueueId"] = {
		["Solo"] = "solo",
		["Duos"] = "duos",
		["Trios"] = "trios",
		["Quads"] = "quads",
		["TestingSolo"] = "testing_solo",
		["TestingDuos"] = "testing_duos",
		["TestingTrios"] = "testing_trios",
		["TestingQuads"] = "testing_quads",
		["Private"] = "private",
		["TestingPrivate"] = "testing_private",
		["DuelsSolo"] = "duels_solo",
		["DuelsDuos"] = "duels_duos",
		["TestingDuelsSolo"] = "testing_duels_solo",
		["TestingDuelsDuos"] = "testing_duels_duos",
		["EggWarsQuads"] = "eggwars_quads",
		["TestingEggWarsQuads"] = "testing_eggwars_quads",
	},
}
