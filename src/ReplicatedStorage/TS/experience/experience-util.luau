-- ExperienceUtil

type ExperienceUtil = {
	BASE: number,
	MAX_LEVEL: number,
	getLevel: (experience: number) -> number,
	prettyPrintPercent: (percent: number) -> string,
	getExperience: (level: number) -> number,
}

local ExperienceUtil: ExperienceUtil = {
	["BASE"] = 13,
	["MAX_LEVEL"] = 101,
}
local experienceLevels: { number } = {}
function ExperienceUtil.getLevel(experience: number): number
	local level = 0
	for index = 0, #experienceLevels - 1 do
		if experienceLevels[index + 1] > experience then
			break
		end
		level = index
	end
	return level
end
function ExperienceUtil.prettyPrintPercent(percent: number): string
	local scaledValue = percent * 100 * 100
	local rounded = math.round(scaledValue) / 100
	return tostring(rounded) .. "%"
end
function ExperienceUtil.getExperience(level: number): number
	local exponent = 0.01 * level + 2
	local experience = math.pow(level, exponent) * 13
	return math.ceil(experience) * 10
end
for index = 0, 100 do
	local nextLevel = index + 1
	local exponent = 0.01 * index + 2
	local experience = math.pow(index, exponent) * 13
	experienceLevels[nextLevel] = math.ceil(experience) * 10
end
return {
	["ExperienceUtil"] = ExperienceUtil,
}
