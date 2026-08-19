-- KillsCard

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StringUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Card = RuntimeLib.import(script, script.Parent.Parent, "card").Card
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji
local useStats = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-stats").useStats
local Statistic = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "statistics").Statistic
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type KillsCardProps = {
	Kills: number?,
}

return {
	["KillsCard"] = function(props: KillsCardProps)
		local kills: number? = props.Kills
		if kills == nil then
			kills = useStats(nil, Statistic.Kills)
		end
		local remainingProps = table.clone(props)
		setmetatable(remainingProps, nil)
		remainingProps.Kills = nil
		local cardProps = {
			["Text"] = nil,
			["LayoutOrder"] = 1,
			["Text"] = ("%*  %*"):format(Emoji.CrossedSwords, StringUtil.formatNumber(kills)),
		}
		for key, value in remainingProps do
			cardProps[key] = value
		end
		return React.createElement(Card, cardProps)
	end,
}
