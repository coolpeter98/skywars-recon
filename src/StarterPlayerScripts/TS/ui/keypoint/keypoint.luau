-- Keypoint

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext

type Props = {
	MarkerSetup: {
		Color: Color3,
		HideBackground: boolean,
		Image: string?,
	},
}

return {
	["Keypoint"] = function(props: Props)
		local outerGridProps = {
			["Size"] = UDim2.fromOffset(50, 50),
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
		}
		local viewportProps = {
			["value"] = {
				["Scale"] = 1,
				["AspectRatio"] = 1.7777777777777777,
				["ViewportSize"] = nil,
				["ViewportSize"] = Vector2.new(1920, 1080),
			},
		}
		local innerGridProps = {
			["key"] = "Keypoint",
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = nil,
			["Position"] = nil,
			["AnchorPoint"] = nil,
			["Size"] = UDim2.fromOffset(100, 100),
			["BackgroundColor3"] = props.MarkerSetup.Color,
			["BackgroundTransparency"] = props.MarkerSetup.HideBackground and 1 or 0.5,
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
		}
		local imageElement
		if props.MarkerSetup.Image == nil then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ImageTransparency"] = 0.5,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(75, 75),
				["Image"] = props.MarkerSetup.Image,
			})
		end
		return React.createElement(
			Grid,
			outerGridProps,
			React.createElement(
				CameraViewportContext.Provider,
				viewportProps,
				React.createElement(
					Grid,
					innerGridProps,
					imageElement,
					React.createElement(Outline, {
						["Thickness"] = 3,
						["Transparency"] = nil,
						["Transparency"] = props.MarkerSetup.HideBackground and 1 or 0.5,
					}),
					React.createElement("uicorner", {
						["CornerRadius"] = UDim.new(1, 0),
					}),
					React.createElement("uiscale", {
						["Scale"] = 0.55,
					})
				)
			)
		)
	end,
}
