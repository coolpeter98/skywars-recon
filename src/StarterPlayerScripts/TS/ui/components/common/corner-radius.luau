-- CornerRadius

local React = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CornerRadiusProps = {
	CornerRadius: number | UDim,
}

return {
	["CornerRadius"] = function(props: CornerRadiusProps)
		local cornerRadius = props.CornerRadius
		local uicornerProps = {
			["key"] = "UICorner",
		}

		local cornerRadiusProps
		if type(cornerRadius) == "number" then
			cornerRadiusProps = {
				["CornerRadius"] = UDim.new(0, props.CornerRadius),
			}
		else
			cornerRadiusProps = props.CornerRadius
		end

		for key, value in cornerRadiusProps do
			uicornerProps[key] = value
		end

		return React.createElement("uicorner", uicornerProps)
	end,
}
