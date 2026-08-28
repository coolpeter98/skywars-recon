--!strict

-- PregameService — two-phase pre-game built entirely on recovered client surfaces.
--
-- Phase 1: lobby countdown. The client's scoreboard renders "Starting in N..."
-- only for the Pregame state, counting GameConstants.PREGAME_DURATION down
-- from GameStateChangeTime — the server fires GameStateChangeTime(0) and waits
-- exactly that long.
--
-- Phase 2: cages + centre-screen countdown via the client's Title system
-- (TitleController's TitleGui, the recovered 77cfff blue). Beats are
-- 4 (silent), 3/2/1 (Countdown voices); GO fires the same tick the cages drop.
--
-- Cages are byte-for-byte the client's GlassCage design (six 11x11x1
-- "SpawnGlass" parts, six studs from the centre), parented to Workspace.Cages
-- — outside BlockContainer so the client's block raycasts and the fall-damage
-- support raycast never touch them (release drop is a free landing).
--
-- A containment heartbeat re-teleports anyone outside their cage and re-cages
-- freshly respawned characters until GO.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RobloxSound = require(ReplicatedStorage.TS.asset.roblox["roblox-sound"]).RobloxSound
local RoundConfig = require(script.Parent.RoundConfig)

-- Cage geometry, byte-for-byte the client's GlassCage.createCage contract.
local CAGE_MODEL_NAME = "CageGlass"
local CAGE_PART_NAME = "SpawnGlass"
local CAGE_PART_SIZE = Vector3.new(11, 11, 1)
local CAGE_PART_OFFSET = 6
local CAGE_ORIGIN_OFFSET = Vector3.new(0, 6, 0)
local CAGE_NORMALS = {
	Vector3.new(0, 0, -1),
	Vector3.new(1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, -1, 0),
}
-- Walls sit six studs from centre and are one stud thick.
local CAGE_INTERIOR_HALF = 5.5

-- The client's cage convention: the cage CFrame marks the character's feet
-- (CosmeticCageDisplayController stands the character at position + halfHeight).
-- Spawn CFrames hold the HumanoidRootPart, so drop the cage floor to foot height.
local SPAWN_ROOT_TO_FEET = 2.5

local CAGES_FOLDER_NAME = "Cages"

local CONTAINMENT_INTERVAL = 0.1

local COUNTDOWN_SOUNDS = {
	[3] = RobloxSound.Countdown.THREE,
	[2] = RobloxSound.Countdown.TWO,
	[1] = RobloxSound.Countdown.ONE,
}
local BRIDGE_RESET_TICK_COUNT = 3

type CageCountdownStyle = "Opening" | "BridgeReset"

local PregameService = {}
PregameService.__index = PregameService

-- Client counts the scoreboard down from GameStateChangeTime + PregameDuration;
-- phase 1 runs exactly that long so it hits zero as the cages appear.
local function getClientPregameDuration(): number
	return RoundConfig.PregameDuration
end

local function buildCage(position: Vector3, parent: Instance): Model
	local origin = position + CAGE_ORIGIN_OFFSET
	local cage = Instance.new("Model")
	cage.Name = CAGE_MODEL_NAME
	for _, normal in CAGE_NORMALS do
		local part = Instance.new("Part")
		part.Name = CAGE_PART_NAME
		part.Size = CAGE_PART_SIZE
		part.CFrame = CFrame.new(origin + normal * CAGE_PART_OFFSET, origin)
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Material = Enum.Material.SmoothPlastic
		part.Reflectance = 1
		part.Transparency = 0.8
		part.Anchored = true
		part.CanCollide = true
		part.Parent = cage
	end
	cage.Parent = parent
	return cage
end

function PregameService.new(context)
	return setmetatable({
		context = context,
		phase = nil :: "Lobby" | "Cages" | nil,
		phaseEndTime = 0,
		active = false,
		generation = 0,
		startTime = 0,
		duration = 0,
		countdownStyle = nil :: CageCountdownStyle?,
		cages = {} :: { Model },
		cagedEntries = {} :: { [Player]: { SpawnCFrame: CFrame, Center: Vector3 } },
		characterConnections = {} :: { RBXScriptConnection },
	}, PregameService)
end

function PregameService.sendTitle(self, text: string, soundId: string?)
	local title = {
		Text = text,
		Duration = 1,
	}
	if soundId ~= nil and soundId ~= "" then
		-- TitleController plays SoundBefore the moment the title appears.
		title.SoundBefore = soundId
	end
	self.context.outbound:fireAll("Title", title)
end

function PregameService.playSound(self, soundName: string, soundId: string)
	self.context.outbound:fireAll("SoundPlayed", soundName, soundId, nil, { Volume = 1 })
end

function PregameService.stopContainment(self)
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)
	table.clear(self.cagedEntries)
end

function PregameService.destroyArena(self)
	for _, cage in self.cages do
		cage:Destroy()
	end
	table.clear(self.cages)
end

-- Begins phase 1; returns the phase length so the caller can schedule the
-- cage teleport.
function PregameService.startLobbyCountdown(self): number
	self:clear()
	local duration = getClientPregameDuration()
	self.phase = "Lobby"
	self.phaseEndTime = os.clock() + duration
	self.context.outbound:fireAll("GameStateChangeTime", 0)
	return duration
end

