-- TradeUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local TradeConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "trade", "trade-constants").TradeConstants
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil

type Trade = {
	Players: {
		Requester: Player,
		Requestee: Player,
	},
	LastItemUpdateTime: number?,
}

local TradeUtil = {
	["getTradePlayerKey"] = function(trade: Trade, player: Player): string
		return trade.Players.Requester.UserId == player.UserId and "Requester" or "Requestee"
	end,
	["isTradeEqual"] = function(first, second): boolean
		local firstCount = 0
		for _ in first do
			firstCount = firstCount + 1
		end
		local secondCount = 0
		for _ in second do
			secondCount = secondCount + 1
		end
		if firstCount ~= secondCount then
			return false
		end
		for key, value in first do
			local otherValue = second[key]
			if otherValue == nil or value ~= otherValue then
				return false
			end
		end
		return true
	end,
	["isTradeOnCooldown"] = function(trade: Trade): boolean
		local onCooldown
		if trade.LastItemUpdateTime == nil then
			onCooldown = false
		else
			onCooldown = not TimeUtil.elapsed(trade.LastItemUpdateTime, TradeConstants.ITEM_UPDATE_COOLDOWN)
		end
		return onCooldown
	end,
	["createLastItemUpdateTimeSchedule"] = function(trade: Trade, onComplete: () -> ())
		local schedule: RBXScriptConnection? = nil
		schedule = ScheduleUtil.createSchedule(0.2, function()
			if TradeUtil.isTradeOnCooldown(trade) then
				return nil
			end
			schedule:Disconnect()
			onComplete()
		end)
		return schedule
	end,
}

return {
	["TradeUtil"] = TradeUtil,
}
