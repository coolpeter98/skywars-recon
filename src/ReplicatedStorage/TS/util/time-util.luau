-- TimeUtil

return {
	["TimeUtil"] = {
		["elapsed"] = function(startTime: number, duration: number): boolean
			return os.clock() >= startTime + duration
		end,
		["formatTime"] = function(time: number, plain: boolean?): string
			local usePlain = plain == nil and true or plain
			local absolute = math.abs(time)
			local daysFraction = absolute / 86400
			local days = math.floor(daysFraction)
			local hoursFraction = absolute % 86400 / 3600
			local hours = math.floor(hoursFraction)
			local minutesFraction = absolute % 3600 / 60
			local minutes = math.floor(minutesFraction)
			local secondsFraction = absolute % 60
			local seconds = math.floor(secondsFraction)
			local formatted
			if days > 0 then
				formatted = ("%* %*"):format(days, days == 1 and "day" or "days")
			elseif hours > 0 then
				formatted = string.format("%.02d:%.02d:%.02d", hours, minutes, seconds)
			else
				formatted = string.format("%.02d:%.02d", minutes, seconds)
			end
			if usePlain then
				return formatted
			else
				return ("\240\159\149\146 %*"):format(formatted)
			end
		end,
	},
}
