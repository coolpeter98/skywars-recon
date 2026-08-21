-- PlayGameCard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline

return {
	["PlayGameCard"] = function(props: {
		GameModeName: string,
		Size: Vector2,
		Color: Color3,
		Activated: () -> (),
		BackgroundImage: string?,
		RenderedImage: string?,
	})
		local whiteGradient = React.createElement(Grid, {
			key = "WhiteGradient",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color.White,
			ZIndex = 0,
		}, React.createElement("uigradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4, 0),
				NumberSequenceKeypoint.new(1, 1, 0),
			}),
			Color = ColorSequence.new(Color.White),
		}), React.createElement(CornerRadius, {
			Radius = 20,
		}))

		local outlineFrame = React.createElement(Grid, {
			key = "OutlineFrame",
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.fromOffset(props.Size.X - 20, props.Size.Y - 20),
		}, React.createElement(Outline, {
			Thickness = 10,
		}, React.createElement("uigradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4, 0),
				NumberSequenceKeypoint.new(1, 1, 0),
			}),
			Color = ColorSequence.new(Color.White),
		})), React.createElement(CornerRadius, {
			Radius = 10,
		}))

		local interact = React.createElement(Grid, {
			key = "Interact",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 10,
			Selectable = true,
			Activated = props.Activated,
		})

		local textBackground = React.createElement(Grid, {
			key = "TextBackgroundClipping",
			ClipsDescendants = true,
			ZIndex = 5,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 10, 1, -10),
			Size = UDim2.fromOffset(props.Size.X - 20, 60),
		}, React.createElement(Grid, {
			key = "TextBackground",
			BackgroundTransparency = 0.6,
			ZIndex = 4,
			Position = UDim2.fromOffset(0, -10),
			Size = UDim2.fromOffset(props.Size.X - 20, 70),
			BackgroundColor3 = Color.Black,
		}, React.createElement("uigradient", {
			Rotation = 270,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1, 0),
			}),
			Color = ColorSequence.new(Color.Black),
		}), React.createElement(CornerRadius, {
			Radius = 10,
		})), React.createElement(Text, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Text = props.GameModeName,
			TextSize = 30,
			Bold = true,
			ZIndex = 5,
		}))

		local backgroundImage
		if props.BackgroundImage == nil then
			backgroundImage = nil
		else
			backgroundImage = React.createElement(Image, {
				key = "BackgroundImage",
				Size = UDim2.fromScale(1, 1),
				Image = props.BackgroundImage,
				ScaleType = Enum.ScaleType.Stretch,
				ZIndex = 1,
			}, React.createElement(CornerRadius, {
				Radius = 10,
			}))
		end

		return React.createElement(Grid, {
			key = props.GameModeName,
			Size = props.Size:ToUDim2(),
			BackgroundColor3 = props.Color,
			ZIndex = 2,
		}, whiteGradient, outlineFrame, interact, textBackground, React.createElement(Grid, {
			key = "Background",
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.fromOffset(props.Size.X - 20, props.Size.Y - 20),
		}, backgroundImage, React.createElement(Image, {
			key = "RenderImage",
			Size = UDim2.fromScale(1, 1),
			Image = props.RenderedImage,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 3,
		}, React.createElement(CornerRadius, {
			Radius = 10,
		})), React.createElement(CornerRadius, {
			Radius = 20,
		})), React.createElement(CornerRadius, {
			Radius = 20,
		}))
	end,
}
