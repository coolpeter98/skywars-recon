-- Banner

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local useImageBackground =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-image-background").useImageBackground
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type ImageBackgroundConfig = {
	Rows: number,
	Columns: number,
	BackgroundSize: Vector2,
	ImageSize: {
		Min: Vector2,
		Max: Vector2,
	},
	Padding: number,
	Rotation: number,
}

type BannerImage = {
	Position: UDim2,
	Size: UDim2,
	Rotation: number,
	[string]: any,
}

type BannerProps = {
	Image: string,
	children: any?,
	[string]: any,
}

return {
	["Banner"] = function(props: BannerProps)
		local imageBackground = useImageBackground({
			Rows = 2,
			Columns = 15,
			Padding = 10,
			Rotation = 25,
			BackgroundSize = Vector2.new(760, 136),
			ImageSize = {
				Min = Vector2.new(36, 32),
				Max = Vector2.new(62, 54),
			},
		} :: ImageBackgroundConfig)
		local remainingProps = table.clone(props)
		setmetatable(remainingProps, nil)
		remainingProps.Image = nil
		remainingProps.children = nil
		local gridProps = {
			key = "Banner",
			ClipsDescendants = true,
		}
		for key, value in remainingProps do
			gridProps[key] = value
		end
		local children = props.children
		local images: { BannerImage } = imageBackground.Images
		local trophyImages = table.create(#images)
		for i, image in images do
			local _ = i - 1
			local imageProps = table.clone(image)
			setmetatable(imageProps, nil)
			imageProps.key = "Trophy"
			imageProps.AnchorPoint = Vector2.new(0.5, 0.5)
			imageProps.Image = props.Image
			imageProps.ImageTransparency = 0.8
			imageProps.ZIndex = 2
			trophyImages[i] = React.createElement(Image, imageProps)
		end
		return React.createElement(
			Grid,
			gridProps,
			children,
			trophyImages,
			React.createElement(CornerRadius, {
				Radius = 10,
			})
		)
	end,
}
