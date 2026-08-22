-- KnockbackTest — requireable tuning harness for the knockback impulse.
--
-- Drive it from the Studio command bar while playing solo (the command bar
-- runs in the server context during Play Solo):
--
--   local kb = require(game.ServerScriptService.KnockbackTest)
--   kb.shove(18)                     -- melee-style shove, as if hit from the front
--   kb.bow(18)                       -- bow-style shove
--   kb.raw(Vector3.new(0, 60, 0))    -- fire an exact impulse vector, no formula
--   kb.setFactors(8, 10, 0.45)       -- live-tune the module's copies
--   kb.status()                      -- print current tunables
--   kb.spamStart(18, "melee", 0.5)   -- repeat a shove every 0.5 s
--   kb.spamStop()                    -- stop spamming
--   kb.help()                        -- print this usage
--
-- Every shove prints the impulse and the expected velocity change:
-- the client scales the DamageImpulse vector by (AssemblyMass / 14.332)
-- before ApplyImpulse, so effective velocity = impulse.Magnitude / 14.332
-- studs/s. Remember the client ignores impulses less than ~0.32 s apart and
-- scales the vertical component x0.3 while airborne (or when |velocity.Y| > 5).
--
-- Vertical pop: the impulse direction is (horizontal + Vector3.new(0, bias, 0))
-- re-normalized, so the vertical component is strength * bias / sqrt(1 + bias^2).
-- Shipped strengths (bias 0.6): melee 640 -> ~44.7 studs/s (~23 up),
-- projectile 800 -> ~55.8 studs/s (~28.7 up).
--
-- The values below match CombatService's shipped constants: fixed knockback
-- strength = KNOCKBACK_BASE (80) * melee 8 / projectile 10, upward bias 0.6.
-- kb.shove(80) and kb.bow(80) reproduce the exact impulses real hits now use.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DAMAGE_IMPULSE_UUID = "58e809cd-221e-402b-b940-bb0607ed2727"
local MASS_SCALE = 14.332

local meleeFactor = 8
local bowFactor = 10
local upwardBias = 0.6

local remote: RemoteEvent?

local function getRemote(): RemoteEvent?
	if remote ~= nil and remote.Parent ~= nil then
		return remote
	end
	for _, descendant in ReplicatedStorage:GetDescendants() do
		if descendant:IsA("RemoteEvent") and descendant:GetAttribute("id") == DAMAGE_IMPULSE_UUID then
			remote = descendant :: RemoteEvent
			return remote
		end
	end
	return nil
end

local function getDefaultPlayer(): Player?
	local players = Players:GetPlayers()
	for _, player in players do
		if player.Character ~= nil then
			return player
		end
	end
	return players[1]
end

-- The exact CombatService:getKnockback formula: flatten the direction,
-- add the upward bias, re-normalize, scale by strength.
local function computeImpulse(direction: Vector3, strength: number): Vector3
	local horizontal = direction * Vector3.new(1, 0, 1)
	if horizontal.Magnitude < 0.001 then
		horizontal = Vector3.new(1, 0, 0)
	else
		horizontal = horizontal.Unit
	end
	return (horizontal + Vector3.new(0, upwardBias, 0)).Unit * strength
end

local function status()
	local vertical18 = 18 * meleeFactor * upwardBias / math.sqrt(1 + upwardBias * upwardBias) / MASS_SCALE
	print(
		("[KB] meleeFactor=%s bowFactor=%s upwardBias=%.2f | melee 18dmg -> ~%.1f studs/s (vert ~%.1f), bow 18dmg -> ~%.1f studs/s"):format(
			tostring(meleeFactor),
			tostring(bowFactor),
			upwardBias,
			18 * meleeFactor / MASS_SCALE,
			vertical18,
			18 * bowFactor / MASS_SCALE
		)
	)
end

