-- ArrayUtil

local ArrayUtil = {
	["filterDefined"] = function(array: { any }): { any }
		local result = {}
		for _, item in array do
			if item ~= nil then
				table.insert(result, item)
			end
		end
		return result
	end,
}

local removeElements: ((array: { any }, ...any) -> { any })? = nil

function ArrayUtil.random(array: { any }, seed: number?, ...: any): any
	local elements = { ... }
	if elements then
		array = removeElements(array, unpack(elements))
	end
	local random
	if seed == nil then
		random = Random.new()
	else
		random = Random.new(seed)
	end
	return array[random:NextInteger(0, #array - 1) + 1]
end

removeElements = function(array: { any }, ...: any): { any }
	local result = table.clone(array)
	for _, element in { ... } do
		if element ~= nil then
			local index = (table.find(result, element) or 0) - 1
			if index ~= nil then
				table.remove(result, index + 1)
			end
		end
	end
	return result
end

function ArrayUtil.sum(array: { number }): number
	local total = 0
	for i = 1, #array do
		local value = array[i]
		local _ = i - 1
		total = total + value
	end
	return total
end

function ArrayUtil.fill(size: number): { number }
	local hasIncremented = false
	local index = 0
	local result = {}
	while true do
		if hasIncremented then
			index = index + 1
		else
			hasIncremented = true
		end
		if index >= size then
			return result
		end
		result[index + 1] = index
	end
end

function ArrayUtil.isDefined(array: { any }): boolean
	for _, item in array do
		if item == nil then
			return false
		end
	end
	return true
end

function ArrayUtil.isEquals(array1: { any }, array2: { any }): boolean
	if #array1 ~= #array2 then
		return false
	end
	for i = 0, #array1 - 1 do
		if array1[i + 1] ~= array2[i + 1] then
			return false
		end
	end
	return true
end

local function isDeepEquals(array1: { any }, array2: { any }): boolean
	if #array1 ~= #array2 then
		return false
	end
	for i = 0, #array1 - 1 do
		local value1 = array1[i + 1]
		local bothTables = type(value1) == "table"
		if bothTables then
			local value2 = array2[i + 1]
			bothTables = type(value2) == "table"
		end
		if bothTables then
			local leftValue = array1[i + 1]
			local rightValue = array2[i + 1]
			if type(rightValue) ~= typeof(leftValue) then
				return false
			end
			if not isDeepEquals(array1[i + 1], array2[i + 1]) then
				return false
			end
		end
		if array1[i + 1] ~= array2[i + 1] then
			return false
		end
	end
	return true
end

ArrayUtil.isDeepEquals = isDeepEquals

return {
	["ArrayUtil"] = ArrayUtil,
}
