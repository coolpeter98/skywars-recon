-- useAttribute hook

local React =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"react"
	)

local useEffect = React.useEffect
local useState = React.useState

return {
	["useAttribute"] = function(instance: Instance, attribute: string)
		local function getAttribute()
			return instance:GetAttribute(attribute)
		end

		local value, setValue = useState(getAttribute)

		useEffect(function()
			local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
				setValue(getAttribute)
			end)

			return function()
				connection:Disconnect()
			end
		end, { instance })

		return value
	end,
}
