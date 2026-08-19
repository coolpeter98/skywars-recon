-- CrateController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local CrateRewardResultType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").CrateRewardResultType
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent, "events").Events
local CrateRewardsScreen = RuntimeLib.import(
	script,
	script.Parent.Parent.Parent,
	"ui",
	"crate-rewards",
	"crate-rewards-screen"
).CrateRewardsScreen
local LobbyScreen = RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "lobby", "lobby-screen").LobbyScreen
local SidebarScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "sidebar", "sidebar-screen").SidebarScreen
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local CrateUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crate-util").CrateUtil
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local CosmeticsShopScreen = RuntimeLib.import(
	script,
	script.Parent.Parent.Parent,
	"ui",
	"cosmetics-shop",
	"cosmetics-shop-screen"
).CosmeticsShopScreen
local EndGameScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "end-game", "end-game-screen").EndGameScreen
local GameScoreboardScreen = RuntimeLib.import(
	script,
	script.Parent.Parent.Parent,
	"ui",
	"game-scoreboard",
	"game-scoreboard-screen"
).GameScoreboardScreen
local HealthBarScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "health-bar", "health-bar-screen").HealthBarScreen
local HotbarScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "hotbar", "hotbar-screen").HotbarScreen
local LockerScreen =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "locker", "locker-screen").LockerScreen
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local ShopScreen = RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "shop", "shop-screen").ShopScreen

type CrateController = {
	crateRewardResults: { any },
	spectating: boolean,
	winEffectPosition: Vector3?,
}

local CrateController = setmetatable({}, {
	["__tostring"] = function()
		return "CrateController"
	end,
})
CrateController.__index = CrateController

function CrateController.new(...)
	local class = CrateController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function CrateController.constructor(self: CrateController)
	self.crateRewardResults = {}
	self.spectating = false
	self.winEffectPosition = nil
end

function CrateController.onStart(self: CrateController)
	Events.CrateOpened:connect(function(animationType, crateRewardResults)
		self.crateRewardResults = crateRewardResults
		self:closeLobbyScreen()
		self:playCrateOpenedAnimation(animationType, self.crateRewardResults)
		ScheduleUtil.runTask(function()
			return self:openLobbyScreen()
		end, 1)
	end)

	Flamework.resolveDependency("dyD").CrateAnimationCompleted:bind(function()
		self:openCrateRewardsScreen()
	end)

	Flamework.resolveDependency("dyD").CrateAnimationCleanUp:bind(function()
		self:closeCrateRewardsScreen()
		self:displayRewardNotifications()
		self.crateRewardResults = {}
		self:openLobbyScreen()

		if GameConstants.NEW_WIN_EFFECT_ENABLED or not self.winEffectPosition then
			if self.spectating then
				Flamework.resolveDependency("1LA"):startSpectating()
				Flamework.resolveDependency("lB5"):open(GameScoreboardScreen, {})
				self.spectating = false
			end
		else
			Flamework.resolveDependency("K4o"):startWinEffect(self.winEffectPosition)
			self.winEffectPosition = nil
		end
	end)

	self:bindCrateRewardsScreenEvents()
end

function CrateController.bindCrateRewardsScreenEvents(self: CrateController)
	local screenController = Flamework.resolveDependency("lB5")

	screenController.ScreenOpenedEvent:bind(function(screenOpened)
		if
			screenOpened.screenHandler.ScreenId ~= "CrateRewards" and Flamework.resolveDependency("dyD"):isInAnimation()
		then
			screenController:closeScreenId(screenOpened.screenHandler.ScreenId)
		end
	end)

	screenController.ScreenClosedEvent:bind(function(screenClosed)
		if
			screenClosed.screenHandler.ScreenId == "CrateRewards" and Flamework.resolveDependency("dyD"):isInAnimation()
		then
			self:openCrateRewardsScreen()
		end
	end)
end

