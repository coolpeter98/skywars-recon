-- AlertCircle

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type AlertCircleProps = {
	TextBackgroundWidth: number,
	Color: Color3,
	Icon: string,
}

return {
	["AlertCircle"] = function(props: AlertCircleProps)
		local rightCircleWidth = 100 - (80 + props.TextBackgroundWidth)
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
		local leftCircle = createElement(
			Grid,
			{
				["key"] = "LeftCircleClipping",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Size"] = UDim2.fromOffset(80, 100),
			},
			createElement(
				Grid,
				{
					["key"] = "CircleBackground",
					["Size"] = nil,
					["BackgroundTransparency"] = 0.6,
					["Size"] = UDim2.fromOffset(100, 100),
				},
				createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				})
			)
		)
		local rightCircle
		if props.TextBackgroundWidth < 20 then
			rightCircle = createElement(
				Grid,
				{
					["key"] = "RightCircleClipping",
					["Position"] = nil,
					["Size"] = nil,
					["ClipsDescendants"] = true,
					["Position"] = UDim2.new(0, 80 + props.TextBackgroundWidth, 0, 0),
					["Size"] = UDim2.fromOffset(rightCircleWidth, 100),
				},
				createElement(
					Grid,
					{
						["key"] = "CircleBackground",
						["Position"] = nil,
						["Size"] = nil,
						["BackgroundTransparency"] = 0.6,
						["Position"] = UDim2.fromOffset(-(80 + props.TextBackgroundWidth)),
						["Size"] = UDim2.fromOffset(100, 100),
					},
					createElement("uicorner", {
						["CornerRadius"] = UDim.new(1),
					})
				)
			)
		else
			rightCircle = nil
		end
		local createElement = React.createElement
		local Grid = Grid
		local redCircleProps = {
			["key"] = "RedCircleBackground",
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["ZIndex"] = 2,
			["Position"] = UDim2.fromOffset(10, 10),
			["Size"] = UDim2.fromOffset(80, 80),
			["BackgroundColor3"] = props.Color,
		}
		local createElement = React.createElement
		local Image = Image
		local iconProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = 10,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(props.Icon == "" and 16 or 60, 60),
		}
		local iconImage
		if props.Icon == "" then
			iconImage = RobloxImage.Icon.EXCLAMATION
		else
			iconImage = props.Icon
		end
		iconProps.Image = iconImage
		return createElement(
			Fragment,
			fragmentProps,
			leftCircle,
			rightCircle,
			createElement(
				Grid,
				redCircleProps,
				createElement(
					Image,
					iconProps,
					createElement("uicorner", {
						["CornerRadius"] = UDim.new(1),
					})
				)
			)
		)
	end,
}
