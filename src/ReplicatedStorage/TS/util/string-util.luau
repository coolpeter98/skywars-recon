-- StringUtil

local StringUtil = {
	["formatDisplayName"] = function(name: string): (string, number)
		return string.gsub(name, "[A-Z]", " %1")
	end,
	["parseNumber"] = function(value: string): number?
		local digits = string.gsub(value, "%D+", "")
		return tonumber(digits)
	end,
	["formatNumber"] = function(value: number): (string, number)
		local text = tostring(value)
		return string.gsub(string.reverse((string.gsub(string.reverse(text), "%d%d%d", "%1,"))), "^,", "")
	end,
	["stripRichText"] = function(text: string): (string, number)
		local withNewlines = string.gsub(text, "<br%s*/>", "\n")
		return string.gsub(withNewlines, "<[^<>]->", "")
	end,
}
local getPodiumPlaceSuffix = nil
function StringUtil.formatPodiumPlace(place: number): string
	return ("%*%*"):format(place + 1, getPodiumPlaceSuffix(place + 1))
end
getPodiumPlaceSuffix = function(place: number): string
	if place >= 11 and place <= 13 then
		return "th"
	end
	local lastDigit = place % 10
	return lastDigit == 1 and "st" or (lastDigit == 2 and "nd" or (lastDigit == 3 and "rd" or "th"))
end
return {
	["StringUtil"] = StringUtil,
}
