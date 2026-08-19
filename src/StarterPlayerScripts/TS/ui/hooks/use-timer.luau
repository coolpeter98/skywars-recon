-- useTimer

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo

export type UseTimerRef = {
	current: TextLabel?,
}

export type UseTimerConfig = {
	StartTime: number?,
	EndTime: number?,
	Refs: { UseTimerRef }?,
	IncludeImage: boolean?,
	OnUpdate: ((timeLeft: number) -> ())?,
}

return {
	["useTimer"] = function(timerConfig: UseTimerConfig)
		local resolvedStartTime = useMemo(function()
			local startTime = timerConfig.StartTime
			if startTime == nil then
				startTime = os.time()
			end
			return startTime
		end, { timerConfig.StartTime })
		local getRemainingTime = useCallback(function()
			local endTime = timerConfig.EndTime
			local remainingTime
			if endTime == 0 or (endTime ~= endTime or not endTime) then
				remainingTime = os.time() - resolvedStartTime
			else
				remainingTime = timerConfig.EndTime - os.time()
			end
			return math.max(remainingTime, 0)
		end, { resolvedStartTime, timerConfig.EndTime })
		useEffect(function()
			local lastTime = nil
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				local remainingTime = getRemainingTime()
				if remainingTime == lastTime then
					return nil
				end
				lastTime = remainingTime
				if timerConfig.Refs then
					for _, ref in timerConfig.Refs do
						local textLabel = ref.current
						if textLabel then
							textLabel.Text = TimeUtil.formatTime(remainingTime, not timerConfig.IncludeImage)
						end
					end
				end
				if timerConfig.OnUpdate then
					timerConfig.OnUpdate(remainingTime)
				end
			end)
			return function()
				return heartbeatConnection:Disconnect()
			end
		end, { getRemainingTime })
		return getRemainingTime()
	end,
}
