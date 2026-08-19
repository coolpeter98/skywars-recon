-- useSeasonData hook

type Maid = {
	new: () -> Maid,
	GiveTask: (self: Maid, task: any) -> any,
	DoCleaning: (self: Maid) -> (),
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GlobalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local GlobalStore: { getState: () -> any } = GlobalStoreModule.GlobalStore
local GlobalStoreChanged = GlobalStoreModule.GlobalStoreChanged
local Maid: Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local CurrentSeason =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeason
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect: (callback: () -> (() -> ())?, deps: { any }) -> () = React.useEffect
local useState: <T>(initialValue: T) -> (T, (value: T) -> ()) = React.useState

return {
	["useSeasonData"] = function()
		local season, setSeason = useState(GlobalStore:getState().Profile.Season)

		useEffect(function()
			local maid = Maid.new()
			local connection = GlobalStoreChanged("Profile", function(state, _)
				setSeason(state.Season)
			end)

			maid:GiveTask(function()
				return connection:disconnect()
			end)

			return function()
				return maid:DoCleaning()
			end
		end, {})

		return season.SeasonData[CurrentSeason]
	end,
}
