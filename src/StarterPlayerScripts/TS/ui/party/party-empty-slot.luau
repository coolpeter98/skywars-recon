-- PartyEmptySlot

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius

type PartyEmptySlotProps = {
	LayoutOrder: number?,
}

return {
	["PartyEmptySlot"] = function(props: PartyEmptySlotProps)
		return React.createElement(
			Grid,
			{
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["LayoutOrder"] = nil,
				["Size"] = UDim2.fromOffset(260, 112),
				["LayoutOrder"] = props.LayoutOrder,
			},
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
