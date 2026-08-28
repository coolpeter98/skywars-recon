--!strict

-- Pure fall-damage math (no Roblox API; Lune-tested via tools/test_fall_damage.luau).
-- Not velocity-based: compares the block level fallen from with the landing level.
-- Falls under 10 blocks do nothing (verified in the real game). Above that, damage
-- interpolates the measured anchors (approximate — several re-runs under-measured),
-- then +2/block beyond 21, capped at MAX_FALL_DAMAGE.
-- Measured curve: 10→17 11→18 12→18 13→18 14→19 15→25 16→25 17→27 18→27 19→29 20→33 21→33.

export type FallDamageRules = {
	BLOCK_SIZE: number,
	MIN_FALL_BLOCKS: number,
	MAX_FALL_DAMAGE: number,
	getBlockLevel: (worldY: number) -> number,
	getRootLevel: (rootY: number) -> number,
	getFallDamage: (blocksFallen: number) -> number,
}

local FallDamageRules: FallDamageRules = {
	BLOCK_SIZE = 3,
	MIN_FALL_BLOCKS = 10,
	MAX_FALL_DAMAGE = 100,
}

-- Block tops sit at world Y ≡ 1.5 (mod 3).
local BLOCK_GRID_OFFSET = 1.5

-- Per block beyond the last measured anchor (21).
local DAMAGE_PER_BLOCK_BEYOND = 2

type FallAnchor = {
	blocks: number,
	damage: number,
}

-- Measured (blocksFallen, damage) anchors, ascending by blocks.
local FALL_DAMAGE_ANCHORS: { FallAnchor } = {
	{ blocks = 10, damage = 17 },
	{ blocks = 11, damage = 18 },
	{ blocks = 12, damage = 18 },
	{ blocks = 13, damage = 18 },
	{ blocks = 14, damage = 19 },
	{ blocks = 15, damage = 25 },
	{ blocks = 16, damage = 25 },
	{ blocks = 17, damage = 27 },
	{ blocks = 18, damage = 27 },
	{ blocks = 19, damage = 29 },
	{ blocks = 20, damage = 33 },
	{ blocks = 21, damage = 33 },
}

-- Block level of a support surface at world Y.
function FallDamageRules.getBlockLevel(worldY: number): number
	return math.floor(worldY / FallDamageRules.BLOCK_SIZE)
end

-- Block level of a root part: removes the 1.5-stud grid offset first so a root
-- standing on block k resolves to k (hip height is well under one block).
function FallDamageRules.getRootLevel(rootY: number): number
	return math.floor((rootY - BLOCK_GRID_OFFSET) / FallDamageRules.BLOCK_SIZE)
end

-- Linear interpolation between measured anchors, rounded; zero below the minimum.
function FallDamageRules.getFallDamage(blocksFallen: number): number
	if blocksFallen < FallDamageRules.MIN_FALL_BLOCKS then
		return 0
	end
	local firstBlocks, firstDamage = FALL_DAMAGE_ANCHORS[1].blocks, FALL_DAMAGE_ANCHORS[1].damage
	if blocksFallen <= firstBlocks then
		return firstDamage
	end
	local lastAnchor = FALL_DAMAGE_ANCHORS[#FALL_DAMAGE_ANCHORS]
	local lastBlocks, lastDamage = lastAnchor.blocks, lastAnchor.damage
	if blocksFallen >= lastBlocks then
		return math.min(
			FallDamageRules.MAX_FALL_DAMAGE,
			math.floor(lastDamage + (blocksFallen - lastBlocks) * DAMAGE_PER_BLOCK_BEYOND + 0.5)
		)
	end
	for index = 1, #FALL_DAMAGE_ANCHORS - 1 do
		local startBlocks, startDamage = FALL_DAMAGE_ANCHORS[index].blocks, FALL_DAMAGE_ANCHORS[index].damage
		local endBlocks, endDamage = FALL_DAMAGE_ANCHORS[index + 1].blocks, FALL_DAMAGE_ANCHORS[index + 1].damage
		if blocksFallen <= endBlocks then
			local fraction = (blocksFallen - startBlocks) / (endBlocks - startBlocks)
			return math.floor(startDamage + (endDamage - startDamage) * fraction + 0.5)
		end
	end
	return lastDamage
end

return FallDamageRules
