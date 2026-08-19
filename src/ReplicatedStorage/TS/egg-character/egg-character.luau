-- EggCharacter

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type EggHatType = "Viking" | "TopHat" | "Straw" | "ConstructionHelmet"
type EggToolType = "Pitchfork" | "Hammer" | "Cane" | "Axe"

type EggCharacter = {
	ColorName: string,
	Name: string,
	HatType: EggHatType?,
	ToolType: EggToolType?,
	Color: Color3?,
	ColorId: string,
	IconId: string?,
	IconDeadId: string?,
}

local EggHatType: { [string]: EggHatType } = {
	["Viking"] = "Viking",
	["TopHat"] = "TopHat",
	["Straw"] = "Straw",
	["ConstructionHelmet"] = "ConstructionHelmet"
}

local EggToolType: { [string]: EggToolType } = {
	["Pitchfork"] = "Pitchfork",
	["Hammer"] = "Hammer",
	["Cane"] = "Cane",
	["Axe"] = "Axe"
}

local EggCharacters: { [string]: EggCharacter } = {}
for _, eggCharacter in {
	{
		["ColorName"] = "Red",
		["Name"] = "Benedict Egg",
		["HatType"] = nil,
		["ToolType"] = nil,
		["Color"] = nil,
		["ColorId"] = "rbxassetid://11601341136",
		["IconId"] = nil,
		["IconDeadId"] = nil,
		["HatType"] = EggHatType.TopHat,
		["ToolType"] = EggToolType.Cane,
		["Color"] = Color.Red,
		["IconId"] = RobloxImage.Egg.RED,
		["IconDeadId"] = RobloxImage.EggDead.RED
	},
	{
		["ColorName"] = "Lime",
		["Name"] = "Egg Hutch",
		["HatType"] = nil,
		["ToolType"] = nil,
		["Color"] = nil,
		["ColorId"] = "rbxassetid://11600030439",
		["IconId"] = nil,
		["IconDeadId"] = nil,
		["HatType"] = EggHatType.Straw,
		["ToolType"] = EggToolType.Pitchfork,
		["Color"] = Color.Green,
		["IconId"] = RobloxImage.Egg.GREEN,
		["IconDeadId"] = RobloxImage.EggDead.GREEN
	},
	{
		["ColorName"] = "Cyan",
		["Name"] = "Hard Boiled Egg",
		["HatType"] = nil,
		["ToolType"] = nil,
		["Color"] = nil,
		["ColorId"] = "rbxassetid://11601338552",
		["IconId"] = nil,
		["IconDeadId"] = nil,
		["HatType"] = EggHatType.ConstructionHelmet,
		["ToolType"] = EggToolType.Hammer,
		["Color"] = Color.LightBlue,
		["IconId"] = RobloxImage.Egg.BLUE,
		["IconDeadId"] = RobloxImage.EggDead.BLUE
	},
	{
		["ColorName"] = "Yellow",
		["Name"] = "Ogg Egg",
		["HatType"] = nil,
		["ToolType"] = nil,
		["Color"] = nil,
		["ColorId"] = "rbxassetid://11601342933",
		["IconId"] = nil,
		["IconDeadId"] = nil,
		["HatType"] = EggHatType.Viking,
		["ToolType"] = EggToolType.Axe,
		["Color"] = Color.Yellow,
		["IconId"] = RobloxImage.Egg.YELLOW,
		["IconDeadId"] = RobloxImage.EggDead.YELLOW
	}
} do
	EggCharacters[eggCharacter.ColorName] = eggCharacter
end
return {
	["EggHatType"] = EggHatType,
	["EggToolType"] = EggToolType,
	["EggCharacters"] = EggCharacters
}
