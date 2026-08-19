-- adverts

local Color = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

return {
	["getAdvertTimeColor"] = function(time: number): Color3
		if time < 86400 then
			return Color.Red
		elseif time < 259200 then
			return Color.Orange
		else
			return Color.Yellow
		end
	end,
}
