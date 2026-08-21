-- RobloxSound

type SoundActionMap = { [string]: string }
type RobloxSounds = { [string]: SoundActionMap }

local robloxSounds: RobloxSounds = {
	["Chest"] = {
		["OPEN"] = "rbxassetid://128409430735288",
	},
	["Humanoid"] = {
		["DAMAGE"] = "rbxassetid://136068735248127",
	},
	["Inventory"] = {
		["MOVE_ITEM"] = "rbxassetid://100295889451580",
		["EQUIP_TOOL"] = "rbxassetid://86941247054812",
		["EQUIP_BLOCK"] = "rbxassetid://113341874868733",
		["PICKUP_ITEM"] = "rbxassetid://98581106623203",
	},
	["Potion"] = {
		["DRINK"] = "rbxassetid://74556266057216",
	},
	["Block"] = {
		["HIT"] = "rbxassetid://94280058609535",
		["BREAK"] = "rbxassetid://135884814214654",
		["PLACE"] = "rbxassetid://128848977924584",
	},
	["Sword"] = {
		["SLASH"] = "rbxassetid://114644141825874",
		["EQUIP"] = "rbxassetid://94187850731650",
	},
	["Bow"] = {
		["DRAW"] = "rbxassetid://91101272339078",
		["FIRE"] = "rbxassetid://116027260447912",
	},
	["Teleporter"] = {
		["FIRE"] = "rbxassetid://83419744476965",
		["IMPACT"] = "rbxassetid://130585081528198",
	},
	["Snowball"] = {
		["FIRE"] = "rbxassetid://111048538103617",
		["IMPACT"] = "rbxassetid://117838404466480",
	},
	["Capybara"] = {
		["EQUIP"] = "rbxassetid://82106781872799",
		["FLYING"] = "rbxassetid://132601312039073",
		["IMPACT"] = "rbxassetid://122226795469084",
	},
	["Projectile"] = {
		["HIT"] = "rbxassetid://124895370060795",
	},
	["Stats"] = {
		["GAME_WIN"] = "rbxassetid://121640841889921",
		["GAME_LOSE"] = "rbxassetid://78136989114608",
		["GAIN_COINS"] = "rbxassetid://96767745862329",
		["LOSE_COINS"] = "rbxassetid://100679747139510",
		["LEVEL_UP"] = "rbxassetid://98773268912438",
	},
	["Kill"] = {
		["ONE"] = "rbxassetid://118722990389330",
		["TWO"] = "rbxassetid://97947855515221",
		["THREE"] = "rbxassetid://137553170997613",
		["FOUR"] = "rbxassetid://86508816773093",
		["FIVE"] = "rbxassetid://108532505088352",
	},
	["Countdown"] = {
		["THREE"] = "rbxassetid://102026725011504",
		["TWO"] = "rbxassetid://137949350432796",
		["ONE"] = "rbxassetid://109409336346942",
		["GO"] = "rbxassetid://114954535883034",
	},
	["Misc"] = {
		["WIND"] = "rbxassetid://92741501655094",
		["TICK"] = "rbxassetid://117941023691282",
		["TICK_START"] = "rbxassetid://137010036351832",
		["KILL"] = "rbxassetid://119531751164383",
		["WIN"] = "rbxassetid://73616489563560",
		["LOSS"] = "rbxassetid://99109503569557",
		["WIN_PODIUM"] = "rbxassetid://104678757883885",
	},
	["Cosmetic"] = {
		["UFO_IDLE"] = "rbxassetid://87489880856896",
	},
	["Matchmaking"] = {
		["START"] = "rbxassetid://89330419702148",
		["SUCCESSFUL"] = "rbxassetid://91076128131910",
		["CANCEL"] = "rbxassetid://104913777463510",
	},
	["Button"] = {
		["DOWN"] = "rbxassetid://107641683799295",
		["UP"] = "rbxassetid://134386406824823",
	},
	["Lobby"] = {
		["SOUNDTRACK"] = "rbxassetid://79668061824174",
	},
	["Wizard"] = {
		["IDLE_ONE"] = "rbxassetid://139707376710276",
		["IDLE_TWO"] = "rbxassetid://102186139849451",
		["IDLE_THREE"] = "rbxassetid://130314344718745",
		["IDLE_FOUR"] = "rbxassetid://74158037645597",
	},
	["Egg"] = {
		["IDLE_ONE"] = "rbxassetid://95633192387155",
		["IDLE_TWO"] = "rbxassetid://118546812581571",
		["IDLE_THREE"] = "rbxassetid://74800063479716",
		["IDLE_FOUR"] = "rbxassetid://113461199271882",
		["EGG_HIT"] = "rbxassetid://74092427039747",
		["EGG_DEATH"] = "rbxassetid://81732703301774",
	},
	["Blacksmith"] = {
		["IDLE_ONE"] = "rbxassetid://76278398353270",
		["IDLE_TWO"] = "rbxassetid://84401747218107",
		["IDLE_THREE"] = "rbxassetid://134394162276069",
		["IDLE_FOUR"] = "rbxassetid://119877352679390",
	},
	["Dog"] = {
		["IDLE_ONE"] = "rbxassetid://106816853807816",
		["IDLE_TWO"] = "rbxassetid://94561230222356",
		["IDLE_THREE"] = "rbxassetid://103613945189989",
		["IDLE_FOUR"] = "rbxassetid://104039855043915",
	},
	["Dropper"] = {
		["DROPPER_DROP"] = "rbxassetid://139038633879788",
		["DROPPER_IDLE"] = "rbxassetid://128842400105621",
	},
	["EggUi"] = {
		["TEAM_ELIMINATED"] = "rbxassetid://103246009743402",
		["TEAM_UPGRADE"] = "rbxassetid://88654482192868",
		["PURCHASE"] = "rbxassetid://97121720319597",
		["UPGRADE"] = "rbxassetid://137568400446486",
	},
	["Explosion"] = {
		["IMPACT"] = "rbxassetid://103246881865284",
		["FLYING"] = "rbxassetid://137363947521844",
	},
	["Crate"] = {
		["CRATE_OPEN"] = "rbxassetid://100189435197309",
		["CRATE_OPENED_LOOP_01"] = "rbxassetid://138096753877344",
		["CRATE_OPENED_LOOP_02"] = "rbxassetid://106750242262713",
		["CRATE_OPENED_LOOP_03"] = "rbxassetid://99018203458501",
		["CRATE_OPENED_LOOP_04"] = "rbxassetid://130909034536432",
		["CRATE_OPENED_LOOP_05"] = "rbxassetid://122903935786089",
		["CRATE_OPENED_LOOP_06"] = "rbxassetid://74577782370211",
	},
	["WinEffect"] = {
		["WIN_EFFECT"] = "rbxassetid://90923891685806",
		["WIN_EFFECT_AMBIENT"] = "rbxassetid://109180705793243",
		["WIN_EFFECT_PLATFORM_HOVER_LOOP"] = "rbxassetid://116019583040561",
		["WIN_EFFECT_BRONZE_PLATFORM_IN"] = "rbxassetid://92987685376689",
		["WIN_EFFECT_SILVER_PLATFORM_IN"] = "rbxassetid://108250858183468",
		["WIN_EFFECT_GOLD_PLATFORM_IN"] = "rbxassetid://130167578788669",
		["WIN_EFFECT_BRONZE_TROPHY_IN"] = "rbxassetid://137875948535333",
		["WIN_EFFECT_SILVER_TROPHY_IN"] = "rbxassetid://132306615070875",
		["WIN_EFFECT_GOLD_TROPHY_IN"] = "rbxassetid://71707182279239",
	},
}
return {
	["RobloxSound"] = robloxSounds,
}
