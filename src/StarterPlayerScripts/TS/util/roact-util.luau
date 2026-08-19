-- RoactUtil

return {
	["RoactUtil"] = {
		["getBinding"] = function(value: unknown)
			if type(value) == "table" then
				return value:getValue()
			else
				return value
			end
		end,
	},
}
