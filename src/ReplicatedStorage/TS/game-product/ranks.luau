-- Ranks

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji

type Rank = {
	Name: string,
	Color: Color3?,
	Icon: any?,
}

local Ranks: { [string]: Rank } = {
	["ADMIN"] = {
		["Name"] = "Admin",
		["Color"] = nil,
		["Icon"] = nil,
		["Color"] = Color3.fromRGB(255, 0, 0),
		["Icon"] = Emoji.Crown
	},
	["MODERATOR"] = {
		["Name"] = "Moderator",
		["Color"] = nil,
		["Icon"] = nil,
		["Color"] = Color3.fromRGB(116, 195, 255),
		["Icon"] = Emoji.Shield
	},
	["EARLY_SUPPORTER"] = {
		["Name"] = "Early Supporter",
		["Color"] = nil,
		["Icon"] = nil,
		["Color"] = Color3.fromRGB(255, 172, 51),
		["Icon"] = Emoji.Dizzy
	},
	["VERIFIED"] = {
		["Name"] = "Verified",
		["Color"] = nil,
		["Icon"] = nil,
		["Color"] = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color.Green,
		["Icon"] = Emoji.CheckMark
	}
}
return {
	["Ranks"] = Ranks
}
