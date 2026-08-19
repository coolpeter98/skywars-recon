-- Window

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["Window"] = function(props)
		local propsCopy = table.clone(props)
		setmetatable(propsCopy, nil)
		propsCopy.children = nil

		local gridProps = {
			["BackgroundTransparency"] = 0.7,
		}
		for key, value in propsCopy do
			gridProps[key] = value
		end

		local children = props.children
		local cornerRadiusProps = {}
		local cornerRadius = props.CornerRadius
		cornerRadiusProps.Radius = cornerRadius == nil and 10 or cornerRadius

		return React.createElement(Grid, gridProps, children, React.createElement(CornerRadius, cornerRadiusProps))
	end,
}
