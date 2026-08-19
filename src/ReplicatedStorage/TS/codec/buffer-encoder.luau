-- BufferEncoder

export type BufferEncoder = {
	array: { string },
	index: number,
	new: (...any) -> BufferEncoder,
	constructor: (self: BufferEncoder) -> (),
	writeBlock: (self: BufferEncoder, block: Vector3, blockId: number) -> (),
	writeVector: (self: BufferEncoder, vector: Vector3) -> (),
	writeSignedVarInt: (self: BufferEncoder, value: number) -> (),
	writeVarInt: (self: BufferEncoder, value: number) -> (),
	writeString: (self: BufferEncoder, str: string) -> (),
	writePadding: (self: BufferEncoder) -> (),
	getLength: (self: BufferEncoder) -> number,
	getBuffer: (self: BufferEncoder) -> string,
}

local BufferEncoder = setmetatable({}, {
	["__tostring"] = function()
		return "BufferEncoder"
	end,
})
BufferEncoder.__index = BufferEncoder
function BufferEncoder.new(...): BufferEncoder
	local class = BufferEncoder
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end
function BufferEncoder.constructor(self: BufferEncoder)
	self.array = {}
	self.index = 0
end
function BufferEncoder.writeBlock(self: BufferEncoder, block: Vector3, blockId: number)
	self:writeVarInt(block.X / 3)
	self:writeVarInt(block.Y / 3)
	self:writeVarInt(block.Z / 3)
	self:writeVarInt(blockId)
end
function BufferEncoder.writeVector(self: BufferEncoder, vector: Vector3)
	self:writeVarInt(vector.X)
	self:writeVarInt(vector.Y)
	self:writeVarInt(vector.Z)
end
function BufferEncoder.writeSignedVarInt(self: BufferEncoder, value: number)
	local sign = bit32.arshift(value, 31)
	local shifted = bit32.lshift(value, 1)
	self:writeVarInt(bit32.bxor(sign, shifted))
end
function BufferEncoder.writeVarInt(self: BufferEncoder, value: number)
	while value >= 0 do
		if bit32.rshift(value, 6) == 0 then
			local array = self.array
			local nextIndex = self.index + 1
			local byte = bit32.band(value, 63)
			array[nextIndex] = string.char(byte)
			self.index = self.index + 1
			return nil
		end
		local array = self.array
		local nextIndex = self.index + 1
		local byte = bit32.band(value, 63)
		local flaggedByte = bit32.bor(byte, 64)
		array[nextIndex] = string.char(flaggedByte)
		self.index = self.index + 1
		value = bit32.rshift(value, 6)
	end
end
function BufferEncoder.writeString(self: BufferEncoder, str: string)
	self:writeVarInt(#str)
	for i = 0, #str - 1 do
		local from = i + 1
		local to = i + 1
		self.array[self.index + 1] = string.sub(str, from, to)
		self.index = self.index + 1
	end
end
function BufferEncoder.writePadding(self: BufferEncoder)
	self.array[self.index + 1] = "\0"
	self.index = self.index + 1
end
function BufferEncoder.getLength(self: BufferEncoder): number
	return self.index
end
function BufferEncoder.getBuffer(self: BufferEncoder): string
	return table.concat(self.array, "")
end
return {
	["BufferEncoder"] = BufferEncoder,
}
