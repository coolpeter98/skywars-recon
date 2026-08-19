-- use-stats

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local GlobalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local GlobalStore = GlobalStoreModule.GlobalStore
local GlobalStoreChanged = GlobalStoreModule.GlobalStoreChanged
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

type GameModeDefinition = {
	GameType: string,
	Queue: { Production: string, Testing: string? }?,
}

type PlayerProfile = {
	Stats: { [string]: { [string]: number } },
}

return {
	["useStats"] = function(gameType: string?, statistic: string): number
		local queueIds = useMemo(function(): { string }
			local count = 0
			local entries: { GameModeDefinition } = {}
			for index, mode in ObjectUtils.values(GameModes) do
				local _ = index - 1
				if (gameType == nil and true or mode.GameType == gameType) == true then
					count = count + 1
					entries[count] = mode
				end
			end
			local queueIds: { string } = table.create(#entries)
			for index, mode in entries do
				local _ = index - 1
				local queueId: string
				if PlaceUtil.isProduction() then
					queueId = mode.Queue.Production
				else
					queueId = mode.Queue.Testing
				end
				queueIds[index] = queueId
			end
			return queueIds
		end, { gameType })

		local getStatSum = useCallback(function(profile: PlayerProfile): number
			local statValues: { number } = table.create(#queueIds)
			for index, queueId in queueIds do
				local _ = index - 1
				statValues[index] = profile.Stats[queueId][statistic]
			end
			return ArrayUtil.sum(statValues)
		end, { queueIds })

		local stats: number, setStats = useState(getStatSum(GlobalStore:getState().Profile))

		useEffect(function()
			local maid = Maid.new()
			local connection = GlobalStoreChanged(
				"Profile",
				function(newProfile: PlayerProfile, oldProfile: PlayerProfile)
					local newStats: number = getStatSum(newProfile)
					if newStats ~= getStatSum(oldProfile) then
						setStats(newStats)
					end
				end
			)
			maid:GiveTask(function()
				return connection:disconnect()
			end)
			return function()
				return maid:DoCleaning()
			end
		end, {})

		return stats
	end,
}
