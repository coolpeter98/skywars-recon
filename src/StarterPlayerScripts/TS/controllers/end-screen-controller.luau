-- EndScreenController

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
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local LevelUpScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "level-up", "level-up-screen").LevelUpScreen
local LobbyScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "lobby", "lobby-screen").LobbyScreen
local EndGameScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "end-game", "end-game-screen").EndGameScreen
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

type EndScreenController = {
	screenController: any,
	constructor: (self: EndScreenController, screenController: any) -> (),
	onStart: (self: EndScreenController) -> (),
}

local EndScreenController = setmetatable({}, {
	["__tostring"] = function()
		return "EndScreenController"
	end,
})
EndScreenController.__index = EndScreenController
function EndScreenController.new(...)
	local self = setmetatable({}, EndScreenController)
	return self:constructor(...) or self
end
function EndScreenController.constructor(self, screenController)
	self.screenController = screenController
end
function EndScreenController.onStart(self)
	Flamework.resolveDependency("1LA").SetSpectating:bind(function(spectatingData)
		local isSpectating = spectatingData.spectating
		if not isSpectating then
			if not GameConstants.NEW_WIN_EFFECT_ENABLED then
				print(("SetSpectating false %*, win effect not enabled, closing end screen"):format(isSpectating))
				self.screenController:close(EndGameScreen)
			end
			self.screenController:close(LevelUpScreen)
		end
	end)
	self.screenController.ScreenOpenedEvent:bind(function(screenOpenedData)
		local screenHandler = screenOpenedData.screenHandler
		if screenHandler.Options.ScreenId ~= "EndGame" and screenHandler.Options.Focused then
			if not GameConstants.NEW_WIN_EFFECT_ENABLED then
				self.screenController:close(EndGameScreen)
			end
			self.screenController:close(LevelUpScreen)
		end
	end)
	self.screenController.ScreenClosedEvent:bind(function(screenClosedData)
		if screenClosedData.screenHandler.Options.ScreenId == "EndGame" then
			Flamework.resolveDependency("lB5"):open(LobbyScreen, {
				["InLobby"] = false,
			})
		end
	end)
	if not GameConstants.NEW_WIN_EFFECT_ENABLED then
		Events.PlayerKilled:connect(function(player)
			if Players.LocalPlayer ~= player then
				return nil
			end
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Misc.LOSS, {
				["Volume"] = 0.8,
			})
		end)
	end
	Flamework.resolveDependency("rB8").PlayerEliminated:bind(function(playerEliminatedData)
		if GameConstants.NEW_WIN_EFFECT_ENABLED then
			return nil
		end
		if Players.LocalPlayer ~= playerEliminatedData.Player then
			return nil
		end
		Flamework.resolveDependency("lB5"):open(EndGameScreen, {
			["Winner"] = false,
			["GameEnded"] = false,
		})
	end)
	Flamework.resolveDependency("rB8").GameEnded:bind(function(gameEndedData)
		local winners = gameEndedData.GameResult.winners
		local localPlayer = Players.LocalPlayer
		local didWin = table.find(winners, localPlayer) ~= nil
		if not GameConstants.POST_GAME_LOBBY_ENABLED then
			Flamework.resolveDependency("qmA"):playEnding(didWin)
		end
		if not didWin then
			if PlaceUtil.isDuelsServer() then
				Flamework.resolveDependency("jL9"):playSound(RobloxSound.Misc.LOSS, {
					["Volume"] = 0.8,
				})
			end
			return nil
		end
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.Misc.WIN, {
			["Volume"] = 0.8,
		})
		if Flamework.resolveDependency("lB5"):isOpen("EndGame") then
			return nil
		end
		if not GameConstants.NEW_WIN_EFFECT_ENABLED then
			Flamework.resolveDependency("lB5"):open(EndGameScreen, {
				["Winner"] = true,
				["GameEnded"] = true,
			})
		end
	end)
end
Reflect.defineMetadata(EndScreenController, "identifier", "vB0")
Reflect.defineMetadata(EndScreenController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(EndScreenController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(EndScreenController, "$:flamework@Controller", Controller, {})
return {
	["EndScreenController"] = EndScreenController,
}
