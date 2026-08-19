-- usePicker

local React =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"react"
	)
local useRef = React.useRef
local useState = React.useState
return {
	["usePicker"] = function<T>(
		list: { T },
		value: T,
		range: number
	): {
		View: { [T]: number },
		Index: number,
		SetValue: (value: T) -> (),
		Previous: () -> T,
		Next: () -> T,
	}
		local initialIndex = (table.find(list, value) or 0) - 1
		local index, setIndex = useState(initialIndex == nil and 0 or initialIndex)
		local viewRef = useRef({})
		table.clear(viewRef.current)
		local halfRange = range / 2
		local half = math.floor(halfRange)
		local offset = -half
		local first = false
		while true do
			if first then
				offset = offset + 1
			else
				first = true
			end
			if offset > half then
				return {
					["View"] = viewRef.current,
					["Index"] = index,
					["SetValue"] = function(value)
						local list = list
						local index = (table.find(list, value) or 0) - 1
						return setIndex(index == nil and 0 or index)
					end,
					["Previous"] = function()
						local newIndex = (index - 1) % #list
						setIndex(newIndex)
						return list[(newIndex - half) % #list + 1]
					end,
					["Next"] = function()
						local newIndex = (index + 1) % #list
						setIndex(newIndex)
						return list[(newIndex + half) % #list + 1]
					end,
				}
			end
			local item = list[(index + offset) % #list + 1]
			viewRef.current[item] = offset
		end
	end,
}
