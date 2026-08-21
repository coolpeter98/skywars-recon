-- AnimationDump — direct-ID variant of CatOnEdge/AnimationDumper.
-- Run in the REAL game. Downloads every animation from roblox-animation.luau
-- as a real KeyframeSequence (via KeyframeSequenceProvider), names each one
-- KEY_ID, collects them into one Model, and saves it as an .rbxmx through the
-- executor's saveinstance. No passive watching of playing tracks, no hashing,
-- no order mapping: each KeyframeSequence is named by its id directly.
--
-- The (key, id) list below is baked in from the decompiled client — no
-- requires needed, which sidesteps executor require restrictions.
--
-- Production AND studio-place ids are both dumped; the studio variants may
-- fail to load in the live game and show up as FAILED lines — expected.
--
-- saveinstance notes: the model is parented to Workspace AND kept in getgenv()
-- so a failed save can be retried with a one-liner; the call uses no options
-- because this executor rejects UniversalSyn-style options like SafeMode.

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local WAIT_BETWEEN = 0.5
local MAX_RETRIES = 2

local ENTRIES = {
	{ key = "IDLE_DEFAULT", id = "507766388" },
	{ key = "SWORD_SLASH", id = "8542350607" },
	{ key = "SWORD_SLASH", id = "12119128448" },
	{ key = "PICKAXE_BREAK_LOOPED", id = "8542349245" },
	{ key = "PICKAXE_BREAK_LOOPED", id = "12119128483" },
	{ key = "BLOCK_PLACE", id = "8542347276" },
	{ key = "BLOCK_PLACE", id = "12119128523" },
	{ key = "TOOL_EQUIP", id = "8542344677" },
	{ key = "TOOL_EQUIP", id = "12119128555" },
	{ key = "TOOL_IDLE", id = "8542345753" },
	{ key = "TOOL_IDLE", id = "12119128611" },
	{ key = "LONG_AXE_IDLE", id = "10955522521" },
	{ key = "LONG_AXE_IDLE", id = "12119128651" },
	{ key = "LONG_AXE_RUN", id = "10955527248" },
	{ key = "LONG_AXE_RUN", id = "12119128680" },
	{ key = "LONG_AXE_SLASH", id = "10961152812" },
	{ key = "LONG_AXE_SLASH", id = "12119128704" },
	{ key = "AZAZEL_LOBBY_SHARPEN", id = "10955537916" },
	{ key = "AZAZEL_LOBBY_SHARPEN", id = "12119128733" },
	{ key = "CHEST_OPEN", id = "8542341333" },
	{ key = "CHEST_OPEN", id = "12119128752" },
	{ key = "CHEST_IDLE", id = "8542342646" },
	{ key = "CHEST_IDLE", id = "12119128784" },
	{ key = "CHEST_CLOSE", id = "8465158314" },
	{ key = "CHEST_CLOSE", id = "12119128822" },
	{ key = "BOW_DRAW", id = "8542338795" },
	{ key = "BOW_DRAW", id = "12119128847" },
	{ key = "BOW_FIRE", id = "8542336491" },
	{ key = "BOW_FIRE", id = "12119128865" },
	{ key = "BOW_EQUIP", id = "8542337565" },
	{ key = "BOW_EQUIP", id = "12119128888" },
	{ key = "BOW_IDLE", id = "8542335482" },
	{ key = "BOW_IDLE", id = "12119128912" },
	{ key = "PROJECTILE_DRAW", id = "10139754109" },
	{ key = "PROJECTILE_DRAW", id = "12119128938" },
	{ key = "PROJECTILE_FIRE", id = "10139761321" },
	{ key = "PROJECTILE_FIRE", id = "12119128963" },
	{ key = "POWERUP_USE", id = "9403556467" },
	{ key = "POWERUP_USE", id = "12119129002" },
	{ key = "DANCE_ONE", id = "9407664047" },
	{ key = "DANCE_ONE", id = "12119129030" },
	{ key = "DANCE_TWO", id = "9404088174" },
	{ key = "DANCE_TWO", id = "12119129049" },
	{ key = "DANCE_THREE", id = "9403636067" },
	{ key = "DANCE_THREE", id = "12119129064" },
	{ key = "CORGI_SIT", id = "6555612176" },
	{ key = "CORGI_SIT", id = "12119129102" },
	{ key = "HUSKY_SIT", id = "6501974854" },
	{ key = "HUSKY_SIT", id = "12119129146" },
	{ key = "SPANIEL_SIT", id = "6555625403" },
	{ key = "SPANIEL_SIT", id = "12119129183" },
	{ key = "DOG_PET", id = "10768802194" },
	{ key = "DOG_PET", id = "12119129210" },
	{ key = "EGG_IDLE_PRIMARY", id = "11857021612" },
	{ key = "EGG_IDLE_PRIMARY", id = "12119129243" },
	{ key = "EGG_IDLE_SECONDARY", id = "11857016648" },
	{ key = "EGG_IDLE_SECONDARY", id = "12119129271" },
	{ key = "EGG_HIT_ONE", id = "11857002299" },
	{ key = "EGG_HIT_ONE", id = "12119129359" },
	{ key = "EGG_HIT_TWO", id = "11857007696" },
	{ key = "EGG_HIT_TWO", id = "12119129403" },
	{ key = "EGG_JUMP", id = "12123975022" },
	{ key = "EGG_JUMP", id = "12124122242" },
	{ key = "EGG_DANCE", id = "12123979311" },
	{ key = "EGG_DANCE", id = "12124122289" },
	{ key = "EGG_SCRATCH", id = "12123982270" },
	{ key = "EGG_SCRATCH", id = "12124122375" },
	{ key = "EGG_EYE_ROLL", id = "12123986669" },
	{ key = "EGG_EYE_ROLL", id = "12124122492" },
	{ key = "EGG_WAVE", id = "12123989826" },
	{ key = "EGG_WAVE", id = "12124122610" },
	{ key = "EGG_DEATH", id = "12124897564" },
	{ key = "EGG_DEATH", id = "12124899645" },
	{ key = "DROPPER_IDLE", id = "12458749660" },
	{ key = "DROPPER_IDLE", id = "12458779993" },
	{ key = "DROPPER_DROP", id = "12725060642" },
	{ key = "DROPPER_DROP", id = "12725062916" },
	{ key = "WIZARD_DOG_IDLE", id = "12520820315" },
	{ key = "WIZARD_DOG_IDLE", id = "12520822749" },
	{ key = "BLACKSMITH_IDLE", id = "12811935053" },
	{ key = "BLACKSMITH_IDLE", id = "12812007821" },
	{ key = "BLACKSMITH_ACTION_ONE", id = "12811942537" },
	{ key = "BLACKSMITH_ACTION_ONE", id = "12812007918" },
	{ key = "BLACKSMITH_ACTION_TWO", id = "12811956333" },
	{ key = "BLACKSMITH_ACTION_TWO", id = "12812008165" },
	{ key = "WIZARD_IDLE", id = "12811985695" },
	{ key = "WIZARD_IDLE", id = "12812008441" },
	{ key = "WIZARD_ACTION_ONE", id = "12811993287" },
	{ key = "WIZARD_ACTION_ONE", id = "12812008652" },
	{ key = "WIZARD_ACTION_TWO", id = "12812000785" },
	{ key = "WIZARD_ACTION_TWO", id = "12812008796" },
	{ key = "SPACEMAN_DUAL_IDLE", id = "13077938912" },
	{ key = "SPACEMAN_DUAL_IDLE", id = "13077975029" },
	{ key = "SPACEMAN_DUAL_STAB", id = "13085943054" },
	{ key = "SPACEMAN_DUAL_STAB", id = "13085963201" },
	{ key = "SPACEMAN_DUAL_SLASH", id = "13086104527" },
	{ key = "SPACEMAN_DUAL_SLASH", id = "13086119603" },
	{ key = "SPEAR_IDLE", id = "13077955316" },
	{ key = "SPEAR_IDLE", id = "13077975295" },
	{ key = "SPEAR_THRUST", id = "13077959044" },
	{ key = "SPEAR_THRUST", id = "13077975358" },
	{ key = "PAN_SWING", id = "13085936786" },
	{ key = "PAN_SWING", id = "13085963363" },
	{ key = "LAUNCHPAD_FLIP", id = "13181245240" },
	{ key = "LAUNCHPAD_FLIP", id = "13246465883" },
	{ key = "ADRENALINE_INJECT", id = "13237887602" },
	{ key = "ADRENALINE_INJECT", id = "13246465944" },
	{ key = "POGO_IDLE", id = "13245484569" },
	{ key = "POGO_IDLE", id = "13246465986" },
	{ key = "POGO_JUMP", id = "13245494378" },
	{ key = "POGO_JUMP", id = "13246471479" },
	{ key = "FISHING_IDLE", id = "13245526511" },
	{ key = "FISHING_IDLE", id = "13246469662" },
	{ key = "FISHING_WIND", id = "13245535490" },
	{ key = "FISHING_WIND", id = "13246469706" },
	{ key = "FISHING_CAST", id = "13245506383" },
	{ key = "FISHING_CAST", id = "13246469735" },
	{ key = "ANGEL_PLAYER_ASCEND", id = "13684876693" },
	{ key = "ANGEL_PLAYER_ASCEND", id = "13684879299" },
	{ key = "ANGEL_WINGS_FLAP", id = "13684979836" },
	{ key = "ANGEL_WINGS_FLAP", id = "13684982345" },
	{ key = "ICE_PLAYER_FREEZE", id = "13715879970" },
	{ key = "ICE_PLAYER_FREEZE", id = "13715881443" },
	{ key = "ICE_SHOOT_SPIKES", id = "13728285540" },
	{ key = "ICE_SHOOT_SPIKES", id = "13728311184" },
	{ key = "TOMBSTONE_PLAYER_FALL", id = "13684917916" },
	{ key = "TOMBSTONE_PLAYER_FALL", id = "13684919081" },
	{ key = "TOMBSTONE_ANIMATION", id = "13685055837" },
	{ key = "TOMBSTONE_ANIMATION", id = "13685056718" },
	{ key = "THUNDERSTORM_PLAYER_STRIKE", id = "13726772582" },
	{ key = "THUNDERSTORM_PLAYER_STRIKE", id = "13726774416" },
	{ key = "THUNDERSTORM_CLOUDS", id = "13728808278" },
	{ key = "THUNDERSTORM_CLOUDS", id = "13728809589" },
	{ key = "TORNADO_CHARACTER", id = "72489822669167" },
	{ key = "TORNADO_CHARACTER", id = "77280843827599" },
	{ key = "TORNADO_VORTICES", id = "119601066867080" },
	{ key = "TORNADO_VORTICES", id = "83204054079075" },
	{ key = "GATE_OF_BABYLON_CHARACTER", id = "106970862672482" },
	{ key = "GATE_OF_BABYLON_CHARACTER", id = "74945047233694" },
	{ key = "GATE_OF_BABYLON_PORTALS", id = "133383702123902" },
	{ key = "GATE_OF_BABYLON_PORTALS", id = "119669907474054" },
	{ key = "SLIME_CUBE_CHARACTER", id = "114970467350440" },
	{ key = "SLIME_CUBE_CHARACTER", id = "83084655119787" },
	{ key = "SLIME_CUBE_MODEL", id = "102508608924776" },
	{ key = "SLIME_CUBE_MODEL", id = "86825623378735" },
	{ key = "UFO_CHARACTER", id = "114824947893231" },
	{ key = "UFO_CHARACTER", id = "133890192744730" },
	{ key = "UFO_MODEL", id = "103428322954197" },
	{ key = "UFO_MODEL", id = "127502529756090" },
	{ key = "CRATE_OPEN_PLAYER", id = "14932635486" },
	{ key = "CRATE_OPEN_PLAYER", id = "14932634154" },
	{ key = "CRATE_OPEN", id = "18353592110" },
	{ key = "CRATE_OPEN", id = "18353593684" },
	{ key = "CRATE_IDLE", id = "18342990853" },
	{ key = "CRATE_IDLE", id = "18342992049" },
	{ key = "CRATE_IDLE_JUMP", id = "18342630133" },
	{ key = "CRATE_IDLE_JUMP", id = "18342628606" },
	{ key = "CRATE_IDLE_LEFT_TO_RIGHT", id = "18342635036" },
	{ key = "CRATE_IDLE_LEFT_TO_RIGHT", id = "18342636268" },
	{ key = "CRATE_IDLE_SPIN", id = "18342643669" },
	{ key = "CRATE_IDLE_SPIN", id = "18342644721" },
	{ key = "CHAINSAW_EQUIP", id = "17212815314" },
	{ key = "CHAINSAW_EQUIP", id = "17212816971" },
	{ key = "CHAINSAW_IDLE", id = "17212825172" },
	{ key = "CHAINSAW_IDLE", id = "17212826895" },
	{ key = "CHAINSAW_SPRINT", id = "17212830479" },
	{ key = "CHAINSAW_SPRINT", id = "17212832433" },
	{ key = "CHAINSAW_MELEE", id = "17271395346" },
	{ key = "CHAINSAW_MELEE", id = "17271396171" },
	{ key = "CHAINSAW_TOOL_IDLE", id = "17271293370" },
	{ key = "CHAINSAW_TOOL_IDLE", id = "17271294182" },
	{ key = "PLASMA_BLADES_IDLE", id = "90783119875987" },
	{ key = "PLASMA_BLADES_IDLE", id = "102591423600308" },
	{ key = "POWER_SWORD_MELEE", id = "17271714233" },
	{ key = "POWER_SWORD_MELEE", id = "17271714998" },
	{ key = "CLAWS_MELEE_EQUIP", id = "17164239684" },
	{ key = "CLAWS_MELEE_EQUIP", id = "17164240886" },
	{ key = "CLAWS_MELEE_IDLE", id = "17164244157" },
	{ key = "CLAWS_MELEE_IDLE", id = "17164245060" },
	{ key = "CLAWS_MELEE_SPRINT", id = "17164248467" },
	{ key = "CLAWS_MELEE_SPRINT", id = "17164250049" },
	{ key = "CLAWS_MELEE_LEFT", id = "17212997487" },
	{ key = "CLAWS_MELEE_LEFT", id = "17212998678" },
	{ key = "CLAWS_MELEE_RIGHT", id = "17213005094" },
	{ key = "CLAWS_MELEE_RIGHT", id = "17213006789" },
	{ key = "BOXING_GLOVES_EQUIP", id = "17001705050" },
	{ key = "BOXING_GLOVES_EQUIP", id = "17001702807" },
	{ key = "BOXING_GLOVES_IDLE", id = "17002840100" },
	{ key = "BOXING_GLOVES_IDLE", id = "17002841742" },
	{ key = "BOXING_GLOVES_SPRINT", id = "17002900242" },
	{ key = "BOXING_GLOVES_SPRINT", id = "17002901834" },
	{ key = "BOXING_GLOVES_MELEE_LEFT", id = "17138243719" },
	{ key = "BOXING_GLOVES_MELEE_LEFT", id = "17138245138" },
	{ key = "BOXING_GLOVES_MELEE_RIGHT", id = "17138248745" },
	{ key = "BOXING_GLOVES_MELEE_RIGHT", id = "17138250633" },
	{ key = "TWINBLADE_IDLE", id = "123650360356815" },
	{ key = "TWINBLADE_IDLE", id = "70717212450568" },
	{ key = "TWINBLADE_SPRINT", id = "73274633904946" },
	{ key = "TWINBLADE_SPRINT", id = "119257725766882" },
	{ key = "TWINBLADE_MELEE", id = "119532354006441" },
	{ key = "TWINBLADE_MELEE", id = "131137755848251" },
	{ key = "GENERIC_DAGGER_EQUIP", id = "134607060833114" },
	{ key = "GENERIC_DAGGER_EQUIP", id = "96954690269592" },
	{ key = "GENERIC_DAGGER_IDLE", id = "129746897253832" },
	{ key = "GENERIC_DAGGER_IDLE", id = "116632053607073" },
	{ key = "GENERIC_DAGGER_SPRINT", id = "111513718756950" },
	{ key = "GENERIC_DAGGER_SPRINT", id = "117253285110410" },
	{ key = "HEAVY_HAMMERS_MELEE", id = "118781227292600" },
	{ key = "HEAVY_HAMMERS_MELEE", id = "99979119420008" },
	{ key = "DUAL_DAGGERS_MELEE", id = "86898780619289" },
	{ key = "DUAL_DAGGERS_MELEE", id = "106699180679838" },
	{ key = "SAI_DAGGER_MELEE", id = "71769908295042" },
	{ key = "SAI_DAGGER_MELEE", id = "113495359925049" },
	{ key = "SHURIKEN_DRAW", id = "98857352917338" },
	{ key = "SHURIKEN_DRAW", id = "140603160874617" },
	{ key = "SHURIKEN_THROW", id = "115896140857498" },
	{ key = "SHURIKEN_THROW", id = "133514693411462" },
	{ key = "OKATANA_EQUIP", id = "100743583613281" },
	{ key = "OKATANA_EQUIP", id = "101830084228114" },
	{ key = "OKATANA_IDLE", id = "133638974261654" },
	{ key = "OKATANA_IDLE", id = "114793275056592" },
	{ key = "OKATANA_SPRINT", id = "102963106333866" },
	{ key = "OKATANA_SPRINT", id = "116008389567257" },
	{ key = "POWER_BOW_IDLE", id = "71612984325080" },
	{ key = "POWER_BOW_IDLE", id = "137091995764923" },
	{ key = "POWER_BOW_TOOL_IDLE", id = "113056236159258" },
	{ key = "POWER_BOW_TOOL_IDLE", id = "97054507849474" },
	{ key = "POWER_BOW_CHARACTER_DRAW", id = "121764712282913" },
	{ key = "POWER_BOW_CHARACTER_DRAW", id = "79772492326887" },
	{ key = "POWER_BOW_TOOL_DRAW", id = "119149202774152" },
	{ key = "POWER_BOW_TOOL_DRAW", id = "124140962870384" },
	{ key = "POWER_BOW_CHARACTER_FIRE", id = "96556532695160" },
	{ key = "POWER_BOW_CHARACTER_FIRE", id = "78954483401942" },
	{ key = "POWER_BOW_TOOL_FIRE", id = "106249109154737" },
	{ key = "POWER_BOW_TOOL_FIRE", id = "70509175664313" },
	{ key = "ADVERT_PUSH_UP", id = "74677161463709" },
	{ key = "ADVERT_PUSH_UP", id = "85641146434835" },
	{ key = "ADVERT_IDLE_1", id = "94610946212044" },
	{ key = "ADVERT_IDLE_1", id = "133283053572638" },
	{ key = "ADVERT_IDLE_2", id = "104953620664854" },
	{ key = "ADVERT_IDLE_2", id = "77823872989709" },
	{ key = "ADVERT_IDLE_3", id = "72107074113386" },
	{ key = "ADVERT_IDLE_3", id = "87948873715935" },
	{ key = "ADVERT_IDLE_4", id = "89567140923074" },
	{ key = "ADVERT_IDLE_4", id = "124428087942444" },
	{ key = "ADVERT_IDLE_5", id = "119490193691268" },
	{ key = "ADVERT_IDLE_5", id = "140363747225314" },
	{ key = "ADVERT_IDLE_6", id = "123974380438837" },
	{ key = "ADVERT_IDLE_6", id = "83563254896890" },
	{ key = "ADVERT_POINT", id = "110887342961612" },
	{ key = "ADVERT_POINT", id = "74351400367170" },
	{ key = "WIN_EFFECT_ANIMATION", id = "115733988878774" },
	{ key = "WIN_EFFECT_ANIMATION", id = "84582817035596" },
}

