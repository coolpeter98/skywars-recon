-- PrivateMatchController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local PrivateMatchSettingsScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"private-match",
	"settings",
	"private-match-settings-screen"
).PrivateMatchSettingsScreen
local PrivateMatchBrowserScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"private-match",
	"browser",
	"private-match-browser-screen"
).PrivateMatchBrowserScreen

type PrivateMatchController = {
	new: (...any) -> PrivateMatchController,
	screenController: any,
	constructor: (self: PrivateMatchController, screenController: any) -> (),
	onGameStart: (self: PrivateMatchController) -> (),
	openCustomMatchBrowser: (self: PrivateMatchController) -> (),
	toggleCustomMatchSettings: (self: PrivateMatchController) -> (),
	startGame: (self: PrivateMatchController) -> (),
	setServerName: (self: PrivateMatchController, serverName: string) -> (),
	setGameMode: (self: PrivateMatchController, gameMode: string) -> (),
	setAllowTeamSelection: (self: PrivateMatchController, allowTeamSelection: boolean) -> (),
	setPrivacy: (self: PrivateMatchController, privacy: string) -> (),
	setMap: (self: PrivateMatchController, map: string) -> (),
	createPrivateServer: (self: PrivateMatchController, serverConfig: any) -> (),
	joinPrivateServer: (self: PrivateMatchController, joinCode: string) -> (),
	banPlayer: (self: PrivateMatchController, player: Player) -> (),
	unbanPlayer: (self: PrivateMatchController, player: Player) -> (),
	setPlayerTeam: (self: PrivateMatchController, userId: number, team: any) -> (),
	joinTeam: (self: PrivateMatchController, team: any) -> (),
	leaveTeam: (self: PrivateMatchController) -> (),
}

local PrivateMatchController = setmetatable({}, {
	["__tostring"] = function()
		return "PrivateMatchController"
	end,
})
PrivateMatchController.__index = PrivateMatchController

function PrivateMatchController.new(...)
	local self = setmetatable({}, PrivateMatchController)
	return self:constructor(...) or self
end

function PrivateMatchController.constructor(self, screenController)
	self.screenController = screenController
end

function PrivateMatchController.onGameStart(self)
	self.screenController:close(PrivateMatchSettingsScreen)
end

function PrivateMatchController.openCustomMatchBrowser(self)
	self.screenController:open(PrivateMatchBrowserScreen, {})
end

function PrivateMatchController.toggleCustomMatchSettings(self)
	self.screenController:toggle(PrivateMatchSettingsScreen)
end

function PrivateMatchController.startGame(_)
	Events.StartPrivateMatch:fire()
end

function PrivateMatchController.setServerName(_, serverName)
	Events.SetPrivateServerName:fire(serverName)
end

function PrivateMatchController.setGameMode(_, gameMode)
	Events.SetPrivateGameMode:fire(gameMode)
end

function PrivateMatchController.setAllowTeamSelection(_, allowTeamSelection)
	Events.SetPrivateAllowTeamSelection:fire(allowTeamSelection)
end

function PrivateMatchController.setPrivacy(_, privacy)
	Events.SetPrivatePrivacy:fire(privacy)
end

function PrivateMatchController.setMap(_, map)
	Events.SetPrivateMap:fire(map)
end

function PrivateMatchController.createPrivateServer(_, serverConfig)
	Events.CreatePrivateServer:fire(serverConfig)
end

function PrivateMatchController.joinPrivateServer(_, joinCode)
	Events.JoinPrivateServer:fire(joinCode)
end

function PrivateMatchController.banPlayer(_, player)
	Events.SetPlayerBan:fire(player.UserId, player.DisplayName, true)
end

function PrivateMatchController.unbanPlayer(_, player)
	Events.SetPlayerBan:fire(player.UserId, player.DisplayName, false)
end

function PrivateMatchController.setPlayerTeam(_, userId, team)
	Events.SetPlayerTeam:fire(userId, team)
end

function PrivateMatchController.joinTeam(_, team)
	Events.SetPlayerTeam:fire(Players.LocalPlayer.UserId, team)
end

function PrivateMatchController.leaveTeam(_)
	Events.SetPlayerTeam:fire(Players.LocalPlayer.UserId, nil)
end

Reflect.defineMetadata(PrivateMatchController, "identifier", "kXp")
Reflect.defineMetadata(PrivateMatchController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(PrivateMatchController, "flamework:implements", { "VNB" })
Reflect.decorate(PrivateMatchController, "$:flamework@Controller", Controller, {})
return {
	["PrivateMatchController"] = PrivateMatchController,
}
