-- useExperience

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local rodux = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local GlobalStore = rodux.GlobalStore
local GlobalStoreChanged = rodux.GlobalStoreChanged
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

return {
	["useExperience"] = function()
		local experience: number, setExperience: (newExperience: number) -> () =
			useState(GlobalStore:getState().Profile.Experience)

		useEffect(function()
			local maid = Maid.new()

			local connection = GlobalStoreChanged("Profile", function(newProfile, previousProfile)
				local newExperience = newProfile.Experience
				if newExperience ~= previousProfile.Experience then
					setExperience(newExperience)
				end
			end)

			maid:GiveTask(function()
				return connection:disconnect()
			end)

			return function()
				maid:DoCleaning()
			end
		end, {})

		return experience
	end,
}
