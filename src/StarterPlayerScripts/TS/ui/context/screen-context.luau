-- ScreenContext

local React =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"react"
	)

local createContext = React.createContext
local useContext = React.useContext

local ScreenContext = createContext({})

return {
	["ScreenContext"] = ScreenContext,
	["useScreen"] = function()
		return useContext(ScreenContext)
	end,
}
