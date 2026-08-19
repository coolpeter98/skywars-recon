-- HealthController

type HealthController = {
	new: (...any) -> HealthController,
	constructor: (self: HealthController, screenController: any) -> (),
	onStart: (self: HealthController) -> (),
	onGameStart: (self: HealthController, maid: any) -> (),
	getHealth: (self: HealthController, player: Player?) -> number,
	getShield: (self: HealthController, player: Player?) -> number,
	animateDamage: (self: HealthController, character: Model, damage: number, shield: boolean?) -> (),
	open: (self: HealthController) -> (),
	screenController: any,
	HealthChanged: any,
	ShieldChanged: any,
	kills: number,
	running: boolean,
}

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local HealthUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "health-util").HealthUtil
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Distance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").Distance
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local HealthBarScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "health-bar", "health-bar-screen").HealthBarScreen
local GameCurrencyScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "game-currency", "game-currency-screen").GameCurrencyScreen
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local VignetteScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "vignette", "vignette-screen").VignetteScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local DamageType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").DamageType
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

local KILL_SOUNDS = {
	RobloxSound.Kill.ONE,
	RobloxSound.Kill.TWO,
	RobloxSound.Kill.THREE,
	RobloxSound.Kill.FOUR,
	RobloxSound.Kill.FIVE,
}

local HealthController = setmetatable({}, {
	["__tostring"] = function()
		return "HealthController"
	end,
})
HealthController.__index = HealthController

function HealthController.new(...)
	local self = setmetatable({}, HealthController)
	return self:constructor(...) or self
end

function HealthController.constructor(self, screenController)
	self.screenController = screenController
	self.HealthChanged = AsyncEvent.new()
	self.ShieldChanged = AsyncEvent.new()
	self.kills = 0
	self.running = false
end

function HealthController.onStart(self)
	Events["1f8d0466-8b5b-4eaf-a662-1d5a42459023"]:connect(function(character, damage, _, damageType, shield, killer)
		local isLocalPlayerKiller
		if killer == nil then
			isLocalPlayerKiller = false
		else
			isLocalPlayerKiller = killer == Players.LocalPlayer
		end
		self:animateDamage(character, damage, shield)
		if damageType == DamageType.Bow and isLocalPlayerKiller then
			Flamework.resolveDependency("jL9"):playSound(RobloxSound.Projectile.HIT, {
				["Volume"] = 0.8,
			})
		end
	end)
	Flamework.resolveDependency("1LA").SetSpectating:bind(function(spectatingData)
		local isSpectating = spectatingData.spectating
		local inGame = GlobalStore:getState().CustomGame
		if inGame ~= nil then
			inGame = inGame.ServerData.InGame
		end
		local isInGame = inGame == true or PlaceUtil.isGameServer()
		if Players.LocalPlayer:GetAttribute(Attribute.Alive) == true and (not isSpectating and isInGame) then
			self:onGameStart(Maid.new())
		end
	end)
end

function HealthController.onGameStart(self, maid)
	if self.running then
		return nil
	end
	self.running = true
	self.screenController:open(HealthBarScreen, {})
	self.screenController:open(GameCurrencyScreen, {})
	maid:GiveTask(function()
		self.screenController:close(HealthBarScreen)
		self.screenController:close(GameCurrencyScreen)
		self.screenController:close(VignetteScreen)
		self.kills = 0
		self.running = false
	end)
	maid:GiveTask(Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Health):Connect(function()
		self.HealthChanged:fire({
			["health"] = self:getHealth(),
		})
	end))
	maid:GiveTask(Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Shield):Connect(function()
		self.ShieldChanged:fire({
			["shield"] = self:getShield(),
		})
	end))
	maid:GiveTask(Events["6b80b67b-dd78-492a-864a-76fbabf73c2e"]:connect(function(_, killer, _, _)
		if killer and killer == Players.LocalPlayer then
			local soundController = Flamework.resolveDependency("jL9")
			soundController:playSound(KILL_SOUNDS[math.min(self.kills, #KILL_SOUNDS - 1) + 1], {
				["Volume"] = 0.8,
			})
			self.kills = self.kills + 1
		end
	end))
	maid:GiveTask(Flamework.resolveDependency("1LA").SetSpectating:bind(function(spectatingData)
		if spectatingData.spectating then
			maid:DoCleaning()
		end
	end))
	if GameConstants.POST_GAME_LOBBY_ENABLED then
		maid:GiveTask(Events["d7ee8722-a04c-4d29-a954-e324fb1fff79"]:connect(function(player)
			if Players.LocalPlayer == player then
				maid:DoCleaning()
			end
		end))
	end
	maid:GiveTask(Flamework.resolveDependency("rB8").GameEnded:bind(function()
		maid:DoCleaning()
	end))
	maid:GiveTask(self.screenController.ScreenOpenedEvent:bind(function(screenInfo)
		local screenHandler = screenInfo.screenHandler
		if
			screenHandler.Options.DisableDock
			or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar
			or screenHandler.ScreenId == "EndGame"
		then
			self.screenController:close(HealthBarScreen)
			self.screenController:close(GameCurrencyScreen)
		end
	end))
	maid:GiveTask(self.screenController.ScreenClosedEvent:bind(function(screenInfo)
		local screenHandler = screenInfo.screenHandler
		if
			screenHandler.Options.DisableDock
			or ScreenUtil.isMobile() and screenHandler.Options.DisableHealthBar
			or screenHandler.ScreenId == "EndGame"
		then
			self.screenController:open(HealthBarScreen, {})
			self.screenController:open(GameCurrencyScreen, {})
		end
	end))
end

function HealthController.getHealth(_, player: Player?): number
	if player == nil then
		player = Players.LocalPlayer
	end
	local health = player:GetAttribute(Attribute.Health)
	return health == nil and 100 or health
end

function HealthController.getShield(_, player: Player?): number
	if player == nil then
		player = Players.LocalPlayer
	end
	local shield = player:GetAttribute(Attribute.Shield)
	return shield == nil and 0 or shield
end

function HealthController.animateDamage(_, character: Model, damage: number, shield: boolean?)
	local distance = Distance(Players.LocalPlayer, character)
	if distance == nil or distance < 32 * BlockConstants.BLOCK_SIZE then
		Flamework.resolveDependency("Ax3"):playDamageHighlight(character)
	end
	if character ~= Players.LocalPlayer.Character then
		HealthUtil.createDamageIndicator(character, damage, shield)
	end
end

function HealthController.open(_) end

Reflect.defineMetadata(HealthController, "identifier", "51k")
Reflect.defineMetadata(HealthController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(HealthController, "flamework:implements", { "$:flamework@OnStart", "VNB" })
Reflect.decorate(HealthController, "$:flamework@Controller", Controller, {})
return {
	["HealthController"] = HealthController,
}
