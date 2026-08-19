-- RadialPromptGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Outline = RuntimeLib.import(script, script.Parent.Parent, "outline").Outline
local CircularProgress = RuntimeLib.import(script, script.Parent.Parent, "circular-progress").CircularProgress
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local ContextActionService: ContextActionService = Services.ContextActionService
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "util", "input-util").InputUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useEffect = React.useEffect
local useState = React.useState

type RadialPromptGuiProps = {
	Items: { any },
	OnSelect: (item: any) -> (),
	Render: (item: any, props: { [string]: any }) -> any,
}

local getPosition: ((index: number, count: number, radius: number) -> UDim2)?

local function RadialPromptGui(props: RadialPromptGuiProps)
	local rotation, setRotation = useState(0)
	local activeSlot, setActiveSlot = useState(-1)

	useEffect(function()
		local sliceAngle = 360 / #props.Items
		local mouseDelta = Vector2.new(0, 0)
		local connection = RunService.RenderStepped:Connect(function()
			mouseDelta = mouseDelta + UserInputService:GetMouseDelta()
			local maxVector = mouseDelta.Unit * 10
			local clampedX
			if mouseDelta.X > 0 then
				local deltaX = mouseDelta.X
				local limitX = maxVector.X
				clampedX = math.min(deltaX, limitX)
			else
				local deltaX = mouseDelta.X
				local limitX = maxVector.X
				clampedX = math.max(deltaX, limitX)
			end
			local clampedY
			if mouseDelta.Y > 0 then
				local deltaY = mouseDelta.Y
				local limitY = maxVector.Y
				clampedY = math.min(deltaY, limitY)
			else
				local deltaY = mouseDelta.Y
				local limitY = maxVector.Y
				clampedY = math.max(deltaY, limitY)
			end
			mouseDelta = Vector2.new(clampedX, clampedY)
			if mouseDelta == Vector2.zero then
				return nil
			end
			if mouseDelta.Magnitude < 5 then
				setActiveSlot(-1)
				return nil
			end
			local unit = mouseDelta.Unit
			local unitY = unit.Y
			local unitX = unit.X
			local angleRad = math.atan2(unitY, unitX)
			local angleDeg = math.deg(angleRad)
			if angleDeg < 0 then
				angleDeg = angleDeg + 360
			end
			setRotation(angleDeg)
			local slotIndex = (angleDeg + sliceAngle / 2) / sliceAngle
			setActiveSlot(math.floor(slotIndex) % #props.Items)
		end)
		return function()
			return connection:Disconnect()
		end
	end, {})

	useEffect(function()
		local function handleAction(_, _, input)
			if not InputUtil.isPcInteract(input) then
				return Enum.ContextActionResult.Pass
			end
			if activeSlot < 0 then
				return Enum.ContextActionResult.Sink
			end
			local item = props.Items[activeSlot + 1]
			props.OnSelect(item)
			return Enum.ContextActionResult.Sink
		end
		local priority = Enum.ContextActionPriority.High.Value
		local inputTypes = { Enum.UserInputType.MouseButton1 }
		ContextActionService:BindActionAtPriority("SinkActionRadial", handleAction, false, priority, unpack(inputTypes))
		return function()
			return ContextActionService:UnbindAction("SinkActionRadial")
		end
	end, { activeSlot })

	local viewportContext = useContext(CameraViewportContext)
	local gridSize = 200 * viewportContext.Scale
	local progressSize = 500 * viewportContext.Scale
	local radius = 175 * viewportContext.Scale
	local rotationRad = math.rad(rotation)
	local indicatorX = math.cos(rotationRad) * (100 * viewportContext.Scale)
	local indicatorY = math.sin(rotationRad) * (100 * viewportContext.Scale)
	local items = props.Items
	local itemElements = table.create(#items)
	local function renderItem(item, index)
		local position = getPosition(index, #props.Items, radius)
		return props.Render(item, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = position,
		})
	end
	for index, item in items do
		itemElements[index] = renderItem(item, index - 1)
	end
	return React.createElement(
		Grid,
		{
			["key"] = "RadialPrompt",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(gridSize, gridSize),
		},
		itemElements,
		React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.new(0.5, indicatorX, 0.5, indicatorY),
				["Size"] = UDim2.fromOffset(10, 10),
				["BackgroundColor3"] = Color.Green,
			},
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1),
			})
		),
		React.createElement(CircularProgress, {
			["key"] = "CircularProgress",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Progress"] = nil,
			["Rotation"] = nil,
			["CircleImageSize"] = "Large",
			["UseCanvas"] = true,
			["Visible"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(progressSize, progressSize),
			["Color"] = Color.Green,
			["Progress"] = 1 / #props.Items,
			["Rotation"] = activeSlot / #props.Items + 1 / #props.Items / 2,
			["Visible"] = activeSlot >= 0,
		}),
		React.createElement(Outline, {
			["Thickness"] = 150,
			["Color"] = nil,
			["Transparency"] = 0.6,
			["Color"] = Color.Black,
		}),
		React.createElement("uicorner", {
			["CornerRadius"] = UDim.new(1),
		})
	)
end

getPosition = function(index, count, radius)
	local angleDeg = index * (360 / count)
	local angleRad = math.rad(angleDeg)
	local xOffset = math.cos(angleRad) * radius
	local yOffset = math.sin(angleRad) * radius
	return UDim2.new(0.5, xOffset, 0.5, yOffset)
end

return {
	["RadialPromptGui"] = RadialPromptGui,
}
