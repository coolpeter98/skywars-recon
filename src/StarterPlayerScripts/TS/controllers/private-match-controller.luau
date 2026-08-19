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
	Events["d887b207-66e8-4bf5-9cf8-f4b83ceefa37"]:fire()
end

function PrivateMatchController.setServerName(_, serverName)
	Events["a81b8311-38b0-4c39-82db-bd35af3384b4"]:fire(serverName)
end

function PrivateMatchController.setGameMode(_, gameMode)
	Events["69487bdf-63d8-4a61-aef1-eb99b2c84022"]:fire(gameMode)
end

function PrivateMatchController.setAllowTeamSelection(_, allowTeamSelection)
	Events["029a6a32-6361-4bcf-a329-c047192aecaa"]:fire(allowTeamSelection)
end

function PrivateMatchController.setPrivacy(_, privacy)
	Events["2e1b9b77-cd90-4f5a-92ca-d479e5de0dec"]:fire(privacy)
end

function PrivateMatchController.setMap(_, map)
	Events["42e5b069-3ac9-44b2-914a-499f3c5079ed"]:fire(map)
end

function PrivateMatchController.createPrivateServer(_, serverConfig)
	Events["627338f8-6423-40af-9a5e-bf34ed0cfca0"]:fire(serverConfig)
end

function PrivateMatchController.joinPrivateServer(_, joinCode)
	Events["d092d675-6fdc-4fd8-a82c-2efd67c8cddf"]:fire(joinCode)
end

function PrivateMatchController.banPlayer(_, player)
	Events["52b9e38d-3dab-48bf-84da-129d051af061"]:fire(player.UserId, player.DisplayName, true)
end

function PrivateMatchController.unbanPlayer(_, player)
	Events["52b9e38d-3dab-48bf-84da-129d051af061"]:fire(player.UserId, player.DisplayName, false)
end

function PrivateMatchController.setPlayerTeam(_, userId, team)
	Events["c897260e-e7b2-4c31-aafb-15c011643dcd"]:fire(userId, team)
end

function PrivateMatchController.joinTeam(_, team)
	Events["c897260e-e7b2-4c31-aafb-15c011643dcd"]:fire(Players.LocalPlayer.UserId, team)
end

function PrivateMatchController.leaveTeam(_)
	Events["c897260e-e7b2-4c31-aafb-15c011643dcd"]:fire(Players.LocalPlayer.UserId, nil)
end

Reflect.defineMetadata(PrivateMatchController, "identifier", "kXp")
Reflect.defineMetadata(PrivateMatchController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(PrivateMatchController, "flamework:implements", { "VNB" })
Reflect.decorate(PrivateMatchController, "$:flamework@Controller", Controller, {})
return {
	["PrivateMatchController"] = PrivateMatchController,
}
