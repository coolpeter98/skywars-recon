-- RobloxSound

type SoundActionMap = { [string]: string }
type RobloxSounds = { [string]: SoundActionMap }

local robloxSounds: RobloxSounds = {
	["Chest"] = {
		["OPEN"] = "rbxassetid://9709271845",
	},
	["Humanoid"] = {
		["DAMAGE"] = "rbxassetid://8455818629",
	},
	["Inventory"] = {
		["MOVE_ITEM"] = "rbxassetid://8380833278",
		["EQUIP_TOOL"] = "rbxassetid://8380833386",
		["EQUIP_BLOCK"] = "rbxassetid://8380833583",
		["PICKUP_ITEM"] = "rbxassetid://8908013134",
	},
	["Potion"] = {
		["DRINK"] = "rbxassetid://9403380332",
	},
	["Block"] = {
		["HIT"] = "rbxassetid://8455818143",
		["BREAK"] = "rbxassetid://8455817751",
		["PLACE"] = "rbxassetid://8429664778",
	},
	["Sword"] = {
		["SLASH"] = "rbxassetid://8436511628",
		["EQUIP"] = "rbxassetid://8455819490",
	},
	["Bow"] = {
		["DRAW"] = "rbxassetid://8534188700",
		["FIRE"] = "rbxassetid://8534189104",
	},
	["Teleporter"] = {
		["FIRE"] = "rbxassetid://8611122546",
		["IMPACT"] = "rbxassetid://8611122368",
	},
	["Snowball"] = {
		["FIRE"] = "rbxassetid://8611122168",
		["IMPACT"] = "rbxassetid://8611121964",
	},
	["Capybara"] = {
		["EQUIP"] = "rbxassetid://10593895437",
		["FLYING"] = "rbxassetid://10593881209",
		["IMPACT"] = "rbxassetid://10591846837",
	},
	["Projectile"] = {
		["HIT"] = "rbxassetid://8380833720",
	},
	["Stats"] = {
		["GAME_WIN"] = "rbxassetid://6608499332",
		["GAME_LOSE"] = "rbxassetid://6608499387",
		["GAIN_COINS"] = "rbxassetid://6582070562",
		["LOSE_COINS"] = "rbxassetid://6608491383",
		["LEVEL_UP"] = "rbxassetid://6582070491",
	},
	["Kill"] = {
		["ONE"] = "rbxassetid://10098077058",
		["TWO"] = "rbxassetid://10098077409",
		["THREE"] = "rbxassetid://10098076925",
		["FOUR"] = "rbxassetid://10098076768",
		["FIVE"] = "rbxassetid://10098079539",
	},
	["Countdown"] = {
		["THREE"] = "rbxassetid://11095062534",
		["TWO"] = "rbxassetid://11095062429",
		["ONE"] = "rbxassetid://11095062688",
		["GO"] = "rbxassetid://11095062601",
	},
	["Misc"] = {
		["WIND"] = "rbxassetid://9172578252",
		["TICK"] = "rbxassetid://8429665820",
		["TICK_START"] = "rbxassetid://8436512507",
		["KILL"] = "rbxassetid://8455820666",
		["WIN"] = "rbxassetid://9172577042",
		["LOSS"] = "rbxassetid://9172577628",
		["WIN_PODIUM"] = "rbxassetid://9544794938",
	},
	["Cosmetic"] = {
		["UFO_IDLE"] = "rbxassetid://8837591387",
	},
	["Matchmaking"] = {
		["START"] = "rbxassetid://8482233409",
		["SUCCESSFUL"] = "rbxassetid://8482231837",
		["CANCEL"] = "rbxassetid://8482232751",
	},
	["Button"] = {
		["DOWN"] = "rbxassetid://8908013242",
		["UP"] = "rbxassetid://8908012931",
	},
	["Lobby"] = {
		["SOUNDTRACK"] = "rbxassetid://9773372659",
	},
	["Wizard"] = {
		["IDLE_ONE"] = "rbxassetid://12947319318",
		["IDLE_TWO"] = "rbxassetid://12947265111",
		["IDLE_THREE"] = "rbxassetid://12947319813",
		["IDLE_FOUR"] = "rbxassetid://12947264938",
	},
	["Egg"] = {
		["IDLE_ONE"] = "rbxassetid://12947266005",
		["IDLE_TWO"] = "rbxassetid://12947319110",
		["IDLE_THREE"] = "rbxassetid://12947266115",
		["IDLE_FOUR"] = "rbxassetid://12947265896",
		["EGG_HIT"] = "rbxassetid://12947319985",
		["EGG_DEATH"] = "rbxassetid://12947319436",
	},
	["Blacksmith"] = {
		["IDLE_ONE"] = "rbxassetid://12947270476",
		["IDLE_TWO"] = "rbxassetid://12947319745",
		["IDLE_THREE"] = "rbxassetid://12947319911",
		["IDLE_FOUR"] = "rbxassetid://12947268546",
	},
	["Dog"] = {
		["IDLE_ONE"] = "rbxassetid://12947268791",
		["IDLE_TWO"] = "rbxassetid://12947268743",
		["IDLE_THREE"] = "rbxassetid://12947268657",
		["IDLE_FOUR"] = "rbxassetid://12947268441",
	},
	["Dropper"] = {
		["DROPPER_DROP"] = "rbxassetid://12947266168",
		["DROPPER_IDLE"] = "rbxassetid://12947319642",
	},
	["EggUi"] = {
		["TEAM_ELIMINATED"] = "rbxassetid://12947265040",
		["TEAM_UPGRADE"] = "rbxassetid://12947265780",
		["PURCHASE"] = "rbxassetid://12947265840",
		["UPGRADE"] = "rbxassetid://12947270587",
	},
	["Explosion"] = {
		["IMPACT"] = "rbxassetid://13181076146",
		["FLYING"] = "rbxassetid://13181076193",
	},
	["Crate"] = {
		["CRATE_OPEN"] = "rbxassetid://18210578789",
		["CRATE_OPENED_LOOP_01"] = "rbxassetid://18210576237",
		["CRATE_OPENED_LOOP_02"] = "rbxassetid://18210576695",
		["CRATE_OPENED_LOOP_03"] = "rbxassetid://18210578357",
		["CRATE_OPENED_LOOP_04"] = "rbxassetid://18210577027",
		["CRATE_OPENED_LOOP_05"] = "rbxassetid://18210577954",
		["CRATE_OPENED_LOOP_06"] = "rbxassetid://18210577506",
	},
	["WinEffect"] = {
		["WIN_EFFECT"] = "rbxassetid://131179969284554",
		["WIN_EFFECT_AMBIENT"] = "rbxassetid://93476224172163",
		["WIN_EFFECT_PLATFORM_HOVER_LOOP"] = "rbxassetid://125027021117399",
		["WIN_EFFECT_BRONZE_PLATFORM_IN"] = "rbxassetid://124723237216353",
		["WIN_EFFECT_SILVER_PLATFORM_IN"] = "rbxassetid://132736796331505",
		["WIN_EFFECT_GOLD_PLATFORM_IN"] = "rbxassetid://139647530659875",
		["WIN_EFFECT_BRONZE_TROPHY_IN"] = "rbxassetid://90974401644740",
		["WIN_EFFECT_SILVER_TROPHY_IN"] = "rbxassetid://137303053687283",
		["WIN_EFFECT_GOLD_TROPHY_IN"] = "rbxassetid://83148721067912",
	},
}
return {
	["RobloxSound"] = robloxSounds,
}
