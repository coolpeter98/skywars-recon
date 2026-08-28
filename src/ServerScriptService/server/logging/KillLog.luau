--!strict

-- Formats player/entity kills as one structured `[KillLog]` console line and
-- keeps a bounded in-memory history. Pure Luau (no Roblox API) so it can be
-- unit-tested under Lune.

local MAX_HISTORY = 500

export type KillEntry = {
	-- "Player" for player eliminations, "Entity" for tagged entities (eggs).
	Kind: "Player" | "Entity",
	-- The victim's display name (for entities: the entity's Name).
	Victim: string,
	VictimUserId: number?,
	-- The killer, when one exists (Fall/Void kills have none).
	Killer: string?,
	KillerUserId: number?,
	-- The client's damage type: "Melee", "Bow", "Fall", "Void".
	DamageType: string?,
	-- The killer's held item name, best effort (e.g. "IronSword", "Bow").
	Weapon: string?,
	Position: Vector3?,
	RoundId: number?,
	GameMode: string?,
	MapName: string?,
	-- Players still alive after this kill.
	Survivors: number?,
	-- Seconds since server start; filled by record() when nil.
	Clock: number?,
	-- Wall-clock timestamp; filled by record() when nil.
	Timestamp: string?,
}

local KillLog = {}
KillLog.__index = KillLog

local function describeName(name: string, userId: number?): string
	if userId == nil then
		return name
	end
	return string.format("%s(%d)", name, userId)
end

local function damageSuffix(damageType: string?, weapon: string?): string
	local parts: { string } = {}
	if damageType ~= nil and damageType ~= "" then
		table.insert(parts, damageType)
	end
	if weapon ~= nil and weapon ~= "" then
		table.insert(parts, weapon)
	end
	if #parts == 0 then
		return ""
	end
	return " [" .. table.concat(parts, ", ") .. "]"
end

local function formatPosition(position: Vector3?): string
	if position == nil then
		return ""
	end
	return string.format(" @ (%.1f, %.1f, %.1f)", position.X, position.Y, position.Z)
end

local function describeKill(entry: KillEntry): string
	local victim = describeName(entry.Victim, entry.VictimUserId)
	if entry.Kind == "Entity" then
		local killer = if entry.Killer ~= nil then describeName(entry.Killer, entry.KillerUserId) else "Someone"
		return string.format('%s destroyed entity "%s"%s', killer, victim, damageSuffix(entry.DamageType, entry.Weapon))
	end
	if entry.Killer ~= nil then
		local killer = describeName(entry.Killer, entry.KillerUserId)
		return killer .. " killed " .. victim .. damageSuffix(entry.DamageType, entry.Weapon)
	end
	local cause = if entry.DamageType ~= nil and entry.DamageType ~= "" then " by " .. entry.DamageType else ""
	return victim .. " eliminated" .. cause
end

-- Builds the single-line representation of a kill:
--   [KillLog] 2025-06-14 12:34:56 | R3 Airport (SkyWarsSolo) |
--     Peter(123) killed Bob(456) [Melee, IronSword] @ (-12.5, 63.0, 8.0) |
--     survivors 7 | t+123.4s
function KillLog.format(entry: KillEntry): string
	local head = "[KillLog]"
	if entry.Timestamp ~= nil and entry.Timestamp ~= "" then
		head = head .. " " .. entry.Timestamp
	end
	local parts: { string } = { head }
	local contextParts: { string } = {}
	if entry.RoundId ~= nil then
		table.insert(contextParts, "R" .. tostring(entry.RoundId))
	end
	if entry.MapName ~= nil and entry.MapName ~= "" then
		table.insert(contextParts, entry.MapName)
	end
	if entry.GameMode ~= nil and entry.GameMode ~= "" then
		table.insert(contextParts, "(" .. entry.GameMode .. ")")
	end
	if #contextParts > 0 then
		table.insert(parts, table.concat(contextParts, " "))
	end
	table.insert(parts, describeKill(entry) .. formatPosition(entry.Position))
	if entry.Survivors ~= nil then
		table.insert(parts, "survivors " .. tostring(entry.Survivors))
	end
	if entry.Clock ~= nil then
		table.insert(parts, string.format("t+%.1fs", entry.Clock))
	end
	return table.concat(parts, " | ")
end

function KillLog.new()
	return setmetatable({
		history = {} :: { KillEntry },
	}, KillLog)
end

-- Formats and prints the kill, then appends it to the bounded history.
-- Pass silent = true to suppress the print (used by the history-cap test).
function KillLog.record(self, entry: KillEntry, silent: boolean?)
	local logged = table.clone(entry)
	if logged.Clock == nil then
		logged.Clock = os.clock()
	end
	if logged.Timestamp == nil then
		logged.Timestamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
	end
	if not silent then
		print(KillLog.format(logged))
	end
	table.insert(self.history, logged)
	if #self.history > MAX_HISTORY then
		table.remove(self.history, 1)
	end
end

-- A copy of the most recent kills (oldest first), capped at MAX_HISTORY.
function KillLog.getHistory(self): { KillEntry }
	return table.clone(self.history)
end

function KillLog.clear(self)
	table.clear(self.history)
end

return KillLog
