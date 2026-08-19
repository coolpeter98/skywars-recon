-- CosmeticType

type CosmeticType = {
	Id: string,
	CategoryName: string,
}

local cosmeticTypes: { [string]: CosmeticType } = {}
for _, cosmeticType in
	{
		{
			["Id"] = "WinEffect",
			["CategoryName"] = "Win Effects",
		},
		{
			["Id"] = "KillEffect",
			["CategoryName"] = "Kill",
		},
		{
			["Id"] = "Skin",
			["CategoryName"] = "Skins",
		},
		{
			["Id"] = "Cage",
			["CategoryName"] = "Cages",
		},
		{
			["Id"] = "Cape",
			["CategoryName"] = "Capes",
		},
		{
			["Id"] = "Title",
			["CategoryName"] = "Titles",
		},
		{
			["Id"] = "Package",
			["CategoryName"] = "Armour",
		},
		{
			["Id"] = "ArrowTrailEffect",
			["CategoryName"] = "Arrows",
		},
	}
do
	cosmeticTypes[cosmeticType.Id] = cosmeticType
end
return {
	["isCosmeticType"] = function(id: string): boolean
		return cosmeticTypes[id] ~= nil
	end,
	["CosmeticTypes"] = cosmeticTypes,
}
