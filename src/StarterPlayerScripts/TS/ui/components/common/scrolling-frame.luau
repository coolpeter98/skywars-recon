-- ScrollingFrame

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local omit = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "object", "omit").omit
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local RoactUtil = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "util", "roact-util").RoactUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

type Props = {
	CanvasWidth: number,
	CanvasHeight: number,
	ListLayout: { [string]: any }?,
	GridLayout: { [string]: any }?,
	Ref: any?,
	FrameRef: any?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	ScrollBarThickness: number?,
	ZIndex: number?,
	children: any?,
}

return {
	["ScrollingFrame"] = function(props: Props)
		local cameraViewportContext: { Scale: number } = useContext(CameraViewportContext)
		local scrollProps = omit(
			omit(props, {
				"CanvasWidth",
				"CanvasHeight",
				"ListLayout",
				"GridLayout",
				"Ref",
				"FrameRef",
				"AnchorPoint",
				"Position",
			}),
			{ "children", "Size" }
		)
		local scrollBarThickness = RoactUtil.getBinding(scrollProps.ScrollBarThickness)
		local scrollBarThicknessValue = scrollBarThickness == nil and 20 or scrollBarThickness
		local zIndex = RoactUtil.getBinding(scrollProps.ZIndex)
		local zIndexValue = zIndex == nil and 1 or zIndex
		local scaledScrollBarThickness = scrollBarThicknessValue * cameraViewportContext.Scale
		local roundedScrollBarThickness = math.round(scaledScrollBarThickness)
		local adjustedScrollBarThickness = 1 / cameraViewportContext.Scale * roundedScrollBarThickness
		local scrollingFrameProps = {
			["key"] = "ScrollingFrame",
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = nil,
			["ScrollBarImageColor3"] = nil,
			["ScrollBarImageTransparency"] = 0,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["Size"] = UDim2.fromScale(1, 1),
			["CanvasSize"] = UDim2.fromOffset(props.CanvasWidth, props.CanvasHeight),
			["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			["ScrollBarThickness"] = adjustedScrollBarThickness,
			["ScrollBarImageColor3"] = Color.White,
		}
		for key, value in scrollProps do
			scrollingFrameProps[key] = value
		end
		scrollingFrameProps.ZIndex = zIndexValue + 1
		scrollingFrameProps.ref = props.Ref
		local children = props.children
		local listLayoutElement
		if props.ListLayout then
			local listLayoutProps = {
				["Padding"] = UDim.new(0, 10),
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			}
			for key, value in props.ListLayout do
				listLayoutProps[key] = value
			end
			listLayoutElement = React.createElement("uilistlayout", listLayoutProps)
		else
			listLayoutElement = nil
		end
		local gridLayoutElement
		if props.GridLayout then
			local gridLayoutProps = {
				["CellPadding"] = UDim2.fromOffset(10, 10),
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			}
			for key, value in props.GridLayout do
				gridLayoutProps[key] = value
			end
			gridLayoutElement = React.createElement("uigridlayout", gridLayoutProps)
		else
			gridLayoutElement = nil
		end
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Ref"] = nil,
			["Selectable"] = false,
			["ZIndex"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["Ref"] = props.FrameRef,
			["ZIndex"] = zIndexValue,
		}, React.createElement("scrollingframe", scrollingFrameProps, children, listLayoutElement, gridLayoutElement))
	end,
}
