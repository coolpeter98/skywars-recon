--!strict

-- ChestLoot — random loot tables for tiered chests (tiers 1-4).
--
-- Four tiers map onto the recovered chest models (ChestTierOne..Four in
-- ReplicatedStorage/Misc): tiers 1-2 stock the team islands, tiers 3-4 the
-- center island.
--
-- Roll model (reconstructed from player-recorded chest samples):
--  * every chest first receives its tier's `Always` items (team blocks are
--    always present on tiers 1-3, the bronze sword on tier 1),
--  * then `MinCount..MaxCount` extra entries are drawn from the tier's pool,
--    weighted, without replacement across entries,
--  * a pooled entry rolls its quantity uniformly over its own `Min..Max`
--    range (Snowball 1-2 is a fair coin, TeamConcrete 9-12/12-16 uniform),
--  * picking the same item type twice stacks both rolls into one slot; only
--    TeamConcrete can repeat (a second pool entry on tiers 2-3) — that is the
--    source of the observed 24/29-block tier-2 chests and 25-block tier-3
--    chest,
--  * finished items are placed into random distinct slots of the 18-slot
--    chest instead of consecutive slots, so loot appears scattered.
--
-- Weights are fitted to the observed per-item frequencies: the iron sword
-- shows up in most tier-2 chests and the diamond sword in most tier-4 chests,
-- while helmets/leggings stay rare — those rates cannot come from an
-- equal-weight pool. Entries without a Weight default to 1.
--
-- Naming notes from the sample data: "team blocks" = TeamConcrete, "boots" =
-- the tier's Leggings item (the game has no boots armour), "pearl" =
-- Teleporter, potions = the SpeedBoost/JumpBoost/Shield/LifeSteal power-up
-- items. Tier 2 pools only SpeedBoost; tier 3 pools SpeedBoost, JumpBoost and
-- Shield but no explosives, onyx or lifesteal; tier 4 pools the speed, jump,
-- shield and lifesteal potions with equal weight plus the Capybara, but never
-- Dynamite, FishingRod or Adrenaline, and never team blocks.

export type ChestLootEntry = {
	Type: string,
	Quantity: number,
}

export type ChestContents = { [string]: ChestLootEntry & { Slot: number } }

type LootEntryConfig = {
	Type: string,
	Weight: number?,
	Min: number?,
	Max: number?,
}

type TierConfig = {
	Always: { LootEntryConfig },
	Pool: { LootEntryConfig },
	MinCount: number,
	MaxCount: number,
}

-- The client draws CHEST_SIZE (18) chest slots
-- (ReplicatedStorage/TS/inventory/inventory-constants.luau).
local CHEST_SIZE = 18

local TIER_CONFIGS: { [number]: TierConfig } = {
	-- Island tier 1: bronze gear, team blocks and a few snowballs.
	-- Always: team blocks (9-12) + the bronze sword (both appear in every
	-- recorded tier-1 chest). The five pool entries are equally weighted and
	-- drawn 2-5 times, giving 4-7 items total as observed.
	{
		Always = {
			{ Type = "TeamConcrete", Min = 9, Max = 12 },
			{ Type = "BronzeSword" },
		},
		Pool = {
			{ Type = "BronzeHelmet" },
			{ Type = "BronzeChestplate" },
			{ Type = "BronzeLeggings" },
			{ Type = "BronzePickaxe" },
			{ Type = "Snowball", Min = 1, Max = 2 },
		},
		MinCount = 2,
		MaxCount = 5,
	},
	-- Island tier 2: iron gear. The iron sword leads (recorded in 8/10
	-- chests, so it carries most of the pool weight); chestplates, bows,
	-- speed potions and arrows are common; pickaxes, helmets, leggings and
	-- snowballs are rare. Only the speed potion appears in this tier. A
	-- second TeamConcrete entry lets a chest stack another 12-16 blocks onto
	-- the guaranteed stack (the observed 24 and 29 stacks).
	{
		Always = {
			{ Type = "TeamConcrete", Min = 12, Max = 16 },
		},
		Pool = {
			{ Type = "IronSword", Weight = 6 },
			{ Type = "IronChestplate", Weight = 2 },
			{ Type = "Bow", Weight = 2 },
			{ Type = "SpeedBoost", Weight = 2 },
			{ Type = "Arrow", Weight = 2, Min = 8, Max = 16 },
			{ Type = "IronPickaxe" },
			{ Type = "IronHelmet" },
			{ Type = "IronLeggings" },
			{ Type = "Snowball", Min = 1, Max = 2 },
			{ Type = "TeamConcrete", Min = 12, Max = 16 },
		},
		MinCount = 2,
		MaxCount = 4,
	},
	-- Center tier 3: gold/diamond gear. Diamond swords, bows, arrows and
	-- pearls lead; speed/jump/shield potions and the rest of the gear are
	-- rare. No explosives, onyx gear or lifesteal potions. The extra
	-- TeamConcrete entry produces the observed 25-block stack.
	{
		Always = {
			{ Type = "TeamConcrete", Min = 12, Max = 16 },
		},
		Pool = {
			{ Type = "DiamondSword", Weight = 2 },
			{ Type = "Bow", Weight = 2 },
			{ Type = "Arrow", Weight = 2, Min = 9, Max = 16 },
			{ Type = "Teleporter", Weight = 2, Min = 1, Max = 2 },
			{ Type = "GoldSword" },
			{ Type = "GoldHelmet" },
			{ Type = "DiamondPickaxe" },
			{ Type = "DiamondChestplate" },
			{ Type = "DiamondHelmet" },
			{ Type = "DiamondLeggings" },
			{ Type = "SpeedBoost" },
			{ Type = "JumpBoost" },
			{ Type = "Shield" },
			{ Type = "TeamConcrete", Min = 12, Max = 16 },
		},
		MinCount = 2,
		MaxCount = 5,
	},
	-- Center tier 4: top-tier loot. The diamond sword dominates (7/10
	-- chests); diamond chestplates/leggings and pearls are common; the speed,
	-- jump, shield and lifesteal potions can all appear with equal weight.
	-- No team blocks, Dynamite, FishingRod or Adrenaline, and no bow/arrows.
	{
		Always = {},
		Pool = {
			{ Type = "DiamondSword", Weight = 6 },
			{ Type = "DiamondChestplate", Weight = 2 },
			{ Type = "DiamondLeggings", Weight = 2 },
			{ Type = "Teleporter", Weight = 2, Min = 1, Max = 2 },
			{ Type = "OnyxSword" },
			{ Type = "OnyxPickaxe" },
			{ Type = "OnyxChestplate" },
			{ Type = "DiamondHelmet" },
			{ Type = "Capybara" },
			{ Type = "SpeedBoost" },
			{ Type = "JumpBoost" },
			{ Type = "Shield" },
			{ Type = "LifeSteal" },
		},
		MinCount = 2,
		MaxCount = 4,
	},
}

