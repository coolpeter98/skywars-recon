-- PartyController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local PartyInstance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance")
local PARTY_INVITE_TIMEOUT = PartyInstance.PARTY_INVITE_TIMEOUT
local PartyUtil = PartyInstance.PartyUtil
local PartyScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "party", "party-screen").PartyScreen
local DefaultProfileStore =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "profile-store").DefaultProfileStore
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local HttpService: HttpService = Services.HttpService
local Players: Players = Services.Players
local SocialService: SocialService = Services.SocialService

type PartyController = {
	screenController: any,
	notificationController: any,
	notifications: { [string]: any },
}

local PartyController = setmetatable({}, {
	["__tostring"] = function()
		return "PartyController"
	end,
})
PartyController.__index = PartyController

function PartyController.new(...)
	local class = PartyController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function PartyController.constructor(self: PartyController, screenController, notificationController)
	self.screenController = screenController
	self.notificationController = notificationController
	self.notifications = {}
end

function PartyController.onStart(self: PartyController)
	Events.PartyInvite:connect(
		function(inviteId: string, inviter: { UserId: number, UserName: string, DisplayName: string }, partyId: string)
			local notification = {
				["Title"] = inviter.DisplayName,
				["Message"] = "has invited you to their party",
				["Player"] = inviter,
				["Duration"] = PARTY_INVITE_TIMEOUT,
				["Activated"] = function()
					self:updateInvite(inviteId, partyId, true)
				end,
				["Declined"] = function()
					self:updateInvite(inviteId, partyId, false)
				end,
			}
			local notificationHandle = self.notificationController:displayNotification(notification, function()
				local notifications = self.notifications
				local removed = notifications[inviteId] ~= nil
				notifications[inviteId] = nil
				return removed
			end)
			self.notifications[inviteId] = notificationHandle
		end
	)
	Events.PartyInviteCancelled:connect(function(inviteId: string)
		local notificationHandle = self.notifications[inviteId]
		if notificationHandle then
			notificationHandle:close()
		end
	end)
	Events.PartyUpdated:connect(function(party)
		local resolvedParty = party or DefaultProfileStore.Party
		Flamework.resolveDependency("zG"):setValue("Party", resolvedParty)
	end)
end

function PartyController.invitePlayer(_, player, isOffline: boolean)
	local party = GlobalStore:getState().Party
	if party and PartyUtil.isFull(party, false) then
		return nil
	end
	Events.InvitePlayerToParty:fire(player, isOffline)
end

function PartyController.promotePlayer(_, player)
	Events.PartyPromote:fire(player)
end

function PartyController.removePlayer(_, userId: number)
	Events.PartyRemove:fire(userId)
end

function PartyController.leaveParty(_)
	Events.PartyLeave:fire()
end

function PartyController.updateInvite(_, inviteId: string, partyId: string, accepted: boolean)
	Events.PartyInviteResponse:fire(inviteId, partyId, accepted)
end

function PartyController.toggleScreen(self)
	self.screenController:toggle(PartyScreen)
end

function PartyController.sendOfflineInvite(_, userId: number)
	local partyId = GlobalStore:getState().Party.Id
	if partyId == "" or not partyId then
		return nil
	end
	local inviteOptions = Instance.new("ExperienceInviteOptions")
	inviteOptions.InviteUser = userId
	inviteOptions.PromptMessage = "Invite this friend to join your party!"
	inviteOptions.InviteMessageId = "795af254-2c5b-8a49-8736-4f07b96840bc"
	inviteOptions.LaunchData = HttpService:JSONEncode({
		["PartyId"] = nil,
		["Type"] = "PartyAcceptInvite",
		["PartyId"] = partyId,
	})
	SocialService:PromptGameInvite(Players.LocalPlayer, inviteOptions)
end

function PartyController.getPartyId(_): string?
	local partyId = GlobalStore:getState().Party.Id
	if partyId == "" then
		return nil
	else
		return partyId
	end
end

Reflect.defineMetadata(PartyController, "identifier", "PrB")
Reflect.defineMetadata(PartyController, "flamework:parameters", { "lB5", "Odx" })
Reflect.defineMetadata(PartyController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PartyController, "$:flamework@Controller", Controller, {})

return {
	["PartyController"] = PartyController,
}
