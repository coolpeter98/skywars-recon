--!strict

-- PregameService — the caged countdown between a round's spawn and its
-- InGame release. Reconstructs the client's pre-game phase end to end,
-- everything driven through surfaces the recovered client already ships:
--
--   * every assigned player is boxed into a glass cage at their spawn. The
--     cage is the client's own GlassCage design (ReplicatedStorage.TS.cosmetic
--     .cage["glass-cage"]): a "CageGlass" model of six 11x11x1 "SpawnGlass"
--     parts, each six studs from the cage centre along one axis normal,
--     SmoothPlastic, Reflectance 1, Transparency 0.8. The recovered place
--     ships an empty Workspace/Cages folder — the original server's runtime
--     home for exactly these models — so cages are parented there, outside
--     BlockContainer (the client's block raycasts whitelist BlockContainer,
--     and the fall-damage service only measures BlockContainer surfaces, so
--     a caged player can never be measured "standing" on the cage floor).
--   * the client's world-space countdown is driven by placing a four-sided
--     "Timer" tower above the map centre: BillboardComponent mounts a
--     TimerBillboard on every BasePart tagged "billboard" and named "Timer",
--     and ZoneUpdated("Middle", duration) starts it.
--   * the scoreboard's "Starting in N..." text (GameStatus renders only for
--     GameState.Pregame) counts down from GameStateChangeTime +
--     GameConstants.PREGAME_DURATION client-side, so the server fires
--     GameStateChangeTime with an offset that makes that display end exactly
--     when the cages drop.
--   * the recovered countdown audio (Misc.TICK_START / Misc.TICK, then the
--     Countdown.THREE / TWO / ONE voice, and Countdown.GO at release) plays
--     globally through the SoundPlayed pipeline.

local CollectionService = game:GetService("CollectionService")
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

-- The client's cage convention: the cage CFrame marks the character's feet
-- (CosmeticCageDisplayController places the character with its root at
-- position + halfHeight). Spawn CFrames hold the HumanoidRootPart instead,
-- so the cage floor drops to foot height; the character settles onto the
-- glass floor and, on release, falls onto the island (a free landing — the
-- fall-damage service never saw them standing on a BlockContainer surface).
local SPAWN_ROOT_TO_FEET = 2.5

local CAGES_FOLDER_NAME = "Cages"

-- The world-space countdown tower the client renders for parts tagged
-- "billboard" and named "Timer" (Billboard.Timer); the TimerBillboard's zone
-- id is hard-coded to "Middle" client-side.
local BILLBOARD_NAME = "Timer"
local BILLBOARD_TAG = "billboard"
local BILLBOARD_ZONE_ID = "Middle"
local BILLBOARD_WALL_SIZE = Vector3.new(30, 24, 0.5)
local BILLBOARD_ABOVE_MAP = 8
local BILLBOARD_WALL_OFFSET = BILLBOARD_WALL_SIZE.X / 2
local BILLBOARD_WALLS = {
	{ Position = Vector3.new(0, 0, BILLBOARD_WALL_OFFSET), Facing = Vector3.new(0, 0, -1) },
	{ Position = Vector3.new(BILLBOARD_WALL_OFFSET, 0, 0), Facing = Vector3.new(-1, 0, 0) },
	{ Position = Vector3.new(0, 0, -BILLBOARD_WALL_OFFSET), Facing = Vector3.new(0, 0, 1) },
	{ Position = Vector3.new(-BILLBOARD_WALL_OFFSET, 0, 0), Facing = Vector3.new(1, 0, 0) },
}

-- One-second countdown beats, index = seconds elapsed since the countdown
-- started. Beats beyond the countdown length simply never fire.
local COUNTDOWN_BEATS = {
	{ Seconds = 0, Name = "Countdown_TickStart", SoundId = RobloxSound.Misc.TICK_START },
	{ Seconds = 1, Name = "Countdown_Tick", SoundId = RobloxSound.Misc.TICK },
	{ Seconds = 2, Name = "Countdown_Three", SoundId = RobloxSound.Countdown.THREE },
	{ Seconds = 3, Name = "Countdown_Two", SoundId = RobloxSound.Countdown.TWO },
	{ Seconds = 4, Name = "Countdown_One", SoundId = RobloxSound.Countdown.ONE },
}
local GO_SOUND_NAME = "Countdown_Go"

local PregameService = {}
PregameService.__index = PregameService

-- The client counts the scoreboard's "Starting in N..." down from
-- GameStateChangeTime + GameConstants.PREGAME_DURATION (10 in Studio, 15 on
-- production SkyWars servers — PlaceUtil.isProduction() chooses). Mirror the
-- rule so the caged countdown reaches zero exactly when the cages drop.
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

