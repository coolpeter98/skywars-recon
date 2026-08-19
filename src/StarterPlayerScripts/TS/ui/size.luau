-- Size

type Size = {
	X: number,
	Y: number,
}

local Size = setmetatable({}, {
	["__tostring"] = function()
		return "Size"
	end,
})
Size.__index = Size

function Size.new(...): Size
	local class = Size
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function Size.constructor(self: Size, x: number, y: number)
	self.X = (x == 0 or (x ~= x or not x)) and 0 or x
	self.Y = (y == 0 or (y ~= y or not y)) and 0 or y
end

function Size.add(self: Size, x: number, y: number): Size
	local newX = self.X + ((x == 0 or (x ~= x or not x)) and 0 or x)
	local newY = self.Y
	local sanitizedY = (y == 0 or (y ~= y or not y)) and 0 or y
	return Size.new(newX, newY + sanitizedY)
end

function Size.sub(self: Size, x: number, y: number): Size
	local newX = self.X - ((x == 0 or (x ~= x or not x)) and 0 or x)
	local newY = self.Y
	local sanitizedY = (y == 0 or (y ~= y or not y)) and 0 or y
	return Size.new(newX, newY - sanitizedY)
end

function Size.mul(self: Size, x: number, y: number): Size
	local newX = self.X * ((x == 0 or (x ~= x or not x)) and 0 or x)
	local newY = self.Y
	if y == 0 or (y ~= y or not y) then
		y = (x == 0 or (x ~= x or not x)) and 0 or x
	end
	return Size.new(newX, newY * y)
end

function Size.div(self: Size, x: number?, y: number?): Size
	local newX = self.X / (x == nil and 1 or x)
	local newY = self.Y
	if y == nil then
		y = x == nil and 1 or x
	end
	return Size.new(newX, newY / y)
end

function Size.ToUDim(self: Size): UDim
	return UDim.new(0, self.X)
end

function Size.ToUDim2(self: Size): UDim2
	return UDim2.fromOffset(self.X, self.Y)
end

function Size.UDim2(_, size, fallback): UDim2?
	if size ~= nil then
		size = size:ToUDim2()
	end
	return size or fallback
end

return {
	["Size"] = Size,
}
