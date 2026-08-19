-- GameConstants

local PlaceUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"place",
		"place-util"
	).PlaceUtil
return {
	["GameConstants"] = {
		["CHRISTMAS_LOBBY_ENABLED"] = false,
		["PREGAME_LOBBY_ENABLED"] = true,
		["POST_GAME_LOBBY_ENABLED"] = false,
		["NEW_WIN_EFFECT_ENABLED"] = false,
		["PREGAME_DURATION"] = PlaceUtil.isProduction()
				and (PlaceUtil.isEggWarsServer() and 15 or (PlaceUtil.isSkyWarsServer() and 15 or 10))
			or 10,
	},
}
