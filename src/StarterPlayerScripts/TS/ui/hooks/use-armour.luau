-- useArmour

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local useAttribute = RuntimeLib.import(script, script.Parent, "use-attribute").useAttribute
local ItemModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item")
local ArmourType = ItemModule.ArmourType
local Items = ItemModule.Items
return {
	["useArmour"] = function(player: Player): number
		local helmetItemId = useAttribute(player, ArmourType.Helmet)
		local chestplateItemId = useAttribute(player, ArmourType.Chestplate)
		local leggingsItemId = useAttribute(player, ArmourType.Leggings)
		local helmetMitigation
		if helmetItemId then
			local helmetItem = Items[helmetItemId]
			local helmetArmour
			if helmetItem == nil then
				helmetArmour = helmetItem
			else
				helmetArmour = helmetItem.Armour
			end
			helmetMitigation = not helmetArmour and 0 or helmetItem.Armour.DamageMitigation
		else
			helmetMitigation = 0
		end
		local chestplateMitigation
		if chestplateItemId then
			local chestplateItem = Items[chestplateItemId]
			local chestplateArmour
			if chestplateItem == nil then
				chestplateArmour = chestplateItem
			else
				chestplateArmour = chestplateItem.Armour
			end
			chestplateMitigation = not chestplateArmour and 0 or chestplateItem.Armour.DamageMitigation
		else
			chestplateMitigation = 0
		end
		local totalMitigation = helmetMitigation + chestplateMitigation
		local leggingsMitigation
		if leggingsItemId then
			local leggingsItem = Items[leggingsItemId]
			local leggingsArmour
			if leggingsItem == nil then
				leggingsArmour = leggingsItem
			else
				leggingsArmour = leggingsItem.Armour
			end
			leggingsMitigation = not leggingsArmour and 0 or leggingsItem.Armour.DamageMitigation
		else
			leggingsMitigation = 0
		end
		return totalMitigation + leggingsMitigation
	end,
}
