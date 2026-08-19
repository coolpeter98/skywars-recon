-- Image

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RoactUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "roact-util").RoactUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["Image"] = function(props)
		local clonedProps = table.clone(props)
		setmetatable(clonedProps, nil)
		clonedProps.DropShadow = nil
		clonedProps.children = nil
		clonedProps.Ref = nil

		local positionBinding = RoactUtil.getBinding(props.Position)
		local imageLabelProps = {}
		local name = props.Name
		imageLabelProps.key = name == nil and "ImageLabel" or name
		imageLabelProps.BackgroundTransparency = 1
		imageLabelProps.BorderSizePixel = 0
		imageLabelProps.ScaleType = Enum.ScaleType.Fit
		imageLabelProps.ref = props.Ref
		for propName, propValue in clonedProps do
			imageLabelProps[propName] = propValue
		end

		local imageElement = React.createElement("imagelabel", imageLabelProps, props.children)
		local shadowElement
		if props.DropShadow then
			local shadowProps = {
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["ScaleType"] = nil,
				["ScaleType"] = Enum.ScaleType.Fit,
			}
			for propName, propValue in clonedProps do
				shadowProps[propName] = propValue
			end
			shadowProps.Position = (positionBinding or UDim2.new()) + UDim2.fromOffset(props.DropShadow.X, props.DropShadow.Y)
			shadowProps.ImageColor3 = Color.Black
			local imageTransparency = props.ImageTransparency
			shadowProps.ImageTransparency = 0.75 + (imageTransparency == nil and 0 or imageTransparency) * 0.25
			local zIndex = props.ZIndex
			shadowProps.ZIndex = (zIndex == nil and 1 or zIndex) - 1
			shadowElement = React.createElement("imagelabel", shadowProps)
		else
			shadowElement = nil
		end

		return React.createElement(React.Fragment, nil, imageElement, shadowElement)
	end,
}
