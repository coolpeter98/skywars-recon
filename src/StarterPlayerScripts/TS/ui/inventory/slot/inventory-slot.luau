-- InventorySlot

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "events").Events
local ItemSlot = RuntimeLib.import(script, script.Parent, "item-slot").ItemSlot
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items

return {
	["InventorySlot"] = function(props)
		local newProps = table.clone(props)
		setmetatable(newProps, nil)

		function newProps.OnInteract()
			local item = props.Item
			if item then
				local itemData = Items[item.Type]
				local chestController = Flamework.resolveDependency("4El")
				local armourController = Flamework.resolveDependency("JXb")
				if chestController:isChestOpen() then
					chestController:updateChest(props.SlotId, item.Type, item.Quantity)
					return
				elseif itemData.Armour and not armourController:getItemInfoFromArmourType(itemData.Armour.ArmourType) then
					Events["4308b3fa-791a-4f62-ac35-6983a1eb78fa"]:fire(item.Type)
				else
					Flamework.resolveDependency("qOA"):moveItem(item.Type)
				end
			else
				return nil
			end
		end

		newProps.IsInventory = true

		return React.createElement(ItemSlot, newProps)
	end,
}
