-- WinsCard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StringUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Card = RuntimeLib.import(script, script.Parent.Parent, "card").Card
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji
local useStats = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-stats").useStats
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["WinsCard"] = function(props: { Wins: number? })
		local wins = props.Wins
		if wins == nil then
			wins = useStats(nil, Statistic.Wins)
		end

		local propsCopy = table.clone(props)
		setmetatable(propsCopy, nil)
		propsCopy.Wins = nil

		local cardProps = {
			["Text"] = nil,
			["LayoutOrder"] = 1,
			["Text"] = ("%*  %*"):format(Emoji.Trophy, StringUtil.formatNumber(wins)),
		}
		for key, value in propsCopy do
			cardProps[key] = value
		end

		return React.createElement(Card, cardProps)
	end,
}
