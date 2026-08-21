-- RobloxAnimation

local PlaceUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"place",
		"place-util"
	).PlaceUtil

export type RobloxAnimation = { [string]: string }

return {
	["RobloxAnimation"] = {
		["IDLE_DEFAULT"] = "rbxassetid://74379544273802",
		["SWORD_SLASH"] = PlaceUtil.isProduction() and "rbxassetid://125782564726848" or "rbxassetid://138022565561482",
		["PICKAXE_BREAK_LOOPED"] = PlaceUtil.isProduction() and "rbxassetid://126189466763451"
			or "rbxassetid://99597630491721",
		["BLOCK_PLACE"] = PlaceUtil.isProduction() and "rbxassetid://132967120435330" or "rbxassetid://112643677535527",
		["TOOL_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://110747896481335" or "rbxassetid://93967546747640",
		["TOOL_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://111591598167446" or "rbxassetid://123325273811607",
		["LONG_AXE_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://112009620652547"
			or "rbxassetid://108368896003538",
		["LONG_AXE_RUN"] = PlaceUtil.isProduction() and "rbxassetid://112041034586271"
			or "rbxassetid://120288161073955",
		["LONG_AXE_SLASH"] = PlaceUtil.isProduction() and "rbxassetid://97906195202443"
			or "rbxassetid://93257661922212",
		["AZAZEL_LOBBY_SHARPEN"] = PlaceUtil.isProduction() and "rbxassetid://85879614084669"
			or "rbxassetid://124921274623314",
		["CHEST_OPEN"] = PlaceUtil.isProduction() and "rbxassetid://140119704385533" or "rbxassetid://85524930648123",
		["CHEST_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://121026265566128" or "rbxassetid://119013049296991",
		["CHEST_CLOSE"] = PlaceUtil.isProduction() and "rbxassetid://75031258793800" or "rbxassetid://76544742978100",
		["BOW_DRAW"] = PlaceUtil.isProduction() and "rbxassetid://88029761266711" or "rbxassetid://117556443023338",
		["BOW_FIRE"] = PlaceUtil.isProduction() and "rbxassetid://137868037887282" or "rbxassetid://78450373875445",
		["BOW_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://96682944004459" or "rbxassetid://128828891915777",
		["BOW_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://137929409881331" or "rbxassetid://71312620555176",
		["PROJECTILE_DRAW"] = PlaceUtil.isProduction() and "rbxassetid://136010245538742"
			or "rbxassetid://92600686196080",
		["PROJECTILE_FIRE"] = PlaceUtil.isProduction() and "rbxassetid://137269062765012"
			or "rbxassetid://127351581004328",
		["POWERUP_USE"] = PlaceUtil.isProduction() and "rbxassetid://109787335699729" or "rbxassetid://136975951357691",
		["DANCE_ONE"] = PlaceUtil.isProduction() and "rbxassetid://95543332406741" or "rbxassetid://127148099814722",
		["DANCE_TWO"] = PlaceUtil.isProduction() and "rbxassetid://115644196541583" or "rbxassetid://73667396807552",
		["DANCE_THREE"] = PlaceUtil.isProduction() and "rbxassetid://75974365609319" or "rbxassetid://96925492343185",
		["CORGI_SIT"] = PlaceUtil.isProduction() and "rbxassetid://79192577783196" or "rbxassetid://114816301350523",
		["HUSKY_SIT"] = PlaceUtil.isProduction() and "rbxassetid://126536910429893" or "rbxassetid://104260133191822",
		["SPANIEL_SIT"] = PlaceUtil.isProduction() and "rbxassetid://107747921449363" or "rbxassetid://84647621367069",
		["DOG_PET"] = PlaceUtil.isProduction() and "rbxassetid://92740563911036" or "rbxassetid://118363677104730",
		["EGG_IDLE_PRIMARY"] = PlaceUtil.isProduction() and "rbxassetid://133074245568239"
			or "rbxassetid://99456071795560",
		["EGG_IDLE_SECONDARY"] = PlaceUtil.isProduction() and "rbxassetid://123154430963182"
			or "rbxassetid://103477115751447",
		["EGG_HIT_ONE"] = PlaceUtil.isProduction() and "rbxassetid://134736775829471" or "rbxassetid://79962632137990",
		["EGG_HIT_TWO"] = PlaceUtil.isProduction() and "rbxassetid://77513921257473" or "rbxassetid://123459984492638",
		["EGG_JUMP"] = PlaceUtil.isProduction() and "rbxassetid://71970542091618" or "rbxassetid://74251055409338",
		["EGG_DANCE"] = PlaceUtil.isProduction() and "rbxassetid://99402060297845" or "rbxassetid://114912695935462",
		["EGG_SCRATCH"] = PlaceUtil.isProduction() and "rbxassetid://114133910050786" or "rbxassetid://123002708962975",
		["EGG_EYE_ROLL"] = PlaceUtil.isProduction() and "rbxassetid://77789458380135" or "rbxassetid://138611151005453",
		["EGG_WAVE"] = PlaceUtil.isProduction() and "rbxassetid://133685896445531" or "rbxassetid://103107343618142",
		["EGG_DEATH"] = PlaceUtil.isProduction() and "rbxassetid://92568357325242" or "rbxassetid://88531212775744",
		["DROPPER_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://87478908168573" or "rbxassetid://101322495282372",
		["DROPPER_DROP"] = PlaceUtil.isProduction() and "rbxassetid://85525724822153" or "rbxassetid://94724720453050",
		["WIZARD_DOG_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://134996811715586"
			or "rbxassetid://109414801967663",
		["BLACKSMITH_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://129595917623147"
			or "rbxassetid://83181146962263",
		["BLACKSMITH_ACTION_ONE"] = PlaceUtil.isProduction() and "rbxassetid://97564018261018"
			or "rbxassetid://93972045867008",
		["BLACKSMITH_ACTION_TWO"] = PlaceUtil.isProduction() and "rbxassetid://100724879484207"
			or "rbxassetid://121607530427249",
		["WIZARD_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://100530578264110" or "rbxassetid://74914095440048",
		["WIZARD_ACTION_ONE"] = PlaceUtil.isProduction() and "rbxassetid://90558096328137"
			or "rbxassetid://117483913625552",
		["WIZARD_ACTION_TWO"] = PlaceUtil.isProduction() and "rbxassetid://135373386082235"
			or "rbxassetid://110903775355039",
		["SPACEMAN_DUAL_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://124745906419747"
			or "rbxassetid://78763586712470",
		["SPACEMAN_DUAL_STAB"] = PlaceUtil.isProduction() and "rbxassetid://100725702929700"
			or "rbxassetid://116011460190272",
		["SPACEMAN_DUAL_SLASH"] = PlaceUtil.isProduction() and "rbxassetid://120288508469704"
			or "rbxassetid://134094548306130",
		["SPEAR_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://111038537913298" or "rbxassetid://75813235898690",
		["SPEAR_THRUST"] = PlaceUtil.isProduction() and "rbxassetid://91151590609123" or "rbxassetid://111618446958938",
		["PAN_SWING"] = PlaceUtil.isProduction() and "rbxassetid://115986555193769" or "rbxassetid://118876014753670",
		["LAUNCHPAD_FLIP"] = PlaceUtil.isProduction() and "rbxassetid://87414873795011"
			or "rbxassetid://119108177583025",
		["ADRENALINE_INJECT"] = PlaceUtil.isProduction() and "rbxassetid://129849910144133"
			or "rbxassetid://135875968702971",
		["POGO_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://133476792273597" or "rbxassetid://136703823896659",
		["POGO_JUMP"] = PlaceUtil.isProduction() and "rbxassetid://85520703225847" or "rbxassetid://111981919063007",
		["FISHING_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://120622703352930" or "rbxassetid://92032351563942",
		["FISHING_WIND"] = PlaceUtil.isProduction() and "rbxassetid://74093844880076" or "rbxassetid://128511932078548",
		["FISHING_CAST"] = PlaceUtil.isProduction() and "rbxassetid://83541192512641" or "rbxassetid://93986030168382",
		["ANGEL_PLAYER_ASCEND"] = PlaceUtil.isProduction() and "rbxassetid://72963647503329"
			or "rbxassetid://135837144372009",
		["ANGEL_WINGS_FLAP"] = PlaceUtil.isProduction() and "rbxassetid://127113890726055"
			or "rbxassetid://139836600238559",
		["ICE_PLAYER_FREEZE"] = PlaceUtil.isProduction() and "rbxassetid://102832365964164"
			or "rbxassetid://131086389387789",
		["ICE_SHOOT_SPIKES"] = PlaceUtil.isProduction() and "rbxassetid://140083978522257"
			or "rbxassetid://95306302011242",
		["TOMBSTONE_PLAYER_FALL"] = PlaceUtil.isProduction() and "rbxassetid://75772553996478"
			or "rbxassetid://88869196266497",
		["TOMBSTONE_ANIMATION"] = PlaceUtil.isProduction() and "rbxassetid://90775318009234"
			or "rbxassetid://124950729850298",
		["THUNDERSTORM_PLAYER_STRIKE"] = PlaceUtil.isProduction() and "rbxassetid://125601212103909"
			or "rbxassetid://126529189666732",
		["THUNDERSTORM_CLOUDS"] = PlaceUtil.isProduction() and "rbxassetid://138877106170625"
			or "rbxassetid://77545662319263",
		["TORNADO_CHARACTER"] = PlaceUtil.isProduction() and "rbxassetid://133404701280313"
			or "rbxassetid://96424920801401",
		["TORNADO_VORTICES"] = PlaceUtil.isProduction() and "rbxassetid://112783776433578"
			or "rbxassetid://125958356831677",
		["GATE_OF_BABYLON_CHARACTER"] = PlaceUtil.isProduction() and "rbxassetid://113879662025133"
			or "rbxassetid://70725780465813",
		["GATE_OF_BABYLON_PORTALS"] = PlaceUtil.isProduction() and "rbxassetid://99968126813186"
			or "rbxassetid://110136657079989",
		["SLIME_CUBE_CHARACTER"] = PlaceUtil.isProduction() and "rbxassetid://130876474392968"
			or "rbxassetid://139622160463250",
		["SLIME_CUBE_MODEL"] = PlaceUtil.isProduction() and "rbxassetid://134651916967191"
			or "rbxassetid://117466550896299",
		["UFO_CHARACTER"] = PlaceUtil.isProduction() and "rbxassetid://82362349211709"
			or "rbxassetid://119596833905267",
		["UFO_MODEL"] = PlaceUtil.isProduction() and "rbxassetid://91041745048423" or "rbxassetid://97242045163651",
		["CRATE_OPEN_PLAYER"] = PlaceUtil.isProduction() and "rbxassetid://136294320023794"
			or "rbxassetid://110045356071006",
		["CRATE_OPEN"] = PlaceUtil.isProduction() and "rbxassetid://89716111380968" or "rbxassetid://103046640045632",
		["CRATE_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://93497492569956" or "rbxassetid://80785230135005",
		["CRATE_IDLE_JUMP"] = PlaceUtil.isProduction() and "rbxassetid://106893116742768"
			or "rbxassetid://122055637926929",
		["CRATE_IDLE_LEFT_TO_RIGHT"] = PlaceUtil.isProduction() and "rbxassetid://118494489550323"
			or "rbxassetid://115339253165805",
		["CRATE_IDLE_SPIN"] = PlaceUtil.isProduction() and "rbxassetid://80524049690926"
			or "rbxassetid://107546620615209",
		["CHAINSAW_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://114502463741352"
			or "rbxassetid://114564277318821",
		["CHAINSAW_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://130733921915382"
			or "rbxassetid://91922655903564",
		["CHAINSAW_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://106859096844046"
			or "rbxassetid://130870422385265",
		["CHAINSAW_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://97618162191881"
			or "rbxassetid://131821373613117",
		["CHAINSAW_TOOL_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://82115550734192"
			or "rbxassetid://75197219760234",
		["PLASMA_BLADES_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://86899986021014"
			or "rbxassetid://136401530152274",
		["POWER_SWORD_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://127160762081220"
			or "rbxassetid://100484343683774",
		["CLAWS_MELEE_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://120406084440522"
			or "rbxassetid://81840221495480",
		["CLAWS_MELEE_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://103470358179162"
			or "rbxassetid://114461237628796",
		["CLAWS_MELEE_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://104552236888370"
			or "rbxassetid://113784049526665",
		["CLAWS_MELEE_LEFT"] = PlaceUtil.isProduction() and "rbxassetid://87725504971369"
			or "rbxassetid://106266557305070",
		["CLAWS_MELEE_RIGHT"] = PlaceUtil.isProduction() and "rbxassetid://125068970083836"
			or "rbxassetid://79142147288194",
		["BOXING_GLOVES_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://115219682294871"
			or "rbxassetid://132305188973444",
		["BOXING_GLOVES_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://119086126497480"
			or "rbxassetid://72179217581525",
		["BOXING_GLOVES_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://123530049048632"
			or "rbxassetid://91053891432464",
		["BOXING_GLOVES_MELEE_LEFT"] = PlaceUtil.isProduction() and "rbxassetid://117764609505547"
			or "rbxassetid://75178697976115",
		["BOXING_GLOVES_MELEE_RIGHT"] = PlaceUtil.isProduction() and "rbxassetid://94383467151500"
			or "rbxassetid://98895051906589",
		["TWINBLADE_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://86180091394526"
			or "rbxassetid://72722697310606",
		["TWINBLADE_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://92397681660314"
			or "rbxassetid://75729556350328",
		["TWINBLADE_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://127767024503993"
			or "rbxassetid://84510250772960",
		["GENERIC_DAGGER_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://128316304474126"
			or "rbxassetid://127313282579710",
		["GENERIC_DAGGER_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://86035747989969"
			or "rbxassetid://129828273289826",
		["GENERIC_DAGGER_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://81860231669322"
			or "rbxassetid://130740556533721",
		["HEAVY_HAMMERS_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://112852134564418"
			or "rbxassetid://78562361719159",
		["DUAL_DAGGERS_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://103102045274204"
			or "rbxassetid://90596368188993",
		["SAI_DAGGER_MELEE"] = PlaceUtil.isProduction() and "rbxassetid://93181469630567"
			or "rbxassetid://134106673949014",
		["SHURIKEN_DRAW"] = PlaceUtil.isProduction() and "rbxassetid://113598346289855"
			or "rbxassetid://138445546690314",
		["SHURIKEN_THROW"] = PlaceUtil.isProduction() and "rbxassetid://125927723770336"
			or "rbxassetid://136879448287606",
		["OKATANA_EQUIP"] = PlaceUtil.isProduction() and "rbxassetid://105107860763377"
			or "rbxassetid://113426213900557",
		["OKATANA_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://123228624513362" or "rbxassetid://94189676401585",
		["OKATANA_SPRINT"] = PlaceUtil.isProduction() and "rbxassetid://87905925376828"
			or "rbxassetid://133006858469894",
		["POWER_BOW_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://120478522309386"
			or "rbxassetid://88962910284148",
		["POWER_BOW_TOOL_IDLE"] = PlaceUtil.isProduction() and "rbxassetid://97857007664704"
			or "rbxassetid://113035125043672",
		["POWER_BOW_CHARACTER_DRAW"] = PlaceUtil.isProduction() and "rbxassetid://76415127414473"
			or "rbxassetid://90614409789552",
		["POWER_BOW_TOOL_DRAW"] = PlaceUtil.isProduction() and "rbxassetid://93851828968142"
			or "rbxassetid://91201822237572",
		["POWER_BOW_CHARACTER_FIRE"] = PlaceUtil.isProduction() and "rbxassetid://124061786619017"
			or "rbxassetid://139922099959173",
		["POWER_BOW_TOOL_FIRE"] = PlaceUtil.isProduction() and "rbxassetid://133068825228707"
			or "rbxassetid://97314867425199",
		["ADVERT_PUSH_UP"] = PlaceUtil.isProduction() and "rbxassetid://112499043041483"
			or "rbxassetid://98781981348745",
		["ADVERT_IDLE_1"] = PlaceUtil.isProduction() and "rbxassetid://125126294646579"
			or "rbxassetid://118450033160756",
		["ADVERT_IDLE_2"] = PlaceUtil.isProduction() and "rbxassetid://94008006615599" or "rbxassetid://74541856564925",
		["ADVERT_IDLE_3"] = PlaceUtil.isProduction() and "rbxassetid://111447745250925"
			or "rbxassetid://118164145781388",
		["ADVERT_IDLE_4"] = PlaceUtil.isProduction() and "rbxassetid://83128868702376"
			or "rbxassetid://111178306850406",
		["ADVERT_IDLE_5"] = PlaceUtil.isProduction() and "rbxassetid://71912780688736"
			or "rbxassetid://112948061655654",
		["ADVERT_IDLE_6"] = PlaceUtil.isProduction() and "rbxassetid://83084785899899" or "rbxassetid://80001032574236",
		["ADVERT_POINT"] = PlaceUtil.isProduction() and "rbxassetid://118125688034394"
			or "rbxassetid://109042825859628",
		["WIN_EFFECT_ANIMATION"] = PlaceUtil.isProduction() and "rbxassetid://97249564764509"
			or "rbxassetid://87518719686033",
	},
}
