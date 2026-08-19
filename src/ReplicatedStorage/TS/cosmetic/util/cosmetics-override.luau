-- CosmeticsOverride

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId: { [string]: string } =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local SKINS_OVERRIDE: { [string]: string } = {
	["Sword"] = CosmeticId.SwordMayanSpear,
	["Bow"] = CosmeticId.BowTactical,
	["Helmet"] = CosmeticId.HelmetGasMask,
	["Chestplate"] = CosmeticId.ChestplateSharkSuit,
	["Leggings"] = CosmeticId.LeggingsSharkSuit,
	["Pickaxe"] = CosmeticId.PickaxeBooster,
	["Snowball"] = CosmeticId.SnowballShuriken,
}
local COSMETICS_OVERRIDE: { [string]: string } = {
	["ArrowTrailEffect"] = CosmeticId.ArrowTrailGold,
	["KillEffect"] = CosmeticId.KillEffectSlimeCube,
	["Cage"] = CosmeticId.CagePlasmaTitan,
}
return {
	["getSkinOverride"] = nil,
	["getCosmeticOverride"] = nil,
	["COSMETICS_OVERRIDE_ENABLED"] = false,
	["SKINS_OVERRIDE"] = nil,
	["COSMETICS_OVERRIDE"] = nil,
	["getSkinOverride"] = function(_)
		PlaceUtil.isProduction()
		return nil
	end,
	["getCosmeticOverride"] = function(_)
		PlaceUtil.isProduction()
		return nil
	end,
	["SKINS_OVERRIDE"] = SKINS_OVERRIDE,
	["COSMETICS_OVERRIDE"] = COSMETICS_OVERRIDE,
}
