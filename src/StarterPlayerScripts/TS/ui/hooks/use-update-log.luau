-- useUpdateLog

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
local useState = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"react"
).useState

return {
	["useUpdateLog"] = function()
		local profile = useProfile()
		local updateLog = useState(profile.UpdateLog)
		return {
			["UpdateLog"] = updateLog,
			["HasUpdated"] = function(...)
				return Flamework.resolveDependency("9ll"):hasUpdated({ ... }, updateLog)
			end,
			["AddUpdatesToProfile"] = function(...)
				return Flamework.resolveDependency("9ll"):addUpdatesToProfile({ ... }, profile)
			end,
		}
	end,
}
