-- ImgDump — force-downloads every image the client references, one at a time.
-- Run in the REAL game with BloxDump running (default settings).
--
-- RUN PROTOCOL (important - the lobby downloads images on join too):
--   1. Launch BloxDump and answer YES to "clear your cache" (old cache entries
--      would otherwise be dumped at launch and pollute the output).
--   2. Join the game and wait for the lobby to fully load — until BloxDump's
--      console stops printing "Queued ... caches" for ~20 seconds.
--   3. Move everything currently in assets/Textures/ into a "natural/"
--      subfolder (keep them — they are real dumps of the join-time images).
--   4. Run THIS script. Every file that now appears in assets/Textures/ lands
--      in exactly the script's id order (one per ~7s window vs BloxDump's ~5s
--      sweep). IDs that were already cached at join produce no new file, but
--      the script still prints their w x h — pairing happens afterwards.
--   5. Send skywars-image-dump.txt + assets/Textures/ + assets/Textures/natural/.
--
-- The id list below is baked in from the decompiled client (roblox-image,
-- loading-gui, egg-character, void-kill-effect) — no requires needed, which
-- sidesteps executor require restrictions entirely.
--
-- Tie resolution: pixel dimensions verify every pairing locally (each dumped
-- PNG/WebP is checked against this script's printed w x h). Same-dimension
-- collisions are rare and can be re-run individually via START_AT, or resolved
-- by looking at the images directly.

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local WAIT_FOR_DUMPER = 7
local LOAD_TIMEOUT = 15
local START_AT = 1

local IMAGE_IDS = {
	"1359426947",
	"6521408991",
	"6594836468",
	"8447787004",
	"8460258747",
	"8460258994",
	"8460259251",
	"8460259445",
	"8525350336",
	"8525350577",
	"8525350688",
	"8535193079",
	"8552541175",
	"8555857539",
	"8693225673",
	"8757403062",
	"8764035855",
	"8766999140",
	"8766999302",
	"8766999710",
	"8767000110",
	"8767000436",
	"8767009974",
	"8767298119",
	"8768519016",
	"8775144176",
	"8779922257",
	"8838518004",
	"8838518153",
	"8838554019",
	"8838554163",
	"8838723973",
	"8838724124",
	"8838872900",
	"8910049571",
	"8910262789",
	"8910560586",
	"9401833666",
	"9401833789",
	"9401833951",
	"9401834127",
	"9408137904",
	"9467128632",
	"9467200356",
	"9467202463",
	"9515781907",
	"9565297857",
	"9627134475",
	"9710238366",
	"9735716338",
	"9768173987",
	"9768215598",
	"9768400649",
	"9768464161",
	"9768484658",
	"9768490574",
	"9824914797",
	"9826471214",
	"9834778781",
	"9835975003",
	"9869206254",
	"9878964577",
	"9971934337",
	"9972177224",
	"10046410843",
	"10046411243",
	"10118469572",
	"10118469869",
	"10118470505",
	"10118470738",
	"10118470993",
	"10118471244",
	"10118471536",
	"10118471799",
	"10118471985",
	"10118472296",
	"10118472792",
	"10118473136",
	"10118473443",
	"10118473706",
	"10118588515",
	"10118673558",
	"10139511536",
	"10139511712",
	"10256401262",
	"10262577344",
	"10292106599",
	"10415225379",
	"10415877682",
	"10444523602",
	"10444523939",
	"10444605546",
	"10473914664",
	"10527758212",
	"10527758535",
	"10527758853",
	"10527759141",
	"10527759384",
	"10527759664",
	"10527759999",
	"10527760258",
	"10527760550",
	"10527760841",
	"10527761156",
	"10527761626",
	"10527761915",
	"10527762101",
	"10527917439",
	"10527918015",
	"10527918297",
	"10583920250",
	"10583920447",
	"10601437000",
	"10653452285",
	"10653452490",
	"10677242399",
	"10677242533",
	"10677242683",
	"10754473490",
	"10899037683",
	"10957491256",
	"10957491642",
	"10957574056",
	"10957574349",
	"11087997236",
	"11087997666",
	"11087997994",
	"11090457172",
	"11090464499",
	"11482560229",
	"11600030439",
	"11600136384",
	"11601338552",
	"11601341136",
	"11601342933",
	"11978646354",
	"11978734832",
	"12005239947",
	"12064542853",
	"12064544229",
	"12064545147",
	"12064545819",
	"12125643668",
	"12125644320",
	"12125645032",
	"12125645400",
	"12173918468",
	"12173918607",
	"12174152569",
	"12181870734",
	"12341920944",
	"12341921089",
	"12458282694",
	"12458346342",
	"12458346538",
	"12458346791",
	"12504169430",
	"12504169622",
	"12504169874",
	"12504170064",
	"12851524587",
	"12851524762",
	"12940375632",
	"12940375746",
	"12984404464",
	"12984605632",
	"12987736812",
	"13025487735",
	"13026809668",
	"13039684959",
	"13040152634",
	"13065530803",
	"13167610714",
	"13167668099",
	"13167668283",
	"13167668477",
	"13167668589",
	"13167668703",
	"13167668824",
	"13774042872",
	"13817236209",
	"13833541760",
	"14047561106",
	"14643397063",
	"14643397622",
	"14643398352",
	"14643398853",
	"14748036710",
	"15216381223",
	"15717373203",
	"17376826242",
	"17376847447",
	"18118780415",
	"18342521711",
	"18400632325",
	"73062183099472",
	"73885380527176",
	"75526696685922",
	"85837514429724",
	"98130322261993",
	"101071266395125",
	"107140982675462",
	"109175404879484",
	"110693348274844",
	"112343224742133",
	"125459058466110",
	"127097765203641",
	"138751188501730",
	"138803195698088",
	"140308423472317",
}

print("[IMG] total ids:", #IMAGE_IDS)

local lines = {}

local gui = Instance.new("ScreenGui")
gui.Name = "ImgDump"
gui.Enabled = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("ImageLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Parent = gui

for index = START_AT, #IMAGE_IDS do
	local id = IMAGE_IDS[index]
	label.Image = "rbxassetid://" .. id
	local loaded, width, height = false, 0, 0
	local ok = pcall(function()
		ContentProvider:PreloadAsync({ label }, nil)
		loaded = true
	end)
	if ok and loaded then
		task.wait(0.3)
		local size = label.ContentImageSize
		width, height = size.X, size.Y
	end
	local line = string.format(
		"[IMG] %03d id=%s %s",
		index,
		id,
		loaded and string.format("w=%d h=%d", width, height) or "FAILED"
	)
	print(line)
	table.insert(lines, line)
	label.Image = ""
	task.wait(WAIT_FOR_DUMPER)
end

gui:Destroy()

local text = table.concat(lines, "\n")
local wrote, writeErr = pcall(function()
	writefile("skywars-image-dump.txt", text)
end)
if wrote then
	print("[IMG] wrote skywars-image-dump.txt")
else
	local clipped = pcall(function()
		setclipboard(text)
	end)
	if clipped then
		print("[IMG] writefile unavailable (" .. tostring(writeErr) .. ") - copied to clipboard")
	else
		print("[IMG] no writefile/setclipboard - log below")
		print(text)
	end
end
