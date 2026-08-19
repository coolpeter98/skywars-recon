-- CircularProgress

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type CircularProgressProps = {
	Progress: number?,
	Key: string?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	ZIndex: number?,
	Rotation: number?,
	Visible: boolean?,
	UseCanvas: boolean?,
	CircleImageSize: string?,
	Color: Color3?,
	children: any?,
}

return {
	["CircularProgress"] = function(props: CircularProgressProps)
		local progressProp = props.Progress
		local initialProgress = progressProp == nil and 0 or progressProp
		local progress, setProgress = useState((math.clamp(initialProgress, 0, 1)))
		local displayProgress = props.Progress
		if displayProgress == nil then
			displayProgress = progress
		end
		if displayProgress > 1 then
			displayProgress = 1 - displayProgress
		end
		local angle = displayProgress * 360
		local leftRotation
		if displayProgress >= 0 then
			leftRotation = math.clamp(angle, 180, 360)
		else
			local flippedAngle = math.abs(angle) - 180
			leftRotation = math.clamp(flippedAngle, 0, 180)
		end
		local rightRotation
		if displayProgress >= 0 then
			rightRotation = math.clamp(angle, 0, 180)
		else
			local flippedAngle = math.abs(angle) + -180
			rightRotation = math.clamp(flippedAngle, -360, 0)
		end
		useEffect(function()
			if props.Progress ~= nil then
				return nil
			end
			local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
				setProgress(function(previousProgress: number)
					return (previousProgress + 0.01 * (deltaTime / 0.016666666666666666)) % 2
				end)
			end)
			return function()
				return heartbeatConnection:Disconnect()
			end
		end, {})
		local gridProps = {}
		local key = props.Key
		gridProps.key = key == nil and "CircularProgress" or key
		gridProps.AnchorPoint = props.AnchorPoint
		gridProps.Position = props.Position
		gridProps.Size = props.Size or UDim2.fromOffset(65, 65)
		gridProps.ZIndex = props.ZIndex
		local rotation = props.Rotation
		gridProps.Rotation = (rotation == 0 or (rotation ~= rotation or not rotation)) and 0 or props.Rotation * 360
		gridProps.Visible = props.Visible
		local createElement = React.createElement
		local Grid = Grid
		local children = props.children
		local leftElement
		if props.UseCanvas then
			local createElement = React.createElement
			local elementType = "canvasgroup"
			local leftFrameProps = {
				["key"] = "Left",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Size"] = UDim2.fromScale(0.5, 1)
			}
			local createElement = React.createElement
			local Image = Image
			local imageProps = {
				["Size"] = UDim2.fromScale(2, 1)
			}
			local circleImage
			if props.CircleImageSize == "Large" then
				circleImage = RobloxImage.CIRCLE_500_PX
			else
				circleImage = RobloxImage.CIRCLE
			end
			imageProps.Image = circleImage
			imageProps.ZIndex = props.ZIndex
			leftElement = createElement(elementType, leftFrameProps, createElement(Image, imageProps, React.createElement("uigradient", {
				["Color"] = ColorSequence.new(props.Color),
				["Rotation"] = leftRotation,
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.499, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})))
		else
			local createElement = React.createElement
			local Grid = Grid
			local leftFrameProps = {
				["key"] = "Left",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Size"] = UDim2.fromScale(0.5, 1)
			}
			local createElement = React.createElement
			local Image = Image
			local imageProps = {
				["Size"] = UDim2.fromScale(2, 1)
			}
			local circleImage
			if props.CircleImageSize == "Large" then
				circleImage = RobloxImage.CIRCLE_500_PX
			else
				circleImage = RobloxImage.CIRCLE
			end
			imageProps.Image = circleImage
			imageProps.ZIndex = props.ZIndex
			leftElement = createElement(Grid, leftFrameProps, createElement(Image, imageProps, React.createElement("uigradient", {
				["Color"] = ColorSequence.new(props.Color),
				["Rotation"] = leftRotation,
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.499, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})))
		end
		local rightElement
		if props.UseCanvas then
			local createElement = React.createElement
			local elementType = "canvasgroup"
			local rightFrameProps = {
				["key"] = "Right",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["Size"] = UDim2.fromScale(0.5, 1)
			}
			local createElement = React.createElement
			local Image = Image
			local imageProps = {
				["key"] = "Circle",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = nil,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["Size"] = UDim2.fromScale(2, 1)
			}
			local circleImage
			if props.CircleImageSize == "Large" then
				circleImage = RobloxImage.CIRCLE_500_PX
			else
				circleImage = RobloxImage.CIRCLE
			end
			imageProps.Image = circleImage
			imageProps.ZIndex = props.ZIndex
			rightElement = createElement(elementType, rightFrameProps, createElement(Image, imageProps, React.createElement("uigradient", {
				["Color"] = ColorSequence.new(props.Color),
				["Rotation"] = rightRotation,
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.499, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})))
		else
			local createElement = React.createElement
			local Grid = Grid
			local rightFrameProps = {
				["key"] = "Right",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["Size"] = UDim2.fromScale(0.5, 1)
			}
			local createElement = React.createElement
			local Image = Image
			local imageProps = {
				["key"] = "Circle",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = nil,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.fromScale(1, 0),
				["Size"] = UDim2.fromScale(2, 1)
			}
			local circleImage
			if props.CircleImageSize == "Large" then
				circleImage = RobloxImage.CIRCLE_500_PX
			else
				circleImage = RobloxImage.CIRCLE
			end
			imageProps.Image = circleImage
			imageProps.ZIndex = props.ZIndex
			rightElement = createElement(Grid, rightFrameProps, createElement(Image, imageProps, React.createElement("uigradient", {
				["Color"] = ColorSequence.new(props.Color),
				["Rotation"] = rightRotation,
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.499, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})))
		end
		return createElement(Grid, gridProps, children, leftElement, rightElement)
	end
}
