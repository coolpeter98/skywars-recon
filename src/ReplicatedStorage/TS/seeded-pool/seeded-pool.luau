-- SeededPool

type Period = "Daily" | "Weekly"

type DateTable = {
	year: number,
	month: number,
	day: number,
	hour: number,
	min: number,
	sec: number,
	wday: number,
	yday: number,
	isdst: boolean,
}

local Period: { Daily: "Daily", Weekly: "Weekly" } = {
	["Daily"] = "Daily",
	["Weekly"] = "Weekly",
}

local SeededPool: {
	getActiveRotation: (pool: { string }, period: Period, amount: number) -> { string },
	getNextPeriodTime: (period: Period) -> number?,
} =
	{}

local startOfDay: (date: DateTable) -> DateTable
local getSecondsInPeriod: (period: Period) -> number?

function SeededPool.getActiveRotation(pool: { string }, period: Period, amount: number): { string }
	local items: { string } = table.clone(pool)
	local random: Random = Random.new(0)
	local elapsedPeriods = os.time() / getSecondsInPeriod(period)
	local periodIndex = math.floor(elapsedPeriods)
	local firstIteration = false
	local index = 0
	local rotation: { string } = {}
	while true do
		if firstIteration then
			index = index + 1
		else
			firstIteration = true
		end
		if index >= amount or #items == 0 then
			return rotation
		end
		local randomFloat = random:NextNumber() * #items
		local pickIndex = (math.floor(randomFloat) + periodIndex) % #items
		local item = table.remove(items, pickIndex + 1)
		if item ~= 0 and (item == item and (item ~= "" and item)) then
			table.insert(rotation, item)
		end
	end
end

function SeededPool.getNextPeriodTime(period: Period): number?
	local now: DateTable = os.date("!*t")
	local tomorrow: DateTable = os.date("!*t", os.time() + 86400)
	local nextWeek: DateTable = os.date("!*t", os.time() + (7 - (now.wday - 1)) * 60 * 60 * 24)
	local tomorrowStart = startOfDay(tomorrow)
	local nextWeekStart = startOfDay(nextWeek)
	if period == Period.Daily then
		return os.time(tomorrowStart)
	end
	if period == Period.Weekly then
		return os.time(nextWeekStart)
	end
end

startOfDay = function(date: DateTable): DateTable
	local dayStart = table.clone(date)
	setmetatable(dayStart, nil)
	dayStart.hour = 0
	dayStart.min = 0
	dayStart.sec = 0
	return dayStart
end

getSecondsInPeriod = function(period: Period): number?
	if period == Period.Daily then
		return 86400
	end
	if period == Period.Weekly then
		return 604800
	end
end

return {
	["Period"] = Period,
	["SeededPool"] = SeededPool,
}
