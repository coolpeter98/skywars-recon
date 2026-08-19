-- ProfileStore

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local SharedDataProfileTemplate = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"profile",
	"data-profile"
).SharedDataProfileTemplate
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

type LeaderboardEntry = {
	Stats: any?,
	ReceiveTime: any?,
	Loading: boolean,
}

type ProfileStoreState = {
	Profile: any?,
	Party: any?,
	Friends: any?,
	FriendIds: any?,
	ShowVerify: boolean,
	Leaderboards: { [string]: LeaderboardEntry }?,
}

type ProfileStoreAction = {
	type: string,
	stats: any?,
	receiveTime: any?,
	leaderboardKey: string?,
}

local ProfileStoreActionType = {
	["UpdateLeaderboard"] = "UpdateLeaderboard",
}

local function ProfileStoreReducer(state: ProfileStoreState, action: ProfileStoreAction): ProfileStoreState?
	if action.type == ProfileStoreActionType.UpdateLeaderboard then
		local leaderboardEntry = {
			["Stats"] = nil,
			["ReceiveTime"] = nil,
			["Loading"] = false,
			["Stats"] = action.stats,
			["ReceiveTime"] = action.receiveTime,
		}
		local leaderboards = table.clone(state.Leaderboards)
		leaderboards[action.leaderboardKey] = leaderboardEntry
		local newState = table.clone(state)
		setmetatable(newState, nil)
		newState.Leaderboards = leaderboards
		return newState
	end
end

return {
	["ProfileStoreReducer"] = ProfileStoreReducer,
	["DefaultProfileStore"] = {
		["Profile"] = nil,
		["Party"] = nil,
		["Friends"] = nil,
		["FriendIds"] = nil,
		["ShowVerify"] = false,
		["Leaderboards"] = nil,
		["Profile"] = SharedDataProfileTemplate,
		["Party"] = PartyUtil.getDefaultParty(Players.LocalPlayer),
		["Friends"] = {},
		["FriendIds"] = {},
		["Leaderboards"] = {},
	},
	["ProfileStoreActionType"] = ProfileStoreActionType,
}
