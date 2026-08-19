-- BlockConstants

type BlockConstants = {
	BLOCK_SIZE: number,
	BLOCK_DIMENSION: Vector3,
	BLOCK_HIT_EXPIRE: number,
	MAXIMUM_PLACE_RANGE: number,
	BLOCK_BREAK_SEGMENTS: number,
}

return {
	["BlockConstants"] = {
		["BLOCK_SIZE"] = 3,
		["BLOCK_DIMENSION"] = Vector3.new(3, 3, 3),
		["BLOCK_HIT_EXPIRE"] = 5,
		["MAXIMUM_PLACE_RANGE"] = 6,
		["BLOCK_BREAK_SEGMENTS"] = 8,
	},
} :: { BlockConstants: BlockConstants }
