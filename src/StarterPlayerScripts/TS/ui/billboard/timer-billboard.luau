-- TimerBillboard

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CircularProgress =
	RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local useTimer = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-timer").useTimer
local GlobalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local GlobalStore = GlobalStoreModule.GlobalStore
local GlobalStoreChanged = GlobalStoreModule.GlobalStoreChanged
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useState = React.useState

type TimerBillboardProps = {
	ZoneId: string,
}

return {
	["TimerBillboard"] = function(props: TimerBillboardProps)
		local textRef = useRef()
		local zone, setZone = useState(GlobalStore:getState().Zones[props.ZoneId])
		local progress, setProgress = useState(0)
		local totalDuration = useMemo(function()
			return not zone and 1 or zone.EndTime - zone.StartTime
		end, { zone })
		local timerConfig = {}
		local startTime
		if zone == nil then
			startTime = zone
		else
			startTime = zone.StartTime
		end
		timerConfig.StartTime = startTime
		if zone ~= nil then
			zone = zone.EndTime
		end
		timerConfig.EndTime = zone
		timerConfig.Refs = { textRef }
		function timerConfig.OnUpdate(remainingTime)
			return setProgress(remainingTime / totalDuration)
		end
		useTimer(timerConfig)
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 96,
			["Bold"] = true,
			["Text"] = TimeUtil.formatTime(0, true),
		})
		useEffect(function()
			local connection = GlobalStoreChanged("Zones", function(newZones, oldZones)
				local newZone = newZones[props.ZoneId]
				local oldZone = oldZones[props.ZoneId]
				if not newZone then
					setZone(nil)
					return nil
				end
				if oldZone and (newZone.StartTime == oldZone.StartTime and newZone.EndTime == oldZone.EndTime) then
					return nil
				end
				setZone(newZone)
			end)
			return function()
				return connection:disconnect()
			end
		end, { props.ZoneId })
		local circularProgressElement = React.createElement(CircularProgress, {
			["key"] = "CircularProgress",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Progress"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 163),
			["Size"] = UDim2.fromOffset(148, 148),
			["Color"] = Color.White,
			["Progress"] = progress,
		})
		local countdownTextProps = {
			["key"] = "CountdownText",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["TextXAlignment"] = nil,
			["Ref"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0),
			["Position"] = UDim2.new(0.5, -textProps.Size.X.Offset / 2, 0, 311),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["Ref"] = textRef,
		}
		for key, value in textProps do
			countdownTextProps[key] = value
		end
		return React.createElement(
			"surfacegui",
			{
				["CanvasSize"] = Vector2.new(750, 600),
				["Face"] = Enum.NormalId.Front,
			},
			React.createElement(Grid, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromScale(1, 1),
			}, circularProgressElement, React.createElement(Text, countdownTextProps))
		)
	end,
}
