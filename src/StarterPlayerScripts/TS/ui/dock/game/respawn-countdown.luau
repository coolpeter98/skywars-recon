-- RespawnCountdown

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local CircularProgress =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "circular-progress").CircularProgress
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type RespawnCountdownProps = {
	RespawnTime: number,
	RespawnDelay: number,
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["RespawnCountdown"] = function(props: RespawnCountdownProps)
		local function getRemainingTime(): number
			local remaining = props.RespawnTime - os.clock()
			return math.max(remaining, 0)
		end
		local timeLeft: number, setTimeLeft: (number) -> () = useState(getRemainingTime)
		local textProps: { [string]: any } = getTextProps({
			["Text"] = "RESPAWN IN",
			["TextSize"] = 30,
			["Bold"] = true,
		})
		useEffect(function()
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				setTimeLeft(getRemainingTime)
			end)
			return function()
				return heartbeatConnection:Disconnect()
			end
		end, { props.RespawnTime })
		local progress: number = timeLeft / props.RespawnDelay
		local labelProps = {
			["key"] = "RespawnInText",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromScale(0, 0.5),
		}
		for key, value in textProps do
			labelProps[key] = value
		end
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = "RespawnCountdown",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(textProps.Size.X.Offset + 20 + 80, 80),
		}
		local labelElement = React.createElement(Text, labelProps)
		local backgroundElement = React.createElement(CircularProgress, {
			["key"] = "CircularProgressBackground",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Progress"] = 1,
			["ZIndex"] = 1,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.fromScale(1, 0.5),
			["Size"] = UDim2.fromOffset(80, 80),
			["Color"] = Color.Grey,
		})
		local createElement = React.createElement
		local circularProgress = CircularProgress
		local circularProgressProps = {
			["key"] = "CircularProgress",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Progress"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.fromScale(1, 0.5),
			["Size"] = UDim2.fromOffset(80, 80),
			["Color"] = Color.White,
			["Progress"] = progress,
		}
		local createElement = React.createElement
		local countdownText = Text
		local countdownTextProps = {
			["key"] = "CountdownText",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 40,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		local secondsLeft: number = math.ceil(timeLeft)
		countdownTextProps.Text = tostring(secondsLeft)
		return createElement(
			grid,
			gridProps,
			labelElement,
			backgroundElement,
			createElement(circularProgress, circularProgressProps, createElement(countdownText, countdownTextProps))
		)
	end,
}
