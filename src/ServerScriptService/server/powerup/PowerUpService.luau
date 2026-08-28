--!strict

-- Authoritative potions. Client fires ActivatePowerUp after its drink animation;
-- we re-validate everything anyway, then drive the client contract:
-- PowerUpToggled (card + movement modifiers applied client-side),
-- PowerUpEffect (floating bottle), CooldownUpdated (Adrenaline's 15s cooldown).
-- Shield absorbs exactly one hit regardless of remaining shield (see
-- CombatService); consuming it ends the Shield power-up early.
-- Effect durations come from the shared power-ups data.

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

-- Clamped at HealthConstants.MAX_SHIELD.
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
	-- Only Adrenaline has a cooldown; the client's drink gate reads the same
	-- key via the CooldownUpdated replication below.
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
	-- Re-drinking bumps the generation so the previous expiry timer can't cut
	-- the refreshed effect short.
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

-- Shield potion's single guaranteed block is spent, so it ends early.
-- Other shield sources (Adrenaline) keep their own timers.
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

-- Generation bump kills all pending expiry timers; shield only comes from
-- power-ups, so it drops to zero.
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
