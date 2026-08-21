--!strict

local Validation = require(script.Parent.Parent.Validation)

export type ServerListEntry = {
	OwnerId: number,
	OwnerDisplayName: string,
	ServerName: string,
	ServerKey: string,
	ServerAccessCode: string,
	PlayersOnline: number,
	SpectatorsOnline: number,
	Privacy: "Public" | "Private",
	Settings: {
		GameMode: string,
		MapName: string,
		AllowTeamSelection: boolean,
	},
	InGame: boolean,
	BannedPlayers: { { UserId: number, DisplayName: string } },
}

local CustomServersService = {}
CustomServersService.__index = CustomServersService

function CustomServersService.new(context)
	return setmetatable({ context = context }, CustomServersService)
end

function CustomServersService.getCustomServers(self, player: Player): { ServerListEntry }
	return self.context.customGameService:listPublicServers(player)
end

function CustomServersService.getRoutes(self)
	return {
		{
			Name = "GetCustomServers",
			Validate = Validation.tuple({}),
			Handle = function(player, _)
				return self:getCustomServers(player)
			end,
		},
	}
end

return CustomServersService
