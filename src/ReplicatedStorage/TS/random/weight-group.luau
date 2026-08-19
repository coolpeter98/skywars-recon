-- WeightGroup: a group of weighted items for random selection

export type WeightGroup = {
	items: { { Weight: number } },
}

local WeightGroup = setmetatable({}, {
	["__tostring"] = function()
		return "WeightGroup"
	end,
})

WeightGroup.__index = WeightGroup

function WeightGroup.new(...): WeightGroup
	local class = WeightGroup
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function WeightGroup.constructor(self: WeightGroup, ...)
	self.items = { ... }
end

function WeightGroup.select(self: WeightGroup): { Weight: number }
	local total = 0
	for _, item in self.items do
		total = total + item.Weight
	end

	local remaining = math.random() * total
	local started = false
	local index = 0
	while true do
		if started then
			index = index + 1
		else
			started = true
		end

		if index >= #self.items - 1 then
			break
		end

		remaining = remaining - self.items[index + 1].Weight
		if remaining <= 0 then
			break
		end
	end

	return self.items[index + 1]
end

return {
	["WeightGroup"] = WeightGroup,
}
