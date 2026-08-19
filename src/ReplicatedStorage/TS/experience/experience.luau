-- ExperienceCauses

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage

type ExperienceCause = {
	Text: string,
	Image: string?,
	Color: Color3?,
}

local ExperienceCauses: { [string]: ExperienceCause } = {
	TimePlayed = {
		Text = "Time Played",
		Image = "",
		Color = Color.Green,
	},
	PodiumPosition = {
		Text = "Podium",
		Image = RobloxImage.Icon.TROPHY,
		Color = Color.Green,
	},
	PlayerKill = {
		Text = "Kills",
		Image = RobloxImage.Icon.SWORDS,
		Color = Color.Green,
	},
	EggKill = {
		Text = "Egg Kill",
		Image = RobloxImage.Icon.EGG,
		Color = Color.Green,
	},
	Mission = {
		Text = "Missions",
		Image = RobloxImage.Icon.LIST_CHECK,
		Color = Color.Green,
	},
	LoginStreak = {
		Text = "Daily Login",
		Image = RobloxImage.Icon.CLOCK,
		Color = Color.Yellow,
	},
	SummerScavengerHunt = {
		Text = "Duck Hunt",
		Image = RobloxImage.Icon.CLOCK,
		Color = Color.Yellow,
	},
}
return {
	["ExperienceCauses"] = ExperienceCauses,
}
