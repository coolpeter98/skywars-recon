-- Separator

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["Separator"] = function(props: { [string]: any })
		local mergedProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["BackgroundColor3"] = Color.White,
		}
		for key, value in props do
			mergedProps[key] = value
		end
		return React.createElement(
			Grid,
			mergedProps,
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1, 0),
			})
		)
	end,
}
