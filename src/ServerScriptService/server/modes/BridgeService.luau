--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.TS.attribute).Attribute
local RobloxSound = require(ReplicatedStorage.TS.asset.roblox["roblox-sound"]).RobloxSound
local BridgeMap = require(script.Parent.BridgeMap)
local BridgeRules = require(script.Parent.BridgeRules)

type ArenaData = BridgeMap.ArenaData

local GAME_MODES = {
	DuelsSolo = true,
	DuelsDuos = true,
}
local ARROW_LOOP_STEP = 0.05
local POINT_RESULT_DURATION = 3

local BridgeService = {}
BridgeService.__index = BridgeService

local function getTeamId(player: Player): string?
	local teamId = player:GetAttribute(Attribute.TeamId)
	return if type(teamId) == "string" and teamId ~= "" then teamId else nil
end

function BridgeService.new(context)
	return setmetatable({
		context = context,
		active = false,
		generation = 0,
		arenaData = nil :: ArenaData?,
		scores = { Red = 0, Blue = 0 },
		scoringEnabled = false,
		portalConnections = {} :: { RBXScriptConnection },
	}, BridgeService)
end

function BridgeService.isGameMode(_: any, gameMode: string?): boolean
	return gameMode ~= nil and GAME_MODES[gameMode] == true
end

function BridgeService.isActive(self): boolean
	return self.active
end

function BridgeService.canRespawn(self, _: Player): boolean
	return self.active
end

function BridgeService.getRespawnDelay(_: any): number
	return 0
end

function BridgeService.getOpponentTeam(_: any, teamId: string): string?
	if teamId == "Red" then
		return "Blue"
	elseif teamId == "Blue" then
		return "Red"
	end
	return nil
end

function BridgeService.replicatePlayer(self, player: Player)
	self.context.outbound:setValue(player, "DuelsScore", {
		Red = self.scores.Red,
		Blue = self.scores.Blue,
	})
	local indicatorPosition: Vector3? = nil
	local arenaData = self.arenaData
	local teamId = getTeamId(player)
	local opposingTeam = if teamId ~= nil then self:getOpponentTeam(teamId) else nil
	if self.active and arenaData ~= nil and opposingTeam ~= nil then
		indicatorPosition = arenaData.IndicatorPositions[opposingTeam]
	end
	self.context.outbound:setValue(player, "IndicatorPosition", indicatorPosition)
end

function BridgeService.replicateAll(self)
	for _, player in Players:GetPlayers() do
		self:replicatePlayer(player)
	end
end

function BridgeService.getWinners(_: any, teamId: string): { Player }
	local winners = {}
	for _, player in Players:GetPlayers() do
		if getTeamId(player) == teamId then
			table.insert(winners, player)
		end
	end
	return winners
end

function BridgeService.showPointResult(self, scoringTeamId: string)
	for _, player in Players:GetPlayers() do
		local teamId = getTeamId(player)
		if teamId == scoringTeamId then
			self.context.outbound:fire("Title", player, {
				Text = "Round Won!",
				Duration = POINT_RESULT_DURATION,
				SoundBefore = RobloxSound.Misc.WIN,
			})
		elseif teamId == self:getOpponentTeam(scoringTeamId) then
			self.context.outbound:fire("Title", player, {
				Text = "Round Lost",
				Duration = POINT_RESULT_DURATION,
				SoundBefore = RobloxSound.Misc.LOSS,
			})
		end
	end
end

function BridgeService.onPortalTouched(self, goalTeamId: string, hit: BasePart)
	if not self.active or not self.scoringEnabled or not self.context.roundService:isInRound() then
		return
	end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character) or nil
	if
		player == nil
		or player:GetAttribute(Attribute.Alive) ~= true
		or player:GetAttribute(Attribute.Spectating) == true
	then
		return
	end
	local scoringTeamId = getTeamId(player)
	if scoringTeamId == nil or scoringTeamId == goalTeamId then
		return
	end
	self.scoringEnabled = false
	local score, won = BridgeRules.recordScore(self.scores[scoringTeamId] or 0)
	self.scores[scoringTeamId] = score
	self:replicateAll()
	self:showPointResult(scoringTeamId)
	if won then
		local generation = self.generation
		local winners = self:getWinners(scoringTeamId)
		task.delay(POINT_RESULT_DURATION, function()
			if self.active and self.generation == generation and self.context.roundService:isInRound() then
				self.context.roundService:finishRound(winners)
			end
		end)
	elseif not self.context.roundService:beginBridgeScoreReset(BridgeRules.CageResetDuration) then
		self.scoringEnabled = true
	end
end

function BridgeService.connectPortals(self)
	local arenaData = self.arenaData
	if arenaData == nil then
		return
	end
	for teamId, portal in arenaData.PortalsByTeam do
		table.insert(
			self.portalConnections,
			portal.Touched:Connect(function(hit)
				self:onPortalTouched(teamId, hit)
			end)
		)
	end
end

function BridgeService.grantArrowTick(self)
	for _, player in Players:GetPlayers() do
		if
			player:GetAttribute(Attribute.Alive) == true
			and player:GetAttribute(Attribute.Spectating) ~= true
			and self.context.inventoryService:getItemQuantity(player, "Arrow") == 0
		then
			self.context.inventoryService:changeItem(player, "Arrow", 1)
		end
	end
end

function BridgeService.startArrowClock(self)
	local generation = self.generation
	task.spawn(function()
		local elapsed = 0
		local previousTime = os.clock()
		while self.active and self.generation == generation do
			local currentTime = os.clock()
			local deltaTime = currentTime - previousTime
			previousTime = currentTime
			local ticks
			elapsed, ticks = BridgeRules.advanceArrowClock(elapsed, deltaTime, self.context.roundService:isInRound())
			for _ = 1, ticks do
				self:grantArrowTick()
			end
			task.wait(ARROW_LOOP_STEP)
		end
	end)
end

function BridgeService.prepareRound(self, gameMode: string, map: Model): boolean
	if not self:isGameMode(gameMode) then
		return true
	end
	self:clearRound()
	local arenaData = BridgeMap.populate(map)
	if arenaData == nil then
		warn(("[BridgeService] failed to populate %s"):format(map.Name))
		return false
	end
	self.active = true
	self.generation += 1
	self.arenaData = arenaData
	self.scores = { Red = 0, Blue = 0 }
	self.scoringEnabled = false
	self:connectPortals()
	self:startArrowClock()
	return true
end

function BridgeService.onCagesReleased(self)
	if self.active then
		self.scoringEnabled = true
	end
end

function BridgeService.onCagesStarted(self)
	self.scoringEnabled = false
end

function BridgeService.disconnectPortals(self)
	for _, connection in self.portalConnections do
		connection:Disconnect()
	end
	table.clear(self.portalConnections)
end

function BridgeService.endRound(self)
	if not self.active then
		return
	end
	self.active = false
	self.generation += 1
	self.scoringEnabled = false
	self:disconnectPortals()
end

function BridgeService.clearRound(self)
	self.active = false
	self.generation += 1
	self.scoringEnabled = false
	self:disconnectPortals()
	self.arenaData = nil
	self.scores = { Red = 0, Blue = 0 }
	self:replicateAll()
end

function BridgeService.stop(self)
	self:clearRound()
end

return BridgeService
