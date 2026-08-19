-- usePlayerTitle hook

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local useAttribute = RuntimeLib.import(script, script.Parent, "use-attribute").useAttribute
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Ranks = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "ranks").Ranks
return {
	["usePlayerTitle"] = function(playerData: { Player: Player })
		local rank = useAttribute(playerData.Player, Attribute.Rank)
		local title = useAttribute(playerData.Player, Attribute.Title)
		if rank then
			rank = Ranks[rank]
		end
		if title then
			title = Cosmetics[title]
		end
		return title and {
			["Title"] = title.Title,
			["Color"] = title.Color,
			["Icon"] = title.Icon,
		} or (rank and {
			["Title"] = rank.Name,
			["Color"] = rank.Color,
			["Icon"] = rank.Icon,
		} or nil)
	end,
}
