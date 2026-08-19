-- MapUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Maps = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "map", "map-info").Maps
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type MapOptions = {
	GameType: string?,
	MapSize: string?,
}

type MapInfo = {
	Name: string,
	DisplayName: string,
	GameType: string,
	PartySupported: boolean?,
}

return {
	["MapUtil"] = {
		["getMaps"] = function(options: MapOptions?): { MapInfo }
			local mapSize: string?
			if options == nil then
				mapSize = options
			else
				mapSize = options.MapSize
			end
			local isLarge: boolean
			if mapSize then
				isLarge = options.MapSize == "Large"
			else
				isLarge = false
			end
			local maps: { MapInfo } = ObjectUtils.values(Maps)
			local result: { MapInfo } = {}
			for i = 1, #maps do
				local map: MapInfo = maps[i]
				local _ = i - 1
				local gameType: string? | boolean
				if options == nil then
					gameType = options
				else
					gameType = options.GameType
				end
				if gameType then
					gameType = map.GameType ~= options.GameType
				end
				if not gameType then
					if not isLarge or map.PartySupported ~= false then
						table.insert(result, map)
					end
				end
			end
			return result
		end,
	},
}
