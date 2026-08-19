-- GameShopPrefab

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ShopType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "shop", "game-shop").ShopType
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation

local shopPrefabs = {}
local blacksmithShop = {
	["Type"] = ShopType.Blacksmith,
	["Prefab"] = {
		["Prefab"] = nil,
		["Offset"] = nil,
		["Rigged"] = true,
		["IdleAnimation"] = nil,
		["RandomAnimations"] = nil,
		["Prefab"] = ReplicatedStorage.Prefab.Blacksmith,
		["Offset"] = CFrame.new(-4.5, 0, 8),
		["IdleAnimation"] = RobloxAnimation.BLACKSMITH_IDLE,
		["RandomAnimations"] = { RobloxAnimation.BLACKSMITH_ACTION_ONE, RobloxAnimation.BLACKSMITH_ACTION_TWO },
	},
	["ScenePrefabs"] = {
		{
			["Prefab"] = ReplicatedStorage.Prefab.BlacksmithHouse,
			["Offset"] = CFrame.new(),
		},
	},
}
local merchantShop = {
	["Type"] = ShopType.Merchant,
	["Prefab"] = {
		["Prefab"] = nil,
		["Rigged"] = true,
		["Offset"] = nil,
		["IdleAnimation"] = nil,
		["RandomAnimations"] = nil,
		["Prefab"] = ReplicatedStorage.Prefab.Wizard,
		["Offset"] = CFrame.new(8, 0, 4),
		["IdleAnimation"] = RobloxAnimation.WIZARD_IDLE,
		["RandomAnimations"] = { RobloxAnimation.WIZARD_ACTION_ONE, RobloxAnimation.WIZARD_ACTION_TWO },
	},
	["ScenePrefabs"] = {
		{
			["Prefab"] = ReplicatedStorage.Prefab.MerchantCart,
			["Offset"] = CFrame.new(0, -1.31, 0),
		},
		{
			["Prefab"] = nil,
			["Rigged"] = true,
			["Offset"] = nil,
			["IdleAnimation"] = nil,
			["Prefab"] = ReplicatedStorage.Prefab.WizardDog,
			["Offset"] = CFrame.new(-6, 3, 5),
			["IdleAnimation"] = RobloxAnimation.WIZARD_DOG_IDLE,
		},
	},
}
-- Decompiler helper (definition was lost during the rename pass; restored for correctness)
local function __set_list(list: { any }, startIndex: number, values: { any })
	for i = 1, #values do
		list[startIndex + i - 1] = values[i]
	end
end

__set_list(shopPrefabs, 1, { blacksmithShop, merchantShop })
local shopPrefabMap = {}
for _, shopPrefab in shopPrefabs do
	shopPrefabMap[shopPrefab.Type] = shopPrefab
end
return {
	["ShopPrefabs"] = shopPrefabMap,
}
