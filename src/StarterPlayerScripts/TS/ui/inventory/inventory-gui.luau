-- InventoryGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CharacterViewport = RuntimeLib.import(script, script.Parent.Parent, "viewport", "character-viewport").CharacterViewport
local InventorySlot = RuntimeLib.import(script, script.Parent, "slot", "inventory-slot").InventorySlot
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local InventoryConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants")
local HOTBAR_SIZE = InventoryConstants.HOTBAR_SIZE
local INVENTORY_SIZE = InventoryConstants.INVENTORY_SIZE
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local ArmourType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").ArmourType
local ArmourSlot = RuntimeLib.import(script, script.Parent, "slot", "armour-slot").ArmourSlot
local Separator = RuntimeLib.import(script, script.Parent.Parent, "components", "separator").Separator
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type InventoryGuiProps = {
	LayoutOrder: number,
}

return {
	["InventoryGui"] = function(props: InventoryGuiProps)
		local inventoryStore = useGlobalStore("Inventory")
		local armourSlots = {}
		for _, armourType in ObjectUtils.values(ArmourType) do
			local slotId = armourType == ArmourType.Helmet and 0 or (armourType == ArmourType.Chestplate and 1 or 2)
			local itemInfo = Flamework.resolveDependency("JXb"):getItemInfoFromArmourType(armourType)
			if itemInfo then
				local armourSlot = React.createElement(ArmourSlot, {
					["SlotId"] = slotId,
					["Item"] = {
						["Type"] = nil,
						["Quantity"] = 1,
						["Type"] = itemInfo.Name
					}
				})
				table.insert(armourSlots, armourSlot)
			else
				local armourSlot = React.createElement(ArmourSlot, {
					["SlotId"] = slotId
				})
				table.insert(armourSlots, armourSlot)
			end
		end
		local inventorySlots = {}
		for i = 0, INVENTORY_SIZE - 1 do
			local slotId = i + HOTBAR_SIZE
			local inventorySlot = React.createElement(InventorySlot, {
				["SlotId"] = slotId,
				["Item"] = inventoryStore.Contents[slotId]
			})
			table.insert(inventorySlots, inventorySlot)
		end
		return React.createElement(Window, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(1040, 380),
			["LayoutOrder"] = props.LayoutOrder
		}, React.createElement(Grid, {
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.5,
			["Position"] = UDim2.fromOffset(30, 30),
			["Size"] = UDim2.fromOffset(210, 320)
		}, React.createElement(CharacterViewport), React.createElement(CornerRadius, {
			["Radius"] = 10
		})), React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(250, 30),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, armourSlots, React.createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Vertical,
			["SortOrder"] = Enum.SortOrder.LayoutOrder,
			["Padding"] = UDim.new(0, 10)
		})), React.createElement(Separator, {
			["Position"] = UDim2.fromOffset(410, 30),
			["Size"] = UDim2.fromOffset(4, 320)
		}), React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(470, 30),
			["Size"] = UDim2.fromOffset(540, 320)
		}, inventorySlots, React.createElement("uigridlayout", {
			["CellSize"] = nil,
			["CellPadding"] = nil,
			["FillDirection"] = nil,
			["FillDirectionMaxCells"] = 5,
			["SortOrder"] = nil,
			["CellSize"] = UDim2.fromOffset(100, 100),
			["CellPadding"] = UDim2.fromOffset(10, 10),
			["FillDirection"] = Enum.FillDirection.Horizontal,
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		})))
	end
}
