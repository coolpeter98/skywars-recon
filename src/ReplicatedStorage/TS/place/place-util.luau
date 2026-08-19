-- PlaceUtil

type Lobby = {
	PlaceId: number,
	PlaceType: string,
}

type GamePlace = {
	PlaceId: number,
	PlaceType: string,
	QueueId: number?,
	GameMode: number?,
}

type PlaceGroup = {
	PlaceGroupType: number,
	Production: boolean,
	Lobby: Lobby?,
	Games: { GamePlace }?,
	Dragonfly: Lobby?,
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService: HttpService = Services.HttpService
local RunService: RunService = Services.RunService
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local QueueId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "matchmaking", "queue-id").QueueId
local PlaceGroupTypeNames: { [number]: string } = {}
local PlaceGroupType = setmetatable({}, {
	["__index"] = PlaceGroupTypeNames,
})
PlaceGroupType.Game = 0
PlaceGroupTypeNames[0] = "Game"
PlaceGroupType.Dragonfly = 1
PlaceGroupTypeNames[1] = "Dragonfly"
local studioJobId: string = HttpService:GenerateGUID(false)
local placeGroups: { PlaceGroup } = {}
local testingPlaceGroup1 = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 9629915660,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 9629953894,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingSolo,
			["GameMode"] = GameMode.SkyWarsSolo
		},
		{
			["PlaceId"] = 10392710953,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingQuads,
			["GameMode"] = GameMode.SkyWarsQuads
		},
		{
			["PlaceId"] = 10486765429,
			["PlaceType"] = "Duels",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingDuelsSolo,
			["GameMode"] = GameMode.DuelsSolo
		},
		{
			["PlaceId"] = 10489360543,
			["PlaceType"] = "Private",
			["QueueId"] = nil,
			["QueueId"] = QueueId.TestingPrivate
		}
	}
}
local testingPlaceGroup2 = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 8555061965,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 7809622268,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingSolo,
			["GameMode"] = GameMode.SkyWarsSolo
		},
		{
			["PlaceId"] = 8694366502,
			["PlaceType"] = "Private",
			["QueueId"] = nil,
			["QueueId"] = QueueId.TestingPrivate
		},
		{
			["PlaceId"] = 11417059718,
			["PlaceType"] = "EggWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingSolo,
			["GameMode"] = GameMode.EggWarsQuads
		}
	}
}
local testingPlaceGroup3 = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 8556405552,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 8556406943,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingSolo,
			["GameMode"] = GameMode.SkyWarsSolo
		},
		{
			["PlaceId"] = 8590534029,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingDuos,
			["GameMode"] = GameMode.SkyWarsDuos
		},
		{
			["PlaceId"] = 8707139273,
			["PlaceType"] = "Private",
			["QueueId"] = nil,
			["QueueId"] = QueueId.TestingPrivate
		},
		{
			["PlaceId"] = 8898515233,
			["PlaceType"] = "Duels",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingDuelsSolo,
			["GameMode"] = GameMode.DuelsSolo
		},
		{
			["PlaceId"] = 11978894256,
			["PlaceType"] = "EggWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingEggWarsQuads,
			["GameMode"] = GameMode.EggWarsQuads
		}
	}
}
local productionPlaceGroup = {
	["PlaceGroupType"] = nil,
	["Production"] = true,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 8542259458,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 8542275097,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.Solo,
			["GameMode"] = GameMode.SkyWarsSolo
		},
		{
			["PlaceId"] = 8592115909,
			["PlaceType"] = "SkyWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.Duos,
			["GameMode"] = GameMode.SkyWarsDuos
		},
		{
			["PlaceId"] = 8768229691,
			["PlaceType"] = "Private",
			["QueueId"] = nil,
			["QueueId"] = QueueId.Private
		},
		{
			["PlaceId"] = 13246639586,
			["PlaceType"] = "Duels",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.DuelsSolo,
			["GameMode"] = GameMode.DuelsSolo
		},
		{
			["PlaceId"] = 8951451142,
			["PlaceType"] = "EggWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.EggWarsQuads,
			["GameMode"] = GameMode.EggWarsQuads
		}
	}
}
local dragonflyPlaceGroup = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Dragonfly"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Dragonfly,
	["Dragonfly"] = {
		["PlaceId"] = 9345668428,
		["PlaceType"] = "Dragonfly"
	}
}
local devPlaceGroup = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 8542259458,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 0,
			["PlaceType"] = "EggWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingSolo,
			["GameMode"] = GameMode.EggWarsQuads
		}
	}
}
local eggWarsTestingPlaceGroup = {
	["PlaceGroupType"] = nil,
	["Production"] = false,
	["Lobby"] = nil,
	["Games"] = nil,
	["PlaceGroupType"] = PlaceGroupType.Game,
	["Lobby"] = {
		["PlaceId"] = 12340910958,
		["PlaceType"] = "Lobby"
	},
	["Games"] = {
		{
			["PlaceId"] = 12340937402,
			["PlaceType"] = "EggWars",
			["QueueId"] = nil,
			["GameMode"] = nil,
			["QueueId"] = QueueId.TestingEggWarsQuads,
			["GameMode"] = GameMode.EggWarsQuads
		}
	}
}
__set_list(placeGroups, 1, {testingPlaceGroup1, testingPlaceGroup2, testingPlaceGroup3, productionPlaceGroup, dragonflyPlaceGroup, devPlaceGroup, eggWarsTestingPlaceGroup})
local PlaceUtil = {
	["isDragonflyServer"] = function(): boolean
		for _, placeGroup in placeGroups do
			if placeGroup.PlaceGroupType == PlaceGroupType.Dragonfly and placeGroup.Dragonfly.PlaceId == game.PlaceId then
				return true
			end
		end
		return false
	end,
	["isLobbyServer"] = function(placeId: number?): boolean
		if placeId == nil then
			placeId = game.PlaceId
		end
		for _, placeGroup in placeGroups do
			if placeGroup.PlaceGroupType == PlaceGroupType.Game and placeGroup.Lobby.PlaceId == placeId then
				return true
			end
		end
		return false
	end,
	["isGameServer"] = function(placeId: number?): boolean
		if placeId == nil then
			placeId = game.PlaceId
		end
		for _, placeGroup in placeGroups do
			if placeGroup.PlaceGroupType == PlaceGroupType.Game then
				for _, place in placeGroup.Games do
					if place.PlaceId == placeId and (place.QueueId ~= QueueId.TestingPrivate and place.QueueId ~= QueueId.Private) then
						return true
					end
				end
			end
		end
		return false
	end,
	["isPrivateServer"] = function(placeId: number?): boolean
		if placeId == nil then
			placeId = game.PlaceId
		end
		for _, placeGroup in placeGroups do
			if placeGroup.PlaceGroupType == PlaceGroupType.Game then
				for _, place in placeGroup.Games do
					if place.PlaceId == placeId and (place.QueueId == QueueId.TestingPrivate or place.QueueId == QueueId.Private) then
						return true
					end
				end
			end
		end
		return false
	end
}
local isPlaceType: (placeId: number?, placeType: string) -> boolean = nil
function PlaceUtil.isDuelsServer(placeId: number?): boolean
	if placeId == nil then
		placeId = game.PlaceId
	end
	return isPlaceType(placeId, "Duels")
