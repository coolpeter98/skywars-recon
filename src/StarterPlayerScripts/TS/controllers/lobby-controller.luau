-- LobbyController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local LobbyScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "lobby", "lobby-screen").LobbyScreen
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local SidebarScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "sidebar", "sidebar-screen").SidebarScreen
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local GameConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

type LobbyController = {
	screenController: any,
}

local LobbyController = setmetatable({}, {
	["__tostring"] = function()
		return "LobbyController"
	end
})
LobbyController.__index = LobbyController

function LobbyController.new(...)
	local self = setmetatable({}, LobbyController)
	return self:constructor(...) or self
end

function LobbyController.constructor(self: LobbyController, screenController: any)
	self.screenController = screenController
end

function LobbyController.onLobbyStart(self: LobbyController, maid)
	Flamework.resolveDependency("lB5"):open(LobbyScreen, {
		["InLobby"] = true
	})
	Flamework.resolveDependency("lB5"):open(SidebarScreen, {})
	maid:GiveTask(self.screenController.ScreenOpenedEvent:bind(function(screenOpenedEvent)
		local screenHandler = screenOpenedEvent.screenHandler
		if screenHandler.Options.DisableDock or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar then
			self.screenController:close(LobbyScreen)
		end
	end))
	maid:GiveTask(self.screenController.ScreenClosedEvent:bind(function(screenClosedEvent)
		local screenHandler = screenClosedEvent.screenHandler
		if screenHandler.Options.DisableDock or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar then
			self.screenController:open(LobbyScreen, {
				["InLobby"] = true
			})
		end
	end))
end

function LobbyController.onGameStart(self: LobbyController, maid)
	self.screenController:close(LobbyScreen)
	if Flamework.resolveDependency("1LA"):isSpectating() and not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
		self.screenController:open(LobbyScreen, {
			["InLobby"] = false
		})
	end
	maid:GiveTask(Events["b9b935e9-55ee-43ad-be87-84a7ef56cad9"]:connect(function()
		if not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
			self.screenController:open(LobbyScreen, {
				["InLobby"] = false
			})
		end
	end))
	maid:GiveTask(Events["98d1d5c5-45be-4173-9e49-0abd7cd7efb2"]:connect(function()
		if Players.LocalPlayer:GetAttribute(Attribute.Alive) == true and not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
			self.screenController:close(LobbyScreen)
		end
	end))
	maid:GiveTask(Flamework.resolveDependency("rB8").PlayerEliminated:bind(function(playerEliminatedData)
		if playerEliminatedData.Player ~= Players.LocalPlayer or GameConstants.NEW_WIN_EFFECT_ENABLED and playerEliminatedData.GameEnding then
			return nil
		end
		if not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
			self.screenController:open(LobbyScreen, {
				["InLobby"] = false
			})
		end
	end))
	if GameConstants.NEW_WIN_EFFECT_ENABLED then
		maid:GiveTask(Flamework.resolveDependency("XNg").WinEffectEnded:bind(function()
			if not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
				self.screenController:open(LobbyScreen, {
					["InLobby"] = false
				})
			end
		end))
	else
		maid:GiveTask(Flamework.resolveDependency("rB8").GameEnded:bind(function()
			if not (self.screenController:isHealthBarDisabled() and ScreenUtil.isMobile()) then
				self.screenController:open(LobbyScreen, {
					["InLobby"] = false
				})
			end
		end))
	end
	maid:GiveTask(self.screenController.ScreenOpenedEvent:bind(function(screenOpenedEvent)
		local screenHandler = screenOpenedEvent.screenHandler
		if screenHandler.Options.DisableDock or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar then
			self.screenController:close(LobbyScreen)
		end
	end))
	maid:GiveTask(self.screenController.ScreenClosedEvent:bind(function(screenClosedEvent)
		local screenHandler = screenClosedEvent.screenHandler
		local alive = Players.LocalPlayer:GetAttribute(Attribute.Alive) == true
		local spectating = Flamework.resolveDependency("1LA"):isSpectating()
		local inLobby = Flamework.resolveDependency("Jj"):isInLobby()
		local gameState = GlobalStore:getState().GameState
		if screenHandler.Options.DisableDock then
			print((("ScreenClosedEvent DisableDock alive %* isInLobby %* gameState %*"):format(alive, inLobby, gameState)))
		end
		local shouldOpen
		if GameConstants.POST_GAME_LOBBY_ENABLED then
			shouldOpen = not alive
			if shouldOpen then
				shouldOpen = gameState ~= GameState.Pregame
			end
		else
			shouldOpen = spectating or gameState == GameState.Ended
		end
		if (screenHandler.Options.DisableDock or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar) and shouldOpen then
			self.screenController:open(LobbyScreen, {
				["InLobby"] = false
			})
		end
	end))
end

Reflect.defineMetadata(LobbyController, "identifier", "pY0")
Reflect.defineMetadata(LobbyController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(LobbyController, "flamework:implements", { "09p", "VNB" })
Reflect.decorate(LobbyController, "$:flamework@Controller", Controller, {})
return {
	["LobbyController"] = LobbyController
}
