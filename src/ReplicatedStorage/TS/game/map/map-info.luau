-- MapInfo

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil

type MapInfo = {
	Name: string,
	DisplayName: string,
	GameType: string,
	Image: string?,
	PartySupported: boolean?,
	Ref: Instance?,
	PartyRef: Instance?,
}

local maps: { [string]: MapInfo } = {}
for _, mapInfo: MapInfo in
	{
		{
			Name = "HomeTree",
			DisplayName = "Home Tree",
			GameType = "SkyWars",
			Image = RobloxImage.Map.HOME_TREE,
		},
		{
			Name = "Construction",
			DisplayName = "Construction",
			GameType = "SkyWars",
			Image = RobloxImage.Map.CONSTRUCTION,
		},
		{
			Name = "WildWest",
			DisplayName = "Wild West",
			GameType = "SkyWars",
			Image = RobloxImage.Map.WILD_WEST,
		},
		{
			Name = "Sakura",
			DisplayName = "Sakura",
			GameType = "SkyWars",
			Image = RobloxImage.Map.SAKURA,
		},
		{
			Name = "Acropolis",
			DisplayName = "Acropolis",
			GameType = "SkyWars",
			Image = RobloxImage.Map.ACROPOLIS,
		},
		{
			Name = "Farmland",
			DisplayName = "Farmland",
			GameType = "SkyWars",
			Image = RobloxImage.Map.FARMLAND,
		},
		{
			Name = "Aztec",
			DisplayName = "Aztec",
			GameType = "SkyWars",
			Image = RobloxImage.Map.AZTEC,
		},
		{
			Name = "Colosseum",
			DisplayName = "Colosseum",
			GameType = "SkyWars",
			Image = RobloxImage.Map.COLOSSEUM,
		},
		{
			Name = "Savannah",
			DisplayName = "Savannah",
			GameType = "SkyWars",
			Image = RobloxImage.Map.SAVANNAH,
		},
		{
			Name = "Airport",
			DisplayName = "Airport",
			GameType = "SkyWars",
			Image = RobloxImage.Map.AIRPORT,
		},
		{
			Name = "Prison",
			DisplayName = "Prison",
			GameType = "SkyWars",
			Image = RobloxImage.Map.PRISON,
		},
		{
			Name = "Bank",
			DisplayName = "Bank",
			GameType = "SkyWars",
			Image = RobloxImage.Map.BANK,
		},
		{
			Name = "ThemePark",
			DisplayName = "Theme Park",
			GameType = "SkyWars",
			Image = RobloxImage.Map.THEME_PARK,
		},
		{
			Name = "Castle",
			DisplayName = "Castle",
			GameType = "Duels",
			Image = RobloxImage.Map.CASTLE_BRIDGE,
			PartySupported = false,
		},
		{
			Name = "Tundra",
			DisplayName = "Tundra",
			GameType = "SkyWars",
			Image = RobloxImage.Map.TUNDRA,
		},
		{
			Name = "Ruins",
			DisplayName = "Ruins",
			GameType = "SkyWars",
			Image = RobloxImage.Map.RUINS,
		},
		{
			Name = "Cargo",
			DisplayName = "Cargo",
			GameType = "SkyWars",
			Image = RobloxImage.Map.CARGO,
		},
		{
			Name = "Suburbia",
			DisplayName = "Suburbia",
			GameType = "SkyWars",
			Image = RobloxImage.Map.SUBURBIA,
		},
		{
			Name = "GrandPrix",
			DisplayName = "Grand Prix",
			GameType = "SkyWars",
			Image = RobloxImage.Map.GRAND_PRIX,
		},
		{
			Name = "Ships",
			DisplayName = "Ships",
			GameType = "Duels",
			Image = RobloxImage.Map.SHIPS_BRIDGE,
			PartySupported = false,
		},
		{
			Name = "Ash",
			DisplayName = "Ash",
			GameType = "SkyWars",
			Image = RobloxImage.Map.ASH,
		},
		{
			Name = "Cove",
			DisplayName = "Cove",
			GameType = "SkyWars",
			Image = RobloxImage.Map.COVE,
			PartySupported = false,
		},
		{
			Name = "Fungiland",
			DisplayName = "Fungiland",
			GameType = "SkyWars",
			Image = RobloxImage.Map.FUNGILAND,
		},
		{
			Name = "Atlantis",
			DisplayName = "Atlantis",
			GameType = "SkyWars",
			Image = RobloxImage.Map.ATLANTIS,
		},
		{
			Name = "Sphinx",
			DisplayName = "Sphinx",
			GameType = "SkyWars",
			Image = RobloxImage.Map.SPHINX,
		},
		{
			Name = "PhoenixGate",
			DisplayName = "Phoenix Gate",
			GameType = "SkyWars",
			Image = RobloxImage.Map.PHOENIX_GATE,
		},
		{
			Name = "Mines",
			DisplayName = "Mines",
			GameType = "SkyWars",
			Image = RobloxImage.Map.MINES,
		},
		{
			Name = "PhoenixBridge",
			DisplayName = "Phoenix Bridge",
			GameType = "Duels",
			Image = RobloxImage.Map.PHOENIX_BRIDGE,
			PartySupported = false,
		},
		{
			Name = "Neon",
			DisplayName = "Neon",
			GameType = "SkyWars",
			Image = RobloxImage.Map.AIRPORT,
		},
		{
			Name = "ConstructionEgg",
			DisplayName = "ConstructionEgg",
			GameType = "EggWars",
			Image = RobloxImage.Map.AIRPORT,
			PartySupported = false,
		},
		{
			Name = "PhoenixEgg",
			DisplayName = "PhoenixEgg",
			GameType = "EggWars",
			Image = RobloxImage.Map.AIRPORT,
			PartySupported = false,
		},
		{
			Name = "FarmlandEgg",
			DisplayName = "FarmlandEgg",
			GameType = "EggWars",
			Image = RobloxImage.Map.AIRPORT,
			PartySupported = false,
		},
		{
			Name = "TundraEgg",
			DisplayName = "TundraEgg",
			GameType = "EggWars",
			Image = RobloxImage.Map.AIRPORT,
			PartySupported = false,
		},
		{
			Name = "AtlantisEgg",
			DisplayName = "AtlantisEgg",
			GameType = "EggWars",
			Image = RobloxImage.Map.AIRPORT,
			PartySupported = false,
		},
	}
do
	local shouldAddToMaps = true
	if RunService:IsServer() then
		local ServerStorage: ServerStorage = game:GetService("ServerStorage")
		if PlaceUtil.isProduction() or ServerStorage.Maps[mapInfo.GameType]:FindFirstChild(mapInfo.Name) then
			mapInfo.Ref = ServerStorage.Maps[mapInfo.GameType][mapInfo.Name]
			local partyName = ("%*_party"):format(mapInfo.Name)
			if mapInfo.PartySupported ~= false then
				if PlaceUtil.isProduction() or ServerStorage.Maps[mapInfo.GameType]:FindFirstChild(partyName) then
					mapInfo.PartyRef = ServerStorage.Maps[mapInfo.GameType][partyName]
				else
					mapInfo.PartySupported = false
				end
			end
		else
			print("Skipped loading map")
			shouldAddToMaps = false
		end
	end
	if shouldAddToMaps then
		maps[mapInfo.Name] = mapInfo
	end
end
return {
	Maps = maps,
}
