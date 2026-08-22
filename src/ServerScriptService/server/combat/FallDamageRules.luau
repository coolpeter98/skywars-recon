--!strict

-- Pure fall-damage math (no Roblox API — unit-testable under Lune via
-- tools/test_fall_damage.luau).
--
-- The game does NOT compute fall damage from velocity: it compares the Y
-- level of the block the player fell from with the Y level of the block they
-- land on. The client's block grid is 3 studs per block and block tops sit
-- at world Y ≡ 1.5 (mod 3), so the level of a support surface is
-- floor(Y / BLOCK_SIZE). FallDamageService measures the two levels and feeds
-- their difference here as `blocksFallen`.
--
-- Falls shorter than MIN_FALL_BLOCKS deal nothing. Verified in the real
-- game: falling fewer than 10 blocks causes no damage at all, so the damage
-- function is locked to blocksFallen >= 10.
--
-- From 10 blocks up, damage follows a piecewise-linear curve fitted to
-- measurements taken in the real game (blocksFallen -> damage):
--
--   10 -> 17   11 -> 18   12 -> 18   13 -> 18   14 -> 19
--   15 -> 25   16 -> 25   17 -> 27   18 -> 27   19 -> 29
--   20 -> 33   21 -> 33
--
-- The measurements are approximate (several re-runs under-measured), so the
-- curve interpolates linearly between the measured anchors instead of
-- forcing an exact formula. Beyond the last anchor, damage keeps growing by
-- DAMAGE_PER_BLOCK_BEYOND per block and is capped at MAX_FALL_DAMAGE.

export type FallDamageRules = {
	BLOCK_SIZE: number,
	MIN_FALL_BLOCKS: number,
	MAX_FALL_DAMAGE: number,
	getBlockLevel: (worldY: number) -> number,
	getRootLevel: (rootY: number) -> number,
	getFallDamage: (blocksFallen: number) -> number,
}

local FallDamageRules: FallDamageRules = {
	-- The client's placement grid: one block cell per 3 studs.
	BLOCK_SIZE = 3,
	-- The recovered game locks fall damage to falls of at least 10 blocks.
	MIN_FALL_BLOCKS = 10,
	-- The health bar tops out at 100; longer falls stop scaling here.
	MAX_FALL_DAMAGE = 100,
}

-- Block tops sit at world Y ≡ 1.5 (mod 3); this half-block grid offset
-- aligns a root-part Y with the same levels.
local BLOCK_GRID_OFFSET = 1.5

-- Damage added per block beyond the last measured anchor (21 blocks).
local DAMAGE_PER_BLOCK_BEYOND = 2

type FallAnchor = {
	blocks: number,
	damage: number,
}

-- Measured (blocksFallen, damage) anchor points, ascending by blocks.
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

-- The block level of a support surface at world Y: tops at 3k + 1.5 (and
-- any Y within the block above them) resolve to level k.
function FallDamageRules.getBlockLevel(worldY: number): number
	return math.floor(worldY / FallDamageRules.BLOCK_SIZE)
end

-- The block level of a player root part at world Y. The 1.5-stud grid
-- offset is removed first so a root standing on block k (root Y = block top
-- + hip height, with the hip height well under one block) resolves to level
-- k exactly, matching getBlockLevel on the surface beneath them.
function FallDamageRules.getRootLevel(rootY: number): number
	return math.floor((rootY - BLOCK_GRID_OFFSET) / FallDamageRules.BLOCK_SIZE)
end

-- Fall damage for a fall of `blocksFallen` blocks. Zero below
-- MIN_FALL_BLOCKS; the measured anchor curve between the anchors (linear
-- interpolation, rounded to the nearest integer); a fixed per-block ramp
-- beyond the last anchor, capped at MAX_FALL_DAMAGE.
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
