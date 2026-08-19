-- GameController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
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
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local GameScoreboardScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"game-scoreboard",
	"game-scoreboard-screen"
).GameScoreboardScreen
local EndGameScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "end-game", "end-game-screen").EndGameScreen
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local EggwarsScoreboardScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"eggwars-scoreboard",
	"eggwars-scoreboard-screen"
).EggwarsScoreboardScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local EggCharacters = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character"
).EggCharacters
local KillfeedScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "killfeed", "killfeed-screen").KillfeedScreen
local KillfeedEntityType =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "killfeed", "killfeed-entity").KillfeedEntityType
local DamageType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").DamageType
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState

type GameController = {
	screenController: any,
	KillFeedRemoved: any,
	GameEnded: any,
	PlayerEliminated: any,
}

local GameController = setmetatable({}, {
	["__tostring"] = function()
		return "GameController"
	end,
})
GameController.__index = GameController

function GameController.new(...)
	local self = setmetatable({}, GameController)
	return self:constructor(...) or self
end

function GameController.constructor(self: GameController, screenController: any)
	self.screenController = screenController
	self.KillFeedRemoved = AsyncEvent.new()
	self.GameEnded = AsyncEvent.new()
	self.PlayerEliminated = AsyncEvent.new()
end

function GameController.onStart(self: GameController)
	Events.PlayerKilled:connect(function(killedPlayer, killerPlayer, damageType)
		self:createKillFeedCard(killedPlayer, killerPlayer, damageType)
	end)
	Events.EggEliminated:connect(function(eggName, player)
		if not player then
			return nil
		end
		local eggCharacter = EggCharacters[eggName]
		local killfeedIndex = self.screenController:getOpenCount("Killfeed")
		local screenController = self.screenController
		local killfeedData = {
			["Index"] = killfeedIndex,
		}
		local killedEntity = {
			["Type"] = KillfeedEntityType.Abstract,
			["Name"] = ("%* Egg"):format(eggName),
			["Color"] = Flamework.resolveDependency("x5"):getTeamColour(eggName),
		}
		if eggCharacter ~= nil then
			eggCharacter = eggCharacter.IconId
		end
		killedEntity.Icon = eggCharacter == nil and "" or eggCharacter
		killfeedData.Killed = killedEntity
		killfeedData.Killer = {
			["Type"] = KillfeedEntityType.Player,
			["Player"] = PlayerUtil.toReplicated(player),
			["Color"] = Flamework.resolveDependency("x5"):getPlayerTeamColour(player),
		}
		killfeedData.DamageType = DamageType.Melee
		screenController:open(KillfeedScreen, killfeedData)
	end)
	Events.GameResult:connect(function(gameResult)
		self.GameEnded:fire({
			["GameResult"] = gameResult,
		})
	end)
	Events.Respawn:connect(function()
		if not Flamework.resolveDependency("Jj"):isInLobby() then
			self.screenController:close(EndGameScreen)
		end
	end)
	Events.PlayerEliminated:connect(function(player)
		local gameTeams = table.clone(GlobalStore:getState().GameTeams)
		local playerTeam = gameTeams[player:GetAttribute(Attribute.TeamId)]
		playerTeam.AliveCount = playerTeam.AliveCount - 1
		local aliveTeamCount = 0
		local aliveTeams = {}
		for index, team in ObjectUtils.values(gameTeams) do
			local _ = index - 1
			if team.AliveCount > 0 == true then
				aliveTeamCount = aliveTeamCount + 1
				aliveTeams[aliveTeamCount] = team
			end
		end
		local remainingTeamIds = table.create(#aliveTeams)
		for index, team in aliveTeams do
			local _ = index - 1
			remainingTeamIds[index] = team.Id
		end
		local gameEnding = #remainingTeamIds <= 1
		self.PlayerEliminated:fire({
			["Player"] = player,
			["GameEnding"] = gameEnding,
		})
	end)
end

function GameController.onGameStart(self: GameController, maid)
	self:openScoreboard()
	maid:GiveTask(Flamework.resolveDependency("rB8").GameEnded:bind(function()
		self:closeScoreboard()
	end))
	local stateChangeConnection = Events.GameStateChangeTime:connect(function(duration)
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "GameStateChangeTime",
			["Value"] = nil,
			["Value"] = os.time() + duration,
		})
	end)
	maid:GiveTask(function()
		self:closeScoreboard()
		stateChangeConnection:Disconnect()
	end)
	maid:GiveTask(self.screenController.ScreenOpenedEvent:bind(function(screen)
		local screenHandler = screen.screenHandler
		if
			screenHandler.Options.DisableDock
			or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar
			or screenHandler.ScreenId == "EndGame"
		then
			self:closeScoreboard()
		end
	end))
	maid:GiveTask(self.screenController.ScreenClosedEvent:bind(function(screen)
		local screenHandler = screen.screenHandler
		local gameState = GlobalStore:getState().GameState
		if
			screenHandler.Options.DisableDock
			or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar
			or screenHandler.ScreenId == "EndGame" and gameState ~= GameState.Ended
		then
			self:openScoreboard()
		end
	end))
end

function GameController.createKillFeedCard(self: GameController, killedPlayer, killerPlayer, damageType)
	local killfeedIndex = self.screenController:getOpenCount("Killfeed")
	self.screenController:open(KillfeedScreen, {
		["Index"] = killfeedIndex,
		["Killed"] = {
			["Type"] = KillfeedEntityType.Player,
			["Player"] = PlayerUtil.toReplicated(killedPlayer),
			["Color"] = Flamework.resolveDependency("x5"):getPlayerTeamColour(killedPlayer),
		},
		["Killer"] = killerPlayer and {
			["Type"] = KillfeedEntityType.Player,
			["Player"] = PlayerUtil.toReplicated(killerPlayer),
			["Color"] = Flamework.resolveDependency("x5"):getPlayerTeamColour(killerPlayer),
		} or nil,
		["DamageType"] = damageType,
	})
end

function GameController.openScoreboard(self: GameController)
	if PlaceUtil.isEggWarsServer() then
		self.screenController:open(EggwarsScoreboardScreen, {})
	else
		self.screenController:open(GameScoreboardScreen, {})
	end
end

function GameController.closeScoreboard(self: GameController)
	if PlaceUtil.isEggWarsServer() then
		self.screenController:close(EggwarsScoreboardScreen)
	else
		self.screenController:close(GameScoreboardScreen)
	end
end

Reflect.defineMetadata(GameController, "identifier", "rB8")
Reflect.defineMetadata(GameController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(GameController, "flamework:implements", { "$:flamework@OnStart", "VNB" })
Reflect.decorate(GameController, "$:flamework@Controller", Controller, {})
return {
	["GameController"] = GameController,
}