local rng = Random.new()

local function getEntryWeight(entry: LootEntryConfig): number
	if entry.Weight ~= nil then
		return entry.Weight
	end
	return 1
end

-- Uniform roll over the entry's quantity range; bare entries are singles.
local function rollQuantity(entry: LootEntryConfig): number
	local min = entry.Min
	local max = entry.Max
	if min == nil then
		return 1
	end
	if max == nil or max <= min then
		return min
	end
	return rng:NextInteger(min, max)
end

-- Weighted draw without replacement across the pool's entries.
local function pickFromPool(config: TierConfig, count: number): { ChestLootEntry }
	local remaining = table.clone(config.Pool)
	local picks: { ChestLootEntry } = {}
	for _ = 1, count do
		if #remaining == 0 then
			break
		end
		local totalWeight = 0
		for _, entry in remaining do
			totalWeight += getEntryWeight(entry)
		end
		local roll = rng:NextNumber() * totalWeight
		local cumulative = 0
		local chosenIndex = #remaining
		for index, entry in remaining do
			cumulative += getEntryWeight(entry)
			if roll < cumulative then
				chosenIndex = index
				break
			end
		end
		local chosen = table.remove(remaining, chosenIndex)
		if chosen == nil then
			break
		end
		table.insert(picks, { Type = chosen.Type, Quantity = rollQuantity(chosen) })
	end
	return picks
end

-- `count` distinct slots drawn uniformly from 0..CHEST_SIZE-1 (partial
-- Fisher-Yates shuffle), so loot lands scattered across the chest grid.
local function randomSlots(count: number): { number }
	count = math.min(count, CHEST_SIZE)
	local slots: { number } = table.create(count)
	local deck: { number } = table.create(CHEST_SIZE)
	for slot = 0, CHEST_SIZE - 1 do
		deck[slot + 1] = slot
	end
	for index = 1, count do
		local swapIndex = rng:NextInteger(index, CHEST_SIZE)
		deck[index], deck[swapIndex] = deck[swapIndex], deck[index]
		slots[index] = deck[index]
	end
	return slots
end

local function rollContents(tier: number): ChestContents?
	local config = TIER_CONFIGS[tier]
	if config == nil then
		return nil
	end
	local picks = pickFromPool(config, rng:NextInteger(config.MinCount, config.MaxCount))

	-- Merge by type so repeated rolls of the same item share one slot
	-- (TeamConcrete picks stack onto the guaranteed block stack).
	local stacks: { ChestLootEntry } = {}
	local stackIndexByType: { [string]: number } = {}
	local function addToStack(itemType: string, quantity: number)
		local index = stackIndexByType[itemType]
		if index == nil then
			table.insert(stacks, { Type = itemType, Quantity = 0 })
			index = #stacks
			stackIndexByType[itemType] = index
		end
		stacks[index].Quantity += quantity
	end
	for _, entry in config.Always do
		addToStack(entry.Type, rollQuantity(entry))
	end
	for _, pick in picks do
		addToStack(pick.Type, pick.Quantity)
	end

	local slots = randomSlots(#stacks)
	local contents: ChestContents = {}
	for index, stack in stacks do
		local slot = slots[index]
		contents[tostring(slot)] = { Slot = slot, Type = stack.Type, Quantity = stack.Quantity }
	end
	return contents
end

local ChestLoot = {}

-- Highest loot tier defined above; island/center mapping helpers use it.
function ChestLoot.getTierCount(): number
	return #TIER_CONFIGS
end

-- Rolls and returns the slot-keyed contents for a tier (1-based), or nil for
-- an out-of-range tier. Each call is a fresh random roll.
function ChestLoot.getContents(tier: number): ChestContents?
	return rollContents(tier)
end

return ChestLoot
