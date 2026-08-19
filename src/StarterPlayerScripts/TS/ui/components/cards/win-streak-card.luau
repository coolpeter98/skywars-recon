-- WinStreakCard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StringUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Card = RuntimeLib.import(script, script.Parent.Parent, "card").Card
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji
local useStats = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-stats").useStats
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type WinStreakCardProps = {
	WinStreak: number?,
	[string]: any,
}

return {
	["WinStreakCard"] = function(props: WinStreakCardProps)
		local winStreak = props.WinStreak
		if winStreak == nil then
			winStreak = useStats(nil, Statistic.WinStreak)
		end

		local restProps = table.clone(props)
		setmetatable(restProps, nil)
		restProps.WinStreak = nil

		local cardProps = {
			["Text"] = nil,
			["LayoutOrder"] = 1,
			["Text"] = ("%*  %*"):format(Emoji.Flame, StringUtil.formatNumber(winStreak)),
		}
		for key, value in restProps do
			cardProps[key] = value
		end

		return React.createElement(Card, cardProps)
	end,
}
