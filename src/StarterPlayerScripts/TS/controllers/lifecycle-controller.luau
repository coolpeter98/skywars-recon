-- LifecycleController

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
local Controller = FlameworkCore.Controller
local Flamework = FlameworkCore.Flamework
local Reflect = FlameworkCore.Reflect
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GlobalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store")
local GlobalStore = GlobalStoreModule.GlobalStore
local GlobalStoreChanged = GlobalStoreModule.GlobalStoreChanged

export type LifecycleController = {
	gameStartListeners: { [string]: any },
	lobbyStartListeners: { [string]: any },
	maids: { [string]: any },
	new: (...any) -> LifecycleController,
	constructor: (self: LifecycleController) -> (),
	onStart: (self: LifecycleController) -> (),
	fireGameStart: (self: LifecycleController) -> (),
	fireLobbyStart: (self: LifecycleController) -> (),
	clearMaids: (self: LifecycleController) -> (),
}

local LifecycleController = setmetatable({}, {
	__tostring = function()
		return "LifecycleController"
	end,
})
LifecycleController.__index = LifecycleController

function LifecycleController.new(...)
	local class = LifecycleController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function LifecycleController.constructor(self: LifecycleController)
	self.gameStartListeners = {}
	self.lobbyStartListeners = {}
	self.maids = {}
end

function LifecycleController.onStart(self: LifecycleController)
	for id in Reflect.idToObj do
		local dependency = Flamework.resolveDependency(id)
		if Flamework._implements(dependency, "VNB") then
			self.gameStartListeners[id] = dependency
		end
		if Flamework._implements(dependency, "09p") then
			self.lobbyStartListeners[id] = dependency
		end
	end
	if PlaceUtil.isLobbyServer() then
		self:fireLobbyStart()
		return nil
	end
	if PlaceUtil.isGameServer() then
		self:fireGameStart()
		return nil
	end
	local customGame = GlobalStore:getState().CustomGame
	if customGame ~= nil then
		customGame = customGame.ServerData.InGame
	end
	local inGame = customGame == true
	if not inGame then
		self:fireLobbyStart()
	end
	GlobalStoreChanged("CustomGame", function(customGame)
		if customGame and customGame.ServerData.InGame ~= inGame then
			inGame = customGame.ServerData.InGame
			if inGame then
				self:fireGameStart()
			else
				self:fireLobbyStart()
			end
		else
			return nil
		end
	end)
end

function LifecycleController.fireGameStart(self: LifecycleController)
	self:clearMaids()
	for id, listener in self.gameStartListeners do
		local maid = Maid.new()
		listener:onGameStart(maid)
		self.maids[id] = maid
	end
end

function LifecycleController.fireLobbyStart(self: LifecycleController)
	self:clearMaids()
	for id, listener in self.lobbyStartListeners do
		local maid = Maid.new()
		listener:onLobbyStart(maid)
		self.maids[id] = maid
	end
end

function LifecycleController.clearMaids(self: LifecycleController)
	for _, maid in self.maids do
		maid:DoCleaning()
	end
	table.clear(self.maids)
end

Reflect.defineMetadata(LifecycleController, "identifier", "OQ1")
Reflect.defineMetadata(LifecycleController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(LifecycleController, "$:flamework@Controller", Controller, {})

return {
	["LifecycleController"] = LifecycleController,
}
