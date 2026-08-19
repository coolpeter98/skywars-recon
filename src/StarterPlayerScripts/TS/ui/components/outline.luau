-- Outline

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local omit = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "object", "omit").omit

type OutlineProps = {
	Thickness: number?,
	Ref: any?,
	[string]: any,
}

return {
	["Outline"] = function(props: OutlineProps)
		local thickness = props.Thickness
		local clampedThickness = math.max(thickness, 0)
		local uiStrokeProps = {
			["key"] = "UIStroke",
			["Color"] = nil,
			["Color"] = Color.White,
		}
		for key, value in omit(props, { "Ref" }) do
			uiStrokeProps[key] = value
		end
		uiStrokeProps.Thickness = clampedThickness
		uiStrokeProps.ref = props.Ref
		return React.createElement("uistroke", uiStrokeProps)
	end,
}
