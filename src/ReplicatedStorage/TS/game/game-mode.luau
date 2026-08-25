-- GameMode

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local QueueId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "matchmaking", "queue-id").QueueId
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type MapSettings = {
	Size: string,
	ExcludedRegions: { string }?,
}

type RespawnBehaviour = {
	Type: string,
	Delay: number?,
	Scaling: ((playerCount: number) -> number)?,
}

type GameModeExperience = {
	ExperiencePerKill: number,
	ExperiencePerAssist: number,
	ExperiencePerPosition: { number }?,
}

type GameModeDefinition = {
	Type: string,
	GameType: string,
	TeamSize: number,
	MaxTeams: number,
	DisplayName: string,
	AllowedInPrivate: boolean,
	Queue: { Production: string, Testing: string? }?,
	Image: any?,
	Color: any?,
	LightColor: any?,
	MapSettings: MapSettings?,
	RespawnBehaviour: RespawnBehaviour?,
	Experience: GameModeExperience?,
}

local GameMode = {
	SkyWarsSolo = "SkyWarsSolo",
	SkyWarsDuos = "SkyWarsDuos",
	SkyWarsTrios = "SkyWarsTrios",
	SkyWarsQuads = "SkyWarsQuads",
	SkyWarsOctos = "SkyWarsOctos",
	DuelsSolo = "DuelsSolo",
	DuelsDuos = "DuelsDuos",
	EggWarsQuads = "EggWarsQuads",
}

local skyWarsSolo: GameModeDefinition = {
	Type = GameMode.SkyWarsSolo,
	GameType = "SkyWars",
	TeamSize = 1,
	MaxTeams = 12,
	DisplayName = "Solo",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.Solo,
		Testing = QueueId.TestingSolo,
	},
	Image = RobloxImage.GameMode.SOLO,
	Color = Color.Green,
	LightColor = Color.GameMode.LightGreen,
	MapSettings = {
		Size = "Small",
	},
	RespawnBehaviour = {
		Type = "Never",
	},
	Experience = {
		ExperiencePerKill = 50,
		ExperiencePerAssist = 25,
		ExperiencePerPosition = {
			750,
			550,
			475,
			350,
			250,
			175,
			150,
			125,
			75,
			60,
			45,
			35,
		},
	},
}

local skyWarsDuos: GameModeDefinition = {
	Type = GameMode.SkyWarsDuos,
	GameType = "SkyWars",
	TeamSize = 2,
	MaxTeams = 12,
	DisplayName = "Party",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.Duos,
		Testing = QueueId.TestingDuos,
	},
	Image = RobloxImage.GameMode.DUOS,
	Color = Color.LightBlue,
	LightColor = Color.GameMode.LightBlue,
	MapSettings = {
		Size = "Large",
	},
	RespawnBehaviour = {
		Type = "Never",
	},
	Experience = {
		ExperiencePerKill = 50,
		ExperiencePerAssist = 25,
		ExperiencePerPosition = {
			750,
			750,
			550,
			550,
			475,
			475,
			350,
			350,
			250,
			250,
			175,
			175,
			150,
			150,
			125,
			125,
			75,
			75,
			60,
			60,
			45,
			45,
			35,
			35,
		},
	},
}

local skyWarsTrios: GameModeDefinition = {
	Type = GameMode.SkyWarsTrios,
	GameType = "SkyWars",
	TeamSize = 3,
	MaxTeams = 8,
	DisplayName = "Trios",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.Trios,
		Testing = QueueId.TestingTrios,
	},
	Image = RobloxImage.GameMode.SOLO,
	Color = Color.Orange,
	LightColor = Color.GameMode.LightGreen,
	MapSettings = {
		Size = "Large",
		ExcludedRegions = {
			"N P",
			"S P",
			"W P",
			"E P",
		},
	},
	RespawnBehaviour = {
		Type = "Never",
	},
}

local skyWarsQuads: GameModeDefinition = {
	Type = GameMode.SkyWarsQuads,
	GameType = "SkyWars",
	TeamSize = 4,
	MaxTeams = 8,
	DisplayName = "Squads",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.Quads,
		Testing = QueueId.TestingQuads,
	},
	Image = RobloxImage.GameMode.SOLO,
	Color = Color.Purple,
	LightColor = Color.GameMode.LightGreen,
	MapSettings = {
		Size = "Large",
		ExcludedRegions = {
			"N P",
			"S P",
			"W P",
			"E P",
		},
	},
	RespawnBehaviour = {
		Type = "Never",
	},
}

