-- useImageBackground

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type ImageBackgroundProps = {
	BackgroundSize: Vector2,
	Padding: number,
	Columns: number,
	Rows: number,
	ImageSize: {
		Min: Vector2,
		Max: Vector2,
	},
	Rotation: number,
}

type BackgroundImage = {
	Position: UDim2,
	Size: UDim2,
	Rotation: number,
}

return {
	["useImageBackground"] = function(props: ImageBackgroundProps): { Images: { BackgroundImage } }
		local images: { BackgroundImage }, setImages = useState({})
		useEffect(function()
			local cellWidth = (props.BackgroundSize.X - props.Padding * 2) / props.Columns
			local cellHeight = (props.BackgroundSize.Y - props.Padding * 2) / props.Rows
			local randomOffset = math.random() > 0.5 and 0 or 1
			local firstRow = false
			local row = 0
			local generatedImages = {}
			do
				::nextRow::
				if firstRow then
					row = row + 1
				else
					firstRow = true
				end
				if row >= props.Rows then
					setImages(generatedImages)
					return
				end
				local column = randomOffset % 2
				local firstColumn = false
				while true do
					if true then
						if firstColumn then
							column = column + 2
						else
							firstColumn = true
						end
					end
					if column >= props.Columns then
						break
					end
					local imageWidth = MathUtil.random(props.ImageSize.Min.X, props.ImageSize.Max.X)
					local imageHeight = MathUtil.random(props.ImageSize.Min.Y, props.ImageSize.Max.Y)
					local image = {
						["Position"] = UDim2.fromOffset(
							cellWidth * column + props.Padding + props.ImageSize.Max.X / 2,
							cellHeight * row + props.Padding + props.ImageSize.Max.Y / 2
						),
						["Size"] = UDim2.fromOffset(imageWidth, imageHeight),
						["Rotation"] = MathUtil.random(-props.Rotation, props.Rotation),
					}
					table.insert(generatedImages, image)
				end
				randomOffset = randomOffset + 1
				goto nextRow
			end
		end, {})
		return {
			["Images"] = images,
		}
	end,
}
