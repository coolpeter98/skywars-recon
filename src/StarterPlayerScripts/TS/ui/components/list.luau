-- List

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ListProps = {
	Vertical: boolean?,
	Offset: number?,
}

return {
	["List"] = function(props: ListProps)
		local newProps = table.clone(props)
		setmetatable(newProps, nil)
		newProps.Vertical = nil
		newProps.Offset = nil

		local layoutProps = {
			["key"] = "UIListLayout",
			["FillDirection"] = nil,
		}

		local fillDirection
		if props.Vertical then
			fillDirection = Enum.FillDirection.Vertical
		else
			fillDirection = Enum.FillDirection.Horizontal
		end
		layoutProps.FillDirection = fillDirection

		local offset = props.Offset
		local padding = offset == nil and 10 or offset
		layoutProps.Padding = UDim.new(0, padding)
		layoutProps.SortOrder = Enum.SortOrder.LayoutOrder
		layoutProps.VerticalAlignment = Enum.VerticalAlignment.Center
		layoutProps.HorizontalAlignment = Enum.HorizontalAlignment.Center

		for propName, propValue in newProps do
			layoutProps[propName] = propValue
		end

		return React.createElement("uilistlayout", layoutProps)
	end,
}
