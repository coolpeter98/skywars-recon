-- ChestGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local InventoryGui = RuntimeLib.import(script, script.Parent.Parent, "inventory", "inventory-gui").InventoryGui
local ChestSlot = RuntimeLib.import(script, script.Parent.Parent, "inventory", "slot", "chest-slot").ChestSlot
local CHEST_SIZE: number =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants").CHEST_SIZE
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
return {
	["ChestGui"] = function(_)
		local store = useGlobalStore("Chest")
		local viewportContext = useContext(CameraViewportContext)
		local slotElements = {}
		for slotIndex = 0, CHEST_SIZE - 1 do
			local slotProps = {
				["SlotId"] = slotIndex,
			}
			local item
			if store == nil then
				item = store
			else
				item = store.Contents[slotIndex]
			end
			slotProps.Item = item
			local slotElement = React.createElement(ChestSlot, slotProps)
			table.insert(slotElements, slotElement)
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.new(
					0.5,
					0,
					0.5,
					not ScreenUtil.isMobile() and -115 or -115 * viewportContext.Scale
				),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(
				Window,
				{
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["LayoutOrder"] = 1,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(1040, 270),
				},
				React.createElement(
					Grid,
					{
						["Position"] = UDim2.fromOffset(30, 30),
						["Size"] = UDim2.fromOffset(980, 210),
					},
					slotElements,
					React.createElement("uigridlayout", {
						["CellSize"] = nil,
						["CellPadding"] = nil,
						["FillDirection"] = nil,
						["FillDirectionMaxCells"] = 9,
						["SortOrder"] = nil,
						["CellSize"] = UDim2.fromOffset(100, 100),
						["CellPadding"] = UDim2.fromOffset(10, 10),
						["FillDirection"] = Enum.FillDirection.Horizontal,
						["SortOrder"] = Enum.SortOrder.LayoutOrder,
					})
				)
			),
			React.createElement(InventoryGui, {
				["LayoutOrder"] = 2,
			}),
			React.createElement("uilistlayout", {
				["Padding"] = UDim.new(0, not ScreenUtil.isMobile() and 30 or 30 * viewportContext.Scale),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["FillDirection"] = Enum.FillDirection.Vertical,
			})
		)
	end,
}
