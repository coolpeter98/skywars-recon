--!strict

-- Server-authoritative power-ups (potions). The client plays the drink
-- animation and fires ActivatePowerUp (no payload) when it completes; this
-- service re-validates the drink against the player's actual held item,
-- consumes the potion, applies the effect, and drives the client's
-- replicated contract:
--
--   * `PowerUpToggled(powerUp, activated)` — the only source of truth for
--     the client's PowerUps store. The card countdown and the movement
--     modifiers (SpeedBoost x1.2, JumpBoost x1.65, Adrenaline x1.1) are
--     applied locally by PowerUpController when the toggle arrives.
--   * `PowerUpEffect(character)` broadcast — the floating potion bottle
--     above the drinker's head for 5 seconds.
--   * `CooldownUpdated` — the Adrenaline potion's 15-second cooldown (the
--     only potion whose shared item definition carries a Cooldown).
--
-- Effect rules (shared client data + observed behavior):
--   * SpeedBoost: 30s speed modifier (client-side).
--   * JumpBoost: 20s jump modifier (client-side).
--   * LifeSteal: 60s, ~3 health to the attacker on every validated hit
--     (hooked in CombatService.dealDamage).
--   * Shield: 60s, +50 shield health. Shield health always fully absorbs
--     exactly one hit regardless of how much remains (1 shield point still
--     blocks an entire hit) and is then removed; the power-up ends when its
--     shield is consumed.
--   * Adrenaline: 30s, +30 shield, speed modifier (client-side), 15s
--     cooldown between drinks.
--
-- Cleanup: eliminations, round resets, and players leaving clear all active
-- power-ups and fire PowerUpToggled(false) for each so the client's cards
-- and modifiers disappear with the effect.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local HealthConstants = require(ReplicatedStorage.TS.health["health-constants"]).HealthConstants
local ItemModule = require(ReplicatedStorage.TS.item.item)
local PowerUps = require(ReplicatedStorage.TS["power-up"]["power-ups"]).PowerUps

type ItemDefinition = {
	Name: string,
	PowerUp: { Type: string, Cooldown: number? }?,
}

type PowerUpDefinition = {
	Type: string,
	DisplayName: string,
	Duration: number,
	Icon: any,
	Color: any,
	Animation: any?,
}

local Items = ItemModule.Items :: { [string]: ItemDefinition }
local PowerUpTable = PowerUps :: { [string]: PowerUpDefinition }

-- Shield health granted by the Shield potion; the shared HealthConstants cap
-- the Shield attribute at 50.
local SHIELD_POWER_UP_SHIELD = 50

type ActiveEntry = {
	ExpiresAt: number,
	Generation: number,
}

type PowerUpContext = {
	outbound: any,
	playerSessions: any,
	inventoryService: any,
	combatService: any,
	roundService: any,
}

local PowerUpService = {}
PowerUpService.__index = PowerUpService

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function getShield(player: Player): number
	local shield = player:GetAttribute(Attribute.Shield)
	if not isFiniteNumber(shield) then
		return 0
	end
	return math.clamp(shield, 0, HealthConstants.MAX_SHIELD)
end

function PowerUpService.new(context: PowerUpContext)
	return setmetatable({
		context = context,
		active = setmetatable({}, { __mode = "k" }) :: { [Player]: { [string]: ActiveEntry } },
		generations = setmetatable({}, { __mode = "k" }) :: { [Player]: number },
		playerRemovingConnection = nil :: RBXScriptConnection?,
		started = false,
	}, PowerUpService)
end

-- Entry point for the ActivatePowerUp remote. The client only fires after
-- its drink animation completes, but a hostile client could fire directly,
-- so every gate the client applies is re-checked here.
function PowerUpService.activate(self, player: Player)
	local combatService = self.context.combatService
	if combatService == nil or not combatService:isInRound() then
		return
	end
	if player:GetAttribute(Attribute.Alive) ~= true or player:GetAttribute(Attribute.Spectating) == true then
		return
	end
	local session = self.context.playerSessions:get(player)
	if session == nil then
		return
	end
	local heldItemType = session.heldItemType
	if type(heldItemType) ~= "string" then
		return
	end
	local itemDefinition: ItemDefinition? = Items[heldItemType]
	local powerUpInfo = itemDefinition and itemDefinition.PowerUp or nil
	if powerUpInfo == nil or PowerUpTable[powerUpInfo.Type] == nil then
		return
	end
	local powerUpType = powerUpInfo.Type :: string
	local inventoryService = self.context.inventoryService
	if inventoryService == nil or inventoryService:getItemQuantity(player, heldItemType) < 1 then
		return
	end
	-- Server-side cooldown gate (only Adrenaline has one). The client-side
	-- drink gate reads the same key via CooldownUpdated below.
	if combatService:isOnCooldown(player, heldItemType) then
		return
	end
	if not inventoryService:changeItem(player, heldItemType, -1) then
		return
	end

	local cooldown = powerUpInfo.Cooldown
	if isFiniteNumber(cooldown) and cooldown > 0 then
		combatService:setCooldown(player, heldItemType, cooldown, true)
	end
	self:applyPowerUp(player, powerUpType)
