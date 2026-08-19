-- LevelRewards

type LevelRewards = {
	[number]: { string },
}

local CosmeticId: {
	CapeLevelTen: string,
	CapeLevelTwenty: string,
	CapeLevelThirty: string,
	CapeLevelForty: string,
	CapeLevelFifty: string,
} =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"cosmetic",
		"cosmetic-id"
	).CosmeticId

local LevelRewards: LevelRewards = {
	[10] = { CosmeticId.CapeLevelTen },
	[20] = { CosmeticId.CapeLevelTwenty },
	[30] = { CosmeticId.CapeLevelThirty },
	[40] = { CosmeticId.CapeLevelForty },
	[50] = { CosmeticId.CapeLevelFifty },
}

return {
	["getLevelUnlocked"] = function(item: string?): number?
		if not item then
			return nil
		end
		for level, rewards in LevelRewards do
			if table.find(rewards, item) ~= nil then
				return level
			end
		end
		return nil
	end,
	["LevelRewards"] = LevelRewards,
}
