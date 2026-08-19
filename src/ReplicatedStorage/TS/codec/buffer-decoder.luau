-- BufferDecoder

export type BufferDecoder = {
	index: number,
	data: string,
}

local BufferDecoder = setmetatable({}, {
	["__tostring"] = function(): string
		return "BufferDecoder"
	end,
})
BufferDecoder.__index = BufferDecoder

function BufferDecoder.new(...): BufferDecoder
	local self = BufferDecoder
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function BufferDecoder.constructor(self: BufferDecoder, data: string?)
	local dataValue = data == nil and "" or data
	self.index = 0
	self.data = dataValue
end

function BufferDecoder.readBlockTranslate(self: BufferDecoder): { position: Vector3, id: number }
	local block = {}
	local x = self:readVarInt()
	local y = self:readVarInt()
	block.position = Vector3.new(x, y, self:readVarInt())
	block.id = self:readVarInt()
	return block
end

function BufferDecoder.readBlock(self: BufferDecoder): { position: Vector3, id: number }
	local block = {}
	local x = self:readVarInt() * 3
	local y = self:readVarInt() * 3
	local z = self:readVarInt() * 3
	block.position = Vector3.new(x, y, z)
	block.id = self:readVarInt()
	return block
end

function BufferDecoder.readVector(self: BufferDecoder): Vector3
	local x = self:readVarInt()
	local y = self:readVarInt()
	return Vector3.new(x, y, self:readVarInt())
end

function BufferDecoder.readSignedVarInt(self: BufferDecoder): number
	local value = self:readVarInt()
	local shifted = bit32.rshift(value, 1)
	local sign = -bit32.band(value, 1)
	return bit32.bxor(shifted, sign)
end

function BufferDecoder.readVarInt(self: BufferDecoder): number
	local result = 0
	local chunkIndex = 0
	while true do
		local data = self.data
		local bytePos = self.index + 1
		local byte = string.byte(data, bytePos)
		self.index = self.index + 1
		local chunk = bit32.band(byte, 63)
		local bitOffset = chunkIndex * 6
		local shiftedChunk = bit32.lshift(chunk, bitOffset)
		result = bit32.bor(result, shiftedChunk)
		if bit32.band(byte, 64) == 0 then
			break
		end
		chunkIndex = chunkIndex + 1
	end
	return result
end

function BufferDecoder.readString(self: BufferDecoder): string
	local length = self:readVarInt()
	local data = self.data
	local startPos = self.index + 1
	local endPos = self.index + length
	local result = string.sub(data, startPos, endPos)
	self.index = self.index + length
	return result
end

function BufferDecoder.getRemainingData(self: BufferDecoder): string
	local data = self.data
	local startPos = self.index + 1
	local endPos = #self.data + 1
	return string.sub(data, startPos, endPos)
end

function BufferDecoder.size(self: BufferDecoder): number
	return #self.data
end

function BufferDecoder.isComplete(self: BufferDecoder): boolean
	return self.index == #self.data
end

return {
	["BufferDecoder"] = BufferDecoder,
}
