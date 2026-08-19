-- useChangelog

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useCallback = React.useCallback
local useMemo = React.useMemo
local ChangelogList =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "changelog", "changelog").ChangelogList
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile

type ChangelogEntry = {
	Name: string,
	Timestamp: number,
	Changes: { any },
}

return {
	["useChangelog"] = function()
		local profile = useProfile()
		local getChangelogItem = useCallback(function(changelog: ChangelogEntry)
			return { changelog, changelog.Timestamp < profile.PreviousJoinedTime }
		end, { profile.PreviousJoinedTime })

		local sortByNewest = useCallback(function(a, b)
			return a[1].Timestamp > b[1].Timestamp
		end, {})

		return useMemo(function()
			local changelogItems = table.create(#ChangelogList)
			for index, changelog in ChangelogList do
				changelogItems[index] = getChangelogItem(changelog, index - 1, ChangelogList)
			end
			table.sort(changelogItems, sortByNewest)
			return changelogItems
		end, { getChangelogItem, sortByNewest })
	end,
}