end
function PlaceUtil.isSkyWarsServer(placeId: number?): boolean
	if placeId == nil then
		placeId = game.PlaceId
	end
	return isPlaceType(placeId, "SkyWars")
end
function PlaceUtil.isEggWarsServer(placeId: number?): boolean
	if placeId == nil then
		placeId = game.PlaceId
	end
	return isPlaceType(placeId, "EggWars")
end
function PlaceUtil.getPlaceType(placeId: number?): string?
	if placeId == nil then
		placeId = game.PlaceId
	end
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			if placeGroup.Lobby.PlaceId == placeId then
				return placeGroup.Lobby.PlaceType
			end
			for _, place in placeGroup.Games do
				if place.PlaceId == placeId then
					return place.PlaceType
				end
			end
		end
	end
	return nil
end
isPlaceType = function(placeId: number?, placeType: string): boolean
	if placeId == nil then
		placeId = game.PlaceId
	end
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			for _, place in placeGroup.Games do
				if place.PlaceId == placeId and place.PlaceType == placeType then
					return true
				end
			end
		end
	end
	return false
end
PlaceUtil.isPlaceType = isPlaceType
function PlaceUtil.getLobbyId(): number
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			if placeGroup.Lobby.PlaceId == game.PlaceId then
				return placeGroup.Lobby.PlaceId
			end
			local count = 0
			local matchingGames = {}
			for index, place in placeGroup.Games do
				local _ = index - 1
				if place.PlaceId == game.PlaceId == true then
					count = count + 1
					matchingGames[count] = place
				end
			end
			if #matchingGames > 0 then
				return placeGroup.Lobby.PlaceId
			end
		end
	end
	return -1
