-- HotbarSlot

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ItemSlot = RuntimeLib.import(script, script.Parent, "item-slot").ItemSlot
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "events").Events

type HotbarSlotProps = {
	SlotId: number,
	Item: { Type: string, Quantity: number }?,
	Active: boolean?,
	BackgroundColour3: Color3?,
}

return {
	["HotbarSlot"] = function(props: HotbarSlotProps)
		return React.createElement(ItemSlot, {
			["SlotId"] = nil,
			["Item"] = nil,
			["Text"] = nil,
			["Outlined"] = nil,
			["OnInteract"] = nil,
			["IsInventory"] = true,
			["BackgroundColour3"] = nil,
			["SlotId"] = props.SlotId,
			["Item"] = props.Item,
			["Text"] = ("%*"):format(props.SlotId + 1),
			["Outlined"] = props.Active,
			["OnInteract"] = function()
				local item = props.Item
				if item then
					local itemData = Items[item.Type]
					local chestController = Flamework.resolveDependency("4El")
					local inventoryController = Flamework.resolveDependency("qOA")
					local armourController = Flamework.resolveDependency("JXb")
					if chestController:isChestOpen() then
						chestController:updateChest(props.SlotId, item.Type, item.Quantity)
						return
					elseif
						itemData.Armour and not armourController:getItemInfoFromArmourType(itemData.Armour.ArmourType)
					then
						Events["4308b3fa-791a-4f62-ac35-6983a1eb78fa"]:fire(item.Type)
						return
					elseif inventoryController:isInventoryOpen() then
						inventoryController:moveItem(item.Type)
					else
						Flamework.resolveDependency("Dqk"):setActiveSlot(props.SlotId)
					end
				else
					Flamework.resolveDependency("Dqk"):setActiveSlot(props.SlotId)
					return nil
				end
			end,
			["BackgroundColour3"] = props.BackgroundColour3,
		})
	end,
}