function CrateController.openLobbyScreen(_)
	local screenController = Flamework.resolveDependency("lB5")
	local props = {}
	local inLobby = PlaceUtil.isLobbyServer()

	if not inLobby then
		inLobby = PlaceUtil.isPrivateServer()

		if inLobby then
			local inGame = GlobalStore:getState().CustomGame

			if inGame ~= nil then
				inGame = inGame.ServerData.InGame
			end

			inLobby = inGame == false
		end
	end

	props.InLobby = inLobby
	screenController:open(LobbyScreen, props)
	Flamework.resolveDependency("lB5"):open(SidebarScreen, {})
end

function CrateController.closeLobbyScreen(_)
	Flamework.resolveDependency("lB5"):close(LobbyScreen)
	Flamework.resolveDependency("lB5"):close(SidebarScreen)
end

function CrateController.openCrateRewardsScreen(self: CrateController)
	Flamework.resolveDependency("lB5"):open(CrateRewardsScreen, {
		["CrateRewardResults"] = self.crateRewardResults,
	})
end

function CrateController.closeCrateRewardsScreen(_)
	Flamework.resolveDependency("lB5"):close(CrateRewardsScreen)
end

function CrateController.playCrateOpenedAnimation(self: CrateController, animationType, _)
	self.spectating = Flamework.resolveDependency("1LA"):stopSpectating()
	self.winEffectPosition = Flamework.resolveDependency("K4o"):stopWinEffect()
	Flamework.resolveDependency("XNg"):stopWinEffect()
	Flamework.resolveDependency("K4o"):stopWinEffect()
	Flamework.resolveDependency("lB5"):close(CosmeticsShopScreen)
	Flamework.resolveDependency("lB5"):close(ShopScreen)
	Flamework.resolveDependency("lB5"):close(EndGameScreen)
	Flamework.resolveDependency("lB5"):close(GameScoreboardScreen)
	Flamework.resolveDependency("lB5"):close(HealthBarScreen)
	Flamework.resolveDependency("lB5"):close(HotbarScreen)
	Flamework.resolveDependency("dyD"):playAnimation(animationType)
end

function CrateController.displayRewardNotifications(self: CrateController)
	Flamework.resolveDependency("jL9"):playSound(RobloxSound.Stats.GAME_WIN, {
		["Volume"] = 0.8,
	})

	local totalGems = 0

	for _, rewardResult in self.crateRewardResults do
		if rewardResult.Type == CrateRewardResultType.Duplicate then
			totalGems = totalGems + rewardResult.GemsQuantity
		else
			local rarity = CosmeticRarities[CrateUtil.getRarity(rewardResult)]
			Flamework.resolveDependency("Odx"):displayNotification({
				["Title"] = nil,
				["Icon"] = nil,
				["IconColor"] = nil,
				["IconScale"] = 0.8,
				["Message"] = "Added item to your locker!",
				["Duration"] = 10,
				["Activated"] = nil,
				["ActivatedText"] = "View",
				["Title"] = CrateUtil.getDisplayName(rewardResult),
				["Icon"] = RobloxImage.Icon.CHEST,
				["IconColor"] = rarity.Color,
				["Activated"] = function()
					return Flamework.resolveDependency("lB5"):open(LockerScreen, {})
				end,
			})
		end
	end

	if totalGems > 0 then
		Flamework.resolveDependency("Odx"):displayNotification({
			["Title"] = "Gems",
			["Icon"] = nil,
			["IconColor"] = nil,
			["IconScale"] = 0.8,
			["Message"] = nil,
			["Duration"] = 10,
			["Icon"] = RobloxImage.Icon.CHEST,
			["IconColor"] = Color.Green,
			["Message"] = ("Added %* gem%* to your balance!"):format(totalGems, totalGems == 1 and "" or "s"),
		})
	end
end

function CrateController.getCrateRewardResults(self: CrateController)
	return self.crateRewardResults
end

Reflect.defineMetadata(CrateController, "identifier", "jaW")
Reflect.defineMetadata(CrateController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CrateController, "$:flamework@Controller", Controller, {})

return {
	["CrateController"] = CrateController,
}
