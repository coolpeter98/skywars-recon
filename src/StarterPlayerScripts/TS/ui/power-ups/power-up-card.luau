-- PowerUpCard

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local PowerUps = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "power-up", "power-ups").PowerUps
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local CircularProgress =
	RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil

type PowerUpCardProps = {
	PowerUp: string,
	StartTime: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["PowerUpCard"] = function(props: PowerUpCardProps)
		local elapsedTime: number, setElapsedTime = useState(0)
		useEffect(function()
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				setElapsedTime(os.clock() - props.StartTime)
			end)
			return function()
				return heartbeatConnection:Disconnect()
			end
		end, { props.StartTime })
		local powerUpInfo = PowerUps[props.PowerUp]
		local progress = 1 - elapsedTime / powerUpInfo.Duration
		local cardProps = {
			["key"] = ("PowerUp_%*"):format(props.PowerUp),
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(150, 75),
		}
		local powerUpName = props.PowerUp
		local nameLength = #props.PowerUp
		cardProps.LayoutOrder = ArrayUtil.sum({ string.byte(powerUpName, 1, nameLength) })
		local circle = React.createElement(
			Grid,
			{
				["key"] = "Circle",
				["Size"] = nil,
				["ZIndex"] = 2,
				["Size"] = UDim2.fromOffset(75, 75),
			},
			React.createElement(CircularProgress, {
				["key"] = nil,
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Color"] = nil,
				["Progress"] = nil,
				["ZIndex"] = 2,
				["key"] = ("CircularProgress_%*"):format(props.PowerUp),
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Color"] = Color.Green,
				["Progress"] = progress,
			}),
			React.createElement(Image, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["ScaleType"] = nil,
				["ZIndex"] = 3,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(28, 28),
				["Image"] = powerUpInfo.Icon,
				["ImageColor3"] = powerUpInfo.Color,
				["ScaleType"] = Enum.ScaleType.Fit,
			})
		)
		local circleClipping = React.createElement(
			Grid,
			{
				["key"] = "CircleClipping",
				["Size"] = nil,
				["ClipsDescendants"] = true,
				["Size"] = UDim2.fromOffset(65, 75),
			},
			React.createElement(
				Grid,
				{
					["key"] = "CircleBackground",
					["Size"] = nil,
					["BackgroundTransparency"] = 0.6,
					["Size"] = UDim2.fromOffset(75, 75),
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			)
		)
		local textClippingProps = {
			["key"] = "TextClipping",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ClipsDescendants"] = true,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 65, 0.5, 0),
			["Size"] = UDim2.fromOffset(85, 50),
		}
		local textArea = React.createElement(
			Grid,
			{
				["key"] = "TextArea",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, -40, 0.5, 0),
				["Size"] = UDim2.fromOffset(125, 50),
			},
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local textProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["TextXAlignment"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(85, 50),
		}
		local timeLeft = powerUpInfo.Duration - elapsedTime
		textProps.Text = TimeUtil.formatTime(math.max(timeLeft, 0), true)
		textProps.TextXAlignment = Enum.TextXAlignment.Center
		return React.createElement(
			Grid,
			cardProps,
			circle,
			circleClipping,
			React.createElement(Grid, textClippingProps, textArea, React.createElement(Text, textProps))
		)
	end,
}