end

function PowerUpService.applyPowerUp(self, player: Player, powerUpType: string)
	local powerUp = PowerUpTable[powerUpType]
	if powerUp == nil then
		return
	end

	-- Shield health: the Shield potion grants 50, Adrenaline 30 (shared
	-- constant). Both clamp at the shared maximum.
	if powerUpType == "Shield" then
		player:SetAttribute(
			Attribute.Shield,
			math.min(HealthConstants.MAX_SHIELD, getShield(player) + SHIELD_POWER_UP_SHIELD)
		)
	elseif powerUpType == "Adrenaline" then
		player:SetAttribute(
			Attribute.Shield,
			math.min(HealthConstants.MAX_SHIELD, getShield(player) + HealthConstants.ADRENALINE_SHIELD)
		)
	end

	local playerState = self.active[player]
	if playerState == nil then
		playerState = {}
		self.active[player] = playerState
	end
	-- Re-drinking refreshes the duration: the new generation invalidates the
	-- previous expiry timer, so it can never cut a refreshed effect short.
	local generation = (self.generations[player] or 0) + 1
	self.generations[player] = generation
	playerState[powerUpType] = { ExpiresAt = os.clock() + powerUp.Duration, Generation = generation }

	self.context.outbound:fire("PowerUpToggled", player, powerUpType, true)
	local character = player.Character
	if character ~= nil then
		self.context.outbound:fireAll("PowerUpEffect", character)
	end

	task.delay(powerUp.Duration, function()
		local state = self.active[player]
		local entry = state and state[powerUpType] or nil
		if entry == nil or entry.Generation ~= generation then
			return
		end
		state[powerUpType] = nil
		self.context.outbound:fire("PowerUpToggled", player, powerUpType, false)
	end)
end

-- Ends one active power-up early (expiry, shield consumption, cleanup).
function PowerUpService.endPowerUp(self, player: Player, powerUpType: string)
	local playerState = self.active[player]
	if playerState == nil or playerState[powerUpType] == nil then
		return
	end
	playerState[powerUpType] = nil
	self.context.outbound:fire("PowerUpToggled", player, powerUpType, false)
end

-- Called by CombatService when a hit is fully absorbed by shield health and
-- the shield drops to zero: the Shield power-up's single guaranteed block is
-- spent, so it ends early and the client's card disappears with the
-- protection. Other shield sources (e.g. Adrenaline) keep their own timers.
function PowerUpService.onShieldConsumed(self, player: Player)
	self:endPowerUp(player, "Shield")
end

function PowerUpService.hasPowerUp(self, player: Player, powerUpType: string): boolean
	local playerState = self.active[player]
	if playerState == nil then
		return false
	end
	local entry = playerState[powerUpType]
	return entry ~= nil and os.clock() < entry.ExpiresAt
end

-- Removes every active power-up for one player: bumps the generation so all
-- pending expiry timers die, fires PowerUpToggled(false) for each effect so
-- the client's cards/modifiers disappear, and drops shield health (shield
-- only ever comes from power-ups).
function PowerUpService.clearPlayer(self, player: Player)
	self.generations[player] = (self.generations[player] or 0) + 1
	local playerState = self.active[player]
	if playerState ~= nil then
		for powerUpType in playerState do
			self.context.outbound:fire("PowerUpToggled", player, powerUpType, false)
		end
		table.clear(playerState)
	end
	player:SetAttribute(Attribute.Shield, 0)
end

function PowerUpService.clearAll(self)
	for player in self.active do
		self:clearPlayer(player)
	end
	table.clear(self.active)
	table.clear(self.generations)
end

function PowerUpService.start(self)
	if self.started then
		return
	end
	self.started = true
	self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self:clearPlayer(player)
	end)
end

function PowerUpService.stop(self)
	self.started = false
	if self.playerRemovingConnection ~= nil then
		self.playerRemovingConnection:Disconnect()
		self.playerRemovingConnection = nil
	end
	self:clearAll()
end

return PowerUpService
