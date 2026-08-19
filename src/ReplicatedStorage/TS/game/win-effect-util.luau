-- WinEffectUtil

local RobloxAnimation: { DANCE_ONE: string, DANCE_TWO: string, DANCE_THREE: string } = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation

type TrophyConfig = {
	Type: string,
	PlacementIndex: number,
	Animation: string,
}

local winEffectTrophies: { [string]: TrophyConfig } = {}
for _, trophyConfig in
	{
		{
			["Type"] = "Bronze",
			["PlacementIndex"] = 2,
			["Animation"] = nil,
			["Animation"] = RobloxAnimation.DANCE_ONE,
		},
		{
			["Type"] = "Silver",
			["PlacementIndex"] = 1,
			["Animation"] = nil,
			["Animation"] = RobloxAnimation.DANCE_TWO,
		},
		{
			["Type"] = "Gold",
			["PlacementIndex"] = 0,
			["Animation"] = nil,
			["Animation"] = RobloxAnimation.DANCE_THREE,
		},
	}
do
	winEffectTrophies[trophyConfig.Type] = trophyConfig
end

type WinEffect = {
	placements: { [number]: { [number]: unknown } },
}

return {
	["WinEffectTrophies"] = winEffectTrophies,
	["WinEffectUtil"] = {
		["isGroupWinEffect"] = function(winEffect: WinEffect): boolean
			local foundGroup = nil
			for index, group in winEffect.placements do
				local _ = index - 1
				if #group > 2 == true then
					foundGroup = group
					break
				end
			end
			return foundGroup ~= nil
		end,
	},
}
