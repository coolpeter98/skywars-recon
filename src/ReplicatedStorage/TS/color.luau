-- Color

local Color: { [string]: Color3 | { [string]: Color3 } } = {
	["White"] = Color3.fromRGB(255, 255, 255),
	["Black"] = Color3.fromRGB(0, 0, 0),
	["HealthGreen"] = Color3.fromRGB(102, 255, 99),
	["Green"] = Color3.fromRGB(54, 226, 112),
	["HealthRed"] = Color3.fromRGB(223, 66, 75),
	["Red"] = Color3.fromRGB(224, 103, 103),
	["HealthOrange"] = Color3.fromRGB(244, 156, 74),
	["Orange"] = Color3.fromRGB(245, 141, 44),
	["Yellow"] = Color3.fromRGB(255, 238, 81),
	["PartyYellow"] = Color3.fromRGB(255, 205, 76),
	["Purple"] = Color3.fromRGB(154, 89, 204),
	["Pink"] = Color3.fromRGB(252, 3, 227),
	["LightGrey"] = Color3.fromRGB(166, 166, 166),
	["Grey"] = Color3.fromRGB(65, 65, 65),
	["LightBlue"] = Color3.fromRGB(43, 181, 224),
	["Blue"] = Color3.fromRGB(43, 80, 224),
	["PlaceholderGrey"] = Color3.fromRGB(196, 196, 196),
	["VoxelGreen"] = Color3.fromRGB(43, 177, 94),
	["VoxelGrey"] = Color3.fromRGB(26, 26, 26),
	["ViewportGrey"] = Color3.fromRGB(39, 45, 47),
	["ViewportLightGrey"] = Color3.fromRGB(65, 91, 129),
	["Mobile"] = {
		["Aqua"] = Color3.fromRGB(52, 235, 235),
		["Red"] = Color3.fromRGB(223, 94, 66),
		["Yellow"] = Color3.fromRGB(220, 223, 66),
		["Blue"] = Color3.fromRGB(43, 181, 224),
	},
	["Card"] = {
		["Green"] = Color3.fromRGB(54, 226, 112),
		["Blue"] = Color3.fromRGB(43, 181, 224),
		["Red"] = Color3.fromRGB(249, 88, 78),
		["Purple"] = Color3.fromRGB(174, 73, 175),
	},
}
local ButtonColors: { [string]: { Primary: Color3, Light: Color3, Dark: Color3 } } = {
	["Green"] = {
		["Primary"] = Color.Green,
		["Light"] = Color3.fromRGB(124, 240, 112),
		["Dark"] = Color3.fromRGB(32, 177, 81),
	},
	["Blue"] = {
		["Primary"] = Color.LightBlue,
		["Light"] = Color3.fromRGB(74, 212, 255),
		["Dark"] = Color3.fromRGB(31, 144, 178),
	},
	["Purple"] = {
		["Primary"] = Color.Purple,
		["Light"] = Color3.fromRGB(188, 120, 240),
		["Dark"] = Color3.fromRGB(141, 56, 207),
	},
	["Red"] = {
		["Primary"] = Color.Red,
		["Light"] = Color3.fromRGB(244, 138, 138),
		["Dark"] = Color3.fromRGB(191, 69, 69),
	},
	["Grey"] = {
		["Primary"] = Color3.fromRGB(114, 114, 114),
		["Light"] = Color3.fromRGB(135, 135, 135),
		["Dark"] = Color3.fromRGB(80, 80, 80),
	},
	["Yellow"] = {
		["Primary"] = Color3.fromRGB(255, 203, 103),
		["Light"] = Color3.fromRGB(255, 220, 152),
		["Dark"] = Color3.fromRGB(220, 173, 82),
	},
}
Color.Button = ButtonColors
Color.Team = {
	["LightBlue"] = Color3.fromRGB(171, 196, 255),
	["Red"] = Color3.fromRGB(255, 0, 0),
	["Lime"] = Color3.fromRGB(52, 235, 88),
	["Yellow"] = Color3.fromRGB(252, 255, 0),
	["Blue"] = Color3.fromRGB(0, 179, 255),
	["Cyan"] = Color3.fromRGB(33, 159, 148),
	["Orange"] = Color3.fromRGB(253, 166, 0),
	["Purple"] = Color3.fromRGB(86, 3, 189),
	["Pink"] = Color3.fromRGB(255, 93, 228),
	["Magenta"] = Color3.fromRGB(255, 0, 151),
	["White"] = Color3.fromRGB(255, 255, 255),
	["Brown"] = Color3.fromRGB(82, 55, 47),
}
Color.Health = {
	["Green"] = Color3.fromRGB(102, 255, 99),
}
Color.GameMode = {
	["LightGreen"] = Color3.fromRGB(174, 255, 201),
	["LightBlue"] = Color3.fromRGB(182, 229, 255),
	["LightRed"] = Color3.fromRGB(255, 175, 170),
}
Color.Rarity = {
	["Grey"] = Color3.fromRGB(124, 124, 124),
	["Green"] = Color3.fromRGB(68, 187, 68),
	["Blue"] = Color3.fromRGB(75, 115, 255),
	["Purple"] = Color3.fromRGB(141, 56, 207),
	["Gold"] = Color3.fromRGB(241, 196, 15),
	["Red"] = Color3.fromRGB(208, 33, 33),
}
Color.Level = {
	["TierOne"] = Color3.fromRGB(182, 182, 182),
	["TierTwo"] = Color3.fromRGB(113, 219, 168),
	["TierThree"] = Color3.fromRGB(255, 220, 115),
	["TierFour"] = Color3.fromRGB(142, 202, 255),
	["TierFive"] = Color3.fromRGB(185, 141, 239),
	["TierSix"] = Color3.fromRGB(255, 94, 94),
	["TierSeven"] = Color3.fromRGB(28, 165, 99),
	["TierEight"] = Color3.fromRGB(255, 190, 64),
	["TierNine"] = Color3.fromRGB(68, 87, 255),
	["TierTen"] = Color3.fromRGB(144, 57, 255),
}
Color.Loading = {
	["Blue"] = Color3.fromRGB(19, 88, 225),
}
Color.Shop = {
	["SeasonPass"] = Color3.fromRGB(211, 174, 27),
	["Crate"] = Color3.fromRGB(122, 70, 208),
	["Bundle"] = Color3.fromRGB(45, 77, 236),
	["SeasonPassRed"] = Color.Level.TierSix,
	["KnightBruteCrate"] = Color.Level.TierFour,
	["NinjaCrate"] = Color3.fromRGB(182, 94, 206),
	["BundleGreen"] = Color.Level.TierSeven,
}
return {
	["Color"] = Color,
}
