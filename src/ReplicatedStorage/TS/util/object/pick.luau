-- Pick

return {
	["pick"] = function<T, U>(object: { [T]: U }, keys: { T }): { [T]: U }
		local result: { [T]: U } = {}
		for i = 1, #keys do
			local key = keys[i]
			local _ = i - 1
			result[key] = object[key]
		end
		return result
	end,
}
