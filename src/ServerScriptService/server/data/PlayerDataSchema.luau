--!strict
-- PlayerDataSchema
--
-- The Drop schema for the persisted PlayerData document. Drop applies the
-- migration chain to every stored record on read, so the on-disk format can
-- evolve without ever touching the runtime profile shape.
--
-- Evolution protocol:
--   * Never edit the initial value or an existing migration step. Append a
--     new `PlayerDataSchema = Drop.migrate(PlayerDataSchema, function(old) ... end)`
--     line below the previous one, numbered V<next>.
--   * Migrations receive the previous version's document and must return a
--     complete document for the next version.

local ServerStorage = game:GetService("ServerStorage")

local Drop = require(ServerStorage.Drop)
local PlayerDataRules = require(script.Parent.PlayerDataRules)

-- V1 — initial format: progression lives under Stats.
local PlayerDataSchema = Drop.schema(PlayerDataRules.initialPlayerData())

-- V2 — (future example)
-- PlayerDataSchema = Drop.migrate(PlayerDataSchema, function(old)
-- 	...
-- end)

return PlayerDataSchema
