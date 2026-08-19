-- Grid

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BaseGrid = RuntimeLib.import(script, script.Parent, "base-grid").BaseGrid
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local RoactUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "roact-util").RoactUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type GridProps = {
	TitleText: string?,
	TitleTextSize: number?,
	TitleImage: string?,
	TitleImageSize: number?,
	TitleAnchorPoint: Vector2?,
	TitlePosition: UDim2?,
	CornerRadius: number | { [string]: number }?,
	children: any?,
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	ZIndex: number?,
	[string]: any,
}

local getCornerRadius = nil
local function Grid(props: GridProps)
	local restProps = table.clone(props)
	setmetatable(restProps, nil)
	restProps.children = nil
	restProps.CornerRadius = nil
	local titleImageSize: number? = props.TitleImageSize
	local titleSize: number = titleImageSize == nil and 20 or titleImageSize
	local topLeftRadius: number = getCornerRadius(props.CornerRadius, "TopLeft")
	local topRightRadius: number = getCornerRadius(props.CornerRadius, "TopRight")
	local bottomLeftRadius: number = getCornerRadius(props.CornerRadius, "BottomLeft")
	local bottomRightRadius: number = getCornerRadius(props.CornerRadius, "BottomRight")
	local size: UDim2 = RoactUtil.getBinding(props.Size) or UDim2.new()
	local topLeftFromOffset = UDim2.fromOffset
	local topLeftHalfWidth: number = size.X.Offset / 2
	local topLeftX: number = math.floor(topLeftHalfWidth)
	local topLeftHalfHeight: number = size.Y.Offset / 2
	local topLeftSize: UDim2 = topLeftFromOffset(topLeftX, math.ceil(topLeftHalfHeight))
	local topRightFromOffset = UDim2.fromOffset
	local topRightHalfWidth: number = size.X.Offset / 2
	local topRightX: number = math.ceil(topRightHalfWidth)
	local topRightHalfHeight: number = size.Y.Offset / 2
	local topRightSize: UDim2 = topRightFromOffset(topRightX, math.ceil(topRightHalfHeight))
	local bottomLeftFromOffset = UDim2.fromOffset
	local bottomLeftHalfWidth: number = size.X.Offset / 2
	local bottomLeftX: number = math.floor(bottomLeftHalfWidth)
	local bottomLeftHalfHeight: number = size.Y.Offset / 2
	local bottomLeftSize: UDim2 = bottomLeftFromOffset(bottomLeftX, math.floor(bottomLeftHalfHeight))
	local bottomRightFromOffset = UDim2.fromOffset
	local bottomRightHalfWidth: number = size.X.Offset / 2
	local bottomRightX: number = math.ceil(bottomRightHalfWidth)
	local bottomRightHalfHeight: number = size.Y.Offset / 2
	local bottomRightSize: UDim2 = bottomRightFromOffset(bottomRightX, math.floor(bottomRightHalfHeight))
	local hasCornerRadius = props.CornerRadius
	if hasCornerRadius ~= 0 and (hasCornerRadius == hasCornerRadius and hasCornerRadius) then
		local cornerRadius = props.CornerRadius
		local isNumber = type(cornerRadius) == "number"
		hasCornerRadius = not isNumber
	end
	local gridProps = table.clone(restProps)
	setmetatable(gridProps, nil)
	gridProps.BackgroundTransparency = hasCornerRadius ~= 0
			and (hasCornerRadius == hasCornerRadius and hasCornerRadius)
			and 1
		or props.BackgroundTransparency
	local corners
	if hasCornerRadius == 0 or (hasCornerRadius ~= hasCornerRadius or not hasCornerRadius) then
		corners = nil
	else
		local topLeftProps = {
			["key"] = "TopLeft",
			["Size"] = topLeftSize + UDim2.fromOffset(topLeftRadius, topLeftRadius),
			["BackgroundColor3"] = restProps.BackgroundColor3,
			["BackgroundTransparency"] = restProps.BackgroundTransparency,
			["ZIndex"] = restProps.ZIndex,
		}
		local topLeftClipping = React.createElement(
			BaseGrid,
			{
				["key"] = "TopLeftClipping",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Size"] = topLeftSize,
			},
			React.createElement(
				BaseGrid,
				topLeftProps,
				React.createElement(CornerRadius, {
					["Radius"] = topLeftRadius,
				})
			)
		)
		local topRightProps = {
			["key"] = "TopRight",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.fromScale(1, 0),
			["Size"] = topRightSize + UDim2.fromOffset(topRightRadius, topRightRadius),
			["BackgroundColor3"] = restProps.BackgroundColor3,
			["BackgroundTransparency"] = restProps.BackgroundTransparency,
			["ZIndex"] = restProps.ZIndex,
		}
		local topRightClipping = React.createElement(
			BaseGrid,
			{
				["key"] = "TopRightClipping",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["Size"] = topRightSize,
			},
			React.createElement(
				BaseGrid,
				topRightProps,
				React.createElement(CornerRadius, {
					["Radius"] = topRightRadius,
				})
			)
		)
		local bottomLeftProps = {
			["key"] = "BottomLeft",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AnchorPoint"] = Vector2.new(0, 1),
			["Position"] = UDim2.fromScale(0, 1),
			["Size"] = bottomLeftSize + UDim2.fromOffset(bottomLeftRadius, bottomLeftRadius),
			["BackgroundColor3"] = restProps.BackgroundColor3,
			["BackgroundTransparency"] = restProps.BackgroundTransparency,
			["ZIndex"] = restProps.ZIndex,
		}
		local bottomLeftClipping = React.createElement(
			BaseGrid,
			{
				["key"] = "BottomLeftClipping",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["AnchorPoint"] = Vector2.new(0, 1),
				["Position"] = UDim2.fromScale(0, 1),
				["Size"] = bottomLeftSize,
			},
			React.createElement(
				BaseGrid,
				bottomLeftProps,
				React.createElement(CornerRadius, {
					["Radius"] = bottomLeftRadius,
				})
			)
		)
		local bottomRightProps = {
			["key"] = "BottomRight",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AnchorPoint"] = Vector2.new(1, 1),
			["Position"] = UDim2.fromScale(1, 1),
			["Size"] = bottomRightSize + UDim2.fromOffset(bottomRightRadius, bottomRightRadius),
			["BackgroundColor3"] = restProps.BackgroundColor3,
			["BackgroundTransparency"] = restProps.BackgroundTransparency,
			["ZIndex"] = restProps.ZIndex,
		}
		corners = React.createElement(
			BaseGrid,
			{
				["key"] = "CornerRadius",
				["Size"] = nil,
				["Size"] = size,
			},
			topLeftClipping,
			topRightClipping,
			bottomLeftClipping,
			React.createElement(
				BaseGrid,
				{
					["key"] = "BottomRightClipping",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ClipsDescendants"] = true,
					["AnchorPoint"] = Vector2.new(1, 1),
					["Position"] = UDim2.fromScale(1, 1),
					["Size"] = bottomRightSize,
				},
				React.createElement(
					BaseGrid,
					bottomRightProps,
					React.createElement(CornerRadius, {
						["Radius"] = bottomRightRadius,
					})
				)
			)
		)
	end
	local titleImage = props.TitleText
	if titleImage ~= "" and titleImage then
		titleImage = props.TitleImage
	end
	local title
	if titleImage == "" or not titleImage then
		title = nil
	else
		local titleImageElement = React.createElement(Image, {
			["Size"] = UDim2.fromOffset(titleSize, titleSize),
			["Image"] = props.TitleImage,
		})
		local titleTextProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, titleSize + 10, 0.5, 0),
			["Text"] = props.TitleText,
		}
		local titleTextSize: number? = props.TitleTextSize
		titleTextProps.TextSize = titleTextSize == nil and 20 or titleTextSize
		title = React.createElement(BaseGrid, {
			["AnchorPoint"] = props.TitleAnchorPoint,
			["Position"] = props.TitlePosition or UDim2.fromOffset(30, 20),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}, titleImageElement, React.createElement(Text, titleTextProps))
	end
	local children = props.children
	local cornerRadiusIsNumber = props.CornerRadius
	if cornerRadiusIsNumber ~= 0 and (cornerRadiusIsNumber == cornerRadiusIsNumber and cornerRadiusIsNumber) then
		local cornerRadius = props.CornerRadius
		cornerRadiusIsNumber = type(cornerRadius) == "number"
	end
	local createElement = React.createElement
	local baseGrid = BaseGrid
	local cornerRadiusElement
	if cornerRadiusIsNumber == 0 or (cornerRadiusIsNumber ~= cornerRadiusIsNumber or not cornerRadiusIsNumber) then
		cornerRadiusElement = nil
	else
		cornerRadiusElement = React.createElement(CornerRadius, {
			["Radius"] = props.CornerRadius,
		})
	end
	return createElement(baseGrid, gridProps, corners, title, children, cornerRadiusElement)
end
getCornerRadius = function(cornerRadius: number | { [string]: number } | nil, corner: string): number
	if type(cornerRadius) ~= "number" then
		if cornerRadius ~= nil then
			cornerRadius = cornerRadius[corner]
		end
	end
	return cornerRadius == nil and 0 or cornerRadius
end
return {
	["Grid"] = Grid,
}