local skyWarsOctos: GameModeDefinition = {
	Type = GameMode.SkyWarsOctos,
	GameType = "SkyWars",
	TeamSize = 8,
	MaxTeams = 12,
	DisplayName = "Octos",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.Quads,
		Testing = QueueId.TestingQuads,
	},
	Image = RobloxImage.GameMode.SOLO,
	Color = Color.Purple,
	LightColor = Color.GameMode.LightGreen,
	MapSettings = {
		Size = "Large",
	},
	RespawnBehaviour = {
		Type = "Never",
	},
}

local duelsSolo: GameModeDefinition = {
	Type = GameMode.DuelsSolo,
	GameType = "Duels",
	TeamSize = 1,
	MaxTeams = 2,
	DisplayName = "Bridge 1v1",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.DuelsSolo,
		Testing = QueueId.TestingDuelsSolo,
	},
	Image = RobloxImage.GameMode.BRIDGE,
	Color = Color.VoxelGrey,
	LightColor = Color.Grey,
	MapSettings = {
		Size = "Small",
	},
	RespawnBehaviour = {
		Type = "Always",
		Delay = 0,
	},
}

local duelsDuos: GameModeDefinition = {
	Type = GameMode.DuelsDuos,
	GameType = "Duels",
	TeamSize = 2,
	MaxTeams = 2,
	DisplayName = "Bridge 2v2",
	AllowedInPrivate = true,
	Queue = {
		Production = QueueId.DuelsDuos,
		Testing = QueueId.TestingDuelsDuos,
	},
	Image = RobloxImage.GameMode.BRIDGE,
	Color = Color.VoxelGrey,
	LightColor = Color.Grey,
	MapSettings = {
		Size = "Small",
	},
	RespawnBehaviour = {
		Type = "Always",
		Delay = 0.1,
	},
}

local eggWarsQuads: GameModeDefinition = {
	Type = GameMode.EggWarsQuads,
	GameType = "EggWars",
	TeamSize = 4,
	MaxTeams = 4,
	DisplayName = "EggWars",
	AllowedInPrivate = false,
	Queue = {
		Production = QueueId.EggWarsQuads,
		Testing = QueueId.TestingEggWarsQuads,
	},
	Image = RobloxImage.GameMode.BRIDGE,
	Color = Color.VoxelGrey,
	LightColor = Color.Grey,
	MapSettings = {
		Size = "Small",
	},
	RespawnBehaviour = {
		Type = "Team",
		Delay = 6,
		Scaling = function(playerCount: number): number
			return playerCount < 10 and 0.5 or 1
		end,
	},
	Experience = {
		ExperiencePerKill = 30,
		ExperiencePerAssist = 15,
		ExperiencePerPosition = {
			1600,
			1600,
			1600,
			1600,
			1250,
			1250,
			1250,
			1250,
			750,
			750,
			750,
			750,
			550,
			550,
			550,
			550,
		},
	},
}

local gameModes: { GameModeDefinition } = {
	skyWarsSolo,
	skyWarsDuos,
	skyWarsTrios,
	skyWarsQuads,
	skyWarsOctos,
	duelsSolo,
	duelsDuos,
	eggWarsQuads,
}

local gameModesByType: { [string]: GameModeDefinition } = {}
for _, mode: GameModeDefinition in gameModes do
	gameModesByType[mode.Type] = mode
end

return {
	["getGameMode"] = function(teamSize: number): string?
		local result: GameModeDefinition? = nil
		for _, mode: GameModeDefinition in gameModes do
			if mode.GameType == "SkyWars" and mode.TeamSize == teamSize then
				result = mode
				break
			end
		end
		if result ~= nil then
			return result.Type
		end
		return nil
	end,
	["getGameModes"] = function(): { GameModeDefinition }
		return gameModes
	end,
	["GameMode"] = GameMode,
	["GameModes"] = gameModesByType,
}
