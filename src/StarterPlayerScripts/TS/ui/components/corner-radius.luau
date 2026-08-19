-- CornerRadius

local React =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"react"
	)

return {
	["CornerRadius"] = function(props: { Radius: number })
		return React.createElement("uicorner", {
			["key"] = "CornerRadius",
			["CornerRadius"] = nil,
			["CornerRadius"] = UDim.new(0, props.Radius),
		})
	end,
}
