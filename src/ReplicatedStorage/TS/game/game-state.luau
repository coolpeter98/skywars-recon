-- GameState

export type GameState = "Pregame" | "Countdown" | "InGame" | "Ended"

return {
	["GameState"] = {
		["Pregame"] = "Pregame",
		["Countdown"] = "Countdown",
		["InGame"] = "InGame",
		["Ended"] = "Ended",
	},
}
