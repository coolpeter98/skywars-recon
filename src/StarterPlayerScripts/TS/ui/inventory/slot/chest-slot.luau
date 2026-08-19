-- ChestSlot

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

return {
	["ChestSlot"] = function(props)
		local newProps = table.clone(props)
		setmetatable(newProps, nil)

		function newProps.OnInteract()
			local item = props.Item
			if not item then
				return nil
			end
			Flamework.resolveDependency("4El"):updateChest(props.SlotId, item.Type, -item.Quantity)
		end

		return React.createElement(ItemSlot, newProps)
	end,
}
