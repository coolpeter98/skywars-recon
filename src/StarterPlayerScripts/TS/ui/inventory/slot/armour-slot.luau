-- ArmourSlot

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ItemSlot = RuntimeLib.import(script, script.Parent, "item-slot").ItemSlot
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "events").Events

type ArmourSlotProps = {
	SlotId: number,
	Item: { Type: string, Quantity: number } | nil,
	OnInteract: (() -> ()) | nil,
}

return {
	["ArmourSlot"] = function(props: ArmourSlotProps)
		local newProps = table.clone(props)
		setmetatable(newProps, nil)

		function newProps.OnInteract()
			local item = props.Item
			if not item then
				return nil
			end
			Events["5b2f659e-3d54-4d54-b57a-0a4f043d196b"]:fire(item.Type)
		end

		return React.createElement(ItemSlot, newProps)
	end,
}
