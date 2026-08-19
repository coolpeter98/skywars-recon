-- FriendController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = flamework.Reflect
local Flamework = flamework.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = services.Players
local SocialService: SocialService = services.SocialService
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore

type FriendController = {
	screenController: any,
	FriendListUpdated: any,
	onlineFriends: { any },
	canInvite: boolean,
}

local FriendController = setmetatable({}, {
	["__tostring"] = function()
		return "FriendController"
	end
})
FriendController.__index = FriendController
function FriendController.new(...): FriendController
	local self = setmetatable({}, FriendController)
	return self:constructor(...) or self
end
function FriendController.constructor(self: FriendController, screenController: any)
	self.screenController = screenController
	self.FriendListUpdated = AsyncEvent.new()
	self.onlineFriends = {}
	self.canInvite = false
end
function FriendController.onStart(self: FriendController)
	task.spawn(function()
		Flamework.resolveDependency("lw"):getCoreSafe("PlayerFriendedEvent").Event:Connect(function(friend)
			print(("Processed new added friend: %*"):format(friend.UserId))
			local friendIdSet = {}
			for _, friendId in GlobalStore:getState().FriendIds do
				friendIdSet[friendId] = true
			end
			friendIdSet[friend.UserId] = true
			local friendIds = {}
			for friendId in friendIdSet do
				table.insert(friendIds, friendId)
			end
			GlobalStore:dispatch({
				["type"] = "SetValue",
				["Key"] = "FriendIds",
				["Value"] = nil,
				["Value"] = friendIds
			})
		end)
	end)
	task.spawn(function()
		self.canInvite = SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
	end)
	task.spawn(function()
		repeat
			local success, _ = RuntimeLib.try(function()
				self:pullAllFriends()
				return RuntimeLib.TRY_BREAK
			end, function(_)
				print("Error whilst initially polling for offline friends list, retrying!")
				task.wait(10)
			end)
		until success
	end)
	task.spawn(function()
		while true do
			self:updateOnlineFriends()
			task.wait(FriendController.FRIENDS_UPDATE_INTERVAL)
		end
	end)
end
function FriendController.canSendInvites(self: FriendController): boolean
	return self.canInvite
end
function FriendController.pullAllFriends(self: FriendController)
	local pages = Players:GetFriendsAsync(Players.LocalPlayer.UserId)
	local friendIdSet = {}
	while true do
		for _, friend in pages:GetCurrentPage() do
			friendIdSet[friend.Id] = true
		end
		if pages.IsFinished then
			local count = 0
			for _ in friendIdSet do
				count = count + 1
			end
			print(("Loaded %* friend IDs"):format(count))
			for _, friendId in GlobalStore:getState().FriendIds do
				friendIdSet[friendId] = true
			end
			local friendIds = {}
			for friendId in friendIdSet do
				table.insert(friendIds, friendId)
			end
			print(("Merged friends size: %*"):format(#friendIds))
			GlobalStore:dispatch({
				["type"] = "SetValue",
				["Key"] = "FriendIds",
				["Value"] = nil,
				["Value"] = friendIds
			})
			return
		end
		pages:AdvanceToNextPageAsync()
	end
end
function FriendController.updateOnlineFriends(self: FriendController)
	local onlineFriends = {}
	local failed, result = RuntimeLib.try(function()
		onlineFriends = Players.LocalPlayer:GetFriendsOnline()
	end, function(err)
		print(err)
		return RuntimeLib.TRY_RETURN, {}
	end)
	if failed then
		return unpack(result)
	end
	table.clear(self.onlineFriends)
	local onlineFriendList = onlineFriends
	for _, friend in onlineFriends do
		local friendList = self.onlineFriends
		table.insert(friendList, friend)
	end
	GlobalStore:dispatch({
		["type"] = "SetValue",
		["Key"] = "Friends",
		["Value"] = nil,
		["Value"] = self.onlineFriends
	})
	self.FriendListUpdated:fire({
		["onlineFriends"] = onlineFriendList
	})
end
FriendController.FRIENDS_UPDATE_INTERVAL = 10
Reflect.defineMetadata(FriendController, "identifier", "Y6K")
Reflect.defineMetadata(FriendController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(FriendController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(FriendController, "$:flamework@Controller", Controller, {})
return {
	["FriendController"] = FriendController
}
