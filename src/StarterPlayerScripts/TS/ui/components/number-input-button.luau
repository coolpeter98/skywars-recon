-- NumberInputButton

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local useButton = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-button").useButton
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

export type NumberInputButtonProps = {
	Disabled: boolean?,
	Activated: (() -> ())?,
	Color: Color3,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	CornerRadius: UDim?,
	ImageRotation: number?,
}

return {
	["NumberInputButton"] = function(props: NumberInputButtonProps)
		local buttonState = useButton({
			["Disabled"] = props.Disabled,
			["Activated"] = props.Activated,
		})
		local color
		if props.Disabled then
			color = Color.Button.Grey.Primary
		else
			color = props.Color
		end
		if buttonState.Hovering then
			local hue, saturation, value = color:ToHSV()
			color = Color3.fromHSV(hue, saturation, value * 0.8)
		end
		local hue, saturation, value = color:ToHSV()
		local backgroundColor = Color3.fromHSV(hue, saturation, value * 0.8)
		local createElement = React.createElement
		local Grid = Grid
		local wrapperProps = {
			["key"] = "Wrapper",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Activated"] = nil,
			["Event"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(50, 50),
			["Activated"] = buttonState.Activated,
			["Event"] = {
				["MouseEnter"] = buttonState.MouseEnter,
				["MouseLeave"] = buttonState.MouseLeave,
			},
		}
		return createElement(
			Grid,
			wrapperProps,
			createElement(
				Grid,
				{
					["key"] = "Background",
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["CornerRadius"] = nil,
					["Size"] = UDim2.fromOffset(50, 50),
					["BackgroundColor3"] = backgroundColor,
					["CornerRadius"] = props.CornerRadius,
				},
				createElement(
					Grid,
					{
						["key"] = "Foreground",
						["Size"] = nil,
						["BackgroundColor3"] = nil,
						["CornerRadius"] = nil,
						["Size"] = UDim2.fromOffset(50, 46),
						["BackgroundColor3"] = color,
						["CornerRadius"] = props.CornerRadius,
					},
					createElement(Image, {
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.5),
						["Size"] = UDim2.fromOffset(32, 20),
						["Image"] = RobloxImage.Icon.DROPDOWN,
						["Rotation"] = props.ImageRotation,
					})
				)
			)
		)
	end,
}