-- Begins phase 2: cage everyone, run the Title countdown + containment
-- heartbeat until GO.
function PregameService.begin(
	self,
	players: { Player },
	spawnPositions: { [Player]: CFrame },
	duration: number,
	countdownStyle: CageCountdownStyle?
): boolean
	if duration <= 0 then
		return false
	end
	-- A re-started round replaces any previous pre-game.
	self:clear()
	self.phase = "Cages"
	self.active = true
	self.generation += 1
	self.startTime = os.clock()
	self.duration = duration
	self.countdownStyle = countdownStyle or "Opening"

	local cagesFolder = Workspace:FindFirstChild(CAGES_FOLDER_NAME)
	if cagesFolder == nil or not cagesFolder:IsA("Folder") then
		cagesFolder = Instance.new("Folder")
		cagesFolder.Name = CAGES_FOLDER_NAME
		cagesFolder.Parent = Workspace
	end
	local generation = self.generation
	for _, player in players do
		local spawnCFrame = spawnPositions[player]
		if spawnCFrame ~= nil and player.Parent ~= nil then
			local feetPosition = spawnCFrame.Position - Vector3.new(0, SPAWN_ROOT_TO_FEET, 0)
			table.insert(self.cages, buildCage(feetPosition, cagesFolder))
			self.cagedEntries[player] = {
				SpawnCFrame = spawnCFrame,
				Center = feetPosition + CAGE_ORIGIN_OFFSET,
			}
			-- Resets respawn at a lobby SpawnLocation; re-cage the new character.
			table.insert(
				self.characterConnections,
				player.CharacterAdded:Connect(function(character)
					if not self.active or self.generation ~= generation then
						return
					end
					task.wait()
					character:PivotTo(spawnCFrame)
				end)
			)
		end
	end

	-- Containment heartbeat: anyone outside their cage goes back with zeroed
	-- momentum; deleted characters are reloaded.
	task.spawn(function()
		while self.active and self.generation == generation do
			for player, entry in self.cagedEntries do
				if player.Parent == nil then
					continue
				end
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if character == nil then
					pcall(function()
						player:LoadCharacter()
					end)
					continue
				end
				if root == nil or not root:IsA("BasePart") then
					continue
				end
				local position = root.Position
				local center = entry.Center
				local escaped = math.abs(position.X - center.X) > CAGE_INTERIOR_HALF
					or math.abs(position.Y - center.Y) > CAGE_INTERIOR_HALF
					or math.abs(position.Z - center.Z) > CAGE_INTERIOR_HALF
				if escaped then
					character:PivotTo(entry.SpawnCFrame)
					root.AssemblyLinearVelocity = Vector3.zero
				end
			end
			task.wait(CONTAINMENT_INTERVAL)
		end
	end)

	if self.countdownStyle == "BridgeReset" then
		-- Ticks at t=2/3/4, release sound at t=5. SoundPlayed (not Title events)
		-- keeps the point-result title visible for its full three seconds.
		local firstTickTime = math.max(0, duration - BRIDGE_RESET_TICK_COUNT)
		for tickIndex = 1, BRIDGE_RESET_TICK_COUNT do
			local tickTime = firstTickTime + tickIndex - 1
			if tickTime < duration then
				task.delay(tickTime, function()
					if self.active and self.generation == generation then
						self:playSound("BridgeCageTick", RobloxSound.Misc.TICK)
					end
				end)
			end
		end
	else
		for secondsRemaining = math.ceil(duration), 1, -1 do
			local visibleSeconds = secondsRemaining
			local elapsed = duration - visibleSeconds
			if elapsed <= 0 then
				self:sendTitle(tostring(visibleSeconds), COUNTDOWN_SOUNDS[visibleSeconds])
			elseif elapsed < duration then
				task.delay(elapsed, function()
					if self.active and self.generation == generation then
						self:sendTitle(tostring(visibleSeconds), COUNTDOWN_SOUNDS[visibleSeconds])
					end
				end)
			end
		end
	end
	return true
end

-- GO: title/sound fire the same tick the cages drop; caller flips to InGame.
function PregameService.finish(self)
	if not self.active then
		return
	end
	if self.countdownStyle == "BridgeReset" then
		self:playSound("BridgeCageRelease", RobloxSound.Misc.TICK_START)
	else
		self:sendTitle("", RobloxSound.Countdown.GO)
	end
	self.active = false
	self.generation += 1
	self:stopContainment()
	self:destroyArena()
	self.phase = nil
	self.countdownStyle = nil
end

-- Silent cleanup (round aborts, shutdown) — no GO sound.
function PregameService.clear(self)
	if self.active then
		self.active = false
		self.generation += 1
		self:stopContainment()
		self:destroyArena()
	end
	self.phase = nil
	self.countdownStyle = nil
end

-- A player arriving mid-pre-game (e.g. a spectator admitted late) gets the
-- remaining time: re-based scoreboard during the lobby countdown, current
-- centre-screen number during the cage countdown.
function PregameService.syncPlayer(self, player: Player)
	if self.phase == "Lobby" then
		local remaining = math.max(self.phaseEndTime - os.clock(), 0)
		self.context.outbound:fire("GameStateChangeTime", player, remaining - getClientPregameDuration())
		return
	end
	if not self.active then
		return
	end
	if self.countdownStyle == "BridgeReset" then
		return
	end
	local remaining = self.startTime + self.duration - os.clock()
	if remaining <= 0 then
		return
	end
	if remaining < 1 then
		self.context.outbound:fire("Title", player, { Text = "", Duration = remaining })
		return
	end
	self.context.outbound:fire("Title", player, {
		Text = tostring(math.ceil(remaining)),
		Duration = remaining,
	})
end

function PregameService.isActive(self): boolean
	return self.active
end

return PregameService