-- Four thin walls form a hollow tower above the map's highest point, one
-- wall per compass direction so the countdown reads from every island.
local function buildBillboardTower(mapModel: Model): Model
	local boundingCFrame, boundingSize = mapModel:GetBoundingBox()
	local tower = Instance.new("Model")
	tower.Name = "CountdownBillboard"
	local center = Vector3.new(
		boundingCFrame.X,
		boundingCFrame.Y + boundingSize.Y / 2 + BILLBOARD_ABOVE_MAP + BILLBOARD_WALL_SIZE.Y / 2,
		boundingCFrame.Z
	)
	for _, wall in BILLBOARD_WALLS do
		local wallPosition = center + wall.Position
		local part = Instance.new("Part")
		part.Name = BILLBOARD_NAME
		part.Size = BILLBOARD_WALL_SIZE
		-- CFrame.lookAt aims a part's -Z face at the target; NormalId.Front
		-- is the -Z face, which is exactly where the client's SurfaceGui
		-- renders, so the front faces outward from the tower centre.
		part.CFrame = CFrame.lookAt(wallPosition, wallPosition + wall.Facing)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Parent = tower
		CollectionService:AddTag(part, BILLBOARD_TAG)
	end
	tower.Parent = Workspace
	return tower
end

function PregameService.new(context)
	return setmetatable({
		context = context,
		active = false,
		generation = 0,
		startTime = 0,
		duration = 0,
		cages = {} :: { Model },
		billboardTower = nil :: Model?,
	}, PregameService)
end

function PregameService.playSound(self, name: string, soundId: string)
	-- No position: a global sound every client hears at full volume. The
	-- name keys the sound in the client's sounds folder (one-shot sounds
	-- destroy themselves when they end).
	self.context.outbound:fireAll("SoundPlayed", name, soundId, nil, { Volume = 1 })
end

function PregameService.destroyArena(self)
	for _, cage in self.cages do
		cage:Destroy()
	end
	table.clear(self.cages)
	if self.billboardTower ~= nil then
		self.billboardTower:Destroy()
		self.billboardTower = nil
	end
end

-- Stops any running pregame and removes its world (no GO sound — used for
-- round aborts and service shutdown).
function PregameService.clear(self)
	if self.active then
		self.active = false
		self.generation += 1
		self:destroyArena()
	end
end

-- Begins the caged countdown. `players`/`spawnPositions` pair each assigned
-- participant with the spawn CFrame they were just placed at; spectators get
-- no cage but still receive the countdown events and audio.
function PregameService.begin(
	self,
	players: { Player },
	spawnPositions: { [Player]: CFrame },
	mapModel: Model?,
	duration: number
): boolean
	if duration <= 0 then
		return false
	end
	-- Restart safety: a re-started round replaces any previous pregame.
	self:clear()
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
	for _, player in players do
		local spawnCFrame = spawnPositions[player]
		if spawnCFrame ~= nil and player.Parent ~= nil then
			local feetPosition = spawnCFrame.Position - Vector3.new(0, SPAWN_ROOT_TO_FEET, 0)
			table.insert(self.cages, buildCage(feetPosition, cagesFolder))
		end
	end
	if mapModel ~= nil then
		self.billboardTower = buildBillboardTower(mapModel)
	end

	-- Client countdown surfaces: the world timer (ZoneUpdated) and the
	-- scoreboard's "Starting in N..." (GameStateChangeTime). The negative
	-- offset when the countdown is shorter than the client's PREGAME_DURATION
	-- constant is the client's own arithmetic — remaining time is always
	-- GameStateChangeTime + PREGAME_DURATION - now.
	self.context.outbound:fireAll("ZoneUpdated", BILLBOARD_ZONE_ID, duration)
	self.context.outbound:fireAll("GameStateChangeTime", duration - getClientPregameDuration())

	local generation = self.generation
	for _, beat in COUNTDOWN_BEATS do
		if beat.Seconds == 0 then
			self:playSound(beat.Name, beat.SoundId)
		elseif beat.Seconds < duration then
			task.delay(beat.Seconds, function()
				if self.active and self.generation == generation then
					self:playSound(beat.Name, beat.SoundId)
				end
			end)
		end
	end
	return true
end

-- The GO moment: cages and the countdown tower drop, and the release voice
-- plays. The caller flips the round into InGame right after.
function PregameService.finish(self)
	if not self.active then
		return
	end
	self.active = false
	self.generation += 1
	self:destroyArena()
	self:playSound(GO_SOUND_NAME, RobloxSound.Countdown.GO)
end

-- A player arriving mid-countdown (spectators admitted during a round) gets
-- the remaining time on both countdown surfaces.
function PregameService.syncPlayer(self, player: Player)
	if not self.active then
		return
	end
	local remaining = math.max(self.startTime + self.duration - os.clock(), 0)
	self.context.outbound:fire("ZoneUpdated", player, BILLBOARD_ZONE_ID, remaining)
	self.context.outbound:fire("GameStateChangeTime", player, remaining - getClientPregameDuration())
end

function PregameService.isActive(self): boolean
	return self.active
end

return PregameService
