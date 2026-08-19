-- CosmeticUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ItemModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item")
local Items = ItemModule.Items
local ItemsByGroup = ItemModule.ItemsByGroup
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
return {
	["CosmeticUtil"] = {
		["isCosmeticId"] = function(cosmeticId: string): boolean
			return Cosmetics[cosmeticId] ~= nil
		end,
		["getCosmeticItem"] = function(cosmeticId: string, material: string)
			local cosmetic = Cosmetics[cosmeticId]
			local cosmeticType
			if cosmetic == nil then
				cosmeticType = cosmetic
			else
				cosmeticType = cosmetic.Type
			end
			if cosmeticType == "Skin" then
				if cosmetic.ItemGroup == ItemGroup.Bow then
					return Items.Bow
				else
					local items = ItemsByGroup[cosmetic.ItemGroup]
					if items ~= nil then
						local count = 0
						items = {}
						for index, item in items do
							local _ = index - 1
							if item.ItemMaterial == material == true then
								count = count + 1
								items[count] = item
							end
						end
					end
					if items and #items ~= 0 then
						return items[1]
					else
						return nil
					end
				end
			else
				return nil
			end
		end
	}
}
