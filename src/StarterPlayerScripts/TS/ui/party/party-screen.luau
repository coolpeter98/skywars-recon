-- PartyScreen

type PartyScreen = {
	new: (...any) -> PartyScreen,
	constructor: (PartyScreen, ...any) -> (),
	Component: (PartyScreen) -> any,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local PartyGuiModule = RuntimeLib.import(script, script.Parent, "party-gui")
local PartyGui = PartyGuiModule.PartyGui
local SocialFilterType = PartyGuiModule.SocialFilterType
local PartyInstance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance")
local PartyUtil = PartyInstance.PartyUtil
local SocialStatus = PartyInstance.SocialStatus
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local Distance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").Distance
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore

local getAll
local getFriends
local getNearbyPlayers

local PartyScreen: PartyScreen = setmetatable({}, {
	["__tostring"] = function()
		return "PartyScreen"
	end,
	["__index"] = Screen,
})
PartyScreen.__index = PartyScreen

function PartyScreen.new(...)
	local class = PartyScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function PartyScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local friends = useGlobalStore("Friends")
		local friendIds = useGlobalStore("FriendIds")
		local party = useGlobalStore("Party")
		local filter, setFilter = useState(SocialFilterType.All)
		local players
		if filter == SocialFilterType.All then
			players = getAll(friends)
		elseif filter == SocialFilterType.Friends then
			players = getFriends(friends)
		else
			players = getNearbyPlayers()
		end
		local props = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
			["Party"] = party,
			["Filter"] = filter,
			["SetFilter"] = setFilter,
		}
		local count = 0
		local playerList = {}
		for index, player in players do
			local _ = index - 1
			if not PartyUtil.isInParty(player, party) == true then
				count = count + 1
				playerList[count] = player
			end
		end
		props.PlayerList = playerList
		props.FriendIds = friendIds
		return React.createElement(PartyGui, props)
	end
end

Reflect.defineMetadata(PartyScreen, "identifier", "MOv")
Reflect.decorate(PartyScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Party",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

local function friendToSocialPlayer(friend)
	local replicated = PlayerUtil.toReplicated(friend)
	if friend.LocationType ~= 1 and friend.LocationType ~= 4 and friend.LocationType ~= 6 then
		local socialPlayer = table.clone(replicated)
		setmetatable(socialPlayer, nil)
		local status
		if (friend.LocationType == 0 or friend.LocationType == 2) and true or friend.LocationType == 5 then
			status = SocialStatus.Online
		else
			status = SocialStatus.Offline
		end
		socialPlayer.Status = status
		return socialPlayer
	end
	local socialPlayer = table.clone(replicated)
	setmetatable(socialPlayer, nil)
	socialPlayer.Status = SocialStatus.InGame
	socialPlayer.GameId = friend.GameId
	socialPlayer.PlaceId = friend.PlaceId
	return socialPlayer
end

getAll = function(friends)
	local friendPlayers = getFriends(friends)
	local nearbyPlayers = getNearbyPlayers()
	local count = 0
	local inGameFriends = {}
	local result = {}
	for index, friend in friendPlayers do
		local _ = index - 1
		local inOurUniverse
		if friend.Status == SocialStatus.InGame then
			inOurUniverse = PlaceUtil.isOurUniverse(friend.PlaceId)
		else
			inOurUniverse = false
		end
		if inOurUniverse == true then
			count = count + 1
			inGameFriends[count] = friend
		end
	end
	for index, friend in inGameFriends do
		local _ = index - 1
		table.insert(result, friend)
		local _ = #result
	end
	local function notInResult(player)
		local found = nil
		for index, existing in result do
			local _ = index - 1
			if existing.UserId == player.UserId == true then
				found = existing
				break
			end
		end
		return not found
	end
	local count = 0
	local nearbyFiltered = {}
	for index, player in nearbyPlayers do
		if notInResult(player, index - 1, nearbyPlayers) == true then
			count = count + 1
			nearbyFiltered[count] = player
		end
	end
	for index, player in nearbyFiltered do
		local _ = index - 1
		table.insert(result, player)
		local _ = #result
	end
	local count = 0
	local remainingFriends = {}
	for index, friend in friendPlayers do
		local _ = index - 1
		local notInOurUniverse
		if friend.Status == SocialStatus.InGame then
			if friend.Status == SocialStatus.InGame then
				notInOurUniverse = not PlaceUtil.isOurUniverse(friend.PlaceId)
			else
				notInOurUniverse = false
			end
		else
			notInOurUniverse = true
		end
		if notInOurUniverse == true then
			count = count + 1
			remainingFriends[count] = friend
		end
	end
	local function notInResult(player)
		local found = nil
		for index, existing in result do
			local _ = index - 1
			if existing.UserId == player.UserId == true then
				found = existing
				break
			end
		end
		return not found
	end
	local count = 0
	local remainingFiltered = {}
	for index, friend in remainingFriends do
		if notInResult(friend, index - 1, remainingFriends) == true then
			count = count + 1
			remainingFiltered[count] = friend
		end
	end
	for index, friend in remainingFiltered do
		local _ = index - 1
		table.insert(result, friend)
		local _ = #result
	end
	return result
end

getFriends = function(friends)
	local converted = table.create(#friends)
	for index, friend in friends do
		converted[index] = friendToSocialPlayer(friend)
	end
	table.sort(converted, function(playerA, playerB)
		return playerA.Status < playerB.Status
	end)
	return converted
end

getNearbyPlayers = function()
	local players = Players:GetPlayers()
	table.sort(players, function(playerA, playerB)
		if not playerA.Character then
			return false
		end
		if not playerB.Character then
			return true
		end
		local rawDistanceA = Distance(Players.LocalPlayer, playerA.Character)
		local distanceA = rawDistanceA == nil and (1 / 0) or rawDistanceA
		local rawDistanceB = Distance(Players.LocalPlayer, playerB.Character)
		return distanceA < (rawDistanceB == nil and (1 / 0) or rawDistanceB)
	end)
	local nearbyPlayers = table.create(#players)
	for index, player in players do
		local _ = index - 1
		local socialPlayer = table.clone(PlayerUtil.toReplicated(player))
		setmetatable(socialPlayer, nil)
		socialPlayer.Status = SocialStatus.InGame
		socialPlayer.GameId = game.JobId
		socialPlayer.PlaceId = game.PlaceId
		nearbyPlayers[index] = socialPlayer
	end
	return nearbyPlayers
end

return {
	["PartyScreen"] = PartyScreen,
}
