-- usePlayerSearch

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
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
	["usePlayerSearch"] = function(searchQuery: string): { Player }
		local players, setPlayers = useState(Players:GetPlayers())
		useEffect(function()
			local maid = Maid.new()
			local function updatePlayers()
				return setPlayers(Players:GetPlayers())
			end
			maid:GiveTask(Players.PlayerAdded:Connect(updatePlayers))
			maid:GiveTask(Players.PlayerRemoving:Connect(updatePlayers))
			return function()
				return maid:DoCleaning()
			end
		end, {})
		local function filterPlayer(player: Player): boolean
			local query
			if searchQuery == "" then
				query = false
			else
				query = searchQuery
			end
			local matches = not query
			if not matches then
				local lowerDisplayName = string.lower(player.DisplayName)
				local lowerQuery = string.lower(searchQuery)
				local matchResult = string.match(lowerDisplayName, lowerQuery)
				if matchResult == 0 or matchResult ~= matchResult then
					matchResult = false
				elseif matchResult == "" then
					matchResult = false
				end
				matches = matchResult and true or false
			end
			return matches
		end
		local resultCount = 0
		local results = {}
		for i, player in players do
			if filterPlayer(player, i - 1, players) == true then
				resultCount = resultCount + 1
				results[resultCount] = player
			end
		end
		return results
	end,
}
