-- TeamController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute

type Team = {
	Id: number,
	Color: Color3,
	AliveCount: number,
}

type TeamController = {
	getPlayerTeamColour: (self: TeamController, player: Player?) -> Color3?,
	getPlayerTeam: (self: TeamController, player: Player?) -> Team?,
	getPlayerTeamId: (self: TeamController, player: Player?) -> number?,
	getTeamColour: (self: TeamController, teamId: string) -> Color3?,
}

local TeamController = setmetatable({}, {
	["__tostring"] = function()
		return "TeamController"
	end,
})
TeamController.__index = TeamController

function TeamController.new(...)
	local self = setmetatable({}, TeamController)
	return self:constructor(...) or self
end

function TeamController.constructor(self: TeamController) end

function TeamController.getPlayerTeamColour(self: TeamController, player: Player?)
	if player == nil then
		player = Players.LocalPlayer
	end
	local team: any = self:getPlayerTeam(player)
	if team ~= nil then
		team = team.Color
	end
	return team
end

function TeamController.getPlayerTeam(self: TeamController, player: Player?)
	if player == nil then
		player = Players.LocalPlayer
	end
	local teamId = player:GetAttribute(Attribute.TeamId)
	if teamId == "" or not teamId then
		return nil
	else
		return GlobalStore:getState().GameTeams[teamId]
	end
end

function TeamController.getPlayerTeamId(self: TeamController, player: Player?)
	if player == nil then
		player = Players.LocalPlayer
	end
	local team: any = self:getPlayerTeam(player)
	if team ~= nil then
		team = team.Id
	end
	return team
end

function TeamController.getTeamColour(self: TeamController, teamId: string)
	local team = GlobalStore:getState().GameTeams[teamId]
	if team ~= nil then
		team = team.Color
	end
	return team
end

Reflect.defineMetadata(TeamController, "identifier", "x5")
Reflect.decorate(TeamController, "$:flamework@Controller", Controller, {})
return {
	["TeamController"] = TeamController,
}
