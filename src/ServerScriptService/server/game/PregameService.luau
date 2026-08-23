--!strict

-- PregameService — the two-phase pre-game that opens every game round,
-- everything driven through surfaces the recovered client already ships:
--
-- Phase 1 (the pre-game lobby countdown): the round opens in the Pregame
-- state while the players wait in the pre-game lobby world. The client's
-- scoreboard shows its "Starting in N..." countdown for exactly this state —
-- GameStatus counts GameConstants.PREGAME_DURATION down from the
-- GameStateChangeTime event — so the server fires GameStateChangeTime(0)
-- and waits the same length the client displays (10 s in Studio, 15 s on
-- production SkyWars servers).
--
-- Phase 2 (the caged countdown): once the scoreboard countdown ends, the
-- caller teleports everyone to the arena and this service cages every
-- assigned player at their spawn. The 4-second centre-screen cooldown is
-- the client's Title system: TitleController opens a big centred
-- TitleGui text (default colour Color3.fromHex("77cfff")) per Title event,
-- playing the title's SoundBefore exactly when it appears. The beats are
-- 4 (silent), 3 / 2 / 1 (the recovered Countdown.THREE/TWO/ONE voices),
-- and GO fires at the exact release moment — its sound and the cages
-- dropping are simultaneous.
--
-- Cages: byte-for-byte the client's GlassCage design (six 11x11x1
-- "SpawnGlass" parts, SmoothPlastic, Reflectance 1, Transparency 0.8, one
-- per axis normal six studs from the cage centre), parented to
-- Workspace.Cages — the folder the original place ships empty for exactly
-- this — outside BlockContainer so the client's block raycasts and the
-- fall-damage support raycast never touch them (the release drop onto the
-- island is a free landing).
--
-- Containment: while the countdown runs, a heartbeat re-teleports any
-- player found outside their cage back inside and re-cages freshly
-- respawned characters — a player clipping through the glass or a cheater
-- escaping is always put back in their cage until GO.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RobloxSound = require(ReplicatedStorage.TS.asset.roblox["roblox-sound"]).RobloxSound

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
-- The walls sit six studs from the cage centre and are one stud thick, so
-- the walkable interior spans half this from the centre on every axis.
local CAGE_INTERIOR_HALF = 5.5

-- The client's cage convention: the cage CFrame marks the character's feet
-- (CosmeticCageDisplayController stands the character at position +
-- halfHeight). Spawn CFrames hold the HumanoidRootPart instead, so the cage
-- floor drops to foot height; the character settles onto the glass floor and
-- falls onto their island at GO.
local SPAWN_ROOT_TO_FEET = 2.5

local CAGES_FOLDER_NAME = "Cages"

-- How often the containment heartbeat checks caged players.
local CONTAINMENT_INTERVAL = 0.1

-- The centre-screen cooldown beats: index = seconds since the cages
-- appeared. The first beat is silent; the voice countdown follows.
local COUNTDOWN_TITLES = {
	{ Seconds = 0, Text = "4", SoundId = nil },
	{ Seconds = 1, Text = "3", SoundId = RobloxSound.Countdown.THREE },
	{ Seconds = 2, Text = "2", SoundId = RobloxSound.Countdown.TWO },
	{ Seconds = 3, Text = "1", SoundId = RobloxSound.Countdown.ONE },
}
local GO_TITLE_TEXT = "GO!"

local PregameService = {}
PregameService.__index = PregameService

-- The client counts the scoreboard's "Starting in N..." down from
-- GameStateChangeTime + GameConstants.PREGAME_DURATION (10 in Studio, 15 on
-- production SkyWars servers — PlaceUtil.isProduction() chooses). Phase 1
-- runs exactly that long so the display reaches zero when the cages appear.
local function getClientPregameDuration(): number
	if RunService:IsStudio() then
		return 10
	end
	return 15
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
		-- TitleController plays SoundBefore the moment the title appears, so
		-- each countdown voice lands exactly on its number.
		title.SoundBefore = soundId
	end
	self.context.outbound:fireAll("Title", title)
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

-- Begins phase 1: the pre-game lobby countdown. Fires the scoreboard's
-- GameStateChangeTime(0) so every client counts "Starting in N..." from now,
-- and returns the phase length so the caller can schedule the cage teleport.
function PregameService.startLobbyCountdown(self): number
	self:clear()
	local duration = getClientPregameDuration()
	self.phase = "Lobby"
	self.phaseEndTime = os.clock() + duration
	self.context.outbound:fireAll("GameStateChangeTime", 0)
	return duration
end

-- Begins phase 2: cages every assigned player at their spawn, starts the
-- centre-screen Title countdown, and runs the containment heartbeat until GO.
function PregameService.begin(
	self,
	players: { Player },
	spawnPositions: { [Player]: CFrame },
	duration: number
): boolean
	if duration <= 0 then
		return false
	end
	-- Restart safety: a re-started round replaces any previous pre-game.
	self:clear()
	self.phase = "Cages"
	self.active = true
	self.generation += 1
	self.startTime = os.clock()
	self.duration = duration

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
			-- A player who resets mid-countdown respawns at a lobby
			-- SpawnLocation; put their new character straight back in the cage.
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

	-- Containment heartbeat: anyone outside their cage (clipped through the
	-- glass, noclip, a teleport exploit) is put straight back inside with
	-- their momentum zeroed, and a deleted character is reloaded.
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

	-- The centre-screen cooldown: 4 (silent), then the voice countdown.
	for _, beat in COUNTDOWN_TITLES do
		if beat.Seconds == 0 then
			self:sendTitle(beat.Text, beat.SoundId)
		elseif beat.Seconds < duration then
			task.delay(beat.Seconds, function()
				if self.active and self.generation == generation then
					self:sendTitle(beat.Text, beat.SoundId)
				end
			end)
		end
	end
	return true
end

-- The GO moment: the release title and its sound fire at the exact moment
-- the cages drop. The caller flips the round into InGame right after.
function PregameService.finish(self)
	if not self.active then
		return
	end
	self:sendTitle(GO_TITLE_TEXT, RobloxSound.Countdown.GO)
	self.active = false
	self.generation += 1
	self:stopContainment()
	self:destroyArena()
	self.phase = nil
end

-- Stops any running pre-game and removes its world without a GO sound —
-- round aborts and service shutdown.
function PregameService.clear(self)
	if self.active then
		self.active = false
		self.generation += 1
		self:stopContainment()
		self:destroyArena()
	end
	self.phase = nil
end

-- A player arriving mid-pre-game (spectators admitted during a round) gets
-- the remaining time: during the lobby countdown the scoreboard display is
-- re-based so it ends with everyone else's; during the caged countdown they
-- get the current centre-screen number.
function PregameService.syncPlayer(self, player: Player)
	if self.phase == "Lobby" then
		local remaining = math.max(self.phaseEndTime - os.clock(), 0)
		self.context.outbound:fire("GameStateChangeTime", player, remaining - getClientPregameDuration())
		return
	end
	if not self.active then
		return
	end
	local remaining = self.startTime + self.duration - os.clock()
	if remaining <= 0 then
		return
	end
	if remaining < 1 then
		self.context.outbound:fire("Title", player, { Text = GO_TITLE_TEXT, Duration = remaining })
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