print("[ANIM] total entries:", #ENTRIES)

local logLines = {}
local function log(message: string)
	print("[ANIM] " .. message)
	table.insert(logLines, "[ANIM] " .. message)
end

local outputModel = Instance.new("Model")
outputModel.Name = "SkyWarsAnimations"
outputModel.Parent = workspace
getgenv().AnimDumpModel = outputModel

local function tryLoad(entry): KeyframeSequence?
	local ok, result = pcall(function()
		return KeyframeSequenceProvider:GetKeyframeSequenceAsync("rbxassetid://" .. entry.id)
	end)
	if not ok or result == nil or not result:IsA("KeyframeSequence") then
		return nil
	end
	return if result.Parent == nil then result else result:Clone()
end

local failed = {}
local okCount = 0
for index, entry in ENTRIES do
	local sequence = tryLoad(entry)
	for attempt = 1, MAX_RETRIES do
		if sequence ~= nil then
			break
		end
		task.wait(2)
		sequence = tryLoad(entry)
	end
	if sequence ~= nil then
		sequence.Name = entry.key .. "_" .. entry.id
		sequence.Parent = outputModel
		okCount += 1
		log(string.format("%03d OK %s %s (%d keyframes)", index, entry.id, entry.key, #sequence:GetKeyframes()))
	else
		table.insert(failed, entry)
		log(string.format("%03d FAILED %s %s", index, entry.id, entry.key))
	end
	task.wait(WAIT_BETWEEN)
end

log(string.format("DONE ok=%d failed=%d", okCount, #failed))

local saveOk, saveErr = pcall(function()
	saveinstance(outputModel, "skywars-animations")
end)
if not saveOk then
	saveOk, saveErr = pcall(function()
		saveinstance(outputModel, "skywars-animations", { noscripts = true })
	end)
end
if saveOk then
	log("saved skywars-animations.rbxmx to executor workspace")
else
	log("saveinstance failed: " .. tostring(saveErr))
	log("RETRY LATER: saveinstance(getgenv().AnimDumpModel or workspace.SkyWarsAnimations, 'skywars-animations')")
end

local text = table.concat(logLines, "\n")
local wrote, writeErr = pcall(function()
	writefile("skywars-animations-log.txt", text)
end)
if wrote then
	log("log written to skywars-animations-log.txt")
else
	local clipped = pcall(function()
		setclipboard(text)
	end)
	if clipped then
		log("writefile unavailable (" .. tostring(writeErr) .. ") - log copied to clipboard")
	else
		print(text)
	end
end
