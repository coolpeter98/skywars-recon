-- events

local Networking =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@flamework",
		"networking",
		"out"
	).Networking
return {
	["GlobalEvents"] = Networking.createEvent("aYZ"),
	["GlobalFunctions"] = Networking.createFunction("dYE"),
}
