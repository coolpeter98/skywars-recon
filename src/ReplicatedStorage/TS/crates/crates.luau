-- Crates

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local GameProducts = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").GameProducts
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type CrateGameProduct = {
	ProductId: string,
	Crate: {
		Id: string,
		Quantity: number,
	}?,
}

type CrateDefinition = {
	Id: string,
	DisplayName: string,
	Description: string,
	Color: Color3?,
	Image: string?,
	Rewards: { { CosmeticId: string?, Probability: number } }?,
	Products: { { ProductId: string, Quantity: number } }?,
}

local crateList: { CrateDefinition } = {}
local knightBruteCrate: CrateDefinition = {
	["Id"] = "KnightBruteCrate",
	["DisplayName"] = "Knight Brute Crate",
	["Color"] = nil,
	["Description"] = "",
	["Image"] = nil,
	["Rewards"] = nil,
	["Color"] = Color.Shop.KnightBruteCrate,
	["Image"] = RobloxImage.KNIGHT_BRUTE_CRATE,
	["Rewards"] = {
		{
			["CosmeticId"] = nil,
			["Probability"] = 0.5,
			["CosmeticId"] = CosmeticId.SwordLight
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.HelmetKnightBrute
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.ChestplateKnightBrute
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.LeggingsKnightBrute
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 3.5,
			["CosmeticId"] = CosmeticId.SwordChainsaw
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.SwordBoxingGloves
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.SwordClaws
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.PickaxeToucan
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.SwordBaseballBat
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.SwordGolfClub
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.SwordKnockyaOut3310
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.PickaxeHoned
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetWizardHat
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetBucket
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetFootball
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetTvHead
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetCrown
		}
	}
}
local ninjaCrate: CrateDefinition = {
	["Id"] = "NinjaCrate",
	["DisplayName"] = "Ninja Crate",
	["Color"] = nil,
	["Description"] = "",
	["Image"] = nil,
	["Rewards"] = nil,
	["Color"] = Color.Shop.NinjaCrate,
	["Image"] = RobloxImage.NINJA_CRATE,
	["Rewards"] = {
		{
			["CosmeticId"] = nil,
			["Probability"] = 0.5,
			["CosmeticId"] = CosmeticId.SwordTwinblade
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.HelmetNinja
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.ChestplateNinja
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 1,
			["CosmeticId"] = CosmeticId.LeggingsNinja
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 3.5,
			["CosmeticId"] = CosmeticId.SwordOkatana
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.SwordSaiDagger
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.PickaxePlasma
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 5,
			["CosmeticId"] = CosmeticId.BowPurpleTactical
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.SwordDualDaggers
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.SwordHeavyHammers
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 6,
			["CosmeticId"] = CosmeticId.KillEffectSmoke
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.LeggingsRocketBoots
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.ChestplateJetPack
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.LeggingsBeachSlippers
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.ChestplateFloatie
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetFireFighter
		},
		{
			["CosmeticId"] = nil,
			["Probability"] = 8,
			["CosmeticId"] = CosmeticId.HelmetTopHat
		}
	}
}
-- Decompiler helper (definition was lost during the rename pass; restored for correctness)
local function __set_list(list: { any }, startIndex: number, values: { any })
	for i = 1, #values do
		list[startIndex + i - 1] = values[i]
	end
end

__set_list(crateList, 1, { knightBruteCrate, ninjaCrate })
local function getCrateGameProducts(crateId: string): { CrateGameProduct }
	local index = 0
	local result: { CrateGameProduct } = {}
	for i, gameProduct: CrateGameProduct in ObjectUtils.values(GameProducts) do
		local _ = i - 1
		local crate = gameProduct.Crate
		if crate ~= nil then
			crate = crate.Id
		end
		if crate == crateId == true then
			index = index + 1
			result[index] = gameProduct
		end
	end
	return result
end
local crates: { [string]: CrateDefinition } = {}
local CrateRewardResultType: { [string]: string } = {
	["Cosmetic"] = "Cosmetic",
	["Duplicate"] = "Duplicate"
}
for _, crate: CrateDefinition in crateList do
	local gameProducts: { CrateGameProduct } = getCrateGameProducts(crate.Id)
	local crateId = crate.Id
	local clonedCrate: CrateDefinition = table.clone(crate)
	setmetatable(clonedCrate, nil)
	local products: { { ProductId: string, Quantity: number } } = table.create(#gameProducts)
	for i, gameProduct: CrateGameProduct in gameProducts do
		local _ = i - 1
		products[i] = {
			["ProductId"] = gameProduct.ProductId,
			["Quantity"] = gameProduct.Crate.Quantity
		}
	end
	clonedCrate.Products = products
	crates[crateId] = clonedCrate
end
return {
	["CrateRewardResultType"] = CrateRewardResultType,
	["Crates"] = crates
}