-- Shoves a player with `damage * factor` strength along a direction that
-- points from an attacker in front of them toward them (their -LookVector).
-- Returns the impulse that was fired, or nil if it could not be fired.
local function shove(damage: number, mode: string?, player: Player?): Vector3?
	local event = getRemote()
	if event == nil then
		warn("[KB] DamageImpulse remote not found under ReplicatedStorage")
		return nil
	end
	player = player or getDefaultPlayer()
	if player == nil then
		warn("[KB] no player to shove")
		return nil
	end
	local character = player.Character
	local root = character and character.PrimaryPart or nil
	if root == nil then
		warn("[KB] player has no character/root yet")
		return nil
	end
	mode = mode or "melee"
	local factor = if mode == "bow" then bowFactor else meleeFactor
	local impulse = computeImpulse(-root.CFrame.LookVector, damage * factor)
	event:FireClient(player, impulse)
	print(
		("[KB] %s %d dmg | impulse %s | expected velocity ~%.1f studs/s (vert ~%.1f)"):format(
			mode,
			damage,
			tostring(impulse),
			impulse.Magnitude / MASS_SCALE,
			impulse.Y / MASS_SCALE
		)
	)
	return impulse
end

local function bow(damage: number, player: Player?): Vector3?
	return shove(damage, "bow", player)
end

-- Fires an exact impulse vector without any formula applied.
local function raw(vector: Vector3, player: Player?): Vector3?
	local event = getRemote()
	if event == nil then
		warn("[KB] DamageImpulse remote not found under ReplicatedStorage")
		return nil
	end
	player = player or getDefaultPlayer()
	if player == nil then
		warn("[KB] no player to shove")
		return nil
	end
	event:FireClient(player, vector)
	print(
		("[KB] raw %s | expected velocity ~%.1f studs/s (vert ~%.1f)"):format(
			tostring(vector),
			vector.Magnitude / MASS_SCALE,
			vector.Y / MASS_SCALE
		)
	)
	return vector
end

local function setFactors(melee: number, ranged: number?, bias: number?)
	meleeFactor = melee
	if ranged ~= nil then
		bowFactor = ranged
	end
	if bias ~= nil then
		upwardBias = math.clamp(bias, 0, 1)
	end
	status()
end

local function help()
	print([[
[KB] KnockbackTest usage (command bar):
  local kb = require(game.ServerScriptService.KnockbackTest)
  kb.shove(18)                     -- melee-style shove (18 = BronzeSword damage)
  kb.bow(18)                       -- bow-style shove
  kb.shove(18, "melee", somePlayer) -- explicit player (defaults to first player)
  kb.raw(Vector3.new(0, 60, 0))    -- exact impulse, no formula
  kb.computeImpulse(dir, strength) -- formula only, returns the vector
  kb.setFactors(8, 10, 0.45)       -- live-tune factors + upward bias
  kb.status()                      -- print current tunables
  kb.spamStart(18, "melee", 0.5)   -- repeat a shove (min interval 0.35 s)
  kb.spamStop()                    -- stop spamming
  kb.help()                        -- show this
[KB] effective velocity = impulse.Magnitude / 14.332 studs/s; air hits get
     vertical x0.3; impulses < ~0.32 s apart are ignored by the client.]])
end

local spamToken: {}?

local function spamStop()
	if spamToken ~= nil then
		spamToken = nil
		print("[KB] spam stopped")
	end
end

local function spamStart(damage: number, mode: string?, interval: number?, player: Player?)
	spamStop()
	local token = {}
	spamToken = token
	task.spawn(function()
		while spamToken == token do
			shove(damage, mode or "melee", player)
			task.wait(math.max(interval or 0.5, 0.35))
		end
	end)
	print(
		("[KB] spamming %s %d dmg every %.2fs (kb.spamStop() to stop)"):format(
			mode or "melee",
			damage,
			math.max(interval or 0.5, 0.35)
		)
	)
end

return {
	["shove"] = shove,
	["bow"] = bow,
	["raw"] = raw,
	["computeImpulse"] = computeImpulse,
	["setFactors"] = setFactors,
	["status"] = status,
	["help"] = help,
	["spamStart"] = spamStart,
	["spamStop"] = spamStop,
	["MassScale"] = MASS_SCALE,
}
