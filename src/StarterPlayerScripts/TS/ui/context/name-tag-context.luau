-- NameTagContext

local React =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"react"
	)

local NameTagContext = React.createContext({})

return {
	["NameTagContext"] = NameTagContext,
}
