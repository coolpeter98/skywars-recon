-- ActionBarGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ActionBarItemModule = RuntimeLib.import(script, script.Parent, "action-bar-item")
local ACTION_BAR_FRAME_HEIGHT = ActionBarItemModule.ACTION_BAR_FRAME_HEIGHT
local ActionBarItem = ActionBarItemModule.ActionBarItem
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

type ActionBarGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

local function ActionBarGui(props: ActionBarGuiProps)
	local actionBarMap = useGlobalStore("ActionBarMap")
	local actionBarItems = ObjectUtils.values(actionBarMap)
	local removedIndex = 0
	local removedItems = {}
	for index, item in actionBarItems do
		local _ = index - 1
		if item.Removed == true then
			removedIndex = removedIndex + 1
			removedItems[removedIndex] = item
		end
	end
	local removedCount = #removedItems
	table.sort(actionBarItems, function(left, right)
		return left.StartTime < right.StartTime
	end)
	local visibleItems = {}
	for i = 1, #actionBarItems do
		local item = actionBarItems[i]
		if i - 1 < removedCount + 2 then
			table.insert(visibleItems, item)
		end
	end
	local slots = visibleItems
	local children = table.create(#slots)
	local function renderSlot(item, index: number)
		local indexFromBottom = #slots - index - 1
		local props = {
			["key"] = item.ActionBarId,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(0.5, 0, 0, (ACTION_BAR_FRAME_HEIGHT + 10) * indexFromBottom + ACTION_BAR_FRAME_HEIGHT / 2),
		}
		for key, value in item do
			props[key] = value
		end
		return React.createElement(ActionBarItem, props)
	end
	local slotsCopy = slots
	for index, item in slots do
		children[index] = renderSlot(item, index - 1, slotsCopy)
	end
	return React.createElement(Grid, {
		["key"] = "ActionBarGui",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = UDim2.fromOffset(400, ScreenUtil.getGridSize(40, 10, 2)),
	}, children)
end

return {
	["ActionBarGui"] = ActionBarGui,
}
