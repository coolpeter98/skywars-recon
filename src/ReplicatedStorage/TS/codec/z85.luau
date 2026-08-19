-- Z85

type Z85Module = {
	encode: (str: string) -> string,
	decode: (str: string) -> string,
}

local Z85: Z85Module = {}

local Z85_ALPHABET: { string } = {
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	".",
	"-",
	":",
	"+",
	"=",
	"^",
	"!",
	"/",
	"*",
	"?",
	"&",
	"<",
	">",
	"(",
	")",
	"[",
	"]",
	"{",
	"}",
	"@",
	"%",
	"$",
	"#",
}
local Z85_DECODE_TABLE: { number } = {
	0,
	68,
	0,
	84,
	83,
	82,
	72,
	0,
	75,
	76,
	70,
	65,
	0,
	63,
	62,
	69,
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	64,
	0,
	73,
	66,
	74,
	71,
	81,
	36,
	37,
	38,
	39,
	40,
	41,
	42,
	43,
	44,
	45,
	46,
	47,
	48,
	49,
	50,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	58,
	59,
	60,
	61,
	77,
	0,
	78,
	67,
	0,
	0,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20,
	21,
	22,
	23,
	24,
	25,
	26,
	27,
	28,
	29,
	30,
	31,
	32,
	33,
	34,
	35,
	79,
	0,
	80,
	0,
	0,
}
function Z85.encode(str: string): string
	local length = #str
	local multipleOf4 = length % 4 == 0
	assert(multipleOf4, "String must be bound to 4 bytes!")
	local outputLength = length * 1.25
	local output = table.create(outputLength)
	local i = 0
	local value = 0
	local position = 0
	while i < length do
		local nextIndex = i + 1
		local byteIndex = i + 1
		value = value * 256 + string.byte(str, byteIndex)
		if nextIndex % 4 == 0 then
			local divisor = 52200625
			while divisor >= 1 do
				local nextPosition = position + 1
				local outputIndex = position + 1
				local alphabet = Z85_ALPHABET
				local quotient = value / divisor
				output[outputIndex] = alphabet[math.floor(quotient) % 85 + 1]
				divisor = divisor / 85
				position = nextPosition
			end
			value = 0
		end
		i = nextIndex
	end
	local lengthMatches = position == outputLength
	assert(lengthMatches)
	return table.concat(output, "")
end
function Z85.decode(str: string): string
	local length = #str
	local multipleOf5 = length % 5 == 0
	assert(multipleOf5, "String must be bound to 5 bytes!")
	local outputLength = length * 0.8
	local output = table.create(outputLength)
	local i = 0
	local value = 0
	local position = 0
	while i < length do
		local previousValue = value * 85
		local decodeTable = Z85_DECODE_TABLE
		local nextIndex = i + 1
		local charIndex = i + 1
		value = previousValue + decodeTable[string.byte(str, charIndex) - 31]
		if nextIndex % 5 == 0 then
			local divisor = 16777216
			while divisor ~= 0 do
				local nextPosition = position + 1
				local outputIndex = position + 1
				local byteValue = value / divisor % 256
				output[outputIndex] = string.char(byteValue)
				local nextDivisor = divisor / 256
				divisor = math.floor(nextDivisor)
				position = nextPosition
			end
			value = 0
		end
		i = nextIndex
	end
	local lengthMatches = position == outputLength
	assert(lengthMatches)
	return table.concat(output, "")
end
return {
	["Z85"] = Z85,
}
