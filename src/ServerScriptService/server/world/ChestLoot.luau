--!strict

-- ChestLoot — deterministic loot tables for the placeholder map's chests.
--
-- Four tiers map onto the recovered chest models (ChestTierOne..Four in
-- ReplicatedStorage/Misc): tiers 1-2 stock the team islands, tiers 3-4 the
-- center island. Every combat/building item the server supports is covered:
-- swords, pickaxes, armour, the bow, all six projectile weapons, and blocks.
-- Utility items without server behavior yet (Landmine, Launchpad,
-- SmokeGrenade, Tornado) are deliberately excluded.
--
-- Contents fit the client's CHEST_SIZE (18 slots); getContents returns the
-- slot-keyed table the chest Inventory attribute serializes.

export type ChestLootEntry = {
	Type: string,
	Quantity: number,
}

export type ChestContents = { [string]: { Slot: number, Type: string, Quantity: number } }

local TIER_LOOT: { [number]: { ChestLootEntry } } = {
	-- Island: basic gear, building blocks, a few snowballs.
	{
		{ Type = "BronzeSword", Quantity = 1 },
		{ Type = "BronzePickaxe", Quantity = 1 },
		{ Type = "BronzeHelmet", Quantity = 1 },
		{ Type = "BronzeLeggings", Quantity = 1 },
		{ Type = "Planks", Quantity = 16 },
		{ Type = "StoneBricks", Quantity = 12 },
		{ Type = "Ice", Quantity = 8 },
		{ Type = "Snowball", Quantity = 3 },
	},
	-- Island: iron gear plus a bow.
	{
		{ Type = "IronSword", Quantity = 1 },
		{ Type = "IronPickaxe", Quantity = 1 },
		{ Type = "IronChestplate", Quantity = 1 },
		{ Type = "IronLeggings", Quantity = 1 },
		{ Type = "Bow", Quantity = 1 },
		{ Type = "Arrow", Quantity = 8 },
		{ Type = "Planks", Quantity = 16 },
		{ Type = "StoneBricks", Quantity = 12 },
		{ Type = "Snowball", Quantity = 4 },
	},
	-- Center: gold gear, the bow, and the first explosives.
	{
		{ Type = "GoldSword", Quantity = 1 },
		{ Type = "GoldPickaxe", Quantity = 1 },
		{ Type = "GoldChestplate", Quantity = 1 },
		{ Type = "GoldLeggings", Quantity = 1 },
		{ Type = "Bow", Quantity = 1 },
		{ Type = "Arrow", Quantity = 12 },
		{ Type = "Dynamite", Quantity = 2 },
		{ Type = "Capybara", Quantity = 1 },
		{ Type = "FishingRod", Quantity = 1 },
		{ Type = "StoneBricks", Quantity = 16 },
		{ Type = "Snowball", Quantity = 6 },
	},
	-- Center: top-tier gear and every special weapon.
	{
		{ Type = "OnyxSword", Quantity = 1 },
		{ Type = "DiamondSword", Quantity = 1 },
		{ Type = "OnyxPickaxe", Quantity = 1 },
		{ Type = "OnyxChestplate", Quantity = 1 },
		{ Type = "DiamondHelmet", Quantity = 1 },
		{ Type = "DiamondLeggings", Quantity = 1 },
		{ Type = "Bow", Quantity = 1 },
		{ Type = "Arrow", Quantity = 16 },
		{ Type = "Capybara", Quantity = 2 },
		{ Type = "Dynamite", Quantity = 3 },
		{ Type = "Teleporter", Quantity = 1 },
		{ Type = "FishingRod", Quantity = 1 },
		{ Type = "Snowball", Quantity = 8 },
		{ Type = "StoneBricks", Quantity = 24 },
		{ Type = "Iron", Quantity = 12 },
	},
}

local ChestLoot = {}

-- Highest loot tier defined above; island/center mapping helpers use it.
function ChestLoot.getTierCount(): number
	return #TIER_LOOT
end

-- Returns the slot-keyed contents for a tier (1-based), or nil for an
-- out-of-range tier. Slots are sequential from 0.
function ChestLoot.getContents(tier: number): ChestContents?
	local entries = TIER_LOOT[tier]
	if entries == nil then
		return nil
	end
	local contents: ChestContents = {}
	for index, entry in entries do
		local slot = index - 1
		contents[tostring(slot)] = {
			Slot = slot,
			Type = entry.Type,
			Quantity = entry.Quantity,
		}
	end
	return contents
end

return ChestLoot
