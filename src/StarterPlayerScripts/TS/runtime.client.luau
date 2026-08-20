-- RuntimeClient

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

type Flamework = {
	_addPaths: (paths: { { string } }) -> (),
	ignite: () -> (),
}

type PlaceUtil = {
	isProduction: () -> boolean,
}

local Flamework: Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local PlaceUtil: PlaceUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil

Flamework._addPaths({
	{
		"StarterPlayer",
		"StarterPlayerScripts",
		"TS",
		"components",
	},
})
Flamework._addPaths({
	{
		"StarterPlayer",
		"StarterPlayerScripts",
		"TS",
		"controllers",
	},
})
Flamework._addPaths({
	{
		"StarterPlayer",
		"StarterPlayerScripts",
		"TS",
		"cosmetics",
	},
})
print("BOOT-DEBUG: paths 1-3 done")
Flamework._addPaths({
	{ "ReplicatedStorage", "TS", "components" },
})
print("BOOT-DEBUG: rs components done")
Flamework._addPaths({
	{
		"ReplicatedStorage",
		"TS",
		"cosmetic",
		"cage",
	},
})
print("BOOT-DEBUG: cage done")
Flamework._addPaths({
	{ "ReplicatedStorage", "TS", "modules" },
})
print("BOOT-DEBUG: modules done")
Flamework.ignite()
print("BOOT-DEBUG: ignite done")Flamework.ignite()
PlaceUtil.isProduction()
