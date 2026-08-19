-- LoadingGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Workspace: Workspace = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local ProgressBarNew = RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local CameraViewportContext = RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local CircularProgress = RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useEffect = React.useEffect
local useState = React.useState

local BACKGROUND_SEGMENTS = {
	["Resolution"] = nil,
	["SegmentsSize"] = nil,
	["Segments"] = nil,
	["AlwaysShownHeight"] = 1280,
	["Resolution"] = Vector2.new(5120, 3072),
	["SegmentsSize"] = Vector2.new(5, 3),
	["Segments"] = {
		[Vector3.new(0, 0, 0)] = "rbxassetid://10118473706",
		[Vector3.new(1, 0, 0)] = "rbxassetid://10118473443",
		[Vector3.new(2, 0, 0)] = "rbxassetid://10118473136",
		[Vector3.new(3, 0, 0)] = "rbxassetid://10118472792",
		[Vector3.new(4, 0, 0)] = "rbxassetid://10118472296",
		[Vector3.new(0, 1, 0)] = "rbxassetid://10118471985",
		[Vector3.new(1, 1, 0)] = "rbxassetid://10118471799",
		[Vector3.new(2, 1, 0)] = "rbxassetid://10118471536",
		[Vector3.new(3, 1, 0)] = "rbxassetid://10118471244",
		[Vector3.new(4, 1, 0)] = "rbxassetid://10118470993",
		[Vector3.new(0, 2, 0)] = "rbxassetid://10118470738",
		[Vector3.new(1, 2, 0)] = "rbxassetid://10118470505",
		[Vector3.new(2, 2, 0)] = "rbxassetid://10118673558",
		[Vector3.new(3, 2, 0)] = "rbxassetid://10118469869",
		[Vector3.new(4, 2, 0)] = "rbxassetid://10118469572"
	}
}

return {
	["LoadingGui"] = function()
		local scale = useContext(CameraViewportContext).Scale / (ScreenUtil.isMobile() and 1.35 or 1)
		local segments, setSegments = useState({})
		useEffect(function()
			local viewportSize = Workspace.CurrentCamera.ViewportSize
			local segmentSize = BACKGROUND_SEGMENTS.Resolution / BACKGROUND_SEGMENTS.SegmentsSize
			local heightRatio = viewportSize.Y / BACKGROUND_SEGMENTS.AlwaysShownHeight
			local scaleFactor = math.min(heightRatio, 1)
			local visibleSegments = {}
			for segment, assetId in BACKGROUND_SEGMENTS.Segments do
				local viewportCenter = viewportSize / 2
				local vector2New = Vector2.new
				local centerX = viewportCenter.X
				local flooredCenterX = math.floor(centerX)
				local centerY = viewportCenter.Y
				local flooredCenter = vector2New(flooredCenterX, (math.floor(centerY)))
				local scaledSegmentSize = segmentSize * scaleFactor
				local segmentCoords = Vector2.new(segment.X, segment.Y)
				local scaledHalfResolution = BACKGROUND_SEGMENTS.Resolution / 2 * scaleFactor
				local segmentPosition = scaledSegmentSize * segmentCoords - scaledHalfResolution + flooredCenter
				local segmentEnd = segmentPosition + segmentSize * scaleFactor
				if segmentEnd.X > 0 and (segmentEnd.Y > 0 and (segmentPosition.X < viewportSize.X and segmentPosition.Y < viewportSize.Y)) then
					local segmentProps = {
						["Image"] = assetId
					}
					local fromOffsetSize = UDim2.fromOffset
					local segmentWidth = segmentSize.X * scaleFactor
					local ceilSegmentWidth = math.ceil(segmentWidth)
					local segmentHeight = segmentSize.Y * scaleFactor
					segmentProps.Size = fromOffsetSize(ceilSegmentWidth, (math.ceil(segmentHeight)))
					local fromOffsetPos = UDim2.fromOffset
					local posX = segmentPosition.X
					local ceilPosX = math.ceil(posX)
					local posY = segmentPosition.Y
					segmentProps.Position = fromOffsetPos(ceilPosX, (math.ceil(posY)))
					table.insert(visibleSegments, segmentProps)
				end
			end
			setSegments(visibleSegments)
		end, { Workspace.CurrentCamera.ViewportSize })
		local segmentElements = table.create(#segments)
		for index, props in segments do
			local _ = index - 1
			local clonedProps = table.clone(props)
			setmetatable(clonedProps, nil)
			segmentElements[index] = React.createElement(Image, clonedProps)
		end
		return React.createElement(Grid, {
			["key"] = "LoadingScreen",
			["Size"] = nil,
			["BackgroundTransparency"] = 0,
			["BackgroundColor3"] = nil,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.Loading.Blue
		}, segmentElements, React.createElement(Grid, {
			["key"] = "ScaleContainer",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.4,
			["BackgroundColor3"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromScale(1 / scale, 1 / scale),
			["BackgroundColor3"] = Color.VoxelGrey
		}, React.createElement(Image, {
			["key"] = "SkyWarsLogo",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = 3,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 346),
			["Size"] = UDim2.fromOffset(998, 214),
			["Image"] = RobloxImage.SKYWARS_OUTLINE
		}), React.createElement(ProgressBarNew, {
			["key"] = "ProgressBar",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Progress"] = 0,
			["Colors"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 620),
			["Size"] = UDim2.fromOffset(860, 40),
			["Colors"] = { Color.VoxelGreen }
		}), React.createElement(Grid, {
			["key"] = "CircularProgressContainer",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AutomaticSize"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 690),
			["Size"] = UDim2.fromOffset(0, 44),
			["AutomaticSize"] = Enum.AutomaticSize.X
		}, React.createElement(CircularProgress, {
			["key"] = "CircularProgress",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 10, 0.5, 0),
			["Size"] = UDim2.fromOffset(24, 24),
			["Color"] = Color.White
		}), React.createElement(Text, {
			["key"] = "CircularProgressText",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "Teleporting into game",
			["Bold"] = true,
			["FixSize"] = true,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 44, 0.5, 0)
		}), React.createElement("uipadding", {
			["PaddingRight"] = UDim.new(0, 10)
		}), React.createElement(CornerRadius, {
			["Radius"] = 10
		})), React.createElement("uiscale", {
			["Scale"] = scale
		})))
	end
}
