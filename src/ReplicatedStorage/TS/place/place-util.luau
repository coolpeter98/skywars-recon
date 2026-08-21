-- PlaceUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local HttpService: HttpService = Services.HttpService
local RunService: RunService = Services.RunService
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes
local RuntimeContext = RuntimeLib.import(script, script.Parent, "runtime-context").RuntimeContext

local studioJobId: string = HttpService:GenerateGUID(false)

local function isCurrentPlace(placeId: number?): boolean
	return placeId == nil or placeId == game.PlaceId
end

local function getRole(): string
	return ReplicatedStorage:GetAttribute(RuntimeContext.Attribute.Role) or RuntimeContext.Role.Lobby
end

local function getGameMode(): string?
	local gameMode = ReplicatedStorage:GetAttribute(RuntimeContext.Attribute.GameMode)
	return type(gameMode) == "string" and gameMode or nil
end

local function getGameDefinition(): any?
	local gameMode = getGameMode()
	return gameMode and GameModes[gameMode] or nil
end

local PlaceUtil = {}

function PlaceUtil.isDragonflyServer(): boolean
	return false
end

function PlaceUtil.isLobbyServer(placeId: number?): boolean
	return isCurrentPlace(placeId) and getRole() == RuntimeContext.Role.Lobby
end

function PlaceUtil.isGameServer(placeId: number?): boolean
	return isCurrentPlace(placeId) and getRole() == RuntimeContext.Role.Game
end

function PlaceUtil.isPrivateServer(placeId: number?): boolean
	return isCurrentPlace(placeId) and getRole() == RuntimeContext.Role.Private
end

function PlaceUtil.getPlaceType(placeId: number?): string?
	if not isCurrentPlace(placeId) then
		return nil
	end
	local role = getRole()
	if role == RuntimeContext.Role.Lobby then
		return "Lobby"
	end
	if role == RuntimeContext.Role.Private then
		return "Private"
	end
	local gameDefinition = getGameDefinition()
	return gameDefinition and gameDefinition.GameType or nil
end

function PlaceUtil.isPlaceType(placeId: number?, placeType: string): boolean
	return PlaceUtil.getPlaceType(placeId) == placeType
end

function PlaceUtil.isDuelsServer(placeId: number?): boolean
	return PlaceUtil.isPlaceType(placeId, "Duels")
end

function PlaceUtil.isSkyWarsServer(placeId: number?): boolean
	return PlaceUtil.isPlaceType(placeId, "SkyWars")
end

function PlaceUtil.isEggWarsServer(placeId: number?): boolean
	return PlaceUtil.isPlaceType(placeId, "EggWars")
end

function PlaceUtil.getLobbyId(): number
	return game.PlaceId
end

function PlaceUtil.getGameId(_: string?): number
	return game.PlaceId
end

function PlaceUtil.isProduction(): boolean
	return ReplicatedStorage:GetAttribute(RuntimeContext.Attribute.Production) ~= false
end

function PlaceUtil.isGamePlace(placeId: number?): boolean
	return isCurrentPlace(placeId) and (PlaceUtil.isGameServer() or PlaceUtil.isPrivateServer())
end

function PlaceUtil.getGameQueueId(): string?
	local queueId = ReplicatedStorage:GetAttribute(RuntimeContext.Attribute.QueueId)
	return type(queueId) == "string" and queueId or nil
end

PlaceUtil.getGameMode = getGameMode

function PlaceUtil.isJoinableUniverse(placeId: number?): boolean
	return isCurrentPlace(placeId)
end

function PlaceUtil.isOurUniverse(placeId: number?): boolean
	return placeId ~= nil and placeId ~= 0 and placeId == game.PlaceId
end

function PlaceUtil.getJobIdentifier(): string
	return RunService:IsStudio() and studioJobId or game.JobId
end

return {
	["PlaceUtil"] = PlaceUtil,
}
