-- LeaderboardController

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
local UserService: UserService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).UserService
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ProfileStoreActionType = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"rodux",
	"profile-store"
).ProfileStoreActionType

type LeaderboardEntry = {
	PlayerId: number,
	StatId: string,
	Value: number,
	Position: number,
}

local LeaderboardController = setmetatable({}, {
	["__tostring"] = function()
		return "LeaderboardController"
	end,
})
LeaderboardController.__index = LeaderboardController

function LeaderboardController.new(...)
	local self = setmetatable({}, LeaderboardController)
	return self:constructor(...) or self
end

function LeaderboardController.constructor(_) end

function LeaderboardController.onStart(_)
	Events["e6dfa573-8fbd-41bb-ad88-ec9b831bb8c5"]:connect(
		function(leaderboardKey: string, leaderboardEntries: { LeaderboardEntry }, receiveTime: number)
			local stats: { LeaderboardEntry & { DisplayName: string } } = {}
			RuntimeLib.try(function()
				local playerIds = table.create(#leaderboardEntries)
				for index, entry in leaderboardEntries do
					local _ = index - 1
					playerIds[index] = entry.PlayerId
				end
				for _, userInfo: UserInfo in UserService:GetUserInfosByUserIdsAsync(playerIds) do
					local matchedEntry: LeaderboardEntry? = nil
					for index, entry in leaderboardEntries do
						local _ = index - 1
						if entry.PlayerId == userInfo.Id == true then
							matchedEntry = entry
							break
						end
					end
					if matchedEntry then
						local stat = {
							["PlayerId"] = matchedEntry.PlayerId,
							["DisplayName"] = userInfo.DisplayName,
							["StatId"] = matchedEntry.StatId,
							["Value"] = matchedEntry.Value,
							["Position"] = matchedEntry.Position,
						}
						table.insert(stats, stat)
					end
				end
			end, function(err)
				print(err)
			end)
			GlobalStore:dispatch({
				["type"] = ProfileStoreActionType.UpdateLeaderboard,
				["stats"] = stats,
				["leaderboardKey"] = leaderboardKey,
				["receiveTime"] = receiveTime,
			})
		end
	)
end

function LeaderboardController.pollLeaderboard(
	_,
	leaderboardType: string,
	statId: string,
	statGranularity: string,
	friendIds: { number }?
)
	if friendIds == nil then
		friendIds = nil
	end
	Events["8cac52e9-4b81-4d57-976d-08c4649b1a74"]:fire(leaderboardType, statId, statGranularity, friendIds)
end

Reflect.defineMetadata(LeaderboardController, "identifier", "xBL")
Reflect.defineMetadata(LeaderboardController, "flamework:implements", { "$:flamework@OnStart" })
Controller.decorate(LeaderboardController, "$:flamework@Controller", Controller, {})
return {
	["LeaderboardController"] = LeaderboardController,
}
