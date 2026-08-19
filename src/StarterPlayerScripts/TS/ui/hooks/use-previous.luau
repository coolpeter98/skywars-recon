-- usePrevious

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

return {
	["usePrevious"] = function<T>(value: T): T
		local ref = useRef(value)
		useEffect(function()
			ref.current = value
		end, { value })
		return ref.current
	end,
}
