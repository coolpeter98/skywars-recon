-- HotbarGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local HotbarSlot = RuntimeLib.import(script, script.Parent.Parent, "inventory", "slot", "hotbar-slot").HotbarSlot
local HOTBAR_SIZE = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants").HOTBAR_SIZE
local OpenInventorySlot = RuntimeLib.import(script, script.Parent.Parent, "inventory", "slot", "open-inventory-slot").OpenInventorySlot
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type Props = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	AutomaticSize: Enum.AutomaticSize?,
}

return {
	["HotbarGui"] = function(props: Props)
		local inventory = useGlobalStore("Inventory")
		local activeSlot = useGlobalStore("ActiveSlot")
		local children = {}
		for slotIndex = 0, HOTBAR_SIZE - 1 do
			local slotProps = {
				["SlotId"] = slotIndex,
				["Item"] = inventory.Contents[slotIndex],
				["Active"] = slotIndex == activeSlot
			}
			local slotElement = React.createElement(HotbarSlot, slotProps)
			table.insert(children, slotElement)
		end
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["Active"] = true,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, children, React.createElement(OpenInventorySlot), React.createElement(List, {
			["VerticalAlignment"] = Enum.VerticalAlignment.Top
		}))
	end,
}
