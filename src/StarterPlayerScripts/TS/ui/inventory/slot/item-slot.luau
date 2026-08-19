-- ItemSlot

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
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ItemViewport = RuntimeLib.import(script, script.Parent.Parent.Parent, "viewport", "item-viewport").ItemViewport
local Outline = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "outline").Outline
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ItemSlotProps = {
	SlotId: number,
	Item: { Type: string, Quantity: number }?,
	Text: string?,
	Outlined: boolean?,
	IsInventory: boolean?,
	OnInteract: () -> ()?,
	BackgroundColour3: Color3?,
	children: any?,
	[string]: any,
}

return {
	["ItemSlot"] = function(props: ItemSlotProps)
		local itemViewport
		if props.Item then
			itemViewport = React.createElement(ItemViewport, {
				["ItemType"] = props.Item.Type,
			})
		else
			itemViewport = nil
		end
		local quantityLabel
		if props.Item and props.Item.Quantity > 1 then
			quantityLabel = React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["Bold"] = true,
				["TextSize"] = 24,
				["AnchorPoint"] = Vector2.new(1, 1),
				["Position"] = UDim2.fromOffset(90, 90),
				["Text"] = ("%*"):format(props.Item.Quantity),
			})
		else
			quantityLabel = nil
		end
		local text = props.Text
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = nil,
			["Selectable"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["LayoutOrder"] = nil,
			["Activated"] = nil,
			["BackgroundColor3"] = nil,
		}
		local key
		if props.IsInventory == true then
			key = ("ItemSlot %*"):format(props.SlotId)
		else
			key = ("%*"):format(props.SlotId)
		end
		gridProps.key = key
		gridProps.Selectable = props.Item ~= nil
		gridProps.Size = UDim2.fromOffset(100, 100)
		gridProps.LayoutOrder = props.SlotId
		function gridProps.Activated()
			local onInteract = props.OnInteract
			if onInteract ~= nil then
				onInteract()
			end
			if props.Item then
				Flamework.resolveDependency("jL9"):playSound(RobloxSound.Inventory.MOVE_ITEM, {
					["Volume"] = 0.7,
				})
			end
		end
		gridProps.BackgroundColor3 = props.BackgroundColour3 or Color.Black
		local textLabel
		if text == "" or not text then
			textLabel = nil
		else
			textLabel = React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["Bold"] = true,
				["TextSize"] = 24,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromOffset(90, 6),
				["Text"] = ("%*"):format(props.Text),
			})
		end
		local children = props.children
		local outline
		if props.Outlined then
			outline = React.createElement(Outline, {
				["Thickness"] = 3,
			})
		else
			outline = nil
		end
		return createElement(
			grid,
			gridProps,
			itemViewport,
			quantityLabel,
			textLabel,
			children,
			outline,
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
