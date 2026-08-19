-- PowerUps

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation

type PowerUp = {
	Type: string,
	DisplayName: string,
	Duration: number,
	Icon: any,
	Color: any,
	Animation: any?,
}

local powerUps: { [string]: PowerUp } = {}
for _, powerUp: PowerUp in
	{
		{
			["Type"] = "SpeedBoost",
			["DisplayName"] = "Speed Boost",
			["Duration"] = 30,
			["Icon"] = nil,
			["Color"] = nil,
			["Icon"] = RobloxImage.Icon.BOLT,
			["Color"] = Color.LightBlue,
		},
		{
			["Type"] = "JumpBoost",
			["DisplayName"] = "Jump Boost",
			["Duration"] = 20,
			["Icon"] = nil,
			["Color"] = nil,
			["Icon"] = RobloxImage.Icon.RABBIT_RUNNING,
			["Color"] = Color.Green,
		},
		{
			["Type"] = "LifeSteal",
			["DisplayName"] = "Life Steal",
			["Duration"] = 60,
			["Icon"] = nil,
			["Color"] = nil,
			["Icon"] = RobloxImage.Icon.HEART_CRACK,
			["Color"] = Color.Purple,
		},
		{
			["Type"] = "Shield",
			["DisplayName"] = "Shield",
			["Duration"] = 60,
			["Icon"] = nil,
			["Color"] = nil,
			["Icon"] = RobloxImage.Icon.SHIELD,
			["Color"] = Color.Blue,
		},
		{
			["Type"] = "Adrenaline",
			["DisplayName"] = "Adrenaline",
			["Duration"] = 30,
			["Icon"] = nil,
			["Color"] = nil,
			["Animation"] = nil,
			["Icon"] = RobloxImage.Icon.SHIELD,
			["Color"] = Color.Yellow,
			["Animation"] = RobloxAnimation.ADRENALINE_INJECT,
		},
	}
do
	powerUps[powerUp.Type] = powerUp
end

return {
	PowerUps = powerUps,
}
