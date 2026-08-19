-- Omit - removes the given keys from a shallow copy of a table.

local ObjectUtils: { copy: <T>(object: T) -> T } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")

return {
	["omit"] = function<T, K>(object: T, keys: { K }): T
		local result = ObjectUtils.copy(object)
		for index, key in keys do
			local _ = index - 1
			result[key] = nil
		end
		return result
	end,
}