end
function PlaceUtil.getGameId(queueId: number?): number
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			local isLobby = placeGroup.Lobby.PlaceId == game.PlaceId
			if not isLobby then
				local count = 0
				local matchingGames = {}
				for index, place in placeGroup.Games do
					local _ = index - 1
					if place.PlaceId == game.PlaceId == true then
						count = count + 1
						matchingGames[count] = place
					end
				end
				if #matchingGames > 0 then
					isLobby = true
				else
					isLobby = false
				end
			end
			if isLobby then
				local count = 0
				local matchingGames = {}
				for index, place in placeGroup.Games do
					local _ = index - 1
					if place.QueueId == queueId == true then
						count = count + 1
						matchingGames[count] = place
					end
				end
				if #matchingGames ~= 0 then
					local lastIndex = #matchingGames
					local lastGame = matchingGames[lastIndex]
					matchingGames[lastIndex] = nil
					return lastGame.PlaceId
				end
			end
		end
	end
	return -1
end
function PlaceUtil.isProduction(): boolean
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			if placeGroup.Lobby.PlaceId == game.PlaceId then
				return placeGroup.Production
			end
			local count = 0
			local matchingGames = {}
			for index, place in placeGroup.Games do
				local _ = index - 1
				if place.PlaceId == game.PlaceId == true then
					count = count + 1
					matchingGames[count] = place
				end
			end
			local lastIndex = #matchingGames
			local lastGame = matchingGames[lastIndex]
			matchingGames[lastIndex] = nil
			if lastGame then
				return placeGroup.Production
			end
		end
	end
	return false
end
function PlaceUtil.isGamePlace(placeId: number?): boolean
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			for _, place in placeGroup.Games do
				if place.PlaceId == placeId then
					return true
				end
			end
		end
	end
	return false
end
function PlaceUtil.getGameQueueId(): number?
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			for _, place in placeGroup.Games do
				if place.PlaceId == game.PlaceId then
					return place.QueueId
				end
			end
		end
	end
	return nil
end
function PlaceUtil.getGameMode(): number?
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			for _, place in placeGroup.Games do
				if place.PlaceId == game.PlaceId then
					return place.GameMode
				end
			end
		end
	end
	return nil
end
function PlaceUtil.isJoinableUniverse(placeId: number?): boolean
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game and placeGroup.Lobby.PlaceId == placeId then
			return true
		end
	end
	return false
end
function PlaceUtil.isOurUniverse(placeId: number?): boolean
	if placeId == nil then
		placeId = game.PlaceId
	end
	if placeId == nil or placeId == 0 then
		return false
	end
	for _, placeGroup in placeGroups do
		if placeGroup.PlaceGroupType == PlaceGroupType.Game then
			if placeGroup.Lobby.PlaceId == placeId then
				return true
			end
			for _, place in placeGroup.Games do
				if place.PlaceId == placeId then
					return true
				end
			end
		end
	end
	return false
end
function PlaceUtil.getJobIdentifier(): string
	if RunService:IsStudio() then
		return studioJobId
	else
		return game.JobId
	end
end
return {
	["PlaceUtil"] = PlaceUtil
}
